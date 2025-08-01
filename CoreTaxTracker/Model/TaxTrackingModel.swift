//
//  TaxTrackingModel.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public class TaxTrackingModel {
    @Relationship public var paymentPlan: TaxPaymentPlan
    @Relationship public var receipt: TaxPaymentReceipt?

    // MARK: - Planning

    @Transient
    public var payrollCalendar: PayrollCalendar {
        .init(startDate: paymentPlan.payrollStartDate, interval: paymentPlan.payrollInterval)
    }

    // MARK: - Tax Payment Snapshot

    public struct Amount: Identifiable {
        public var id: String {
            label
        }

        var label: String
        var amount: Double
        var realized: Bool = true
    }

    public struct TaxPaymentSnapshot {
        public var amounts: [Amount]
        public var liabilityAmount: Double
        public var safeHarborAmount: Double
    }

    public func payment(for taxType: TaxType) -> TaxPaymentSnapshot {
        let now = Date()

        let payrollYTD = receipt?.payrollWithholdingTaxYTD[taxType] ?? 0
        let estimateTaxYTD = receipt?.estimateTax[taxType] ?? 0

        let payrollCount = payrollCalendar.payrollDates.count(where: { $0 > now })
        let payrollWithholdings = (paymentPlan.withholdings[taxType] ?? 0) * Double(payrollCount)

        let stockQuantity: Double = paymentPlan.vestingSchedule.reduce(0.0) { result, schedule in
            if schedule.date > now {
                return result + Double(schedule.shares)
            } else {
                return result
            }
        }
        let rsuWithholdings = (paymentPlan.automaticTaxRates[taxType] ?? 0) * paymentPlan.stockPrice * stockQuantity

        let calculator = TaxCalculator(taxType: taxType)
        var grossIncome = 0.0
        if let salaryYTD = receipt?.salaryYTD {
            grossIncome += salaryYTD
        }
        if let rsuYTD = receipt?.rsuYTD {
            grossIncome += rsuYTD
        }
        if let salaryCurrent = receipt?.salaryCurrent {
            grossIncome += Double(payrollCount) * salaryCurrent
        }
        grossIncome += paymentPlan.stockPrice * stockQuantity

        let liabilityAmount: Double = calculator.calculateTax(grossIncome: grossIncome)
        let safeHarborAmount = 1.1 * (paymentPlan.previousYearTaxPayments[taxType] ?? 0)
        return TaxPaymentSnapshot(
            amounts: [
                Amount(label: "Payroll YTD", amount: payrollYTD),
                Amount(label: "EstimateTax YTD", amount: estimateTaxYTD),
                Amount(label: "Payroll Withholding", amount: payrollWithholdings),
                Amount(label: "RSU Withholding", amount: rsuWithholdings),
            ],
            liabilityAmount: liabilityAmount,
            safeHarborAmount: safeHarborAmount
        )
    }

    public init() {
        paymentPlan = .init()
    }
}

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
public class TaxPaymentPlan {
    // MARK: - Payroll

    public var payrollStartDate: Date = Date()
    public var payrollInterval: Int = 14

    // MARK: - Tax Deductions

    public var federalTaxDeduction: Double = 0.0
    public var stateTaxDeduction: Double = 0.0

    public init() {}
}

@Model
public class TaxTrackingModel {
    // MARK: - Planning

    @Relationship public var paymentPlan: TaxPaymentPlan

    @Transient
    public var payrollCalendar: PayrollCalendar {
        .init(startDate: paymentPlan.payrollStartDate, interval: paymentPlan.payrollInterval)
    }

    public init() {
        paymentPlan = .init()
    }
}

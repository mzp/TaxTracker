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

    // MARK: - Planning

    @Transient
    public var payrollCalendar: PayrollCalendar {
        .init(startDate: paymentPlan.payrollStartDate, interval: paymentPlan.payrollInterval)
    }

    // MARK: - Safe Harbar Amount

    public var safeHarborAmount: [TaxType: Double] {
        [
            .federal: 1.1 * (paymentPlan.previousYearTaxPayments[.federal] ?? 0),
            .state: 1.1 * (paymentPlan.previousYearTaxPayments[.state] ?? 0),
        ]
    }

    public init() {
        paymentPlan = .init()
    }
}

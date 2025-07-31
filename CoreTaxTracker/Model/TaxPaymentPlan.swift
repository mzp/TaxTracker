//
//  TaxPaymentPlan.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

/// User preferences for tax payment plan for this year
@Model
public class TaxPaymentPlan {
    // MARK: - Payroll

    public var payrollStartDate: Date = Date()
    public var payrollInterval: Int = 14
    public var withholdings: [TaxType: Double] = [:]

    // MARK: - Previous Year Tax Payments

    public var previousYearTaxPayments: [TaxType: Double] = [:]

    public var automaticTaxRates: [TaxType: Double] = [:]

    public var vestingSchedule: [VestingEvent] = []

    public var stockPrice: Double = 0.0

    public init() {
        // Initialize with default values
        for taxType in TaxType.allCases {
            withholdings[taxType] = 0.0
            previousYearTaxPayments[taxType] = 0.0
            automaticTaxRates[taxType] = 0.0
        }
    }
}

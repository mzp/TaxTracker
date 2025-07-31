//
//  TaxTrackingModel.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

public enum TaxType: String, CaseIterable, Codable {
    case federal
    case state

    public var displayName: String {
        switch self {
        case .federal:
            return "Federal Tax"
        case .state:
            return "State Tax"
        }
    }
}

@Model
public class TaxPaymentPlan {
    // MARK: - Payroll

    public var payrollStartDate: Date = Date()
    public var payrollInterval: Int = 14

    // MARK: - Tax Withholdings

    public var withholdings: [TaxType: Double] = [:]

    public init() {
        // Initialize with default values
        for taxType in TaxType.allCases {
            withholdings[taxType] = 0.0
        }
    }

    // MARK: - Helpers

    public func getTaxWithholding(for type: TaxType) -> Double {
        return withholdings[type] ?? 0.0
    }

    public func setTaxWithholding(for type: TaxType, amount: Double) {
        withholdings[type] = amount
    }
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

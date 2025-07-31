//
//  TaxPaymentPlanTests.swift
//  TaxTrackerTests
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import Foundation
import SwiftData
import Testing

struct TaxPaymentPlanTests {
    @Test func initialization() async throws {
        let plan = TaxPaymentPlan()

        #expect(plan.payrollInterval == 14)
        #expect(plan.getTaxWithholding(for: .federal) == 0.0)
        #expect(plan.getTaxWithholding(for: .state) == 0.0)
        #expect(plan.withholdings[.federal] == 0.0)
        #expect(plan.withholdings[.state] == 0.0)
        #expect(plan.payrollStartDate.timeIntervalSinceNow < 60)
    }

    @Test func payrollConfiguration() async throws {
        let plan = TaxPaymentPlan()
        let testDate = Date(timeIntervalSince1970: 1_690_848_000) // 2023-08-01

        plan.payrollStartDate = testDate
        plan.payrollInterval = 7

        #expect(plan.payrollStartDate == testDate)
        #expect(plan.payrollInterval == 7)
    }

    @Test func federalTaxWithholding() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .federal, amount: 500.50)

        #expect(plan.getTaxWithholding(for: .federal) == 500.50)
        #expect(plan.withholdings[.federal] == 500.50)
    }

    @Test func stateTaxWithholding() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .state, amount: 125.75)

        #expect(plan.getTaxWithholding(for: .state) == 125.75)
        #expect(plan.withholdings[.state] == 125.75)
    }

    @Test func bothTaxWithholdings() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .federal, amount: 400.00)
        plan.setTaxWithholding(for: .state, amount: 100.00)

        #expect(plan.getTaxWithholding(for: .federal) == 400.00)
        #expect(plan.getTaxWithholding(for: .state) == 100.00)
        #expect(plan.withholdings[.federal] == 400.00)
        #expect(plan.withholdings[.state] == 100.00)
    }

    @Test func negativeValues() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .federal, amount: -50.0)
        plan.setTaxWithholding(for: .state, amount: -25.0)

        #expect(plan.getTaxWithholding(for: .federal) == -50.0)
        #expect(plan.getTaxWithholding(for: .state) == -25.0)
    }

    @Test func largeValues() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .federal, amount: 10000.99)
        plan.setTaxWithholding(for: .state, amount: 5000.01)

        #expect(plan.getTaxWithholding(for: .federal) == 10000.99)
        #expect(plan.getTaxWithholding(for: .state) == 5000.01)
    }

    @Test func payrollIntervalBoundaries() async throws {
        let plan = TaxPaymentPlan()

        plan.payrollInterval = 1
        #expect(plan.payrollInterval == 1)

        plan.payrollInterval = 30
        #expect(plan.payrollInterval == 30)

        plan.payrollInterval = 365
        #expect(plan.payrollInterval == 365)
    }

    @Test func taxTypeEnumHandling() async throws {
        let plan = TaxPaymentPlan()

        plan.setTaxWithholding(for: .federal, amount: 300.0)
        plan.setTaxWithholding(for: .state, amount: 75.0)

        #expect(plan.getTaxWithholding(for: .federal) == 300.0)
        #expect(plan.getTaxWithholding(for: .state) == 75.0)

        #expect(plan.withholdings[.federal] == 300.0)
        #expect(plan.withholdings[.state] == 75.0)
    }

    @Test func taxTypeDisplayNames() async throws {
        #expect(TaxType.federal.displayName == "Federal Tax")
        #expect(TaxType.state.displayName == "State Tax")
    }

    @Test func withholdingsDictionaryAccess() async throws {
        let plan = TaxPaymentPlan()

        // Test direct dictionary access
        plan.withholdings[.federal] = 250.0
        plan.withholdings[.state] = 60.0

        #expect(plan.withholdings[.federal] == 250.0)
        #expect(plan.withholdings[.state] == 60.0)

        // Test helper methods still work
        #expect(plan.getTaxWithholding(for: .federal) == 250.0)
        #expect(plan.getTaxWithholding(for: .state) == 60.0)
    }

    @Test func defaultInitialization() async throws {
        let plan = TaxPaymentPlan()

        // All tax types should be initialized to 0.0
        for taxType in TaxType.allCases {
            #expect(plan.withholdings[taxType] == 0.0)
            #expect(plan.getTaxWithholding(for: taxType) == 0.0)
        }
    }
}

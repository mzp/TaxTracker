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
        #expect(plan.federalTaxDeduction == 0.0)
        #expect(plan.stateTaxDeduction == 0.0)
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

    @Test func federalTaxDeduction() async throws {
        let plan = TaxPaymentPlan()

        plan.federalTaxDeduction = 500.50

        #expect(plan.federalTaxDeduction == 500.50)
    }

    @Test func stateTaxDeduction() async throws {
        let plan = TaxPaymentPlan()

        plan.stateTaxDeduction = 125.75

        #expect(plan.stateTaxDeduction == 125.75)
    }

    @Test func bothTaxDeductions() async throws {
        let plan = TaxPaymentPlan()

        plan.federalTaxDeduction = 400.00
        plan.stateTaxDeduction = 100.00

        #expect(plan.federalTaxDeduction == 400.00)
        #expect(plan.stateTaxDeduction == 100.00)
    }

    @Test func negativeValues() async throws {
        let plan = TaxPaymentPlan()

        plan.federalTaxDeduction = -50.0
        plan.stateTaxDeduction = -25.0

        #expect(plan.federalTaxDeduction == -50.0)
        #expect(plan.stateTaxDeduction == -25.0)
    }

    @Test func largeValues() async throws {
        let plan = TaxPaymentPlan()

        plan.federalTaxDeduction = 10000.99
        plan.stateTaxDeduction = 5000.01

        #expect(plan.federalTaxDeduction == 10000.99)
        #expect(plan.stateTaxDeduction == 5000.01)
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
}

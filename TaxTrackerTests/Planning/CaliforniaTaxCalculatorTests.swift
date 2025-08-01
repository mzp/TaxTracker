//
//  CaliforniaTaxCalculatorTests.swift
//  TaxTrackerTests
//
//  Created by mzp on 2025/07/16.
//

@testable import CoreTaxTracker
import Foundation
import Testing

struct TaxCalculatorCaliforniaTests {
    private let calculator = TaxCalculator(taxType: .state)

    @Test func calculateCaliforniaTaxMidIncome() {
        let grossIncome = 75000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        #expect(tax > 2000.0)
        #expect(tax < 8000.0)
    }

    @Test func calculateCaliforniaTaxHighIncome() {
        let grossIncome = 500_000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        #expect(tax > 40000.0)
    }

    @Test func calculateCaliforniaTaxVeryLowIncome() {
        let grossIncome = 5000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        #expect(tax == 0.0)
    }

    @Test func progressiveTaxBrackets() {
        let income1 = 20000.0
        let income2 = 100_000.0

        let tax1 = calculator.calculateTax(grossIncome: income1)
        let tax2 = calculator.calculateTax(grossIncome: income2)

        #expect(tax2 > tax1)
    }

    @Test func zeroIncomeZeroTax() {
        let tax = calculator.calculateTax(grossIncome: 0.0)
        #expect(tax == 0.0)
    }

    @Test func negativeIncomeZeroTax() {
        let tax = calculator.calculateTax(grossIncome: -1000.0)
        #expect(tax == 0.0)
    }

    @Test func calculateCaliforniaTaxIncludesCapitalGains() {
        let grossIncome = 75000.0
        let capitalGain = 10000.0

        let taxWithoutCapitalGains = calculator.calculateTax(grossIncome: grossIncome)
        let taxWithCapitalGains = calculator.calculateTax(grossIncome: grossIncome, capitalGain: capitalGain)
        let taxOnCombinedIncome = calculator.calculateTax(grossIncome: grossIncome + capitalGain)

        // California should include capital gains in taxable income
        #expect(taxWithCapitalGains > taxWithoutCapitalGains)
        #expect(taxWithCapitalGains == taxOnCombinedIncome)
    }
}

//
//  FederalTaxCalculatorTests.swift
//  TaxTrackerTests
//
//  Created by mzp on 2025/07/16.
//

@testable import CoreTaxTracker
import Foundation
import Testing

struct TaxCalculatorFederalTests {
    private let calculator = TaxCalculator(taxType: .federal)

    @Test func calculateFederalTaxSingleFiler() {
        let grossIncome = 50000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        let expectedTax = 11925.0 * 0.10 + (35000.0 - 11925.0) * 0.12
        #expect(abs(tax - expectedTax) < 0.01)
    }

    @Test func calculateFederalTaxHighIncome() {
        let grossIncome = 500_000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        #expect(tax > 100_000.0)
    }

    @Test func calculateFederalTaxLowIncome() {
        let grossIncome = 10000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome)

        #expect(tax == 0.0)
    }

    @Test func progressiveTaxBrackets() {
        let income1 = 20000.0
        let income2 = 200_000.0

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

    @Test func calculateFederalTaxWithCapitalGains() {
        let grossIncome = 50000.0
        let capitalGain = 10000.0
        let tax = calculator.calculateTax(grossIncome: grossIncome, capitalGain: capitalGain)

        let expectedRegularTax = 11925.0 * 0.10 + (35000.0 - 11925.0) * 0.12
        let expectedCapitalGainsTax = capitalGain * 0.213
        let expectedTotalTax = expectedRegularTax + expectedCapitalGainsTax

        #expect(abs(tax - expectedTotalTax) < 0.01)
    }

    @Test func calculateFederalTaxNoCapitalGains() {
        let grossIncome = 50000.0
        let taxWithoutCapitalGains = calculator.calculateTax(grossIncome: grossIncome, capitalGain: 0)
        let taxWithDefaultCapitalGains = calculator.calculateTax(grossIncome: grossIncome)

        #expect(taxWithoutCapitalGains == taxWithDefaultCapitalGains)
    }
}

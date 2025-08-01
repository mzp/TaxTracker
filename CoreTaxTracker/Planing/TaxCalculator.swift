//
//  TaxCalculator.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/08/01.
//

import Foundation

public final class TaxCalculator: Sendable {
    private let taxType: TaxType

    private struct TaxBracket: Sendable {
        let rate: Double
        let min: Double
        let max: Double?

        init(rate: Double, min: Double, max: Double? = nil) {
            self.rate = rate
            self.min = min
            self.max = max
        }
    }

    private static let federalTaxBrackets2025: [TaxBracket] = [
        TaxBracket(rate: 0.10, min: 0, max: 11925),
        TaxBracket(rate: 0.12, min: 11925, max: 48475),
        TaxBracket(rate: 0.22, min: 48475, max: 103_350),
        TaxBracket(rate: 0.24, min: 103_350, max: 197_300),
        TaxBracket(rate: 0.32, min: 197_300, max: 250_525),
        TaxBracket(rate: 0.35, min: 250_525, max: 626_350),
        TaxBracket(rate: 0.37, min: 626_350),
    ]

    private static let californiaTaxBrackets2025: [TaxBracket] = [
        TaxBracket(rate: 0.01, min: 0, max: 10099),
        TaxBracket(rate: 0.02, min: 10099, max: 23942),
        TaxBracket(rate: 0.04, min: 23942, max: 37788),
        TaxBracket(rate: 0.06, min: 37788, max: 52455),
        TaxBracket(rate: 0.08, min: 52455, max: 66295),
        TaxBracket(rate: 0.093, min: 66295, max: 338_639),
        TaxBracket(rate: 0.103, min: 338_639, max: 406_364),
        TaxBracket(rate: 0.113, min: 406_364, max: 677_278),
        TaxBracket(rate: 0.123, min: 677_278, max: 1_000_000),
        TaxBracket(rate: 0.133, min: 1_000_000),
    ]

    private static let federalStandardDeduction2025 = 15000.0
    private static let californiaStandardDeduction2025 = 5202.0

    public init(taxType: TaxType) {
        self.taxType = taxType
    }

    public var taxBrackets: [Double] {
        let brackets = self.brackets(for: taxType)
        return brackets.compactMap { $0.max }
    }

    public func calculateTax(grossIncome: Double, capitalGain: Double = 0, deductions: Double = 0) -> Double {
        let totalDeductions = max(deductions, standardDeduction)

        switch taxType {
        case .federal:
            // Federal: regular income and capital gains are taxed separately
            let taxableIncome = max(grossIncome - totalDeductions, 0)
            let regularTax = calculateProgressiveTax(on: taxableIncome, for: taxType)
            let capitalGainsTax = capitalGain > 0 ? capitalGain * 0.213 : 0
            return regularTax + capitalGainsTax

        case .state:
            // State: capital gains are added to taxable income and taxed as regular income
            let totalTaxableIncome = max(grossIncome + capitalGain - totalDeductions, 0)
            return calculateProgressiveTax(on: totalTaxableIncome, for: taxType)
        }
    }

    private func brackets(for taxType: TaxType) -> [TaxBracket] {
        switch taxType {
        case .federal:
            return Self.federalTaxBrackets2025
        case .state:
            return Self.californiaTaxBrackets2025
        }
    }

    private var standardDeduction: Double {
        switch taxType {
        case .federal:
            return Self.federalStandardDeduction2025
        case .state:
            return Self.californiaStandardDeduction2025
        }
    }

    private func calculateProgressiveTax(on taxableIncome: Double, for taxType: TaxType) -> Double {
        let brackets = self.brackets(for: taxType)
        var totalTax: Double = 0
        var remainingIncome = taxableIncome

        for bracket in brackets {
            let bracketMin = bracket.min
            let bracketMax = bracket.max ?? Double.greatestFiniteMagnitude

            if remainingIncome <= 0 || taxableIncome <= bracketMin {
                break
            }

            let taxableAtThisBracket = min(remainingIncome, bracketMax - bracketMin)
            let taxForBracket = taxableAtThisBracket * bracket.rate

            totalTax += taxForBracket
            remainingIncome -= taxableAtThisBracket

            if remainingIncome <= 0 {
                break
            }
        }

        return totalTax
    }
}

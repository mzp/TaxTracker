//
//  TaxPaymentReceipt.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/31.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public class TaxPaymentReceipt {
    public var payrollWithholdingTaxYTD: [TaxType: Double]
    public var lastModifiedDate: Date
    public var estimateTax: [TaxType: Double]

    public init(payrollWithholdingTaxYTD: [TaxType: Double] = [:],
                lastModifiedDate: Date = Date(),
                estimateTax: [TaxType: Double] = [:])
    {
        self.payrollWithholdingTaxYTD = payrollWithholdingTaxYTD
        self.lastModifiedDate = lastModifiedDate
        self.estimateTax = estimateTax
    }
}

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

    public init(payrollWithholdingTaxYTD: [TaxType: Double] = [:], lastModifiedDate: Date = Date()) {
        self.payrollWithholdingTaxYTD = payrollWithholdingTaxYTD
        self.lastModifiedDate = lastModifiedDate
    }
}

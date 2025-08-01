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
    public var salaryCurrent: Double?
    public var salaryYTD: Double?
    public var rsuYTD: Double?

    public init(payrollWithholdingTaxYTD: [TaxType: Double] = [:],
                lastModifiedDate: Date = Date(),
                estimateTax: [TaxType: Double] = [:],
                salaryCurrent: Double? = nil,
                salaryYTD: Double? = nil,
                rsuYTD: Double? = nil)
    {
        self.payrollWithholdingTaxYTD = payrollWithholdingTaxYTD
        self.lastModifiedDate = lastModifiedDate
        self.estimateTax = estimateTax
        self.salaryCurrent = salaryCurrent
        self.salaryYTD = salaryYTD
        self.rsuYTD = rsuYTD
    }
}

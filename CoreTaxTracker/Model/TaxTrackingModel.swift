//
//  TaxTrackingModel.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation

public class TaxTrackingModel {
    // MARK: - Planning

    public let payrollCalendar: PayrollCalendar

    public init() {
        payrollCalendar = PayrollCalendar.current
    }
}

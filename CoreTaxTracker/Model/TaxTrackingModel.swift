//
//  TaxTrackingModel.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public class TaxTrackingModel {
    // MARK: - Planning

    @Transient
    public var payrollCalendar: PayrollCalendar {
        PayrollCalendar.current
    }

    public init() {}
}

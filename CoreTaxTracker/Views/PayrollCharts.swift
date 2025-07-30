//
//  PayrollCharts.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import SwiftUI

public struct PayrollCalendarChart: View {
    public var model: TaxTrackingModel

    public init(model: TaxTrackingModel) {
        self.model = model
    }

    public var body: some View {
        GroupBox("Payroll Calendar") {
            if let date = nextPayday {
                LabeledContent("Next pay") {
                    Text("\(date, style: .date)").font(.title)
                }
            }
        }
    }

    var nextPayday: Date? {
        let today = Date()
        return model.payrollCalendar.payrollDates.first(where: { $0 > today })
    }
}

#Preview {
    PayrollCalendarChart(model: TaxTrackingModel())
}

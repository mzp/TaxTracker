//
//  PayrollCalendarChart.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import SwiftUI

public struct PayrollCalendarChart: View {
    @Environment(TaxTrackingModel.self) public var model
    public init() {}
    public var body: some View {
        LabeledContent("Next pay") {
            if let date = nextPayday {
                Text("\(date, style: .date)").font(.headline)
            } else {
                Text("-")
            }
        }
        HStack {
            LabeledContent("Federal Tax") {
                Text("$\(model.paymentPlan.withholdings[.federal] ?? 0.0, format: .number)").font(.subheadline)
            }
            LabeledContent("State Tax") {
                Text("$\(model.paymentPlan.withholdings[.state] ?? 0.0, format: .number)").font(.subheadline)
            }
        }
    }

    var nextPayday: Date? {
        let today = Date()
        return model.payrollCalendar.payrollDates.first(where: { $0 > today })
    }
}

#Preview {
    Form {
        PayrollCalendarChart()
            .environment(TaxTrackingModel())
    }
    .padding()
}

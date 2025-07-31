//
//  PlanningForm.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//
import CoreTaxTracker
import SwiftData
import SwiftUI

struct PlanningForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TaxTrackingModel.self) var model

    @State var date: Date = .init()
    @State var interval = 0

    var body: some View {
        Form {
            DatePicker(
                "Start Date",
                selection: $date,
                displayedComponents: [.date]
            ).onChange(of: date) {
                model.paymentPlan.payrollStartDate = date
                save()
            }
            Stepper(value: $interval, in: 1 ... 20, step: 1) {
                Text("Interval: \(interval)")
            }
            .onChange(of: interval) {
                model.paymentPlan.payrollInterval = interval
                save()
            }
        }.onAppear {
            date = model.paymentPlan.payrollStartDate
            interval = model.paymentPlan.payrollInterval
        }
    }

    func save() {
        try! modelContext.save()
    }
}

#Preview {
    PlanningForm().environment(TaxTrackingModel())
}

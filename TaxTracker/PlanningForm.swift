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
    @State var federalTaxDeduction = 0.0
    @State var stateTaxDeduction = 0.0

    var body: some View {
        Form {
            Section("Payroll Settings") {
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                ).onChange(of: date) {
                    model.paymentPlan.payrollStartDate = date
                    save()
                }
                Stepper(value: $interval, in: 1 ... 20, step: 1) {
                    Text("Interval: \(interval) days")
                }
                .onChange(of: interval) {
                    model.paymentPlan.payrollInterval = interval
                    save()
                }
            }

            Section("Tax Deductions") {
                HStack {
                    Text("Federal Tax")
                    Spacer()
                    TextField("$0.00", value: $federalTaxDeduction, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                .onChange(of: federalTaxDeduction) {
                    model.paymentPlan.federalTaxDeduction = federalTaxDeduction
                    save()
                }

                HStack {
                    Text("State Tax")
                    Spacer()
                    TextField("$0.00", value: $stateTaxDeduction, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                .onChange(of: stateTaxDeduction) {
                    model.paymentPlan.stateTaxDeduction = stateTaxDeduction
                    save()
                }
            }
        }.onAppear {
            date = model.paymentPlan.payrollStartDate
            interval = model.paymentPlan.payrollInterval
            federalTaxDeduction = model.paymentPlan.federalTaxDeduction
            stateTaxDeduction = model.paymentPlan.stateTaxDeduction
        }
    }

    func save() {
        try! modelContext.save()
    }
}

#Preview {
    PlanningForm().environment(TaxTrackingModel())
}

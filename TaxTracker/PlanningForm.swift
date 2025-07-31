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
    @State var taxWithholdings: [TaxType: Double] = [:]

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

            Section("Tax Withholdings") {
                ForEach(TaxType.allCases, id: \.self) { taxType in
                    HStack {
                        Text(taxType.displayName)
                        Spacer()
                        TextField("$0.00", value: Binding(
                            get: { taxWithholdings[taxType] ?? 0.0 },
                            set: { newValue in
                                taxWithholdings[taxType] = newValue
                                model.paymentPlan.setTaxWithholding(for: taxType, amount: newValue)
                                save()
                            }
                        ), format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }.onAppear {
            date = model.paymentPlan.payrollStartDate
            interval = model.paymentPlan.payrollInterval
            for taxType in TaxType.allCases {
                taxWithholdings[taxType] = model.paymentPlan.getTaxWithholding(for: taxType)
            }
        }
    }

    func save() {
        try! modelContext.save()
    }
}

#Preview {
    PlanningForm().environment(TaxTrackingModel())
}

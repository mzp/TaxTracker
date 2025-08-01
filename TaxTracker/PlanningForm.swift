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
    @Query private var savedModels: [TaxTrackingModel]

    @State var date: Date = .init()
    @State var interval = 0
    @State var taxWithholdings: [TaxType: Double] = [:]
    @State var previousYearTaxPayments: [TaxType: Double] = [:]
    @State var automaticTaxRates: [TaxType: Double] = [:]
    @State var stockPrice: Double = 0.0

    private var model: TaxTrackingModel {
        if let existingModel = savedModels.first {
            return existingModel
        } else {
            let newModel = TaxTrackingModel()
            modelContext.insert(newModel)
            try? modelContext.save()
            return newModel
        }
    }

    var body: some View {
        @Bindable var model = model
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
                    TextField(taxType.displayName, value: Binding(
                        get: { taxWithholdings[taxType] ?? 0.0 },
                        set: { newValue in
                            taxWithholdings[taxType] = newValue
                            model.paymentPlan.withholdings[taxType] = newValue
                            save()
                        }
                    ), format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                    #if os(ios)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }

            Section("Previous Year Tax Payments") {
                ForEach(TaxType.allCases, id: \.self) { taxType in
                    TextField(taxType.displayName, value: Binding(
                        get: { previousYearTaxPayments[taxType] ?? 0.0 },
                        set: { newValue in
                            previousYearTaxPayments[taxType] = newValue
                            model.paymentPlan.previousYearTaxPayments[taxType] = newValue
                            save()
                        }
                    ), format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                    #if os(ios)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }

            Section("Automatic Tax Rates") {
                ForEach(TaxType.allCases, id: \.self) { taxType in
                    TextField(taxType.displayName, value: Binding(
                        get: { automaticTaxRates[taxType] ?? 0.0 },
                        set: { newValue in
                            automaticTaxRates[taxType] = newValue
                            model.paymentPlan.automaticTaxRates[taxType] = newValue
                            save()
                        }
                    ), format: .percent)
                        .multilineTextAlignment(.trailing)
                    #if os(ios)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }

            Section("Stock Price") {
                TextField("Price", value: $stockPrice, format: .currency(code: "USD"))
                    .onChange(of: stockPrice) {
                        model.paymentPlan.stockPrice = stockPrice
                        save()
                    }
                    .multilineTextAlignment(.trailing)
                #if os(ios)
                    .keyboardType(.decimalPad)
                #endif
            }

            Section("RSU Vesting Schedule") {
                List {
                    ForEach($model.paymentPlan.vestingSchedule) { $event in
                        HStack {
                            DatePicker("Vest", selection: $event.date, displayedComponents: .date)
                            TextField("Shares", value: $event.shares, format: .number)
                            #if os(iOS)
                                .keyboardType(.numberPad)
                            #endif
                        }.onChange(of: event) {
                            save()
                        }
                    }
                    .onDelete(perform: deleteVestingEvent)
                }
                Button(action: addVestingEvent) {
                    Text("Add Vesting Event")
                }
            }
        }.onAppear {
            date = model.paymentPlan.payrollStartDate
            interval = model.paymentPlan.payrollInterval
            for taxType in TaxType.allCases {
                taxWithholdings[taxType] = model.paymentPlan.withholdings[taxType] ?? 0.0
                previousYearTaxPayments[taxType] = model.paymentPlan.previousYearTaxPayments[taxType] ?? 0.0
                automaticTaxRates[taxType] = model.paymentPlan.automaticTaxRates[taxType] ?? 0.0
            }
            stockPrice = model.paymentPlan.stockPrice
        }
    }

    func addVestingEvent() {
        let newEvent = VestingEvent(date: Date(), shares: 0)
        model.paymentPlan.vestingSchedule.append(newEvent)
        save()
    }

    func deleteVestingEvent(at offsets: IndexSet) {
        model.paymentPlan.vestingSchedule.remove(atOffsets: offsets)
        save()
    }

    func save() {
        try! modelContext.save()
    }
}

#Preview {
    PlanningForm().environment(TaxTrackingModel())
}

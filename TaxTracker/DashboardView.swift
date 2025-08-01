//
//  DashboardView.swift
//  TaxTracker
//
//  Created by mzp on 2025/08/01.
//

import CoreTaxTracker
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]

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
        VStack {
            Group {
                GroupBox("Payroll") {
                    PayrollCalendarChart()
                }
                GroupBox("Tax Payment") {
                    TaxPaymentChart(taxType: .federal)
                    TaxPaymentChart(taxType: .state)
                }
            }
        }
        .environment(model)
    }
}

#Preview {
    DashboardView()
}

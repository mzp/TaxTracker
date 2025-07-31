//
//  ContentView.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]
    @State private var model: TaxTrackingModel?

    var body: some View {
        VStack {
            if let model = model {
                Group {
                    GroupBox("Payroll") {
                        PayrollCalendarChart()
                    }
                    PlanningForm()
                }
                .environment(model)
            }
        }.onAppear {
            loadModel()
        }
    }

    private func loadModel() {
        if let savedModel = savedModels.first {
            model = savedModel
        } else {
            let model = TaxTrackingModel()
            modelContext.insert(model)
            self.model = model
        }
    }
}

#Preview {
    ContentView()
}

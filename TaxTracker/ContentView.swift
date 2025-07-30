//
//  ContentView.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import SwiftUI

struct ContentView: View {
    var model = TaxTrackingModel()

    var body: some View {
        TaxTrackingModelContainer { model, _ in
            PayrollCalendarChart(model: model)
        }
    }
}

#Preview {
    ContentView()
}

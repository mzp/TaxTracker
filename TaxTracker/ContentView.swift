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
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }

            PlanningForm()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planning")
                }

            TaxAdviceView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("AI Advice")
                }

            DocumentImportView()
                .tabItem {
                    Image(systemName: "doc.badge.plus")
                    Text("Import")
                }
        }
    }
}

#Preview {
    ContentView()
}

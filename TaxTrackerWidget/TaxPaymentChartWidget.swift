//
//  TaxPaymentChartWidget.swift
//  TaxTrackerWidget
//
//  Created by mzp on 2025/07/31.
//

import AppIntents
import CoreTaxTracker
import SwiftData
import SwiftUI
import WidgetKit

struct TaxPaymentChartProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> TaxPaymentChartEntry {
        TaxPaymentChartEntry(date: Date(), configuration: TaxTypeSelectionIntent())
    }

    func snapshot(for configuration: TaxTypeSelectionIntent, in _: Context) async -> TaxPaymentChartEntry {
        TaxPaymentChartEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: TaxTypeSelectionIntent, in _: Context) async -> Timeline<TaxPaymentChartEntry> {
        let currentDate = Date()
        let entry = TaxPaymentChartEntry(date: currentDate, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!))
        return timeline
    }
}

struct TaxPaymentChartEntry: TimelineEntry {
    let date: Date
    let configuration: TaxTypeSelectionIntent
}

struct TaxPaymentChartWidgetEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]
    @State private var model: TaxTrackingModel?

    var entry: TaxPaymentChartProvider.Entry

    var body: some View {
        VStack(spacing: 8) {
            if let model = model {
                TaxPaymentChart(taxType: entry.configuration.taxType.taxType)
                    .environment(model)
            } else {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            loadModel()
        }
    }

    private func loadModel() {
        if let savedModel = savedModels.first {
            model = savedModel
        }
    }
}

struct TaxPaymentChartWidget: Widget {
    let kind: String = "TaxPaymentChartWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: TaxTypeSelectionIntent.self, provider: TaxPaymentChartProvider()) { entry in
            TaxPaymentChartWidgetEntryView(entry: entry)
                .modelContainer(for: [TaxTrackingModel.self, TaxPaymentPlan.self])
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tax Payment Chart")
        .description("Shows tax payment progress charts")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    TaxPaymentChartWidget()
} timeline: {
    TaxPaymentChartEntry(date: .now, configuration: TaxTypeSelectionIntent())
}

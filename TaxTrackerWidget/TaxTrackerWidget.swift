//
//  TaxTrackerWidget.swift
//  TaxTrackerWidget
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct TaxTrackerWidgetEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]
    @State private var model: TaxTrackingModel?

    var entry: Provider.Entry
    var body: some View {
        Group {
            if let model = model {
                PayrollCalendarChart()
                    .environment(model)
            }
        }
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

struct TaxTrackerWidget: Widget {
    let kind: String = "TaxTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TaxTrackerWidgetEntryView(entry: entry)
                .modelContainer(for: [TaxTrackingModel.self, TaxPaymentPlan.self])
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Payroll calendar")
        .description("Widget for payroll date")
    }
}

#Preview(as: .systemSmall) {
    TaxTrackerWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}

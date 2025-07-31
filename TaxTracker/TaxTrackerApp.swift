//
//  TaxTrackerApp.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import SwiftData
import SwiftUI

@main
struct TaxTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(
            for: [
                TaxTrackingModel.self,
                TaxPaymentPlan.self,
            ]
        )
    }
}

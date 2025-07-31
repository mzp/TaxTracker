//
//  TaxTrackerWidgetBundle.swift
//  TaxTrackerWidget
//
//  Created by mzp on 2025/07/30.
//

import SwiftUI
import WidgetKit

@main
struct TaxTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TaxTrackerWidget()
        TaxPaymentChartWidget()
    }
}

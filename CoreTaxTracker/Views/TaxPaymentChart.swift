//
//  TaxPaymentChart.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Charts
import SwiftUI

public struct TaxPaymentChart: View {
    @Environment(TaxTrackingModel.self) public var model
    var taxType: TaxType

    public init(taxType: TaxType) {
        self.taxType = taxType
    }

    public var body: some View {
        Chart {}
            .chartXAxis {
                AxisMarks(values: gridValues) { _ in
                    AxisGridLine()
                }
                AxisMarks(values: [safeHarborAmount]) { _ in
                    AxisGridLine().foregroundStyle(.green)
                    AxisValueLabel(format: .currency(code: "USD")).offset(x: -40)
                }
            }
            .chartXScale(domain: 0 ... (safeHarborAmount * 1.2))
            .chartLegend(position: .bottom)
            .frame(height: 150)
    }

    var safeHarborAmount: Double {
        model.safeHarborAmount[taxType] ?? 0.0
    }

    var gridValues: [Double] {
        let value = safeHarborAmount / 4
        return [
            value,
            value * 2,
            value * 3,
        ]
    }
}

#Preview {
    Form {
        TaxPaymentChart(taxType: .federal)
            .environment(TaxTrackingModel())
    }
    .padding()
}

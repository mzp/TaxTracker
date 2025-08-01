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
        let snapshot = model.payment(for: taxType)
        Chart {
            ForEach(snapshot.amounts) { amount in
                BarMark(
                    x: .value("Amount", amount.amount),
                    y: .value("Kind", taxType.displayName)
                ).cornerRadius(6.0)
                    .opacity(amount.realized ? 1.0 : 0.2)
                    .foregroundStyle(by: .value("Category", amount.label))
            }
        }
        .chartXAxis {
            AxisMarks(values: [snapshot.liabilityAmount]) { _ in
                AxisGridLine().foregroundStyle(.yellow)
            }
            AxisMarks(values: [snapshot.safeHarborAmount]) { _ in
                AxisGridLine().foregroundStyle(.green)
                AxisValueLabel(format: .currency(code: "USD")).offset(x: -50)
            }
        }
        .chartXScale(domain: 0 ... (snapshot.safeHarborAmount * 1.1))
        .chartLegend(position: .bottom)
        .frame(height: 100)
    }
}

#Preview {
    Form {
        TaxPaymentChart(taxType: .federal)
            .environment(TaxTrackingModel())
    }
    .padding()
}

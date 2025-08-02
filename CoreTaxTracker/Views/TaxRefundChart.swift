//
//  TaxRefundChart.swift
//  CoreTaxTracker
//
//  Created by Claude on 2025/08/02.
//

import SwiftUI

public struct TaxRefundChart: View {
    let taxType: TaxType
    @Environment(TaxTrackingModel.self) private var model

    private var snapshot: TaxTrackingModel.TaxPaymentSnapshot {
        model.payment(for: taxType)
    }

    private var totalTaxPayment: Double {
        snapshot.amounts.reduce(0) { $0 + $1.amount }
    }

    private var safeHarborDifference: Double {
        totalTaxPayment - snapshot.safeHarborAmount
    }

    private var liabilityDifference: Double {
        totalTaxPayment - snapshot.liabilityAmount
    }

    public init(taxType: TaxType) {
        self.taxType = taxType
    }

    public var body: some View {
        VStack {
            LabeledContent("Safe Harbor") {
                Text(safeHarborDifference, format: .currency(code: "USD"))
                    .fontWeight(.medium)
            }

            LabeledContent("Liability") {
                Text(liabilityDifference, format: .currency(code: "USD"))
                    .fontWeight(.medium)
            }
        }
    }
}

//
//  TaxTrackingModelContainer.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

public struct TaxTrackingModelContainer: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]
    @State private var model: TaxTrackingModel

    var content: (TaxTrackingModel, () -> Void) -> any View

    public init(content: @escaping (TaxTrackingModel, () -> Void) -> any View) {
        self.content = content
        _model = .init(initialValue: TaxTrackingModel())
    }

    public var body: some View {
        AnyView(content(model, saveModel))
            .onAppear {
                loadModel()
            }
            .modelContainer(for: [TaxTrackingModel.self])
    }

    private func loadModel() {
        if let savedModel = savedModels.first {
            model = savedModel
        } else {
            model = TaxTrackingModel()
            modelContext.insert(model)
        }
    }

    private func saveModel() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save model: \(error)")
        }
    }
}

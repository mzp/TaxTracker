//
//  PayslipImportView.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/31.
//

import CoreTaxTracker
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct PayslipImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TaxTrackingModel.self) private var trackingModel

    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Current Receipt") {
                if let receipt = trackingModel.receipt {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Federal Tax YTD:")
                            Spacer()
                            Text("$\(receipt.payrollWithholdingTaxYTD[.federal] ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("State Tax YTD:")
                            Spacer()
                            Text("$\(receipt.payrollWithholdingTaxYTD[.state] ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("Last Updated:")
                            Spacer()
                            Text(receipt.lastModifiedDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("No payslip data imported yet")
                        .foregroundColor(.secondary)
                }
            }

            Button("Import Payslip PDF") {
                isFilePickerPresented = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(isImporting)

            if isImporting {
                ProgressView("Processing payslip...")
                    .progressViewStyle(CircularProgressViewStyle())
            }

            if let result = importResult {
                GroupBox {
                    switch result {
                    case .success:
                        Label("Payslip imported successfully!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case let .error(message):
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Import Payslip")
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }
            importPayslip(from: url)
        case let .failure(error):
            importResult = .error("Failed to select file: \(error.localizedDescription)")
        }
    }

    private func importPayslip(from url: URL) {
        Task {
            await MainActor.run {
                isImporting = true
                importResult = nil
            }

            do {
                // Start accessing the security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    await MainActor.run {
                        isImporting = false
                        importResult = .error("Cannot access selected file")
                    }
                    return
                }

                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                let agent = PayslipAgent()
                try await agent.processPayslip(from: url, for: trackingModel)

                // Save the receipt to SwiftData
                if let receipt = trackingModel.receipt {
                    modelContext.insert(receipt)
                }

                // Save all changes including TaxPaymentPlan withholdings updates
                try modelContext.save()

                await MainActor.run {
                    isImporting = false
                    importResult = .success
                }
            } catch {
                await MainActor.run {
                    isImporting = false
                    importResult = .error("Failed to process payslip: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum ImportResult {
    case success
    case error(String)
}

#Preview {
    PayslipImportView()
        .environment(TaxTrackingModel())
}

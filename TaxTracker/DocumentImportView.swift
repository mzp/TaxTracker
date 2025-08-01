//
//  DocumentImportView.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/31.
//

import CoreTaxTracker
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

enum DocumentType: String, CaseIterable {
    case payslip = "Payslip PDF"
    case irsEmail = "IRS Payment Email"

    var agent: DocumentProcessingAgent {
        switch self {
        case .payslip:
            return PayslipAgent()
        case .irsEmail:
            return TaxPaymentAgent()
        }
    }

    /// Automatically detect document type from URL
    /// First tries to detect as payslip (PDF), then falls back to IRS email
    static func detect(from url: URL) -> DocumentType {
        // Check if it's a PDF file (likely payslip)
        if url.pathExtension.lowercased() == "pdf" {
            return .payslip
        }

        // Check if it's an email file (likely IRS payment email)
        let emailExtensions = ["eml", "msg", "email"]
        if emailExtensions.contains(url.pathExtension.lowercased()) {
            return .irsEmail
        }

        // Check if it's a text file (could be either type, try payslip first)
        let textExtensions = ["txt"]
        if textExtensions.contains(url.pathExtension.lowercased()) {
            return .payslip
        }

        // Default fallback: try payslip first, then IRS email
        // This allows for more sophisticated detection in the future
        return .payslip
    }
}

struct DocumentImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedModels: [TaxTrackingModel]

    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var isFilePickerPresented = false

    private var trackingModel: TaxTrackingModel {
        if let existingModel = savedModels.first {
            return existingModel
        } else {
            let newModel = TaxTrackingModel()
            modelContext.insert(newModel)
            try? modelContext.save()
            return newModel
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Current Receipt") {
                if let receipt = trackingModel.receipt {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("Federal Tax YTD") {
                            Text("$\(receipt.payrollWithholdingTaxYTD[.federal] ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        LabeledContent("State Tax YTD") {
                            Text("$\(receipt.payrollWithholdingTaxYTD[.state] ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        LabeledContent("Salary YTD") {
                            Text("$\(receipt.salaryYTD ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        LabeledContent("RSU YTD") {
                            Text("$\(receipt.rsuYTD ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        LabeledContent("Estimate Tax (Federal)") {
                            Text("$\(receipt.estimateTax[.federal] ?? 0, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        LabeledContent("Last Updated") {
                            Text(receipt.lastModifiedDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("No documents imported yet")
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 16) {
                // Drop zone placeholder for future D&D support
                GroupBox {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)

                        Text("Drag & drop files here")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Or click the button below to browse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .background(.secondary.opacity(0.1))
                .cornerRadius(12)
                // TODO: Add D&D support here in the future
                // .onDrop(of: [UTType.item], isTargeted: nil) { providers in ... }

                Button("Import Document") {
                    isFilePickerPresented = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(isImporting)
            }

            if isImporting {
                ProgressView("Processing document...")
                    .progressViewStyle(CircularProgressViewStyle())
            }

            if let result = importResult {
                GroupBox {
                    switch result {
                    case .success:
                        Label("Document imported successfully!", systemImage: "checkmark.circle.fill")
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
        .navigationTitle("Import Documents")
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [UTType.item], // Allow all file types
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }
            let detectedType = DocumentType.detect(from: url)
            importDocument(from: url, using: detectedType)
        case let .failure(error):
            importResult = .error("Failed to select file: \(error.localizedDescription)")
        }
    }

    private func importDocument(from url: URL, using documentType: DocumentType) {
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

                // Try to process with auto-detected type first
                var agent = documentType.agent
                var processingError: Error?

                do {
                    try await agent.processDocument(from: url, for: trackingModel)
                } catch {
                    processingError = error

                    // If initial processing failed and we detected it as payslip, try as IRS email
                    if documentType == .payslip {
                        agent = DocumentType.irsEmail.agent
                        do {
                            try await agent.processDocument(from: url, for: trackingModel)
                            processingError = nil // Success with fallback
                        } catch {
                            // Keep the original error if both fail
                            processingError = processingError
                        }
                    }
                }

                // If there's still an error, throw it
                if let error = processingError {
                    throw error
                }

                // Save the receipt to SwiftData on MainActor
                await MainActor.run {
                    if let receipt = trackingModel.receipt {
                        modelContext.insert(receipt)
                    }

                    // Save all changes including TaxPaymentPlan withholdings updates
                    do {
                        try modelContext.save()
                        isImporting = false
                        importResult = .success
                    } catch {
                        isImporting = false
                        importResult = .error("Failed to save: \(error.localizedDescription)")
                    }
                }
            } catch {
                await MainActor.run {
                    isImporting = false
                    importResult = .error("Failed to process document: \(error.localizedDescription)")
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
    DocumentImportView()
        .environment(TaxTrackingModel())
}

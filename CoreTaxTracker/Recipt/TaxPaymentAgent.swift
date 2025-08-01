import Foundation
import SwiftData

public enum TaxPaymentAgentError: Error {
    case emailProcessingFailed
    case modelNotFound
}

public actor TaxPaymentAgent: DocumentProcessingAgent {
    public init() {}

    public func processDocument(from url: URL, for trackingModel: TaxTrackingModel) async throws {
        try await processPaymentEmail(from: url, for: trackingModel)
    }

    public func processPaymentEmail(from emailURL: URL, for trackingModel: TaxTrackingModel) async throws {
        guard let emailReader = IRSPaymentEmailReader(url: emailURL) else {
            throw TaxPaymentAgentError.emailProcessingFailed
        }

        let paymentInfo = emailReader.paymentInfo
        let paymentAmount = Double(truncating: paymentInfo.paymentAmount as NSNumber)

        // Create new receipt or update existing one
        let receipt: TaxPaymentReceipt
        if let existingReceipt = trackingModel.receipt {
            // Update existing receipt with estimate tax payment
            receipt = existingReceipt
            receipt.estimateTax[.federal] = paymentAmount
            receipt.lastModifiedDate = Date()
        } else {
            // Create new receipt with estimate tax payment
            receipt = TaxPaymentReceipt(
                estimateTax: [.federal: paymentAmount]
            )
        }

        // Set as the current receipt
        trackingModel.receipt = receipt
    }
}

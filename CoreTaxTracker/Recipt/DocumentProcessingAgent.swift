import Foundation

/// Common protocol for agents that process documents and update tax tracking models
public protocol DocumentProcessingAgent {
    /// Process a document from the given URL and update the tracking model
    /// - Parameters:
    ///   - url: The URL of the document to process
    ///   - trackingModel: The tax tracking model to update
    /// - Throws: An error if processing fails
    func processDocument(from url: URL, for trackingModel: TaxTrackingModel) async throws
}

/// Base error types that can be extended by specific agents
public enum DocumentProcessingError: Error {
    case processingFailed
    case invalidDocument
    case modelUpdateFailed
}

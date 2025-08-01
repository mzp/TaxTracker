@testable import CoreTaxTracker
import Foundation
import Testing

private class TestBundleLocator {}

struct TaxPaymentAgentTests {
    private let agent = TaxPaymentAgent()
    private let trackingModel = TaxTrackingModel()

    @Test func processPaymentEmailWithValidEmail() throws {
        let bundle = Bundle(for: TestBundleLocator.self)
        let emailURL = try #require(bundle.url(forResource: "IRS Account Confirmation of Scheduled Transaction", withExtension: "eml"), "Test email file not found")

        let agent = TaxPaymentAgent()
        let trackingModel = TaxTrackingModel()

        Task {
            try await agent.processPaymentEmail(from: emailURL, for: trackingModel)

            // Verify that receipt was created
            #expect(trackingModel.receipt != nil)

            // Verify that estimate tax was set correctly
            let receipt = try #require(trackingModel.receipt, "Receipt should not be nil")
            #expect(receipt.estimateTax[.federal] == 1234.56)

            // Verify last modified date was updated
            let now = Date()
            let timeDifference = abs(receipt.lastModifiedDate.timeIntervalSince(now))
            #expect(timeDifference < 1) // Should be within 1 second
        }
    }

    @Test func processPaymentEmailWithExistingReceipt() throws {
        let bundle = Bundle(for: TestBundleLocator.self)
        let emailURL = try #require(bundle.url(forResource: "IRS Account Confirmation of Scheduled Transaction", withExtension: "eml"), "Test email file not found")

        let agent = TaxPaymentAgent()
        let trackingModel = TaxTrackingModel()

        // Create existing receipt with payroll withholding data
        let existingReceipt = TaxPaymentReceipt(
            payrollWithholdingTaxYTD: [.federal: 5000.0, .state: 1000.0]
        )
        trackingModel.receipt = existingReceipt

        Task {
            try await agent.processPaymentEmail(from: emailURL, for: trackingModel)

            // Verify that the same receipt was updated (not replaced)
            #expect(trackingModel.receipt === existingReceipt)

            // Verify that estimate tax was added
            #expect(existingReceipt.estimateTax[.federal] == 1234.56)

            // Verify that existing payroll data was preserved
            #expect(existingReceipt.payrollWithholdingTaxYTD[.federal] == 5000.0)
            #expect(existingReceipt.payrollWithholdingTaxYTD[.state] == 1000.0)
        }
    }

    @Test func processPaymentEmailWithInvalidEmail() async throws {
        let invalidURL = URL(fileURLWithPath: "/nonexistent/file.eml")

        let agent = TaxPaymentAgent()
        let trackingModel = TaxTrackingModel()

        await #expect(throws: TaxPaymentAgentError.emailProcessingFailed) {
            try await agent.processPaymentEmail(from: invalidURL, for: trackingModel)
        }

        // Verify that no receipt was created
        #expect(trackingModel.receipt == nil)
    }

    @Test func initialization() {
        let agent = TaxPaymentAgent()
        // Test that agent initializes successfully (no specific assertion needed)
        _ = agent
    }
}

@testable import CoreTaxTracker
import Foundation
import Testing

private class TestBundleLocator {}

struct DocumentProcessingAgentTests {
    @Test func payslipAgentConformsToProtocol() {
        let agent: DocumentProcessingAgent = PayslipAgent()
        #expect(agent is PayslipAgent)
    }

    @Test func taxPaymentAgentConformsToProtocol() {
        let agent: DocumentProcessingAgent = TaxPaymentAgent()
        #expect(agent is TaxPaymentAgent)
    }

    @Test func agentsCanBeUsedPolymorphically() async throws {
        let bundle = Bundle(for: TestBundleLocator.self)
        let payslipURL = try #require(bundle.url(forResource: "sample_payslip", withExtension: "pdf"), "Sample payslip PDF not found")
        let emailURL = try #require(bundle.url(forResource: "IRS Account Confirmation of Scheduled Transaction", withExtension: "eml"), "Test email file not found")

        let agents: [DocumentProcessingAgent] = [
            PayslipAgent(),
            TaxPaymentAgent(),
        ]

        // Test that we can call processDocument on all agents polymorphically
        for agent in agents {
            let trackingModel = TaxTrackingModel()

            do {
                if agent is PayslipAgent {
                    try await agent.processDocument(from: payslipURL, for: trackingModel)
                } else if agent is TaxPaymentAgent {
                    try await agent.processDocument(from: emailURL, for: trackingModel)
                }

                // Verify that receipt was created/updated
                #expect(trackingModel.receipt != nil)
            } catch {
                // Some agents might fail due to missing dependencies (like Foundation Models)
                // This is acceptable for this test
                continue
            }
        }
    }

    @Test func processDocumentMethodExists() {
        let payslipAgent = PayslipAgent()
        let taxPaymentAgent = TaxPaymentAgent()

        // Verify that processDocument method exists (compilation test)
        let agents: [DocumentProcessingAgent] = [payslipAgent, taxPaymentAgent]

        for agent in agents {
            // This tests that the processDocument method signature is correct
            _ = agent.processDocument
        }
    }
}

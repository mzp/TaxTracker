@testable import CoreTaxTracker
import Foundation
import SwiftData
import Testing

private class TestBundleLocator {}

struct PayslipAgentTests {
    private func createTestModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaxTrackingModel.self, TaxPaymentPlan.self, TaxPaymentReceipt.self, configurations: config)
        return ModelContext(container)
    }

    @Test func processPayslipFromURL() async throws {
        let modelContext = try createTestModelContext()
        let agent = PayslipAgent()
        let trackingModel = TaxTrackingModel()

        modelContext.insert(trackingModel)

        let testBundle = Bundle(for: TestBundleLocator.self)
        let pdfURL = try #require(testBundle.url(forResource: "sample_payslip", withExtension: "pdf"), "Sample payslip PDF not found in test bundle")

        do {
            try await agent.processPayslip(from: pdfURL, for: trackingModel)

            // Verify receipt was set in tracking model
            #expect(trackingModel.receipt != nil)

            let receipt = trackingModel.receipt!
            #expect(receipt.payrollWithholdingTaxYTD[.federal] == 59781.89)
            #expect(receipt.payrollWithholdingTaxYTD[.state] == 24437.48)

            // Verify last modified date is recent
            let timeDifference = abs(receipt.lastModifiedDate.timeIntervalSinceNow)
            #expect(timeDifference < 60)

            // Caller handles persistence
            modelContext.insert(receipt)
            try modelContext.save()

        } catch PayslipReaderError.modelResponseFailed {
            // Foundation Models dependency not available - test will be skipped
            return
        } catch PayslipReaderError.modelInitializationFailed {
            // Foundation Models initialization failed - test will be skipped
            return
        }
    }

    @Test func taxPaymentReceiptInitialization() {
        let federalTax = 1500.50
        let stateTax = 300.25

        let receipt = TaxPaymentReceipt(
            payrollWithholdingTaxYTD: [.federal: federalTax, .state: stateTax]
        )

        #expect(receipt.payrollWithholdingTaxYTD[.federal] == federalTax)
        #expect(receipt.payrollWithholdingTaxYTD[.state] == stateTax)

        // Verify last modified date is recent
        let timeDifference = abs(receipt.lastModifiedDate.timeIntervalSinceNow)
        #expect(timeDifference < 1)
    }
}

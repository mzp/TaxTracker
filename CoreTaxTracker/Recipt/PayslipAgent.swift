import Foundation

public class PayslipAgent: DocumentProcessingAgent {
    private let payslipReader: PayslipReader

    public init() {
        payslipReader = PayslipReader()
    }

    public func processDocument(from url: URL, for trackingModel: TaxTrackingModel) async throws {
        try await processPayslip(from: url, for: trackingModel)
    }

    public func processPayslip(from url: URL, for trackingModel: TaxTrackingModel) async throws {
        // Extract data from PDF using PayslipReader
        let payslipData = try await payslipReader.extractTaxData(from: url)

        // Update existing receipt or create new one
        if let existingReceipt = trackingModel.receipt {
            // Update existing receipt with new payslip data
            existingReceipt.payrollWithholdingTaxYTD[.federal] = payslipData.federalTaxYTD
            existingReceipt.payrollWithholdingTaxYTD[.state] = payslipData.stateTaxYTD
            existingReceipt.lastModifiedDate = Date()
            // Keep existing estimateTax values
        } else {
            // Create new receipt
            let receipt = TaxPaymentReceipt(
                payrollWithholdingTaxYTD: [
                    .federal: payslipData.federalTaxYTD,
                    .state: payslipData.stateTaxYTD,
                ],
                lastModifiedDate: Date(),
                estimateTax: [:]
            )
            trackingModel.receipt = receipt
        }

        // Update TaxPaymentPlan withholdings with current period amounts
        trackingModel.paymentPlan.withholdings[.federal] = payslipData.federalTaxCurrent
        trackingModel.paymentPlan.withholdings[.state] = payslipData.stateTaxCurrent
    }
}

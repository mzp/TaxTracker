import Foundation

public class PayslipAgent {
    private let payslipReader: PayslipReader

    public init() {
        payslipReader = PayslipReader()
    }

    public func processPayslip(from url: URL, for trackingModel: TaxTrackingModel) async throws {
        // Extract data from PDF using PayslipReader
        let payslipData = try await payslipReader.extractTaxData(from: url)

        // Create new TaxPaymentReceipt from extracted data
        let receipt = TaxPaymentReceipt(
            payrollWithholdingTaxYTD: [
                .federal: payslipData.federalTaxYTD,
                .state: payslipData.stateTaxYTD,
            ],
            lastModifiedDate: Date()
        )

        // Update TaxPaymentPlan withholdings with current period amounts
        trackingModel.paymentPlan.withholdings[.federal] = payslipData.federalTaxCurrent
        trackingModel.paymentPlan.withholdings[.state] = payslipData.stateTaxCurrent

        // Set as the current receipt
        trackingModel.receipt = receipt
    }
}

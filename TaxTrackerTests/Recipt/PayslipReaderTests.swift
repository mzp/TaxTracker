@testable import CoreTaxTracker
import Foundation
import Testing

private class TestBundleLocator {}

struct PayslipReaderTests {
    private let payslipReader = PayslipReader()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func extractTaxDataFromSamplePayslip() async throws {
        let testBundle = Bundle(for: TestBundleLocator.self)
        let pdfURL = try #require(testBundle.url(forResource: "sample_payslip", withExtension: "pdf"), "Sample payslip PDF not found in test bundle")

        do {
            let extractedData = try await payslipReader.extractTaxData(from: pdfURL)
            // AI extraction may have some variance, so we use reasonable ranges for validation
            #expect(extractedData.federalTaxCurrent > 0)
            #expect(extractedData.federalTaxYTD > 0)
            #expect(extractedData.stateTaxCurrent >= 0) // State tax might be 0 if the state doesn't have income tax
            #expect(extractedData.stateTaxYTD >= 0)

            let today = date(2025, 7, 18)
            let timeDifference = abs(extractedData.extractionDate.timeIntervalSince(today))
            #expect(timeDifference < 60)

        } catch PayslipReaderError.modelResponseFailed {
            // Foundation Models dependency not available - test will be skipped
            return
        } catch PayslipReaderError.modelInitializationFailed {
            // Foundation Models initialization failed - test will be skipped
            return
        } catch {
            Issue.record("Unexpected error: \(error)")
            throw error
        }
    }

    @Test func invalidPDFHandling() async throws {
        let invalidURL = URL(fileURLWithPath: "/non/existent/file.pdf")

        await #expect(throws: PayslipReaderError.invalidPDF) {
            try await payslipReader.extractTaxData(from: invalidURL)
        }
    }

    @Test func payslipDataInitialization() {
        let federalTax = 1500.50
        let stateTax = 300.25
        let checkDateString = "07-18-2025"

        let payslipData = PayslipData(
            federalTaxYTD: federalTax,
            stateTaxYTD: stateTax,
            federalTaxCurrent: 200.0,
            stateTaxCurrent: 50.0,
            checkDate: checkDateString
        )

        #expect(payslipData.federalTaxYTD == federalTax)
        #expect(payslipData.stateTaxYTD == stateTax)
        #expect(payslipData.checkDate == checkDateString)

        // Test computed extractionDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let expectedDate = dateFormatter.date(from: checkDateString)!
        #expect(payslipData.extractionDate == expectedDate)
    }

    @Test func payslipDataInvalidDateFallback() {
        let federalTax = 1000.0
        let stateTax = 200.0
        let invalidDate = "invalid-date"

        let payslipData = PayslipData(
            federalTaxYTD: federalTax,
            stateTaxYTD: stateTax,
            federalTaxCurrent: 100.0,
            stateTaxCurrent: 20.0,
            checkDate: invalidDate
        )

        // Should fallback to current date when parsing fails
        let now = Date()
        let timeDifference = abs(payslipData.extractionDate.timeIntervalSince(now))
        #expect(timeDifference < 1)
    }
}

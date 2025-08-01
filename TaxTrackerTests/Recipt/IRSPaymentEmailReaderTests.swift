@testable import CoreTaxTracker
import Foundation
import Testing

private class TestBundleLocator {}

struct IRSPaymentEmailReaderTests {
    @Test func parseEmail() throws {
        let bundle = Bundle(for: TestBundleLocator.self)
        let testEmailURL = try #require(bundle.url(forResource: "IRS Account Confirmation of Scheduled Transaction", withExtension: "eml"), "Test email file not found")

        let reader = try #require(IRSPaymentEmailReader(url: testEmailURL), "Failed to initialize IRSPaymentEmailReader")

        #expect(reader.paymentInfo.paymentAmount == Decimal(string: "1234.56"))
        #expect(reader.paymentInfo.confirmationNumber == "B99999999999999999")
        #expect(reader.paymentInfo.eftNumber == "999999999999999")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let expectedDate = try #require(dateFormatter.date(from: "January 15, 2024"), "Failed to parse expected date")
        #expect(reader.paymentInfo.date == expectedDate)
    }

    @Test func initWithInvalidURL() {
        let invalidURL = URL(fileURLWithPath: "/nonexistent/file.eml")

        let reader = IRSPaymentEmailReader(url: invalidURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithMissingPaymentAmount() throws {
        let testContent = """
        <span>Date: </span>
        <span>January 15, 2024</span>
        <span>Confirmation Number:</span>
        <span>B99999999999999999</span>
        <span>EFT#:</span>
        <span>999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithMissingDate() throws {
        let testContent = """
        <span>Payment Amount:</span>
        <span>$1,234.56</span>
        <span>Confirmation Number:</span>
        <span>B99999999999999999</span>
        <span>EFT#:</span>
        <span>999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithMissingConfirmationNumber() throws {
        let testContent = """
        <span>Payment Amount:</span>
        <span>$1,234.56</span>
        <span>Date: </span>
        <span>January 15, 2024</span>
        <span>EFT#:</span>
        <span>999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithMissingEFTNumber() throws {
        let testContent = """
        <span>Payment Amount:</span>
        <span>$1,234.56</span>
        <span>Date: </span>
        <span>January 15, 2024</span>
        <span>Confirmation Number:</span>
        <span>B99999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithInvalidDateFormat() throws {
        let testContent = """
        <span>Payment Amount:</span>
        <span>$1,234.56</span>
        <span>Date: </span>
        <span>2024-01-15</span>
        <span>Confirmation Number:</span>
        <span>B99999999999999999</span>
        <span>EFT#:</span>
        <span>999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    @Test func parseEmailWithInvalidPaymentAmount() throws {
        let testContent = """
        <span>Payment Amount:</span>
        <span>$invalid</span>
        <span>Date: </span>
        <span>January 15, 2024</span>
        <span>Confirmation Number:</span>
        <span>B99999999999999999</span>
        <span>EFT#:</span>
        <span>999999999999999</span>
        """

        let tempURL = try createTempFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = IRSPaymentEmailReader(url: tempURL)
        #expect(reader == nil)
    }

    // MARK: - Helper Methods

    private func createTempFile(content: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("eml")
        try content.write(to: tempFile, atomically: true, encoding: .utf8)
        return tempFile
    }
}

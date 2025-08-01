import Foundation
import os.log

public struct IRSPaymentInfo {
    public var paymentAmount: Decimal
    public var date: Date
    public var confirmationNumber: String
    public var eftNumber: String

    public init(paymentAmount: Decimal, date: Date, confirmationNumber: String, eftNumber: String) {
        self.paymentAmount = paymentAmount
        self.date = date
        self.confirmationNumber = confirmationNumber
        self.eftNumber = eftNumber
    }
}

public class IRSPaymentEmailReader {
    private let dateFormatter: DateFormatter
    private let emailContent: String
    public var paymentInfo: IRSPaymentInfo

    private static let logger = Logger(subsystem: "CoreTaxTracker", category: "IRSPaymentEmailReader")

    public init?(url: URL) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")

        do {
            emailContent = try String(contentsOf: url, encoding: .utf8)
        } catch {
            Self.logger.error("Failed to read file at \(url.path): \(error.localizedDescription)")
            return nil
        }

        guard let paymentAmount = Self.extractPaymentAmount(from: emailContent),
              let date = Self.extractDate(from: emailContent, using: dateFormatter),
              let confirmationNumber = Self.extractConfirmationNumber(from: emailContent),
              let eftNumber = Self.extractEFTNumber(from: emailContent)
        else {
            return nil
        }

        paymentInfo = IRSPaymentInfo(
            paymentAmount: paymentAmount,
            date: date,
            confirmationNumber: confirmationNumber,
            eftNumber: eftNumber
        )
    }

    private static func extractPaymentAmount(from content: String) -> Decimal? {
        let regex = /Payment Amount:<\/span>\s*<span[^>]*>\$([^<]+)<\/span>/

        guard let match = content.firstMatch(of: regex) else {
            logger.error("Payment amount not found in email content")
            return nil
        }

        let amountString = String(match.1).replacingOccurrences(of: ",", with: "")
        guard let amount = Decimal(string: amountString) else {
            logger.error("Invalid payment amount format: \(String(match.1))")
            return nil
        }

        return amount
    }

    private static func extractDate(from content: String, using dateFormatter: DateFormatter) -> Date? {
        let regex = /Date: <\/span>\s*<span[^>]*>([^<]+)<\/span>/

        guard let match = content.firstMatch(of: regex) else {
            logger.error("Date not found in email content")
            return nil
        }

        let dateString = String(match.1)
        guard let date = dateFormatter.date(from: dateString) else {
            logger.error("Invalid date format: \(dateString)")
            return nil
        }

        return date
    }

    private static func extractConfirmationNumber(from content: String) -> String? {
        let regex = /Confirmation Number:<\/span>\s*<span[^>]*>([A-Z0-9]+)<\/span>/

        guard let match = content.firstMatch(of: regex) else {
            logger.error("Confirmation number not found in email content")
            return nil
        }

        return String(match.1)
    }

    private static func extractEFTNumber(from content: String) -> String? {
        let regex = /EFT#:<\/span>\s*<span[^>]*>([0-9]+)<\/span>/

        guard let match = content.firstMatch(of: regex) else {
            logger.error("EFT number not found in email content")
            return nil
        }

        return String(match.1)
    }
}

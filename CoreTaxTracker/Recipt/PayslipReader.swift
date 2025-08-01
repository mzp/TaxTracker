import Foundation
import FoundationModels
import OSLog
import PDFKit

public actor PayslipReader {
    private let logger = Logger(subsystem: "CoreTaxTracker", category: "PayslipReader")
    private var languageModelSession: LanguageModelSession?

    public init() {}

    public func extractTaxData(from pdfURL: URL) async throws -> PayslipData {
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            throw PayslipReaderError.invalidPDF
        }

        let extractedText = extractTextFromPDF(pdfDocument)
        logger.info("Extracted text from PDF: \(extractedText.prefix(100))...")

        return try await extractTaxInformation(from: extractedText)
    }

    private func extractTextFromPDF(_ document: PDFDocument) -> String {
        var fullText = ""

        for pageIndex in 0 ..< document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            guard let pageText = page.string else { continue }
            fullText += pageText + "\n"
        }

        return fullText
    }

    private func extractTaxInformation(from text: String) async throws -> PayslipData {
        let session = getLanguageModelSession()

        let prompt = """
        Extract the following information from this payslip:

        1. Year-to-Date (YTD) federal withholding tax amount
        2. Year-to-Date (YTD) state withholding tax amount  
        3. Current pay period federal withholding tax amount
        4. Current pay period state withholding tax amount
        5. Check date

        For tax amounts, look in the tax deductions section:
        - "Federal Withholding Tax" followed by two amounts - take the SECOND amount (year-to-date total) and FIRST amount (current period)
        - "California Withholding Tax" or similar state tax followed by two amounts - take the SECOND amount (year-to-date total) and FIRST amount (current period)
        - When there are two amounts shown for a tax line, the smaller amount is current period, the larger amount is year-to-date total
        - If you cannot find tax information, return 0 for that value

        For check date, look for "Check Date:" followed by the date. Format the date as MM-DD-YYYY.

        CRITICAL: Only look in the "Tax Deductions:" section for tax amounts. Ignore any other tax-related numbers like social security, medicare, or gross pay amounts.

        Payslip text:
        \(text)
        """

        do {
            let response = try await session.respond(to: prompt, generating: PayslipData.self)

            // Use the structured response directly
            let result = response.content
            logger.info("AI extracted - Federal YTD: \(result.federalTaxYTD), State YTD: \(result.stateTaxYTD), Federal Current: \(result.federalTaxCurrent), State Current: \(result.stateTaxCurrent), Date: \(result.checkDate)")

            return result

        } catch {
            logger.error("Foundation Models error: \(error.localizedDescription)")
            throw PayslipReaderError.modelResponseFailed
        }
    }

    private func getLanguageModelSession() -> LanguageModelSession {
        if let session = languageModelSession {
            return session
        }

        let session = LanguageModelSession()
        languageModelSession = session
        return session
    }
}

public enum PayslipReaderError: Error, LocalizedError {
    case invalidPDF
    case modelResponseFailed
    case modelInitializationFailed

    public var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "Invalid PDF file"
        case .modelResponseFailed:
            return "Foundation model response failed"
        case .modelInitializationFailed:
            return "Failed to initialize Foundation Model session"
        }
    }
}

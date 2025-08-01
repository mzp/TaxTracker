import Foundation
@testable import TaxTracker
import Testing

struct DocumentTypeDetectionTests {
    @Test func detectPDFAsPayslip() {
        let pdfURL = URL(fileURLWithPath: "/path/to/document.pdf")
        let detectedType = DocumentType.detect(from: pdfURL)
        #expect(detectedType == .payslip)
    }

    @Test func detectEMLAsIRSEmail() {
        let emlURL = URL(fileURLWithPath: "/path/to/email.eml")
        let detectedType = DocumentType.detect(from: emlURL)
        #expect(detectedType == .irsEmail)
    }

    @Test func detectMSGAsIRSEmail() {
        let msgURL = URL(fileURLWithPath: "/path/to/email.msg")
        let detectedType = DocumentType.detect(from: msgURL)
        #expect(detectedType == .irsEmail)
    }

    @Test func detectEmailAsIRSEmail() {
        let emailURL = URL(fileURLWithPath: "/path/to/email.email")
        let detectedType = DocumentType.detect(from: emailURL)
        #expect(detectedType == .irsEmail)
    }

    @Test func detectTXTAsPayslip() {
        let txtURL = URL(fileURLWithPath: "/path/to/document.txt")
        let detectedType = DocumentType.detect(from: txtURL)
        #expect(detectedType == .payslip)
    }

    @Test func detectUnknownExtensionAsPayslip() {
        let unknownURL = URL(fileURLWithPath: "/path/to/document.xyz")
        let detectedType = DocumentType.detect(from: unknownURL)
        #expect(detectedType == .payslip)
    }

    @Test func detectNoExtensionAsPayslip() {
        let noExtURL = URL(fileURLWithPath: "/path/to/document")
        let detectedType = DocumentType.detect(from: noExtURL)
        #expect(detectedType == .payslip)
    }

    @Test func caseInsensitiveDetection() {
        let pdfUpperURL = URL(fileURLWithPath: "/path/to/document.PDF")
        let pdfDetected = DocumentType.detect(from: pdfUpperURL)
        #expect(pdfDetected == .payslip)

        let emlUpperURL = URL(fileURLWithPath: "/path/to/email.EML")
        let emlDetected = DocumentType.detect(from: emlUpperURL)
        #expect(emlDetected == .irsEmail)

        let txtUpperURL = URL(fileURLWithPath: "/path/to/document.TXT")
        let txtDetected = DocumentType.detect(from: txtUpperURL)
        #expect(txtDetected == .payslip)
    }
}

import Foundation
import FoundationModels

@Generable
public struct PayslipData {
    @Guide(description: "The year-to-date federal withholding tax amount (the larger amount when two amounts are shown for federal tax)")
    public let federalTaxYTD: Double

    @Guide(description: "The year-to-date state withholding tax amount (the larger amount when two amounts are shown for state tax)")
    public let stateTaxYTD: Double

    @Guide(description: "The current pay period federal withholding tax amount (the smaller amount when two amounts are shown for federal tax)")
    public let federalTaxCurrent: Double

    @Guide(description: "The current pay period state withholding tax amount (the smaller amount when two amounts are shown for state tax)")
    public let stateTaxCurrent: Double

    @Guide(description: "The check date from the payslip in MM-DD-YYYY format (e.g., 07-18-2025)")
    public let checkDate: String

    public var extractionDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.date(from: checkDate) ?? Date()
    }

    public init(federalTaxYTD: Double, stateTaxYTD: Double, federalTaxCurrent: Double, stateTaxCurrent: Double, checkDate: String) {
        self.federalTaxYTD = federalTaxYTD
        self.stateTaxYTD = stateTaxYTD
        self.federalTaxCurrent = federalTaxCurrent
        self.stateTaxCurrent = stateTaxCurrent
        self.checkDate = checkDate
    }
}

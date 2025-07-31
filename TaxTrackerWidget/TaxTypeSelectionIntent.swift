//
//  TaxTypeSelectionIntent.swift
//  TaxTrackerWidget
//
//  Created by mzp on 2025/07/31.
//

import AppIntents
import CoreTaxTracker
import Foundation

struct TaxTypeSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Tax Type"
    static var description = IntentDescription("Choose which tax type to display in the widget")

    @Parameter(title: "Tax Type", default: .federal)
    var taxType: TaxTypeAppEnum

    init() {}

    init(taxType: TaxTypeAppEnum) {
        self.taxType = taxType
    }
}

enum TaxTypeAppEnum: String, CaseIterable, AppEnum {
    case federal
    case state

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Tax Type")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .federal: DisplayRepresentation(title: "Federal Tax"),
            .state: DisplayRepresentation(title: "State Tax"),
        ]
    }

    var taxType: TaxType {
        switch self {
        case .federal:
            return .federal
        case .state:
            return .state
        }
    }
}

//
//  TaxType.swift
//  TaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation
import SwiftData
import SwiftUI

public enum TaxType: String, CaseIterable, Codable {
    case federal
    case state

    public var displayName: String {
        switch self {
        case .federal:
            return "Federal Tax"
        case .state:
            return "State Tax"
        }
    }
}

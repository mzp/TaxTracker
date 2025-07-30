//
//  PayrollCalendarTests.swift
//  TaxTrackerTests
//
//  Created by mzp on 2025/07/30.
//

import CoreTaxTracker
import Foundation
import Testing

struct PayrollCalendarTests {
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func payrollDates() async throws {
        let current = PayrollCalendar.current
        #expect(!current.payrollDates.contains(date(2025, 7, 3)))
        #expect(current.payrollDates.contains(date(2025, 7, 4)))
        #expect(current.payrollDates.contains(date(2025, 7, 18)))
    }
}

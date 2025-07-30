//
//  PayrollCalendar.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation

public final class PayrollCalendar: Sendable {
    public static let current = PayrollCalendar(year: 2025, month: 1, day: 3, interval: 14)

    private let startDate: Date
    private let endDate: Date
    private let interval: Int

    public init(year: Int, month: Int, day: Int, interval: Int) {
        let calendar = Calendar.current
        startDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        self.interval = interval
    }

    public var payrollDates: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: interval, to: currentDate) ?? currentDate
        }

        return dates
    }
}

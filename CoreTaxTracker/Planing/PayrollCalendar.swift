//
//  PayrollCalendar.swift
//  CoreTaxTracker
//
//  Created by mzp on 2025/07/30.
//

import Foundation

public final class PayrollCalendar: Sendable {
    public let startDate: Date
    private let endDate: Date
    public let interval: Int

    public init(startDate: Date, interval: Int) {
        let calendar = Calendar.current
        self.startDate = startDate

        let year = calendar.component(.year, from: startDate)
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

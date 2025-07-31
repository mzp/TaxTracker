import Foundation

public struct VestingEvent: Identifiable, Equatable, Codable {
    public var id: Date { date }
    public var date: Date
    public var shares: Int

    public init(date: Date, shares: Int) {
        self.date = date
        self.shares = shares
    }

    public static func == (lhs: VestingEvent, rhs: VestingEvent) -> Bool {
        lhs.date == rhs.date && lhs.shares == rhs.shares
    }
}

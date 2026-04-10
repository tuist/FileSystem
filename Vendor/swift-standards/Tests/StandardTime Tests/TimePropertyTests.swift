// TimePropertyTests.swift
// Time Tests
//
// Property-based tests comparing Time against Foundation across many values

import Foundation
import Testing

@testable import StandardTime

@Suite
struct `Time Property-Based Tests` {

    // MARK: - Test Data Generation

    /// Generate a range of test dates from 1970 to 2100
    static func generateTestDates() -> [(year: Int, month: Int, day: Int)] {
        var dates: [(Int, Int, Int)] = []

        // Test every month boundary in multiple years
        let testYears = [
            1970, 1971, 1980, 1990, 1999, 2000, 2001, 2004, 2010, 2020, 2023, 2024, 2025, 2030,
            2038, 2040, 2050, 2060, 2070, 2080, 2090, 2099, 2100,
        ]

        for year in testYears {
            let daysInMonths =
                Time.Calendar.Gregorian.isLeapYear(Time.Year(year))
                ? [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                : [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

            for month in 1...12 {
                // Test first day, middle day, and last day of each month
                let maxDay = daysInMonths[month - 1]
                let testDays = [1, maxDay / 2, maxDay]

                for day in testDays {
                    dates.append((year, month, day))
                }
            }
        }

        return dates
    }

    /// Generate random times throughout the day
    static func generateTestTimes() -> [(hour: Int, minute: Int, second: Int)] {
        [
            (0, 0, 0),  // Midnight
            (6, 30, 15),  // Morning
            (12, 0, 0),  // Noon
            (18, 45, 30),  // Evening
            (23, 59, 59),  // End of day
        ]
    }

    // MARK: - Epoch Conversion Property Tests

    @Test(
        "Property: Epoch conversion matches Foundation",
        arguments: generateTestDates()
    )
    func testEpochConversionPropertyVsFoundation(year: Int, month: Int, day: Int) throws {
        let time = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)

        // Get our epoch seconds
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        // Get Foundation's epoch seconds
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        guard let foundationDate = calendar.date(from: components) else {
            Issue.record("Foundation failed to create date for \(year)-\(month)-\(day)")
            return
        }

        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(
            ourSeconds == foundationSeconds,
            "Epoch mismatch for \(year)-\(month)-\(day): ours=\(ourSeconds) foundation=\(foundationSeconds)"
        )
    }

    @Test(
        "Property: Epoch round-trip matches original",
        arguments: generateTestDates()
    )
    func testEpochRoundTripProperty(year: Int, month: Int, day: Int) throws {
        let original = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)

        // Convert to epoch and back
        let epochSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: original)
        let roundTrip = Time(secondsSinceEpoch: epochSeconds)

        #expect(roundTrip.year.rawValue == original.year.rawValue)
        #expect(roundTrip.month == original.month)
        #expect(roundTrip.day == original.day)
        #expect(roundTrip.hour.value == original.hour.value)
        #expect(roundTrip.minute.value == original.minute.value)
        #expect(roundTrip.second.value == original.second.value)
    }

    // MARK: - Weekday Property Tests

    @Test(
        "Property: Weekday calculation matches Foundation",
        arguments: generateTestDates()
    )
    func testWeekdayPropertyVsFoundation(year: Int, month: Int, day: Int) throws {
        let weekday = try Time.Weekday(year: year, month: month, day: day)

        // Get Foundation's weekday
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(secondsFromGMT: 0)

        guard let foundationDate = calendar.date(from: components) else {
            Issue.record("Foundation failed to create date for \(year)-\(month)-\(day)")
            return
        }

        let foundationWeekdayValue = calendar.component(.weekday, from: foundationDate)

        // Convert Foundation weekday (1=Sunday) to our enum
        let foundationWeekday: Time.Weekday
        switch foundationWeekdayValue {
        case 1: foundationWeekday = .sunday
        case 2: foundationWeekday = .monday
        case 3: foundationWeekday = .tuesday
        case 4: foundationWeekday = .wednesday
        case 5: foundationWeekday = .thursday
        case 6: foundationWeekday = .friday
        case 7: foundationWeekday = .saturday
        default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
        }

        #expect(
            weekday == foundationWeekday,
            "Weekday mismatch for \(year)-\(month)-\(day): ours=\(weekday) foundation=\(foundationWeekday)"
        )
    }

    // MARK: - Comprehensive Date-Time Property Tests

    @Test(
        "Property: Full date-time conversion matches Foundation",
        arguments: zip(generateTestDates(), generateTestTimes()).map { ($0.0, $0.1) }
    )
    func testFullDateTimePropertyVsFoundation(
        date: (year: Int, month: Int, day: Int),
        time: (hour: Int, minute: Int, second: Int)
    ) throws {
        let ourTime = try Time(
            year: date.year,
            month: date.month,
            day: date.day,
            hour: time.hour,
            minute: time.minute,
            second: time.second
        )

        // Get our epoch seconds
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: ourTime)

        // Get Foundation's epoch seconds
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = date.year
        components.month = date.month
        components.day = date.day
        components.hour = time.hour
        components.minute = time.minute
        components.second = time.second
        components.timeZone = TimeZone(secondsFromGMT: 0)

        guard let foundationDate = calendar.date(from: components) else {
            Issue.record(
                "Foundation failed to create date for \(date.year)-\(date.month)-\(date.day) \(time.hour):\(time.minute):\(time.second)"
            )
            return
        }

        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(
            ourSeconds == foundationSeconds,
            "Epoch mismatch for \(date.year)-\(date.month)-\(date.day) \(time.hour):\(time.minute):\(time.second)"
        )

        // Also verify round-trip
        let roundTrip = Time(secondsSinceEpoch: ourSeconds)
        #expect(roundTrip.year.rawValue == date.year)
        #expect(roundTrip.month == date.month)
        #expect(roundTrip.day == date.day)
        #expect(roundTrip.hour.value == time.hour)
        #expect(roundTrip.minute.value == time.minute)
        #expect(roundTrip.second.value == time.second)
    }

    // MARK: - Days in Month Property Tests

    @Test(
        "Property: Days in month matches Foundation",
        arguments: Array(1970...2100).flatMap { year in
            (1...12).map { month in (year, month) }
        }
    )
    func testDaysInMonthPropertyVsFoundation(year: Int, month: Int) {
        let ourDays = Time.Calendar.Gregorian.daysInMonth(
            Time.Year(year),
            Time.Month(unchecked: month)
        )

        // Get Foundation's days in month
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let date = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: date)
        else {
            Issue.record("Foundation failed to get days in month for \(year)-\(month)")
            return
        }

        let foundationDays = range.count

        #expect(
            ourDays == foundationDays,
            "Days in month mismatch for \(year)-\(month): ours=\(ourDays) foundation=\(foundationDays)"
        )
    }

    // MARK: - Leap Year Property Tests

    @Test(
        "Property: Leap year matches Foundation",
        arguments: Array(1900...2400)
    )
    func testLeapYearPropertyVsFoundation(year: Int) {
        let ourResult = Time.Calendar.Gregorian.isLeapYear(Time.Year(year))

        // Foundation check - properly validate Feb 29 exists AND doesn't roll over
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = year
        components.month = 2
        components.day = 29

        // Create date and verify it's actually Feb 29 (not rolled to Mar 1)
        let foundationResult: Bool
        if let date = calendar.date(from: components) {
            let resultComponents = calendar.dateComponents([.year, .month, .day], from: date)
            foundationResult =
                resultComponents.year == year
                && resultComponents.month == 2
                && resultComponents.day == 29
        } else {
            foundationResult = false
        }

        #expect(
            ourResult == foundationResult,
            "Leap year mismatch for \(year): ours=\(ourResult) foundation=\(foundationResult)"
        )
    }

    // MARK: - Exhaustive Range Tests

    @Test
    func `Property: Every day from 2020-2024 matches Foundation`() throws {
        for year in 2020...2024 {
            let daysInMonths =
                Time.Calendar.Gregorian.isLeapYear(Time.Year(year))
                ? [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                : [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

            for month in 1...12 {
                for day in 1...daysInMonths[month - 1] {
                    let time = try Time(
                        year: year,
                        month: month,
                        day: day,
                        hour: 12,
                        minute: 0,
                        second: 0
                    )
                    let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

                    var calendar = Calendar(identifier: .gregorian)
                    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

                    var components = DateComponents()
                    components.year = year
                    components.month = month
                    components.day = day
                    components.hour = 12
                    components.minute = 0
                    components.second = 0
                    components.timeZone = TimeZone(secondsFromGMT: 0)

                    guard let foundationDate = calendar.date(from: components) else {
                        Issue.record(
                            "Foundation failed to create date for \(year)-\(month)-\(day)"
                        )
                        continue
                    }

                    let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

                    #expect(
                        ourSeconds == foundationSeconds,
                        "Mismatch on \(year)-\(month)-\(day)"
                    )

                    // Verify weekday too
                    let weekday = try Time.Weekday(year: year, month: month, day: day)
                    let foundationWeekdayValue = calendar.component(.weekday, from: foundationDate)

                    let foundationWeekday: Time.Weekday
                    switch foundationWeekdayValue {
                    case 1: foundationWeekday = .sunday
                    case 2: foundationWeekday = .monday
                    case 3: foundationWeekday = .tuesday
                    case 4: foundationWeekday = .wednesday
                    case 5: foundationWeekday = .thursday
                    case 6: foundationWeekday = .friday
                    case 7: foundationWeekday = .saturday
                    default: fatalError("Invalid weekday: \(foundationWeekdayValue)")
                    }

                    #expect(
                        weekday == foundationWeekday,
                        "Weekday mismatch on \(year)-\(month)-\(day)"
                    )
                }
            }
        }
    }
}

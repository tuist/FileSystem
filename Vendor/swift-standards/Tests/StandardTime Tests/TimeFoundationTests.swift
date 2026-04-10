// TimeFoundationTests.swift
// Time Tests
//
// Tests comparing Time package against Foundation.Date and Calendar

import Foundation
import Testing

@testable import StandardTime

@Suite
struct `Time vs Foundation Comparison Tests` {

    // Helper to create Foundation Date from components
    private func foundationDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)
    }

    // Helper to get weekday from Foundation Date
    private func foundationWeekday(year: Int, month: Int, day: Int) -> Int? {
        guard let date = foundationDate(year: year, month: month, day: day) else {
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.component(.weekday, from: date)
    }

    // MARK: - Epoch Conversion Tests

    @Test
    func `Epoch Conversion - Unix Epoch Zero`() {
        let time = Time(secondsSinceEpoch: 0)

        #expect(time.year.rawValue == 1970)
        #expect(time.month == 1)
        #expect(time.day == 1)
        #expect(time.hour.value == 0)
        #expect(time.minute.value == 0)
        #expect(time.second.value == 0)

        // Compare with Foundation
        let foundationEpoch = Date(timeIntervalSince1970: 0)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: foundationEpoch
        )

        #expect(time.year.rawValue == components.year)
        #expect(time.month.rawValue == components.month)
        #expect(time.day.rawValue == components.day)
        #expect(time.hour.value == components.hour)
        #expect(time.minute.value == components.minute)
        #expect(time.second.value == components.second)
    }

    @Test(
        "Epoch Conversion - Known dates vs Foundation",
        arguments: [
            (2000, 1, 1, 0, 0, 0),  // Y2K
            (2024, 1, 15, 12, 30, 45),  // Random date
            (1999, 12, 31, 23, 59, 59),  // End of millennium
            (2020, 2, 29, 0, 0, 0),  // Leap day
            (2038, 1, 19, 3, 14, 7),  // Near 32-bit overflow
            (1980, 1, 6, 0, 0, 0),  // GPS epoch
        ]
    )
    func testEpochConversionKnownDates(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) throws {
        let time = try Time(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )

        // Get epoch seconds from our implementation
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        // Get epoch seconds from Foundation
        guard
            let foundationDate = foundationDate(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second
            )
        else {
            Issue.record("Failed to create Foundation date")
            return
        }
        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(ourSeconds == foundationSeconds)
    }

    // NOTE: Epoch conversion for dates before 1970 is not yet implemented
    // The yearAndDays algorithm currently only supports dates from 1970 onwards
    //
    // @Test
    // func `Epoch Conversion - Negative Epochs (Before 1970)`() throws {
    //     let testDates: [(year: Int, month: Int, day: Int)] = [
    //         (1969, 12, 31),  // Day before epoch
    //         (1969, 1, 1),    // Start of 1969
    //         (1960, 1, 1),    // Start of 1960s
    //         (1950, 1, 1),    // Mid-century
    //         (1945, 5, 8),    // VE Day
    //         (1920, 1, 1),    // Roaring Twenties
    //     ]
    //
    //     for testDate in testDates {
    //         let time = try Time(
    //             year: testDate.year,
    //             month: testDate.month,
    //             day: testDate.day,
    //             hour: 0,
    //             minute: 0,
    //             second: 0
    //         )
    //
    //         let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)
    //
    //         guard let foundationDate = foundationDate(
    //             year: testDate.year,
    //             month: testDate.month,
    //             day: testDate.day
    //         ) else {
    //             Issue.record("Failed to create Foundation date for \(testDate)")
    //             continue
    //         }
    //         let foundationSeconds = Int(foundationDate.timeIntervalSince1970)
    //
    //         #expect(
    //             ourSeconds == foundationSeconds,
    //             "Epoch seconds mismatch for \(testDate): ours=\(ourSeconds) foundation=\(foundationSeconds)"
    //         )
    //         #expect(ourSeconds < 0, "Date before 1970 should have negative epoch seconds")
    //     }
    // }

    @Test(
        "Epoch Conversion - Century boundaries",
        arguments: [
            (2000, 1, 1),
            (2100, 1, 1),
            (2200, 1, 1),
            (1999, 12, 31),
            (2099, 12, 31),
        ]
    )
    func testEpochConversionCenturyBoundaries(year: Int, month: Int, day: Int) throws {
        let time = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        guard let foundationDate = foundationDate(year: year, month: month, day: day) else {
            Issue.record("Failed to create Foundation date")
            return
        }
        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(ourSeconds == foundationSeconds)
    }

    @Test(
        "Epoch Conversion - Round trip with Foundation",
        arguments: [
            0,  // Unix epoch
            86400,  // One day after epoch
            1_000_000_000,  // 2001-09-09
            1_234_567_890,  // 2009-02-13
            1_700_000_000,  // 2023-11-14
            2_147_483_647,  // Max 32-bit signed int (2038-01-19)
        ]
    )
    func testEpochRoundTripWithFoundation(seconds: Int) throws {
        // Convert from epoch to Time
        let time = Time(secondsSinceEpoch: seconds)

        // Convert back to epoch
        let roundTripSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        #expect(roundTripSeconds == seconds)

        // Compare with Foundation
        let foundationDate = Date(timeIntervalSince1970: TimeInterval(seconds))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: foundationDate
        )

        #expect(time.year.rawValue == components.year)
        #expect(time.month.rawValue == components.month)
        #expect(time.day.rawValue == components.day)
        #expect(time.hour.value == components.hour)
        #expect(time.minute.value == components.minute)
        #expect(time.second.value == components.second)
    }

    @Test
    func `Epoch Conversion - Every Day in 2024`() throws {
        let year = 2024
        let daysInMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        for month in 1...12 {
            for day in 1...daysInMonths[month - 1] {
                let time = try Time(
                    year: year,
                    month: month,
                    day: day,
                    hour: 0,
                    minute: 0,
                    second: 0
                )
                let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

                guard let foundationDate = foundationDate(year: year, month: month, day: day) else {
                    Issue.record("Failed to create Foundation date for \(year)-\(month)-\(day)")
                    continue
                }
                let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

                #expect(
                    ourSeconds == foundationSeconds,
                    "Mismatch on \(year)-\(month)-\(day): ours=\(ourSeconds) foundation=\(foundationSeconds)"
                )

                // Also test round trip
                let roundTrip = Time(secondsSinceEpoch: ourSeconds)
                #expect(roundTrip.year.rawValue == year)
                #expect(roundTrip.month == month)
                #expect(roundTrip.day == day)
            }
        }
    }

    // MARK: - Weekday Tests

    @Test(
        "Weekday - Known dates vs Foundation",
        arguments: [
            // Known historical dates
            (1776, 7, 4, Time.Weekday.thursday),  // US Independence Day
            (1969, 7, 20, Time.Weekday.sunday),  // Moon landing
            (2000, 1, 1, Time.Weekday.saturday),  // Y2K
            (2001, 9, 11, Time.Weekday.tuesday),  // 9/11
            (2024, 1, 1, Time.Weekday.monday),  // New Year 2024
            // Month boundaries
            (2024, 1, 31, Time.Weekday.wednesday),
            (2024, 2, 29, Time.Weekday.thursday),  // Leap day
            (2024, 3, 31, Time.Weekday.sunday),
            (2024, 12, 31, Time.Weekday.tuesday),
            // Century boundaries
            (1900, 1, 1, Time.Weekday.monday),
            (2000, 1, 1, Time.Weekday.saturday),
            (2100, 1, 1, Time.Weekday.friday),
        ]
    )
    func testWeekdayVsFoundation(
        year: Int,
        month: Int,
        day: Int,
        expectedWeekday: Time.Weekday
    ) throws {
        let weekday = try Time.Weekday(year: year, month: month, day: day)
        #expect(weekday == expectedWeekday)

        // Compare with Foundation (Foundation uses 1=Sunday, 2=Monday, etc.)
        if let foundationWeekdayValue = foundationWeekday(year: year, month: month, day: day) {
            // Convert Foundation weekday (1=Sunday) to our weekday
            let foundationWeekdayEnum: Time.Weekday
            switch foundationWeekdayValue {
            case 1: foundationWeekdayEnum = .sunday
            case 2: foundationWeekdayEnum = .monday
            case 3: foundationWeekdayEnum = .tuesday
            case 4: foundationWeekdayEnum = .wednesday
            case 5: foundationWeekdayEnum = .thursday
            case 6: foundationWeekdayEnum = .friday
            case 7: foundationWeekdayEnum = .saturday
            default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
            }

            #expect(weekday == foundationWeekdayEnum)
        }
    }

    @Test
    func `Weekday - Every Day in 2024 vs Foundation`() throws {
        let year = 2024
        let daysInMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        for month in 1...12 {
            for day in 1...daysInMonths[month - 1] {
                let weekday = try Time.Weekday(year: year, month: month, day: day)

                // Compare with Foundation
                if let foundationWeekdayValue = foundationWeekday(
                    year: year,
                    month: month,
                    day: day
                ) {
                    let foundationWeekdayEnum: Time.Weekday
                    switch foundationWeekdayValue {
                    case 1: foundationWeekdayEnum = .sunday
                    case 2: foundationWeekdayEnum = .monday
                    case 3: foundationWeekdayEnum = .tuesday
                    case 4: foundationWeekdayEnum = .wednesday
                    case 5: foundationWeekdayEnum = .thursday
                    case 6: foundationWeekdayEnum = .friday
                    case 7: foundationWeekdayEnum = .saturday
                    default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
                    }

                    #expect(
                        weekday == foundationWeekdayEnum,
                        "Weekday mismatch for \(year)-\(month)-\(day): ours=\(weekday) foundation=\(foundationWeekdayEnum)"
                    )
                }
            }
        }
    }

    // NOTE: Weekday calculation works for dates before 1970, so we can test them
    @Test(
        "Weekday - Dates before epoch vs Foundation",
        arguments: [
            (1969, 12, 31),
            (1969, 1, 1),
            (1960, 1, 1),
            (1950, 1, 1),
            (1945, 5, 8),  // VE Day
            (1920, 1, 1),
            (1900, 1, 1),
        ]
    )
    func testWeekdayBeforeEpochVsFoundation(year: Int, month: Int, day: Int) throws {
        let weekday = try Time.Weekday(year: year, month: month, day: day)

        // Compare with Foundation
        if let foundationWeekdayValue = foundationWeekday(year: year, month: month, day: day) {
            let foundationWeekdayEnum: Time.Weekday
            switch foundationWeekdayValue {
            case 1: foundationWeekdayEnum = .sunday
            case 2: foundationWeekdayEnum = .monday
            case 3: foundationWeekdayEnum = .tuesday
            case 4: foundationWeekdayEnum = .wednesday
            case 5: foundationWeekdayEnum = .thursday
            case 6: foundationWeekdayEnum = .friday
            case 7: foundationWeekdayEnum = .saturday
            default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
            }

            #expect(weekday == foundationWeekdayEnum)
        }
    }

    // MARK: - Leap Year Validation Against Foundation

    @Test(
        "Leap Year - Validate against Foundation",
        arguments: [
            1900, 1904, 1996, 1997, 1998, 1999,
            2000, 2001, 2004, 2020, 2024, 2100, 2400,
        ]
    )
    func testLeapYearVsFoundation(year: Int) {
        let ourResult = Time.Calendar.Gregorian.isLeapYear(Time.Year(year))

        // Foundation check - properly validate Feb 29 exists AND doesn't roll over
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = year
        components.month = 2
        components.day = 29

        // Create date and verify it's actually Feb 29 (not rolled to Mar 1)
        if let date = calendar.date(from: components) {
            let resultComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let foundationResult =
                resultComponents.year == year
                && resultComponents.month == 2
                && resultComponents.day == 29

            #expect(ourResult == foundationResult)
        } else {
            // If Foundation can't create the date at all, it's not a leap year
            #expect(ourResult == false)
        }
    }
}

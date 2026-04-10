// TimeTests.swift
// Time Tests
//
// Basic tests for Time target

import Testing

@testable import StandardTime

@Suite
struct `Time Target Tests` {

    @Test
    func `GregorianCalendar - Leap Year`() {
        // Divisible by 400
        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2000)) == true)
        // Divisible by 100, not 400
        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2100)) == false)
        // Divisible by 4, not 100
        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2024)) == true)
        // Not divisible by 4
        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2023)) == false)
    }

    @Test
    func `GregorianCalendar - Days in Month`() {
        #expect(
            Time.Calendar.Gregorian
                .daysInMonth(Time.Year(2024), Time.Month(unchecked: 2)) == 29
        )  // Leap year February
        #expect(
            Time.Calendar.Gregorian
                .daysInMonth(Time.Year(2023), Time.Month(unchecked: 2)) == 28
        )  // Non-leap February
        #expect(
            Time.Calendar.Gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 1)) == 31
        )  // January
        #expect(
            Time.Calendar.Gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 4)) == 30
        )  // April
    }

    @Test
    func `Weekday - Calculate from Date`() throws {
        // January 1, 2024 is a Monday
        let monday = try Time.Weekday(year: 2024, month: 1, day: 1)
        #expect(monday == .monday)

        // January 7, 2024 is a Sunday
        let sunday = try Time.Weekday(year: 2024, month: 1, day: 7)
        #expect(sunday == .sunday)

        // January 15, 2024 is a Monday
        let monday2 = try Time.Weekday(year: 2024, month: 1, day: 15)
        #expect(monday2 == .monday)
    }

    @Test
    func `Weekday - All Cases`() {
        let allCases = Time.Weekday.allCases
        #expect(allCases.count == 7)
        #expect(allCases.contains(.monday))
        #expect(allCases.contains(.sunday))
    }

    @Test
    func `Weekday - Known Dates`() throws {
        // July 4, 1776 was a Thursday
        let independence = try Time.Weekday(year: 1776, month: 7, day: 4)
        #expect(independence == .thursday)

        // December 31, 1999 was a Friday
        let millennium = try Time.Weekday(year: 1999, month: 12, day: 31)
        #expect(millennium == .friday)

        // January 1, 2000 was a Saturday
        let y2k = try Time.Weekday(year: 2000, month: 1, day: 1)
        #expect(y2k == .saturday)
    }

    @Test
    func `Weekday - Invalid Date Throws`() {
        // Invalid month
        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2024, month: 13, day: 1)
        }

        // Invalid day for month
        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2024, month: 2, day: 30)
        }

        // February 29 in non-leap year
        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2023, month: 2, day: 29)
        }
    }

    @Test
    func `DateComponents - Validation`() throws {
        // Valid components
        let valid = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 123,
            microsecond: 456,
            nanosecond: 789
        )
        #expect(valid.year.rawValue == 2024)
        #expect(valid.month == 1)
        #expect(valid.day == 15)
        #expect(valid.hour.value == 12)
        #expect(valid.minute.value == 30)
        #expect(valid.second.value == 45)
        #expect(valid.millisecond.value == 123)
        #expect(valid.microsecond.value == 456)
        #expect(valid.nanosecond.value == 789)

        // Test totalNanoseconds calculation
        #expect(valid.totalNanoseconds == 123_456_789)

        // Invalid month
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 13, day: 1, hour: 0, minute: 0, second: 0)
        }

        // Invalid day for month
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 2, day: 30, hour: 0, minute: 0, second: 0)
        }

        // Invalid hour
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 24, minute: 0, second: 0)
        }

        // Invalid minute
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 60, second: 0)
        }

        // Invalid second
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 61)
        }

        // Invalid millisecond
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 1000)
        }

        // Invalid microsecond
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, microsecond: 1000)
        }

        // Invalid nanosecond
        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 1000)
        }

        // Valid leap second
        let leapSecond = try Time(
            year: 2024,
            month: 1,
            day: 1,
            hour: 23,
            minute: 59,
            second: 60
        )
        #expect(leapSecond.second.value == 60)
    }

    @Test
    func `EpochConversion - Round Trip`() throws {
        // Test Unix epoch itself (transformation: Int → DateComponents)
        let epoch = Time(secondsSinceEpoch: 0)
        #expect(epoch.year.rawValue == 1970)
        #expect(epoch.month == 1)
        #expect(epoch.day == 1)
        #expect(epoch.hour.value == 0)
        #expect(epoch.minute.value == 0)
        #expect(epoch.second.value == 0)

        // Test round trip
        let components = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 0
        )

        // Transformation: DateComponents → Int
        let seconds = Time.Epoch.Conversion.secondsSinceEpoch(from: components)

        // Transformation back: Int → DateComponents
        let roundTrip = Time(secondsSinceEpoch: seconds)
        #expect(roundTrip.year.rawValue == 2024)
        #expect(roundTrip.month == 1)
        #expect(roundTrip.day == 15)
        #expect(roundTrip.hour.value == 12)
        #expect(roundTrip.minute.value == 30)
        #expect(roundTrip.second.value == 0)
    }

    @Test
    func `Calendar - First-Class Value`() {
        // Test Gregorian calendar as a first-class value
        let gregorian = Time.Calendar.gregorian

        #expect(gregorian.isLeapYear(Time.Year(2000)) == true)
        #expect(gregorian.isLeapYear(Time.Year(2024)) == true)
        #expect(gregorian.isLeapYear(Time.Year(2100)) == false)

        #expect(gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 2)) == 29)
        #expect(gregorian.daysInMonth(Time.Year(2023), Time.Month(unchecked: 2)) == 28)
        #expect(gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 1)) == 31)
    }

    @Test
    func `Epoch - First-Class Value`() {
        // Test epochs as first-class values
        let unix = Time.Epoch.unix
        let ntp = Time.Epoch.ntp
        let gps = Time.Epoch.gps

        // Verify Unix epoch reference date
        #expect(unix.referenceDate.year.rawValue == 1970)
        #expect(unix.referenceDate.month == 1)
        #expect(unix.referenceDate.day == 1)

        // Verify NTP epoch reference date
        #expect(ntp.referenceDate.year.rawValue == 1900)
        #expect(ntp.referenceDate.month == 1)
        #expect(ntp.referenceDate.day == 1)

        // Verify GPS epoch reference date
        #expect(gps.referenceDate.year.rawValue == 1980)
        #expect(gps.referenceDate.month == 1)
        #expect(gps.referenceDate.day == 6)

        // Epochs should be equatable
        #expect(unix == Time.Epoch.unix)
        #expect(unix != ntp)
        #expect(ntp != gps)
    }
}

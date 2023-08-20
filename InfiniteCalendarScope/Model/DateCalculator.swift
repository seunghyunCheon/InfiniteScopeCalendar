//
//  DateCalculator.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import Foundation

struct DateCalculator {

    // MARK: Properties - Data
    private let calendar = Calendar(identifier: .gregorian)
    private var selectedDate: Date

    // MARK: Lifecycle
    init(baseDate: Date) {
        self.selectedDate = baseDate
    }

    // MARK: Functions - Public
    func calculateNextMonth(by baseDate: Date) -> Date {

        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: baseDate) else {
            return .now
        }
        return nextMonth
    }

    func calculatePreviousMonth(by baseDate: Date) -> Date {

        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: baseDate) else {
            return .now
        }
        return previousMonth
    }

    func getMonthDays(for baseDate: Date) -> [DayComponent] {
        return generateDays(for: baseDate)
    }

    func getDaysInMonth(for baseDate: Date) -> [[DayComponent]] {

        //        guard let monthlyData = try? getMonth(for: baseDate) else {
        //            return []
        //        }
        //        let firstDayOfMonth = monthlyData.firstDay
        //
        //        let daysInThisMonth = generateDays(for: baseDate)
        //        let daysInNextMonth = generateStartOfNextMonth(using: firstDayOfMonth)
        //
        //        return daysInThisMonth + daysInNextMonth

        let monthlyData = getMonth(for: baseDate)
        let firstDayOfMonth = monthlyData.firstDay

        let daysInPreviousMonth = generateDays(for: calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!)
        let daysInThisMonth = generateDays(for: baseDate)
        let daysInNextMonth = generateDays(for: calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!)

        return [daysInPreviousMonth ,daysInThisMonth, daysInNextMonth]
    }

    func getMonth(of date: Date) -> Int {
        return calendar.component(.month, from: date)
    }

    // MARK: Functions - Private
    func getMonth(for baseDate: Date) -> MonthComponent {

        guard let numberOfDaysInMonth = calendar.range(
            of: .day, in: .month, for: baseDate)?.count,
              let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return MonthComponent(numberOfDays: 0, firstDay: .now, firstDayWeekday: 0)
        }

        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let monthlyDay = MonthComponent(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)

        return monthlyDay
    }

    private func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isIncludeInMonth: Bool) -> DayComponent {

        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        let day = DayComponent(date: date,
                               isIncludeInMonth: isIncludeInMonth)

        return day
    }

    private func generateDays(for baseDate: Date) -> [DayComponent] {

        guard let monthlyData = try? getMonth(for: baseDate) else {
            return []
        }

        let numberOfDays = monthlyData.numberOfDays
        let firstDayOfMonth = monthlyData.firstDay
        let offsetInFirstRow = monthlyData.firstDayWeekday

        let days: [DayComponent] = (1..<(numberOfDays + offsetInFirstRow)).map { day in

            let isIncludeInMonth = day >= offsetInFirstRow
            let dayOffset = isIncludeInMonth ? (day - offsetInFirstRow) : -(offsetInFirstRow - day)

            let day = generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isIncludeInMonth: isIncludeInMonth)

            return day
        }

        return days
    }

    private func generateStartOfNextMonth(using currentMonth: Date) -> [DayComponent] {

        guard let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: currentMonth) else {
            return []
        }

        let additionalDays = 7 - calendar.component(.weekday, from: lastDay)
        guard additionalDays > 0 else {
            return []
        }

        let days: [DayComponent] = (1...additionalDays).map {
            generateDay(offsetBy: $0, for: lastDay, isIncludeInMonth: false)
        }

        return days
    }
}

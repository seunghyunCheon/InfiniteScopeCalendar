//
//  DateCalculator.swift
//  InfiniteCalendarScope
//
//  Created by Brody on 2023/08/20.
//

import Foundation
import Combine

enum SomethingError: LocalizedError {
    case someError
}

class DateCalculator {

    // MARK: Properties - Data
    private let calendar = Calendar(identifier: .gregorian)
    private var selectedDate: Date
    private let coreDataService: CoreDataLottoEntityPersistenceService
    var days = CurrentValueSubject<[DayComponent], Never>([])
    var cancellables = Set<AnyCancellable>()
    // MARK: Lifecycle
    init(baseDate: Date, coreDataService: CoreDataLottoEntityPersistenceService) {
        self.selectedDate = baseDate
        self.coreDataService = coreDataService
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

//    func getMonthDays(for baseDate: Date) -> [DayComponent] {
//        return generateDays(for: baseDate)
//    }

    func fetchDaysInMonth(for baseDate: Date) {

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

        daysInPreviousMonth
            .combineLatest(daysInThisMonth, daysInNextMonth)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { pre, now, next in
                self.days.send(pre + now + next)
            })
            .store(in: &cancellables)
            
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

    private func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isIncludeInMonth: Bool) -> AnyPublisher<DayComponent, Error> {

        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        // 여기서 date를 넣으면 date에 해당하는 스피또: 10000, 로또: 10000 등의 데이터배열을 가져옴.
        return coreDataService.fetchGoalAmount(date: baseDate)
            .map { lottos in
                return DayComponent(
                    date: date,
                    isIncludeInMonth: isIncludeInMonth,
                    lottos: lottos
                )
            }
            .eraseToAnyPublisher()

    }

    private func generateDays(for baseDate: Date) -> AnyPublisher<[DayComponent], Error> {

        guard let monthlyData = try? getMonth(for: baseDate) else {
            return Fail(error: SomethingError.someError).eraseToAnyPublisher()
        }

        let numberOfDays = monthlyData.numberOfDays
        let firstDayOfMonth = monthlyData.firstDay
        let offsetInFirstRow = monthlyData.firstDayWeekday

        var days: [AnyPublisher<DayComponent, Error>] = (1..<(43)).map { day in

            let isIncludeInMonth = day >= offsetInFirstRow
            let dayOffset = isIncludeInMonth ? (day - offsetInFirstRow) : -(offsetInFirstRow - day)

            let day = generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isIncludeInMonth: isIncludeInMonth)

            return day
        }
        

        return Publishers.MergeMany(days).collect().eraseToAnyPublisher()
    }

//    private func generateStartOfNextMonth(using currentMonth: Date) -> [DayComponent] {
//
//        guard let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: currentMonth) else {
//            return []
//        }
//
//        let additionalDays = 7 - calendar.component(.weekday, from: lastDay)
//        guard additionalDays > 0 else {
//            return []
//        }
//
//        let days: [DayComponent] = (1...additionalDays).map {
//            generateDay(offsetBy: $0, for: lastDay, isIncludeInMonth: false)
//        }
//
//        return days
//    }
}

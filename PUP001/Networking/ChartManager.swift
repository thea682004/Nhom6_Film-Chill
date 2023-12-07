//
//  ChartManager.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

enum State {
    case start
    case now
    case mid
    case unowned
}

enum Option {
    case year
    case month
    case week
}

import Foundation
import UIKit

class ChartManager: NSObject {
    
    static let shared = ChartManager()
    
    private var startDate: Date?
    private var nowDate: Date = Date()
    private(set) var listYear: [Int] = []
    private(set) var listMonth: [Int] = []
    private(set) var listWeek: [Int] = []
    private(set) var listDay: [Int] = []
    private(set) var yearState: Int?
    private(set) var monthState: Int?
    private(set) var weekState: Int?
    private var listGenres: [EnumGenres] = []
    
    override init() {
        super.init()
        let firstOpenApp = UserDefaults.standard.object(forKey: "FirstOpenApp") as! Date
        self.startDate = "12-04-2016".asDate()
        self.yearState = Date().getYear()
    }
    
    func changeYearState(yearState: Int) {
        self.yearState = yearState
        self.monthState = nil
        self.weekState = nil
        self.listWeek = []
        self.listDay = []
    }
    
    func changeMonthState(monthState: Int) {
        self.monthState = monthState
        self.weekState = nil
        self.listDay = []
    }
    
    func changeWeekState(weekState: Int) {
        self.weekState = weekState
    }
    
    func filterYear() -> [Int] {
        self.listYear.removeAll()
        guard let startDate = startDate else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        for year in startYear...nowYear {
            self.listYear.append(year)
        }
        return self.listYear
    }
    
    func filterMonth() -> [Int] {
        self.listMonth.removeAll()
        guard let startDate = startDate else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        guard let yearState = yearState else {
            return []
        }
        var state: State!
        if nowYear == startYear {
            state = .unowned
        } else if yearState == nowYear {
            state = .now
        } else if yearState == startYear {
            state = .start
        } else {
            state = .mid
        }
        
        let startMonth: Int!
        let endMonth: Int!
        switch state {
        case .start:
            startMonth = startDate.getMonth()
            endMonth = 12
        case .mid:
            startMonth = 1
            endMonth = 12
        case .now:
            startMonth = 1
            endMonth = nowDate.getMonth()
        default:
            startMonth = startDate.getMonth()
            endMonth = nowDate.getMonth()
        }
        for month in startMonth...endMonth {
            self.listMonth.append(month)
        }
        return self.listMonth
    }
    
    func filterWeek() -> [Int]{
        self.listWeek.removeAll()
        guard
            let startDate = startDate,
            let monthState = monthState
        else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        let startMonth = startDate.getMonth()
        let nowMonth = nowDate.getMonth()
        
        let state: State!
        if startYear == nowYear && startMonth == nowMonth {
            state = .unowned
        } else if monthState == nowMonth && yearState == nowYear {
            state = .now
        } else if monthState == startMonth && yearState == startYear {
            state = .start
        } else {
            state = .mid
        }
        
        let startWeek: Int!
        let endWeek: Int!
        switch state {
        case .start:
            let day = startDate.getDay()
            startWeek = ((day - 1) / 7) + 1
            endWeek = ((Date.getLastDayInMonth(year: self.yearState!, month: startMonth) - 1) / 7) + 1
        case .mid:
            startWeek = 1
            endWeek = monthState == 2 ? 4 : 5
        case .now:
            startWeek = 1
            endWeek = ((nowDate.getDay() - 1) / 7) + 1
        default:
            startWeek = ((startDate.getDay() - 1) / 7) + 1
            endWeek = ((nowDate.getDay() - 1) / 7) + 1
        }
        for week in startWeek...endWeek {
            self.listWeek.append(week)
        }
        return self.listWeek
    }
    
    func filterDay() -> [Int] {
        self.listDay.removeAll()
        guard
            let startDate = startDate,
            let yearState = yearState,
            let monthState = monthState,
            let weekState = weekState
        else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        let startMonth = startDate.getMonth()
        let nowMonth = nowDate.getMonth()
        
        let startWeek = ((startDate.getDay() - 1) / 7) + 1
        let nowWeek = ((nowDate.getDay() - 1) / 7) + 1
        
        let state: State!
        if startYear == nowYear && startMonth == nowMonth && startWeek == nowWeek {
            state = .unowned
        } else if yearState == startYear, monthState == startMonth, weekState == startWeek {
            state = .start
        } else if yearState == nowYear, monthState == nowMonth, weekState == nowWeek {
            state = .now
        } else {
            state = .mid
        }
        
        let startDay: Int!
        let endDay: Int!
        switch state {
        case .start:
            startDay = startDate.getDay()
            endDay = weekState == 5 ? Date.getLastDayInMonth(year: yearState, month: monthState) : weekState * 7
        case .mid:
            startDay = (weekState - 1) * 7 + 1
            endDay = weekState == 5 ? Date.getLastDayInMonth(year: yearState, month: monthState) : weekState * 7
        case .now:
            startDay = (weekState - 1) * 7 + 1
            endDay = nowDate.getDay()
        default:
            startDay = startDate.getDay()
            endDay = nowDate.getDay()
        }
        for day in startDay...endDay {
            self.listDay.append(day)
            print(day)
        }
        return self.listDay
    }
    
    //lấy thời gian từ ngày đầu tiên của tháng tới ngày end cùng của tháng
    func getDateByMonth(_ month: Int) -> [Date] {
        guard
            let startDate = startDate,
            let yearState = yearState
        else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        let startMonth = startDate.getMonth()
        let nowMonth = nowDate.getMonth()
        
        let state: State!
        if nowYear == startYear && startMonth == nowMonth {
            state = .unowned
        } else if yearState == startYear && startMonth == month {
            state = .start
        } else if yearState == nowYear && nowMonth == month {
            state = .now
        } else {
            state = .mid
        }
        
        var result: [Date] = []
        let startDay: Int!
        let endDay: Int!
        switch state {
        case .mid:
            startDay = 1
            endDay = Date.getLastDayInMonth(year: yearState, month: month)
        case .start:
            startDay = startDate.getDay()
            endDay = Date.getLastDayInMonth(year: yearState, month: month)
        case .now:
            startDay = 1
            endDay = nowDate.getDay()
        default:
            startDay = startDate.getDay()
            endDay = nowDate.getDay()
        }
        let firstDay = "\(yearState)-\(month)-01 00:00:00".asDateTime()!
        for day in startDay...endDay {
            result.append(Date(timeInterval: TimeInterval(86400 * (day - 1)), since: firstDay))
        }
        return result
    }
    
    func getDateByWeek(_ week: Int) -> [Date] {
        guard
            let startDate = startDate,
            let yearState = yearState,
            let monthState = monthState
        else {
            return []
        }
        let startYear = startDate.getYear()
        let nowYear = nowDate.getYear()
        
        let startMonth = startDate.getMonth()
        let nowMonth = nowDate.getMonth()
        
        let startWeek = ((startDate.getDay() - 1) / 7) + 1
        let nowWeek = ((nowDate.getDay() - 1) / 7) + 1
        
        let state: State!
        if startYear == nowYear && startMonth == nowMonth && startWeek == nowWeek {
            state = .unowned
        } else if yearState == startYear && monthState == startMonth && week == startWeek {
            state = .start
        } else if yearState == nowYear && monthState == nowMonth && week == nowWeek {
            state = .now
        } else {
            state = .mid
        }
        
        var result: [Date] = []
        let startDay: Int!
        let endDay: Int!
        switch state {
        case .mid:
            startDay = ((week - 1) / 7) + 1
            endDay = week == 5 ? Date.getLastDayInMonth(year: yearState, month: monthState) : week * 7
        case .start:
            startDay = startDate.getDay()
            endDay = week == 5 ? Date.getLastDayInMonth(year: yearState, month: monthState) : week * 7
        case .now:
            startDay = ((week - 1) * 7) + 1
            endDay = nowDate.getDay()
        default:
            startDay = startDate.getDay()
            endDay = nowDate.getDay()
        }
        let firstDay = "\(yearState)-\(monthState)-01 07:30:00".asDateTime()!
        for day in startDay...endDay{
            result.append(Date(timeInterval: TimeInterval(86400 * (day - 1)), since: firstDay))
        }
        return result
    }
    
    func getDateByDay(_ day: Int) -> [Date] {
        guard let yearState = yearState, let monthState = monthState else {
            return []
        }
        
        let dateString = "\(yearState)-\(monthState)-\(day) 00:00:00"
        guard let date = dateString.asDateTime() else {
            return []
        }
        return [date]
    }
    
    
    func filterNoteBy(dates: [Date]) -> [ItemChart] {
        let allNote = getAll()
        var result: [ItemChart] = []
        for date in dates {
            let noteInDate = allNote.filter { watchedNote in
                guard let firstDate = watchedNote.date else {
                    return false
                }
                return firstDate.isToday(with: date)
            }
            result += noteInDate
        }
        return result
    }
    
    func getAll() -> [ItemChart] {
        return RealmManager.shared.getAllObjects(AddWatchListRealm.self)
            .map { item in
                let listString = Array(item.genres)
                return ItemChart(id: item.id,
                                 name: item.name,
                                 date: item.date?.asDateTime(),
                                 time: item.time, poster: item.poster,
                                 genres: listString,
                                 type: item.checkType,
                                 title: item.title,
                                 description: item.descriptionAdd)
            }
    }
    
    func getItemInYear(_ year: Int) -> [ItemChart] {
        return getAll()
            .filter { item in
                return item.date?.getYear() == year
            }
    }
    
    func getRuntime(from notes: [ItemChart]) -> Double {
        var result: Double = 0
        for note in notes {
            result += Double(note.time ?? 0)
        }
        return result / 60
    }
    
    func getTotalMovie(from notes: [ItemChart]) -> Double {
        var result: Double = 0
        result = Double(notes.count)
        return result
    }
    
    func filterByID(id: Int) -> ItemChart? {
        let result = getAll().filter { note in
            return note.id == id
        }
        return result.first
    }
    
    func getOption() -> Option {
        guard weekState == nil else {
            return .week
        }
        guard monthState == nil else {
            return .month
        }
        return .year
    }
    
    func filterGenres(dates: [Date]) -> (genreItem: [(genres: EnumGenres, count: Int)], sum: Int, totalMovie: Int) {
        let allNote = getAll()
        var notes: [ItemChart] = []
        for date in dates {
            let noteInDate = allNote.filter({ $0.date?.asString() == date.asString() })
            notes += noteInDate
        }
        
        var result: [(genres: EnumGenres, count: Int)] = []
        var sum: Int = 0
        for genres in GenresService.shared.allGenres {
            let count = notes.filter { note in
                for noteGenres in self.convertStringToGenres(note.genres) {
                    if genres == noteGenres {
                        return true
                    }
                }
                return false
            }.count
            if count >= 1 {
                sum += count
                result.append((genres, count))
            }
        }
        return (result.sorted { first, second in
            return first.count > second.count
        }, sum, notes.count)
    }
    
    private func convertStringToGenres(_ listItem: [String]) -> [EnumGenres] {
        let enumGenres = GenresService.shared.allGenres
        let result = enumGenres.filter { genres in
            for item in listItem {
                if item == genres.name {
                    return true
                }
            }
            return false
        }
        return result
    }
}

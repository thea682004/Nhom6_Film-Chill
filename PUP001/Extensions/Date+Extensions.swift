//
//  Date+Extensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import UIKit

extension Date {
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date? {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
            
            return self.addingTimeInterval(targetOffset - localOffeset)
        }
        
        return nil
    }
    
    func toStringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: self)
    }
    
    func asStringTime() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateformat.string(from: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
    
    func getStartYear() -> Int? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return year
    }
    
    func getStartMonth() -> Int {
        let calender = Calendar.current
        let month = calender.component(.month, from: self)
        return month
    }
    
    func getStartWeek() -> Int {
        let calender = Calendar.current
        let week = calender.component(.weekOfMonth, from: self)
        return week
    }
    
    func nowDayInMonth(month: Int) -> Int {
        let calender = Calendar.current
        let day = calender.component(.day, from: self)
        return day
    }
    
    func convertDate(isCalendar: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "d m y"
        let showDate = inputFormatter.date(from: isCalendar)
        inputFormatter.dateFormat = "d MMM y"
        guard let showDate = showDate else {
            return ""
        }
        let resultString = inputFormatter.string(from: showDate)
        return resultString
    }
    
    func asString() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd"
        return dateformat.string(from: self)
    }
    
    func asStringTime2() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateformat.string(from: self)
    }
    
    
    func isToday(with secondDate: Date) -> Bool {
        return self.asString() == secondDate.asString()
    }
    
    func getDay() -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.day], from: self)
        guard let day = component.day else {
            return 1
        }
        return day
    }
    
    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {
            return self
        }
        return localDate
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.month], from: self)
        guard let month = component.month else {
            return 1
        }
        return month
    }
    
    func getYear() -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year], from: self)
        guard let year = component.year else {
            return 0
        }
        return year
    }
    
    func getWeek() -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.weekday], from: self)
        guard let week = component.weekday else {
            return 0
        }
        return week
    }
    
    static func getLastDayInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 2:
            return isLeapYear(year: year) ? 29 : 28
        default:
            return 30
        }
    }
    
    static func isLeapYear(year: Int) -> Bool {
        if year % 100 == 0 {
            return year % 400 == 0
        }
        return year % 4 == 0
    }
}




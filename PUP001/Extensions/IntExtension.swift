//
//  IntExtension.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation

// Chia thời gian lấy dư
extension Int {
    func timeStringTotalTimeWatched() -> String {
        let hour = Int(self) / 60 % 60
        let minute = Int(self) % 60
        return String(format: "%2i.%02i Hour", hour, minute)
    }
    
    func timeString() -> String {
        let hour = Int(self) / 60 % 60
        let minute = Int(self) % 60
        return String(format: "%2ih %02im", hour, minute)
    }
    
    func timeStringHour() -> String {
        let hour = Int(self) / 60
        let minute = Int(self) % 60
        return String(format: "%2i Hour", hour)
    }
    
    func timeStringHourFormat() -> String {
        let hour = Int(self) / 60
        let minute = Int(self) % 60
        
        let formattedHour = String(format: "%02i", hour)
        let formattedMinute = String(format: "%02i", minute)
        
        return "\(formattedHour)h:\(formattedMinute)"
    }
    
    
    func getYearFromDate(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            return String(year)
        } else {
            return nil
        }
    }
}

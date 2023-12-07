//
//  GenresService.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation

enum EnumGenres: Int {
    case unknown
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case science_Fiction = 878
    case tv_Movie = 10770
    case thriller = 53
    case war = 10752
    case western = 37
    case action_Adventure = 10759
    case kids = 10762
    case news = 10763
    case reality = 10764
    case sci_Fi_Fantasy = 10765
    case soap = 10766
    case talk = 10767
    case war_Politics = 10768
    var name: String {
        switch self {
        case .action:
            return "Action"
        case .adventure:
            return "Adventure"
        case .animation:
            return "Animation"
        case .comedy:
            return "Comedy"
        case .crime:
            return "Crime"
        case .documentary:
            return "Documentary"
        case .drama:
            return "Drama"
        case .family:
            return "Family"
        case .fantasy:
            return "Fantasy"
        case .history:
            return "History"
        case .horror:
            return "Horror"
        case .music:
            return "Music"
        case .mystery:
            return "Mystery"
        case .romance:
            return "Romance"
        case .science_Fiction:
            return "Science Fiction"
        case .tv_Movie:
            return "TV Movie"
        case .thriller:
            return "Thriller"
        case .war:
            return "War"
        case .western:
            return "Western"
        case .action_Adventure:
            return "Action & Adventure"
        case .kids:
            return "Kids"
        case .news:
            return "News"
        case .reality:
            return "Reality"
        case .sci_Fi_Fantasy:
            return "Sci-Fi & Fantasy"
        case .soap:
            return "Soap"
        case .talk:
            return "Talk"
        case .war_Politics:
            return "War & Politics"
        case .unknown:
            return "Unknown"
        }
    }
}

class GenresService {
    
    static let shared = GenresService()
    
    private(set) var listMovieGenres: [EnumGenres] = [.action, .adventure, .animation, .comedy, .crime, .documentary, .drama, .family, .fantasy, .history, .horror, .music, .mystery, .romance, .science_Fiction, .tv_Movie, .thriller, .war, .western]
    private(set) var listTVShowGenres: [EnumGenres] = [.action_Adventure, .animation, .comedy, .crime, .documentary, .drama, .family, .kids, .mystery, .news, .reality, .sci_Fi_Fantasy, .soap, .talk, .war_Politics, .western]
    
    private (set) var allGenres: [EnumGenres] = [.action, .adventure, .animation, .comedy, .crime, .documentary, .drama, .family, .fantasy, .history, .horror, .music, .mystery, .romance, .science_Fiction, .tv_Movie, .thriller, .war, .western, .action_Adventure, .kids, .mystery, .news, .reality, .sci_Fi_Fantasy, .soap, .talk]
    
    func getGenresNameByID(id: Int) -> String {
        let genres = EnumGenres(rawValue: id) ?? .unknown
        return genres.name
    }
    
    func connectGenres(list: [Int], maxCount: Int) -> String {
        let listGenres = Array(list.prefix(maxCount))
        let stringArray = listGenres.map { id in
            return getGenresNameByID(id: id)
        }
        let result = stringArray.joined(separator: ", ")
        return result.isEmpty ? EnumGenres.unknown.name : result
    }
    
    func getString(array : [String], maxCount: Int) -> String {
        let arrayRemoveDuplicates = array.removingDuplicates()
        let array = Array(arrayRemoveDuplicates.prefix(maxCount))
        let stringArray = array.map{ String($0) }
        return stringArray.joined(separator: ", ")
    }
}

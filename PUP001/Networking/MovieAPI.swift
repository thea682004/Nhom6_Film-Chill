//
//  MovieAPI.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import Moya

enum MovieAPI {
    case topRate(page:Int)
    case popular(page:Int)
    case nowplaying(page:Int)
    case upComing(page: Int)
    case popularActor(page:Int)
    case genres
    case tvTopRate(page:Int)
    case tvAiringToday(page:Int)
    case genresTv
    case popularTv(page:Int)
    case onTv(page:Int)
    case movieDetails(id: Int)
    case tvDetails(id: Int)
    case searchMovie(query: String, page:Int)
    case searchTv(query: String, page: Int)
    case searchActor(query: String, page: Int)
    case episode(id: Int, seasonNumber: Int)
    case actorDetails(id: Int)
    case genresId(page: Int, withGenres: Int)
    case genresIdTV(page: Int, withGenres: Int)
}

extension MovieAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://api.themoviedb.org/3") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .tvTopRate:
            return "/tv/top_rated"
        case .genres:
            return "/genre/movie/list"
        case .topRate:
            return "/movie/top_rated"
        case .popular:
            return "/movie/popular"
        case .nowplaying:
            return "/movie/now_playing"
        case .upComing:
            return "/movie/upcoming"
        case .popularActor:
            return "/person/popular"
        case .tvAiringToday:
            return "tv/airing_today"
        case .genresTv:
            return "/genre/tv/list"
        case .popularTv:
            return "/tv/popular"
        case .onTv:
            return "/tv/on_the_air"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .tvDetails(let id):
            return "/tv/\(id)"
        case .searchMovie:
            return "/search/movie"
        case .searchTv:
            return "/search/tv"
        case .searchActor:
            return "/search/person"
        case .episode(let id, let seasonNumber):
            return "/tv/\(id)/season/\(seasonNumber)"
        case .actorDetails(let id):
            return "/person/\(id)"
        case .genresId:
            return "/discover/movie"
        case .genresIdTV:
            return "/discover/tv"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .genres, .genresTv, .episode:
            return .requestParameters(parameters: ["api_key":  NetworkManager.shared.MovieAPIKey], encoding: URLEncoding.queryString)
            
        case .popular(let page), .nowplaying(let page), .upComing(let page), .topRate(let page), .popularActor(page: let page), .tvTopRate(page: let page), .tvAiringToday(page: let page), .popularTv(page: let page), .onTv(page: let page):
            return .requestParameters(parameters: ["page":page, "api_key": NetworkManager.shared.MovieAPIKey], encoding: URLEncoding.queryString)
            
        case .movieDetails:
            return .requestParameters(parameters: ["api_key": NetworkManager.shared.MovieAPIKey, "append_to_response" : "videos,credits,recommendations,reviews"], encoding: URLEncoding.queryString)
            
        case .tvDetails:
            return .requestParameters(parameters: ["api_key": NetworkManager.shared.MovieAPIKey, "append_to_response" : "videos,credits,recommendations,images"], encoding: URLEncoding.queryString)
            
        case .searchMovie(let query, let page), .searchTv(query: let query, page: let page), .searchActor(let query, let page):
            return .requestParameters(parameters: ["api_key": NetworkManager.shared.MovieAPIKey, "query": query,
                                                   "page": page], encoding: URLEncoding.queryString)
        case .actorDetails:
            return .requestParameters(parameters: ["api_key": NetworkManager.shared.MovieAPIKey, "append_to_response" : "movie_credits,images,tv_credits"], encoding: URLEncoding.queryString)
            
        case .genresId(let page, let withGenres), .genresIdTV(let page, let withGenres):
            return .requestParameters(parameters: ["api_key": NetworkManager.shared.MovieAPIKey, "with_genres": withGenres, "page": page], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

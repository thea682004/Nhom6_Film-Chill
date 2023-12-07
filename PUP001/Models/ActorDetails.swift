//
//  ActorDetails.swift
//  PUP001
//
//  Created by chuottp on 09/06/2023.
//

import Foundation

struct ItemActorDetails: Codable {
    let id: Int?
    let also_known_as: [String]?
    let biography: String?
    let known_for_department: String?
    let name: String?
    let profile_path: String?
    let movie_credits: MovieCredit?
    let images: Image?
    let tv_credits: TVCredit?
}

struct Image: Codable {
    let profiles: [Profile]?
}

struct Profile: Codable {
    let file_path: String?
}

struct TVCredit: Codable {
    let cast: [CastTV]?
    let crew: [CrewTV]?
}

struct CastTV: Codable {
    let id: Int?
    let overview: String?
    let popularity: Double?
    let poster_path: String?
    let name: String?
    let credit_id: String?
    let episode_count: Int?
    let first_air_date: String?
}

struct CrewTV: Codable {
    let id: Int?
    let overview: String?
    let popularity: Double?
    let poster_path: String?
    let first_air_date: String?
    let name: String?
    let credit_id: String?
    let department: String?
    let episode_count: Int?
    let job: String?
}

struct MovieCredit: Codable {
    let cast: [CastMovie]?
    let crew: [CrewMovie]?
}

struct CastMovie: Codable {
    let id: Int?
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let title: String?
    let character: String?
    let credit_id: String?
}

struct CrewMovie: Codable {
    let id: Int?
    let overview: String?
    let poster_path: String?
    let title: String?
    let vote_average: Double?
    let vote_count: Int?
    let credit_id: String?
    let department: String?
    let job: String?
}


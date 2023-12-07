//
//  Enums.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import Foundation

enum  SectionType: Int, CaseIterable {
    case HeaderSection
    case PopularMoviesSection
    case GenresSection
    case NativeAd
    case PopularActorsSection
    case UpcomingMovieSection
    case RecommendSection
    case NowPlayingSection
}

enum  SectionTVType: Int, CaseIterable {
    case HeaderTVSection
    case PopularMoviesTVSection
    case GenresTVSection
    case NativeAd
    case PopularActorsTVSection
    case UpcomingTVSection
    case RecommendTVSection
    case NowPlayingTVSection
}

enum checkDataMovieOrTV {
    case movie
    case tvShow
}

enum SectionDetailsType: Int, CaseIterable {
    case HeaderDetailsSection = 0
    case OverriewTrailerSection = 1
    case StorySection = 2
    case TrailerSection = 3
    case PopularActorsDetailsSection = 4
    case RecommendDetailsSection = 5
}

enum SectionDetailsTVType: Int, CaseIterable {
    case HeaderDetailTVSection = 0
    case OverriewTrailerTVSection = 1
    case StoryTVSection = 2
    case TrailerTVSection = 3
    case SeasonTVSection = 4
    case PopularActorsDetailsTVSection = 5
    case RecommendDetailsTVSection = 6
}

enum AllCheckType: Int, CaseIterable {
    case PopularMovies
    case Genres
    case PopularActor
    case Upcoming
    case Recommend
    case NowPlaying
    case PopularMoviesTV
    case GenresTV
    case PopularActorTV
    case UpcomingTV
    case RecommendTV
    case NowPlayingTV
    case listGenresMovie
    case listGenresTv
}

enum ActorDetailsType: Int, CaseIterable {
    case Header
    case CastCrew
}

enum checkTypeFavorite: Int, CaseIterable {
    case noData
    case haveData
}

enum checkTypeTracking: Int, CaseIterable {
    case noWatchlist
    case timeRange
    case activityGenres
    case total
    case itemMovie
}

enum checkTypeSetting: Int, CaseIterable {
    case privacy
    case share
    case rating
    case feedback
}

enum checkTypeAddWatchlist: Int, CaseIterable {
    case trending
    case resultSearch
}

enum checkTypeAddWatchlistVC: Int, CaseIterable {
    case bannerAdd
    case addNote
}



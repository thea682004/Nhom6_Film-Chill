//
//  NetworkManager.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import Moya

protocol Networkable {
    associatedtype T: TargetType
    var provider: MoyaProvider<T> { get }
    func getDataMovie(endPoint: MovieAPI, completion: @escaping (([ItemMovies]?, Error?)->()))
    func getDataActor(endPoint: MovieAPI, completion: @escaping (([ItemActors]?, Error?) ->()))
    func getDataGenre(endPoint: MovieAPI, completion: @escaping (([Genre]?, Error?) ->()))
    func getDataMovieDetails(endPoint: MovieAPI, completion: @escaping ((ItemMoviesDetail?, Error?) ->()))
    func getDataSearchMovie(endPoint: MovieAPI, completion: @escaping (([ItemSearchMovie]?, Error?) -> ()))
    func getDataSearchTV(endPoint: MovieAPI, completion: @escaping (([ItemSearchTV]?, Error?) -> ()))
    func getDataSearchActor(endPoint: MovieAPI, completion: @escaping (([ItemSearchActor]?, Error?) -> ()))
    func getDataTV(endPoint: MovieAPI, completion: @escaping
                   (([ItemTVShow]?, Error?)->()))
    func getDataTVDetails(endPoint: MovieAPI, completion: @escaping ((ItemTVShowDetails?, Error?) -> ()))
    func getDataEpisode(endPoint: MovieAPI, completion: @escaping
                        (([ItemEpisode]?, Error?) -> ()))
    func getDataActorDetails(endPoint: MovieAPI, completion: @escaping
                             ((ItemActorDetails?, Error?) -> ()))
    func getDataGenresID(endPoint: MovieAPI, completion: @escaping
                         (([ItemGenresID]?, Error?) -> ()))
    func getDataGenresIDTV(endPoint: MovieAPI, completion: @escaping
                           (([ItemGenresIDTV]?, Error?) -> ()))
}

struct NetworkManager: Networkable {
    
    static let shared = NetworkManager()
    
    let MovieAPIKey = "dc9e9a73378330417bb4818abf1b60ed"
    let provider = MoyaProvider<MovieAPI>()
    
    func getDataMovie(endPoint: MovieAPI, completion: @escaping ([ItemMovies]?, Error?)->()){
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(MovieResponse.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataActor(endPoint: MovieAPI, completion: @escaping (([ItemActors]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(ActorResponse.self, from: response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataGenre(endPoint: MovieAPI, completion: @escaping (([Genre]?, Error?) -> ())) {
        
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(GenresResponse.self, from: response.data)
                    completion(results.genres, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataTV(endPoint: MovieAPI, completion: @escaping (([ItemTVShow]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(TVShowResponse.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataMovieDetails(endPoint: MovieAPI, completion: @escaping ((ItemMoviesDetail?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                print(response.data)
                do {
                    let results = try JSONDecoder().decode(ItemMoviesDetail.self, from: response.data)
                    print(response.data)
                    completion(results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataTVDetails(endPoint: MovieAPI, completion: @escaping ((ItemTVShowDetails?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                print(response.data)
                do {
                    let results = try JSONDecoder().decode(ItemTVShowDetails.self, from: response.data)
                    print(response.data)
                    completion(results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataActorDetails(endPoint: MovieAPI, completion: @escaping ((ItemActorDetails?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                print(response.data)
                do {
                    let results = try JSONDecoder().decode(ItemActorDetails.self, from: response.data)
                    print(response.data)
                    completion(results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataSearchMovie(endPoint: MovieAPI, completion: @escaping (([ItemSearchMovie]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(ResponseSearchMovie.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataSearchTV(endPoint: MovieAPI, completion: @escaping (([ItemSearchTV]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(ResponseSearchTV.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataSearchActor(endPoint: MovieAPI, completion: @escaping (([ItemSearchActor]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(ResponseSearchActor.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataEpisode(endPoint: MovieAPI, completion: @escaping (([ItemEpisode]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                print(response.data)
                do {
                    let results = try JSONDecoder().decode(ResponseEpisode.self, from: response.data)
                    print(response.data)
                    completion(results.episodes, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataGenresID(endPoint: MovieAPI, completion: @escaping (([ItemGenresID]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(GenresIDResponse.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func getDataGenresIDTV(endPoint: MovieAPI, completion: @escaping (([ItemGenresIDTV]?, Error?) -> ())) {
        provider.request(endPoint) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(GenresIDTVResponse.self, from: response.data)
                    print(response.data)
                    completion(results.results, nil)
                } catch let err {
                    print(err)
                    completion(nil, err)
                }
            case let .failure(error):
                print(error)
                completion(nil, error)
            }
        }
    }
}

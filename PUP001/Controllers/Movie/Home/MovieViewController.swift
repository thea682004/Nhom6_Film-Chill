//
//  MovieViewController.swift
//  PUP001
//
//  Created by chuottp on 25/04/2023.
//

import UIKit

protocol MovieViewDelegate: AnyObject {
    
    func clickPushDetail(id: Int)
    func clickPushNowplaying(_ type: AllCheckType)
    func clickPushDetailActor(id: Int)
    func clickPushShowAllGenres(id: Int, name: String)
}

class MovieViewController: BaseVC {
    
    private var listItemNowPlaying: [ItemMovies] = []
    private var listItemPopular: [ItemMovies] = []
    private var listItemUpComing: [ItemMovies] = []
    private var listItemTopRate: [ItemMovies] = []
    private var listItemGenres: [Genre] = []
    private var listItemPopularActor: [ItemActors] = []
    private var listItemGenresID: [ItemGenresID] = []
    var genresId: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(UINib(nibName: HeaderSection.className, bundle: nil), forCellWithReuseIdentifier: HeaderSection.className)
            collectionView.register(UINib(nibName: PopularMoviesSection.className, bundle: nil), forCellWithReuseIdentifier: PopularMoviesSection.className)
            collectionView.register(UINib(nibName: NowPlayingSection.className, bundle: nil), forCellWithReuseIdentifier: NowPlayingSection.className)
            collectionView.register(UINib(nibName: UpcomingMovieSection.className, bundle: nil), forCellWithReuseIdentifier: UpcomingMovieSection.className)
            collectionView.register(UINib(nibName: RecommendSection.className,bundle: nil), forCellWithReuseIdentifier: RecommendSection.className)
            collectionView.register(UINib(nibName: PopularActorsSection.className, bundle: nil), forCellWithReuseIdentifier: PopularActorsSection.className)
            collectionView.register(UINib(nibName: GenresSection.className, bundle: nil), forCellWithReuseIdentifier: GenresSection.className)
            collectionView.register(UINib(nibName: AdNativeShowBelowGenres.className, bundle: nil), forCellWithReuseIdentifier: AdNativeShowBelowGenres.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        InternetManager.shared.startMonitoring()
        if InternetManager.shared.isConnected {
            print("no internet")
        } else {
            self.getData()
            print("have internet")
        }
        self.remoteViewLoading()
    }
    
    deinit {
        InternetManager.shared.stopMonitoring()
    }
    
    func getIdGenres(id: Int) {
        self.genresId = id
    }
    
    func getData() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataMovie(endPoint: .nowplaying(page: 1)) { [weak self] respone, error  in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let self = self else { return }
            guard let respone = respone else { return }
            self.listItemNowPlaying = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataMovie(endPoint: .popular(page: 1)) { [weak self] respone, error in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let self = self else { return }
            guard let respone = respone else { return }
            self.listItemPopular = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataMovie(endPoint: .upComing(page: 1)) { [weak self] respone, error  in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let respone = respone else { return }
            self?.listItemUpComing = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataMovie(endPoint: .topRate(page: 1)) { [weak self] respone, error  in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else { return }
            self?.listItemTopRate = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataActor(endPoint: .popularActor(page: 1)) { [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else {
                return
            }
            self?.listItemPopularActor = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataGenre(endPoint: .genres){ [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else { return }
            self?.listItemGenres = respone
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataGenresID(endPoint: .genresId(page: 1, withGenres: self.genresId)) { [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let respone = respone else {return}
            self?.listItemGenresID = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.remoteViewLoading()
        }
    }
}

extension MovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SectionType.allCases[section] {
        case .NativeAd:
            return Global.shared.isStateShowAds == true ? 1 : 0
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch SectionType.allCases[indexPath.section] {
        case .GenresSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresSection.className, for: indexPath) as! GenresSection
            cell.configData(self.listItemGenres)
            cell.delegate = self
            return cell
            
        case .RecommendSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendSection.className, for: indexPath) as! RecommendSection
            cell.configData(self.listItemTopRate)
            cell.delegate = self
            return cell
            
        case .UpcomingMovieSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpcomingMovieSection.className, for: indexPath) as! UpcomingMovieSection
            cell.configData(self.listItemUpComing)
            cell.delegate = self
            return cell
            
        case .PopularActorsSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularActorsSection.className, for: indexPath) as! PopularActorsSection
            cell.configData(self.listItemPopularActor)
            cell.delegate = self
            return cell
            
        case .HeaderSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderSection.className, for: indexPath) as! HeaderSection
            cell.setText(check: .movie)
            return cell
        case .PopularMoviesSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMoviesSection.className, for: indexPath) as! PopularMoviesSection
            cell.configure(listItems: self.listItemPopular)
            cell.delegate = self
            return cell
        case .NowPlayingSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingSection.className, for: indexPath) as! NowPlayingSection
            cell.configData(self.listItemNowPlaying)
            cell.delegate = self
            return cell
        case .NativeAd:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdNativeShowBelowGenres.className, for: indexPath) as! AdNativeShowBelowGenres
            cell.setUpAdNative()
            return cell
        }
    }
}

extension MovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        switch SectionType.allCases[indexPath.section] {
            
        case .HeaderSection:
            return CGSize(width: cellWidth, height: 115)
            
        case .PopularMoviesSection:
            let heightCell = (cellWidth - 16) * 2 / 3
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: cellWidth - 16 , height: heightCell + 120)
            }
            return CGSize(width: cellWidth - 16 , height: heightCell + 70)
            
        case .GenresSection:
            return CGSize(width: cellWidth - 16, height: 105)
            
        case .RecommendSection:
            return CGSize(width: cellWidth - 16, height: 270)
            
        case .PopularActorsSection:
            return CGSize(width: cellWidth - 16, height: 142)
            
        case .UpcomingMovieSection:
            return CGSize(width: cellWidth - 16 , height: 240)
            
        case .NowPlayingSection:
            return CGSize(width: cellWidth - 16, height: 320)
        case .NativeAd:
            return CGSize(width: cellWidth - (16 + 32) , height: 134)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch SectionType.allCases[section] {
            
        case .HeaderSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
            
        case .PopularMoviesSection:
            return UIEdgeInsets(top: 24, left: 32, bottom: 0, right: 0)
            
        case .GenresSection, .UpcomingMovieSection, .RecommendSection, .NowPlayingSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
            
        case .PopularActorsSection:
            return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        case .NativeAd:
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
    }
}

extension MovieViewController: MovieViewDelegate {
    func clickPushShowAllGenres(id: Int, name: String) {
        let showAllGenres = NowPlayingVC()
        showAllGenres.getIdGenres(id: id, name: name)
        showAllGenres.setType(.listGenresMovie)
        self.navigationController?.pushViewController(showAllGenres, animated: true)
    }
    
    func clickPushDetailActor(id: Int) {
        let actorDetailsVC = ActorDetailsVC()
        actorDetailsVC.getIdActor(id: id)
        self.navigationController?.pushViewController(actorDetailsVC, animated: true)
    }
    
    func clickPushNowplaying(_ type: AllCheckType) {
        let nowPlayingVC = NowPlayingVC()
        nowPlayingVC.setType(type)
        self.navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func clickPushDetail(id: Int) {
        let vc = MovieDetailVC()
        vc.getIdMovie(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  TVShowViewController.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit

protocol TVShowViewDelegate: AnyObject {
    
    func clickPushTVDetail(id: Int)
    func clickPushNowplayingTV(_ type: AllCheckType)
    func clickPushDetailActorTV(id: Int)
    func clickShowAllGenresTv(id: Int, name: String)
    
}

class TVShowViewController: BaseVC {
    
    weak var delegate: TVShowViewDelegate?
    private var listItemTopRateTV: [ItemTVShow] = []
    private var listItemPopularActorsTV: [ItemActors] = []
    private var listItemAiringTodayTV: [ItemTVShow] = []
    private var listItemGenresTV: [Genre] = []
    private var listItemPopularTV: [ItemTVShow] = []
    private var listItemOnTV: [ItemTVShow] = []
    
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
        InternetManager.shared.startMonitoring()
        if InternetManager.shared.isConnected {
            print("no internet")
        } else {
            self.getDataTV()
            print("have internet")
        }
        self.remoteViewLoading()
    }
    deinit {
        // Ngừng giám sát trạng thái kết nối mạng
        InternetManager.shared.stopMonitoring()
    }
    
    func getDataTV() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataTV(endPoint: .tvTopRate(page: 1)) { [weak self] respone, error  in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let self = self else { return }
            guard let respone = respone else { return }
            self.listItemTopRateTV = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataActor(endPoint: .popularActor(page: 1)) { [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else { return }
            self?.listItemPopularActorsTV = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataTV(endPoint: .tvAiringToday(page: 1)) { [weak self] respone, error  in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let self = self else { return }
            guard let respone = respone else { return }
            self.listItemAiringTodayTV = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getDataGenre(endPoint: .genresTv){ [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else { return }
            self?.listItemGenresTV = respone
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataTV(endPoint: .popularTv(page: 1)) { [weak self] respone, error in
            
            if error != nil {
                dispatchGroup.leave()
                return
            }
            
            guard let respone = respone else { return }
            self?.listItemPopularTV = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        NetworkManager.shared.getDataTV(endPoint: .onTv(page: 1)) { [weak self] respone, error in
            if error != nil {
                dispatchGroup.leave()
                return
            }
            guard let respone = respone else { return }
            self?.listItemOnTV = respone
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
        
    }
}

extension TVShowViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        switch SectionTVType.allCases[indexPath.section] {
            
        case .HeaderTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderSection.className, for: indexPath) as! HeaderSection
            cell.setText(check: .tv)
            return cell
            
        case .PopularMoviesTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMoviesSection.className, for: indexPath) as! PopularMoviesSection
            cell.configureTv(listItems: self.listItemPopularTV)
            cell.delegateTV = self
            return cell
            
        case .GenresTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresSection.className, for: indexPath) as! GenresSection
            cell.configDataTv(self.listItemGenresTV)
            cell.delegateTV = self
            return cell
            
        case .PopularActorsTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularActorsSection.className, for: indexPath) as! PopularActorsSection
            cell.configData(self.listItemPopularActorsTV, checkTypeData: .tvShow)
            cell.delegateTV = self
            return cell
            
        case .UpcomingTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpcomingMovieSection.className, for: indexPath) as! UpcomingMovieSection
            cell.configDataTv(self.listItemOnTV)
            cell.delegateTV = self
            return cell
            
        case .RecommendTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendSection.className, for: indexPath) as! RecommendSection
            cell.configDataTv(self.listItemTopRateTV)
            cell.setTextRecommend(check: .home)
            cell.delegateTV = self
            return cell
            
        case .NowPlayingTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingSection.className, for: indexPath) as! NowPlayingSection
            cell.configDataTv(self.listItemAiringTodayTV)
            cell.delegateTV = self
            return cell
        case .NativeAd:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdNativeShowBelowGenres.className, for: indexPath) as! AdNativeShowBelowGenres
            cell.setUpAdNative()
            return cell
        }
    }
}

extension TVShowViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        switch SectionTVType.allCases[indexPath.section] {
            
        case .HeaderTVSection:
            return CGSize(width: cellWidth, height: 115)
        case .PopularMoviesTVSection:
            let heightCell = (cellWidth - 16) * 2 / 3
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: cellWidth - 16 , height: heightCell + 120)
            }
            return CGSize(width: cellWidth - 16 , height: heightCell + 70)
        case .GenresTVSection:
            return CGSize(width: cellWidth - 16, height: 105)
        case .PopularActorsTVSection:
            return CGSize(width: cellWidth - 16, height: 142)
        case .UpcomingTVSection:
            return CGSize(width: cellWidth - 16 , height: 240)
        case .RecommendTVSection:
            return CGSize(width: cellWidth - 16, height: 270)
        case .NowPlayingTVSection:
            return CGSize(width: cellWidth - 16, height: 320)
        case .NativeAd:
            return CGSize(width: cellWidth - (16 + 32), height: 134)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch SectionTVType.allCases[section] {
            
        case .HeaderTVSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        case .PopularMoviesTVSection:
            return UIEdgeInsets(top: 24, left: 32, bottom: 0, right: 0)
        case .GenresTVSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        case .PopularActorsTVSection:
            return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        case .UpcomingTVSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        case .RecommendTVSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        case .NowPlayingTVSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 16, right: 0)
        case .NativeAd:
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
    }
    
}

extension TVShowViewController: TVShowViewDelegate {
    func clickShowAllGenresTv(id: Int, name: String) {
        let showAllGenresTV = NowPlayingVC()
        showAllGenresTV.getIdGenres(id: id, name: name)
        showAllGenresTV.setType(.listGenresTv)
        self.navigationController?.pushViewController(showAllGenresTV, animated: true)
    }
    
    func clickPushDetailActorTV(id: Int) {
        let actorDetailsVC = ActorDetailsVC()
        actorDetailsVC.getIdActor(id: id)
        self.navigationController?.pushViewController(actorDetailsVC, animated: true)
    }
    
    func clickPushNowplayingTV(_ type: AllCheckType) {
        let nowPlayingVC = NowPlayingVC()
        nowPlayingVC.setType(type)
        self.navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func clickPushTVDetail(id: Int) {
        let vc = TVShowDetailVC()
        vc.getIdTVDetail(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


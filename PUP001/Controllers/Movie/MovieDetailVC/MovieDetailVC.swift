//
//  MovieDetailVC.swift
//  PUP001
//
//  Created by chuottp on 10/05/2023.
//

import UIKit
import RealmSwift
import AdMobManager

protocol MovieDetailProtocol: AnyObject {
    func tapSeemore(state: Bool)
    func changeSection(_ check: TapType)
    func clickPushShowAll(_ type: AllCheckType)
    func clickPushDetail(id: Int)
    func clickPushDetailActor(id: Int)
}

class MovieDetailVC: BaseVC {
    
    private var itemMovieDetail: ItemMoviesDetail?
    private var listItem: [ItemMovies] = []
    private var stateSeemore: Bool = true
    private var checkType: TapType = .overview
    
    var id: Int = 0
    var idActor: Int = 0
    
    @IBOutlet weak var btnAddWatchlist: UIButton! {
        didSet {
            btnAddWatchlist.layer.cornerRadius = 10
            btnAddWatchlist.isSelected = false
        }
    }
    
    @IBOutlet weak var btnFavorite: UIButton! {
        didSet {
            btnFavorite.isSelected = false
        }
    }
    
    @IBAction func btnAddWatchlist(_ sender: Any) {
        self.actionAddOrDeleteWatchlist(value: self.btnAddWatchlist.isSelected)
        if !self.btnAddWatchlist.isSelected {
            let vc = AddWatchlistVC()
            guard let item = itemMovieDetail else {
                return
            }
            vc.configDataMovie(item: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.btnAddWatchlist.isSelected.toggle()
    }
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var collectionView:
    UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: HeaderDetailSection.className, bundle: nil), forCellWithReuseIdentifier: HeaderDetailSection.className)
            collectionView.register(UINib(nibName: OverviewTrailerSection.className, bundle: nil), forCellWithReuseIdentifier: OverviewTrailerSection.className)
            collectionView.register(UINib(nibName: StorySection.className, bundle: nil), forCellWithReuseIdentifier: StorySection.className)
            collectionView.register(UINib(nibName: TrailerSection.className, bundle: nil), forCellWithReuseIdentifier: TrailerSection.className)
            collectionView.register(UINib(nibName: PopularActorsSection.className, bundle: nil), forCellWithReuseIdentifier: PopularActorsSection.className)
            collectionView.register(UINib(nibName: RecommendSection.className, bundle: nil), forCellWithReuseIdentifier: RecommendSection.className)
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var bannerAdView: BannerAdMobView!
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var heightAdBanner: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.showAdsInter()
        }
        self.getData()
        self.setUpBannerAd()
        self.checkMovieRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkAddWatchlistRealm()
    }
    
    private func setUpBannerAd() {
        if Global.shared.isStateShowAds == true {
            self.bannerAdView.register(id: AppText.keyAds.banner)
            self.heightAdBanner.constant = BannerAdMobView.adHeightMinimum()
            self.bannerAdView.isHidden = false
        } else {
            self.heightAdBanner.constant = 0
            self.bannerAdView.isHidden = true
        }
    }
    
    private func showAdsInter() {
        if Global.shared.isStateShowAds == true {
            if Global.shared.countShowAds % 2 == 0 {
                AdMobManager.shared.show(key: AppText.nameAds.splashInter)
            }
            Global.shared.countShowAds += 1
        }
    }
    
    func getIdMovie(id: Int) {
        self.id = id
    }
    
    func getData() {
        NetworkManager.shared.getDataMovieDetails(endPoint: .movieDetails(id: self.id)) { [weak self] result, _ in
            guard let self = self else { return }
            self.itemMovieDetail = result
            self.collectionView.reloadData()
            self.remoteViewLoading()
        }
    }
    
    
    @IBAction func btnAddFavorite(_ sender: Any) {
        self.btnFavorite.setImage(self.btnFavorite.isSelected ? UIImage(named: "HeartClick") : UIImage(named: "ic_didFavorite"), for: .normal)
        self.actionAddOrDelete(value: self.btnFavorite.isSelected)
        self.btnFavorite.isSelected.toggle()
    }
    
    
    func actionAddOrDelete(value: Bool) {
        switch value {
        case true:
            self.deleteRealm()
        case false:
            self.addMovieRealm()
        }
    }
    
    func actionAddOrDeleteWatchlist(value: Bool) {
        switch value {
        case true:
            self.btnAddWatchlist.setImage(UIImage(named: "ic_addWatchlist"), for: .normal)
            self.deleteWatlistRealm()
        case false:
            break
        }
    }
    
    func addMovieRealm() {
        guard let itemMovieDetail = self.itemMovieDetail,
              let id = itemMovieDetail.id
        else  { return }
        let item = MovieRealm(id: id,
                              image: itemMovieDetail.posterPath,
                              name: itemMovieDetail.title)
        RealmManager.shared.create(object: item)
    }
    
    
    func checkMovieRealm() {
        guard let _ = RealmManager.shared.getById(ofType: MovieRealm.self, id: self.id)
        else  {
            self.btnFavorite.setImage(UIImage(named: "HeartClick"), for: .normal)
            self.btnFavorite.isSelected = false
            return
        }
        self.btnFavorite.setImage(UIImage(named: "ic_didFavorite"), for: .normal)
        self.btnFavorite.isSelected = true
    }
    
    func checkAddWatchlistRealm() {
        guard let _ = RealmManager.shared.getById(ofType: AddWatchListRealm.self, id: self.id)
        else {
            self.btnAddWatchlist.setImage(UIImage(named: "ic_addWatchlist"), for: .normal)
            self.btnAddWatchlist.isSelected = false
            return
        }
        self.btnAddWatchlist.setImage(UIImage(named: "ic_haveBeenAddWatchlist"), for: .normal)
        self.btnAddWatchlist.isSelected = true
    }
    
    func deleteRealm() {
        guard let itemMovieDetail = self.itemMovieDetail,
              let id = itemMovieDetail.id ,
              let item = RealmManager.shared.getById(ofType: MovieRealm.self, id: id)
        else  { return }
        RealmManager.shared.delete(object: item)
    }
    
    func deleteWatlistRealm() {
        guard let itemMovieDetail = self.itemMovieDetail,
              let id = itemMovieDetail.id,
              let item = RealmManager.shared.getById(ofType: AddWatchListRealm.self, id: id)
        else {return}
        RealmManager.shared.delete(object: item)
        
    }
}

extension MovieDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionDetailsType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SectionDetailsType.allCases[section] {
            
        case .HeaderDetailsSection:
            return 1
        case .OverriewTrailerSection:
            return 1
        case .StorySection:
            switch checkType {
                
            case .overview:
                return itemMovieDetail?.overview == nil ? 0 : 1
            case .trailer:
                return 0
            case .season:
                return 0
            }
        case .TrailerSection:
            switch checkType {
            case .overview:
                return 0
            case .trailer:
                return itemMovieDetail?.videos.results.first?.key == nil ? 0 : 1
            case .season:
                return 0
            }
        case .PopularActorsDetailsSection:
            return itemMovieDetail?.credits.cast.count == 0 ? 0 : 1
        case .RecommendDetailsSection:
            return itemMovieDetail?.recommendations?.results.count == 0 ? 0 : 1
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch SectionDetailsType.allCases[indexPath.section] {
            
        case .HeaderDetailsSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderDetailSection.className, for: indexPath) as! HeaderDetailSection
            cell.playVideo = { [weak self] keyYT in
                guard let self = self else { return }
                let view = PlayTrailerView()
                view.frame = self.view.frame
                view.loadView(key: keyYT)
                //set màu alpha, độ mờ
                view.backgroundColor = .black.withAlphaComponent(1.0)
                self.view.addSubview(view)
            }
            cell.configData(item: itemMovieDetail)
            return cell
        case .OverriewTrailerSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewTrailerSection.className, for: indexPath) as! OverviewTrailerSection
            cell.setIsHiden()
            cell.delegateMovie = self
            return cell
        case .StorySection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StorySection.className, for: indexPath) as! StorySection
            if let item = self.itemMovieDetail {
                cell.configSeemoreMovie(item: item, stateSeemore: self.stateSeemore)
            }
            cell.delegate = self
            return cell
        case .TrailerSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailerSection.className, for: indexPath) as! TrailerSection
            
            cell.configureTrailer(key: itemMovieDetail?.videos.results.first?.key ?? "")
            cell.playVideoYTB = { [weak self] keyYTB in
                guard let self = self else { return }
                let view = PlayTrailerView()
                view.frame = self.view.frame
                view.loadView(key: keyYTB)
                //set màu alpha, độ mờ
                view.backgroundColor = .black.withAlphaComponent(1.0)
                self.view.addSubview(view)
            }
            return cell
        case .PopularActorsDetailsSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularActorsSection.className, for: indexPath) as! PopularActorsSection
            cell.configData(self.itemMovieDetail?.credits.cast ?? [], checkTypeData: .detailMovie)
            cell.delegateDetail = self
            return cell
        case .RecommendDetailsSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendSection.className, for: indexPath) as! RecommendSection
            cell.configDataDetails(self.itemMovieDetail?.recommendations?.results ?? [])
            cell.setTextRecommend(check: .detail)
            cell.delegateDetail = self
            return cell
        }
    }
    
}

extension MovieDetailVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.frame.width
        
        switch SectionDetailsType.allCases[indexPath.section] {
            
        case .HeaderDetailsSection:
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: cellWidth, height: 1000)
            } else {
                return CGSize(width: cellWidth, height: cellWidth * 3 / 2)
                
            }
        case .OverriewTrailerSection:
            return CGSize(width: cellWidth - 32, height: 37)
        case .StorySection:
            // tinh chieu cao text
            let heightText = itemMovieDetail?.overview?.heightText(width: cellWidth - 48, font: UIFont.systemFont(ofSize: 12.0)) ?? 72
            // check dieu kien cua chieu cao text
            guard
                let content = itemMovieDetail?.overview,
                let font = UIFont(name: "Inter-Regular", size: 12) else {
                return .zero
            }
            if (heightText <= 72) {
                return CGSize(width: cellWidth - 48, height: heightText + 37)
                
            } else {
                if stateSeemore == true {
                    return CGSize(width: cellWidth - 48, height: 110)
                } else {
                    let height = (content + "Less").heightText(width: cellWidth - 48, font: font)
                    return CGSize(width: cellWidth - 48, height: height + 50)
                }
            }
        case .TrailerSection:
            if UIDevice.current.userInterfaceIdiom == .pad {
                if itemMovieDetail?.videos.results.first?.key?.count == nil {
                    return CGSize(width: 0, height: 0)
                }else{
                    return CGSize(width: cellWidth - 48, height: 500)
                }
            } else {
                if itemMovieDetail?.videos.results.first?.key?.count == nil {
                    return CGSize(width: 0, height: 0)
                }else{
                    return CGSize(width: cellWidth - 48, height: 226)
                }
            }
        case .PopularActorsDetailsSection:
            return CGSize(width: cellWidth - 16, height: 142)
        case .RecommendDetailsSection:
            return CGSize(width: cellWidth - 16, height: 280 )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch SectionDetailsType.allCases[section] {
            
        case .HeaderDetailsSection:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .OverriewTrailerSection:
            return UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 16)
        case .StorySection:
            return UIEdgeInsets(top: 11, left: 24, bottom: 0, right: 24)
        case .TrailerSection:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        case .PopularActorsDetailsSection:
            return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        case .RecommendDetailsSection:
            return UIEdgeInsets(top: 24, left: 0, bottom: 16 + 82 + 24, right: 0)
        }
    }
    
}

extension MovieDetailVC: MovieDetailProtocol {
    
    func clickPushDetailActor(id: Int) {
        let vc = ActorDetailsVC()
        vc.getIdActor(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushDetail(id: Int) {
        let vc = MovieDetailVC()
        vc.getIdMovie(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushShowAll(_ type: AllCheckType) {
        let nowPlayingVC = NowPlayingVC()
        nowPlayingVC.setType(type)
        self.navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func changeSection(_ check: TapType) {
        self.checkType = check
        self.collectionView.reloadData()
    }
    
    func tapSeemore(state: Bool) {
        switch state {
        case true:
            self.stateSeemore = false
        case false:
            self.stateSeemore = true
        }
        self.collectionView.reloadData()
    }
}

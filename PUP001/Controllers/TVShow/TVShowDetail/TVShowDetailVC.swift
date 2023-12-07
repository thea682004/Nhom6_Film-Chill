//
//  TVShowDetailVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

protocol TVDetailProtocol: AnyObject {
    func tapSeemore(state: Bool)
    func changeSection(_ check: TapType)
    func getAllSeason(index: Int)
    func clickPushShowAllTV(_ type: AllCheckType)
    func clickPushDetailTv(id: Int)
    func clickPushActorTv(id: Int)
}

class TVShowDetailVC: BaseVC {
    
    private var itemTVDetails: ItemTVShowDetails?
    private var itemEpisode: [ItemEpisode] = []
    private var stateSeemore: Bool = true
    private var checkType: TapType = .overview
    var id: Int = 0
    private var indexSeletedSeason: Int = -1
    
    @IBOutlet weak var btnAddWatchlist: UIButton! {
        didSet {
            btnAddWatchlist.isSelected = false
        }
    }
    
    @IBOutlet weak var btnFavorite: UIButton! {
        didSet {
            btnFavorite.isSelected = false
        }
    }
    
    @IBOutlet weak var heightAdBanner: NSLayoutConstraint!
    @IBOutlet weak var bannerAdView: BannerAdMobView!
    @IBOutlet weak var btnBackTV: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: HeaderDetailSection.className, bundle: nil), forCellWithReuseIdentifier: HeaderDetailSection.className)
            collectionView.register(UINib(nibName: OverviewTrailerSection.className, bundle: nil), forCellWithReuseIdentifier: OverviewTrailerSection.className)
            collectionView.register(UINib(nibName: StorySection.className, bundle: nil), forCellWithReuseIdentifier: StorySection.className)
            collectionView.register(UINib(nibName: TrailerSection.className, bundle: nil), forCellWithReuseIdentifier: TrailerSection.className)
            collectionView.register(UINib(nibName: SeasonSection.className, bundle: nil), forCellWithReuseIdentifier: SeasonSection.className)
            collectionView.register(UINib(nibName: PopularActorsSection.className, bundle: nil), forCellWithReuseIdentifier: PopularActorsSection.className)
            collectionView.register(UINib(nibName: RecommendSection.className, bundle: nil), forCellWithReuseIdentifier: RecommendSection.className)
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
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
    
    func getIdTVDetail(id: Int) {
        self.id = id
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
            self.deleteWatlistRealm()
        case false:
            break
        }
    }
    
    func addMovieRealm() {
        guard let itemTVDetail = self.itemTVDetails,
              let id = itemTVDetail.id
        else  { return }
        let item = MovieRealm(id: id,
                              image: itemTVDetail.poster_path,
                              name: itemTVDetail.name,
                              checkType: true)
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
        guard let itemTVDetail = self.itemTVDetails,
              let id = itemTVDetail.id ,
              let item = RealmManager.shared.getById(ofType: MovieRealm.self, id: id)
        else  { return }
        RealmManager.shared.delete(object: item)
    }
    
    func deleteWatlistRealm() {
        guard let itemTVDetail = self.itemTVDetails,
              let id = itemTVDetail.id,
              let item = RealmManager.shared.getById(ofType: AddWatchListRealm.self, id: id)
        else {return}
        RealmManager.shared.delete(object: item)
        
    }
    
    @IBAction func btnAddWatchlist(_ sender: Any) {
        self.actionAddOrDeleteWatchlist(value: self.btnAddWatchlist.isSelected)
        let vc = AddWatchlistVC()
        guard let item = itemTVDetails else {
            return
        }
        vc.configDataTV(item: item)
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    @IBAction func btnFavorite(_ sender: Any) {
        self.btnFavorite.setImage(self.btnFavorite.isSelected ? UIImage(named: "HeartClick") : UIImage(named: "ic_didFavorite"), for: .normal)
        self.actionAddOrDelete(value: self.btnFavorite.isSelected)
        self.btnFavorite.isSelected.toggle()
    }
    
    @IBAction func btnBackTV(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getData() {
        NetworkManager.shared.getDataTVDetails(endPoint: .tvDetails(id: self.id)) { [weak self] result, _ in
            guard let self = self else { return }
            self.itemTVDetails = result
            self.collectionView.reloadData()
            self.remoteViewLoading()
        }
    }
    
    func getDataEpisode(season: Int) {
        NetworkManager.shared.getDataEpisode(endPoint: .episode(id: self.id, seasonNumber: season)) { [weak self] result, _ in
            guard let self = self else { return }
            if let result = result {
                self.itemEpisode = result
            }
            self.collectionView.reloadData()
        }
    }
}

extension TVShowDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionDetailsTVType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SectionDetailsTVType.allCases[section] {
            
        case .HeaderDetailTVSection:
            return 1
        case .OverriewTrailerTVSection:
            return 1
        case .StoryTVSection:
            switch checkType {
            case .overview:
                return itemTVDetails?.overview == "" ? 0 : 1
            case .trailer:
                return 0
            case .season:
                return 0
            }
        case .TrailerTVSection:
            switch checkType {
            case .overview:
                return 0
            case .trailer:
                return itemTVDetails?.videos?.results?.first?.key == nil ? 0 : 1
            case .season:
                return 0
            }
        case .SeasonTVSection:
            switch checkType {
            case .overview:
                return 0
            case .trailer:
                return 0
            case .season:
                return itemTVDetails?.seasons?.count ?? 0
            }
        case .PopularActorsDetailsTVSection:
            
            return itemTVDetails?.credits?.cast.count == 0 ? 0 : 1
        case .RecommendDetailsTVSection:
            return itemTVDetails?.recommendations?.results?.count == 0 ? 0 : 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch SectionDetailsTVType.allCases[indexPath.section] {
            
        case .HeaderDetailTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderDetailSection.className, for: indexPath) as! HeaderDetailSection
            cell.playVideo = { [weak self] keyYT in
                guard let self = self else { return }
                let view = PlayTrailerView()
                view.frame = self.view.frame
                view.loadView(key: keyYT)
                view.backgroundColor = .black.withAlphaComponent(1.0)
                self.view.addSubview(view)
            }
            cell.configDataTV(item: itemTVDetails)
            return cell
        case .OverriewTrailerTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewTrailerSection.className, for: indexPath) as! OverviewTrailerSection
            cell.delegate = self
            return cell
        case .StoryTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StorySection.className, for: indexPath) as! StorySection
            if let item = self.itemTVDetails {
                cell.configSeemoreTV(item: item, stateSeemore: self.stateSeemore)
            }
            cell.delegateTV = self
            return cell
        case .TrailerTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailerSection.className, for: indexPath) as! TrailerSection
            cell.configureTrailer(key: itemTVDetails?.videos?.results?.first?.key ?? "")
            cell.playVideoYTB = { [weak self] keyYTB in
                guard let self = self else { return }
                let view = PlayTrailerView()
                view.frame = self.view.frame
                view.loadView(key: keyYTB)
                view.backgroundColor = .black.withAlphaComponent(1.0)
                self.view.addSubview(view)
            }
            return cell
        case .SeasonTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonSection.className, for: indexPath) as! SeasonSection
            if let item = self.itemTVDetails {
                cell.configData(item: item, index: indexPath.row, listEpisode: self.itemEpisode, indexSelected: self.indexSeletedSeason)
            }
            cell.delegate = self
            return cell
        case .PopularActorsDetailsTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularActorsSection.className, for: indexPath) as! PopularActorsSection
            cell.configData(itemTVDetails?.credits?.cast ?? [], checkTypeData: .detailTV)
            cell.delegateTVDetail = self
            return cell
        case .RecommendDetailsTVSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendSection.className, for: indexPath) as! RecommendSection
            cell.configDetailTV(self.itemTVDetails?.recommendations?.results ?? [])
            cell.setTextRecommend(check: .detail)
            cell.delegateTVDetail = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch SectionDetailsTVType.allCases[indexPath.section] {
        case.SeasonTVSection:
            
            if self.indexSeletedSeason == indexPath.row {
                self.indexSeletedSeason = -1
                self.collectionView.reloadData()
                return
            }
            
            self.indexSeletedSeason = indexPath.row
            if let seasonNumber = self.itemTVDetails?.seasons?[indexPath.row].season_number {
                self.getDataEpisode(season: seasonNumber)
            }
            self.collectionView.reloadData()
            print(indexPath.row)
        default:
            break
        }
    }
}

extension TVShowDetailVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        
        switch SectionDetailsTVType.allCases[indexPath.section] {
            
        case .HeaderDetailTVSection:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: cellWidth, height: 1000)
            } else {
                return CGSize(width: cellWidth, height: cellWidth * 3 / 2)
            }
        case .OverriewTrailerTVSection:
            return CGSize(width: cellWidth - 32, height: 37)
        case .StoryTVSection:
            let heightText = itemTVDetails?.overview?.heightText(width: cellWidth - 48, font: UIFont.systemFont(ofSize: 12.0)) ?? 72
            guard
                let content = itemTVDetails?.overview,
                let font = UIFont(name: "Inter-Regular", size: 12) else {
                return .zero
            }
            if (heightText <= 72) {
                return CGSize(width: cellWidth - 48, height: heightText + 37)
                
            } else {
                if stateSeemore == true {
                    return CGSize(width: cellWidth - 48, height: 108)
                } else {
                    let height = (content + "Less").heightText(width: cellWidth - 48, font: font)
                    return CGSize(width: cellWidth - 48, height: height + 37)
                }
            }
        case .TrailerTVSection:
            if UIDevice.current.userInterfaceIdiom == .pad {
                if itemTVDetails?.videos?.results?.first?.key?.count == nil {
                    return CGSize(width: 0, height: 0)
                }else{
                    return CGSize(width: cellWidth - 48, height: 500)
                }
            } else {
                if itemTVDetails?.videos?.results?.first?.key?.count == nil {
                    return CGSize(width: 0, height: 0)
                }else{
                    return CGSize(width: cellWidth - 48, height: 226)
                }
            }
            
        case .SeasonTVSection:
            if self.indexSeletedSeason == indexPath.row {
                var heightCell: CGFloat = 0
                if self.itemEpisode.count <= 5 {
                    heightCell = CGFloat(120 * (self.itemEpisode.count )) + 83
                } else {
                    heightCell = CGFloat(130 * 5) + 83
                }
                return CGSize(width: cellWidth - 48, height: heightCell)
                
            } else {
                return CGSize(width: cellWidth - 48, height: 24)
            }
        case .PopularActorsDetailsTVSection:
            
            return CGSize(width: cellWidth - 16, height: 142)
        case .RecommendDetailsTVSection:
            return CGSize(width: cellWidth - 16, height: 295 - 32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch SectionDetailsTVType.allCases[section] {
            
        case .HeaderDetailTVSection:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .OverriewTrailerTVSection:
            return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
        case .StoryTVSection:
            return self.checkType == .overview ?  UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24) : .zero
        case .TrailerTVSection:
            return self.checkType == .trailer ? UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24) : .zero
        case .SeasonTVSection:
            return self.checkType == .season ? UIEdgeInsets(top: 16, left: 24, bottom: 0, right: 24) : .zero
        case .PopularActorsDetailsTVSection:
            let numberOfItem = collectionView.numberOfItems(inSection: 4)
            if numberOfItem == 0 {
                return .zero
            } else {
                return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
            }
        case .RecommendDetailsTVSection:
            let numberOfitem = collectionView.numberOfItems(inSection: 5)
            if numberOfitem == 0 {
                return UIEdgeInsets(top: 0, left: 0, bottom: 16 + 82 + 24, right: 0)
            } else {
                return UIEdgeInsets(top: 24, left: 0, bottom: 16 + 82 + 24 , right: 0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch SectionDetailsTVType.allCases[section] {
            
        case .HeaderDetailTVSection, .OverriewTrailerTVSection, .StoryTVSection, .TrailerTVSection, .PopularActorsDetailsTVSection, .RecommendDetailsTVSection:
            return .zero
        case .SeasonTVSection:
            return CGFloat(20)
        }
    }
}

extension TVShowDetailVC: TVDetailProtocol {
    func clickPushActorTv(id: Int) {
        let vc = ActorDetailsVC()
        vc.getIdActor(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushDetailTv(id: Int) {
        let vc = TVShowDetailVC()
        vc.getIdTVDetail(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushShowAllTV(_ type: AllCheckType) {
        let nowPlayingVC = NowPlayingVC()
        nowPlayingVC.setType(type)
        self.navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func getAllSeason(index: Int) {
        let vc = AllEpisodeVC()
        vc.configData(item: self.itemTVDetails, indexSelected: index)
        self.navigationController?.pushViewController(vc, animated: true)
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

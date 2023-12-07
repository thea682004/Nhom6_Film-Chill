//
//  ActorDetailsVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

enum checkTypeActor {
    case movie
    case tvshow
}

protocol ActorDetailsViewDelegate: AnyObject {
    func clickPushDetail(id: Int)
    func clickPushDetailTV(id: Int)
}

class ActorDetailsVC: BaseVC {
    
    var id: Int = 0
    private var itemActorDetails: ItemActorDetails?
    private var listCastAndCrew: [KnownForActor] = []
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: HeaderActorSection.className, bundle: nil), forCellWithReuseIdentifier: HeaderActorSection.className)
            collectionView.register(UINib(nibName: CastCrewSection.className, bundle: nil), forCellWithReuseIdentifier: CastCrewSection.className)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    @IBOutlet weak var heightAdBanner: NSLayoutConstraint!
    @IBOutlet weak var bannerAdView: BannerAdMobView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        self.getData()
    }
    
    func getIdActor(id: Int) {
        self.id = id
    }
    
    func getData() {
        
        self.listCastAndCrew.removeAll()
        NetworkManager.shared.getDataActorDetails(endPoint: .actorDetails(id: self.id)) {
            [weak self] result, _ in
            guard let self = self else { return }
            self.itemActorDetails = result
            if let cast = result?.movie_credits?.cast,
               let crew = result?.movie_credits?.crew,
               let castTv = result?.tv_credits?.cast,
               let crewTv = result?.tv_credits?.crew{
                self.listCastAndCrew.append(contentsOf: self.convertCast(listCast: cast))
                self.listCastAndCrew.append(contentsOf: self.convertCrew(listCrew: crew))
                self.listCastAndCrew.append(contentsOf: self.convertCastTv(listCast: castTv))
                self.listCastAndCrew.append(contentsOf: self.convertCrewTv(listCrewTv: crewTv))
                print(cast.count, crew.count, castTv.count, crewTv.count, self.listCastAndCrew.count)
                self.filterIdActor()
            }
            self.collectionView.reloadData()
            self.remoteViewLoading()
        }
    }
    
    func convertCrew(listCrew: [CrewMovie]) -> [KnownForActor] {
        var listCast: [KnownForActor] = []
        listCrew.forEach { item in
            let item = KnownForActor(id: item.id, name: item.title, poster_path: item.poster_path)
            listCast.append(item)
        }
        return listCast
    }
    
    func convertCast(listCast: [CastMovie]) -> [KnownForActor] {
        var list: [KnownForActor] = []
        listCast.forEach { item in
            let item = KnownForActor(id: item.id, name: item.title, poster_path: item.poster_path)
            list.append(item)
        }
        return list
    }
    
    func convertCrewTv(listCrewTv: [CrewTV]) -> [KnownForActor] {
        var listCast: [KnownForActor] = []
        listCrewTv.forEach { item in
            let item = KnownForActor(id: item.id, name: item.name, poster_path: item.poster_path, checkType: .tvshow)
            listCast.append(item)
        }
        return listCast
    }
    
    func convertCastTv(listCast: [CastTV]) -> [KnownForActor] {
        var list: [KnownForActor] = []
        listCast.forEach { item in
            let item = KnownForActor(id: item.id, name: item.name, poster_path: item.poster_path, checkType: .tvshow)
            list.append(item)
        }
        return list
    }
    
    func filterIdActor() {
        self.listCastAndCrew = self.listCastAndCrew.removingDuplicates()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ActorDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ActorDetailsType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch ActorDetailsType.allCases[section] {
            
        case .Header:
            return 1
        case .CastCrew:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch ActorDetailsType.allCases[indexPath.section] {
            
        case .Header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderActorSection.className, for: indexPath) as! HeaderActorSection
            cell.configData(item: itemActorDetails)
            return cell
        case .CastCrew:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCrewSection.className, for: indexPath) as! CastCrewSection
            cell.configData(self.listCastAndCrew)
            cell.delegate = self
            cell.delegateTV = self
            return cell
        }
    }
}

extension ActorDetailsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch ActorDetailsType.allCases[indexPath.section] {
            
        case .Header:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: collectionView.frame.width, height: 887)
            } else {
                return CGSize(width: collectionView.frame.width, height: collectionView.frame.width * 3 / 2)
            }
        case .CastCrew:
            return CGSize(width: collectionView.frame.width - 16, height: 280)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch ActorDetailsType.allCases[section] {
            
        case .Header:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .CastCrew:
            return UIEdgeInsets(top: 24, left: 16, bottom: 56 , right: 0)
        }
    }
}

extension ActorDetailsVC: ActorDetailsViewDelegate {
    func clickPushDetailTV(id: Int) {
        let vc = TVShowDetailVC()
        vc.getIdTVDetail(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushDetail(id: Int) {
        let vc = MovieDetailVC()
        vc.getIdMovie(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

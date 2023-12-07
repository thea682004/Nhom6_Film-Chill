//
//  RecommendSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit

enum checkRecommend {
    case home
    case detail
}

class RecommendSection: UICollectionViewCell {
    
    enum CheckTypeData {
        case movie
        case tvShow
        case detailMovie
        case detailTV
    }
    
    weak var delegate: MovieViewDelegate?
    weak var delegateTV: TVShowViewDelegate?
    weak var delegateDetail: MovieDetailProtocol?
    weak var delegateTVDetail: TVDetailProtocol?
    private var listItem: [ItemMovies] = []
    private var listItemDetails: [ResultRecommendation] = []
    private var listItemDetailsTV: [ResultRecommendationTVDetail] = []
    private var listItemTv: [ItemTVShow] = []
    private var checkTypeData: CheckTypeData = .movie

    @IBOutlet weak var lblRecommend: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.register(UINib(nibName: NowPlayingCell.className, bundle: nil), forCellWithReuseIdentifier: NowPlayingCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btnNext(_ sender: Any) {
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushNowplaying(.Recommend)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.RecommendTV)
        case .detailMovie:
            self.delegateDetail?.clickPushShowAll(.Recommend)
        case .detailTV:
            self.delegateTVDetail?.clickPushShowAllTV(.RecommendTV)
        }
    }
    
    func configData(_ value: [ItemMovies]) {
        self.checkTypeData = .movie
        self.listItem = value
        self.collectionView.reloadData()
    }
    
    func configDataTv(_ value: [ItemTVShow]) {
        self.checkTypeData = .tvShow
        self.listItemTv = value
        self.collectionView.reloadData()
    }
    
    func configDataDetails(_ value: [ResultRecommendation]) {
        self.checkTypeData = .detailMovie
        self.listItemDetails = value
        self.collectionView.reloadData()
    }
    
    func configDetailTV(_ value: [ResultRecommendationTVDetail]) {
        self.checkTypeData = .detailTV
        self.listItemDetailsTV = value
        self.collectionView.reloadData()
    }
    
    func setTextRecommend(check: checkRecommend) {
        switch check {
            
        case .home:
            self.lblRecommend.text = "Recommend for you"
        case .detail:
            self.lblRecommend.text = "Recommend"
        }
    }
}

extension RecommendSection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.checkTypeData {
            
        case .movie:
            return self.listItem.count
        case .tvShow:
            return self.listItemTv.count
        case .detailMovie:
            return self.listItemDetails.count
        case .detailTV:
            return self.listItemDetailsTV.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingCell.className, for: indexPath) as! NowPlayingCell
        switch self.checkTypeData {
        case .movie:
            cell.configData(item: listItem[indexPath.row])
        case .tvShow:
            cell.configDataTv(item: self.listItemTv[indexPath.row])
        case .detailMovie:
            cell.configDataDetail(item: self.listItemDetails[indexPath.row])
        case .detailTV:
            cell.configDataDetailTV(item: self.listItemDetailsTV[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.checkTypeData {
            
        case .movie:
            self.delegate?.clickPushDetail(id: self.listItem[indexPath.row].id ?? 0)
        case .tvShow:
            self.delegateTV?.clickPushTVDetail(id: self.listItemTv[indexPath.row].id ?? 0)
        case .detailMovie:
            self.delegateDetail?.clickPushDetail(id: self.listItemDetails[indexPath.row].id ?? 0)
        case .detailTV:
            self.delegateTVDetail?.clickPushDetailTv(id: self.listItemDetailsTV[indexPath.row].id ?? 0)
        }
    }
}
extension RecommendSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.height)
    }
}

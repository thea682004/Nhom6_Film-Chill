//
//  PopularActorsSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit

class PopularActorsSection: UICollectionViewCell {
    
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
    private var listItem: [ItemActors] = []
    private var checkTypeData: CheckTypeData = .movie
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.register(UINib(nibName: PopularActorCell.className, bundle: nil), forCellWithReuseIdentifier: PopularActorCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configData(_ value: [ItemActors], checkTypeData: CheckTypeData = .movie) {
        self.checkTypeData = checkTypeData
        self.listItem = value
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushDetailActor(id:   self.listItem[indexPath.row].id ?? 0)
        case .tvShow:
            self.delegateTV?.clickPushDetailActorTV(id: self.listItem[indexPath.row].id ?? 0 )
        case .detailMovie:
            self.delegateDetail?.clickPushDetailActor(id: self.listItem[indexPath.row].id ?? 0)
        case .detailTV:
            self.delegateTVDetail?.clickPushActorTv(id: self.listItem[indexPath.row].id ?? 0 )
        }
    }
    
    @IBAction func btnNext(_ sender: Any) {
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushNowplaying(.PopularActor)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.PopularActorTV)
        case .detailMovie:
            self.delegateDetail?.clickPushShowAll(.PopularActor)
        case .detailTV:
            self.delegateTVDetail?.clickPushShowAllTV(.PopularActorTV)
        }
    }
}

extension PopularActorsSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularActorCell.className, for: indexPath) as! PopularActorCell
        cell.configData(item: listItem[indexPath.row])        
        return cell
    }
    
}

extension PopularActorsSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 106)
    }
}

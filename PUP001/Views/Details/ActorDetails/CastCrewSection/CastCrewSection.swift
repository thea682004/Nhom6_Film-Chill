//
//  CastCrewSection.swift
//  PUP001
//
//  Created by chuottp on 09/06/2023.
//

import UIKit

class CastCrewSection: UICollectionViewCell {
    
    weak var delegateTV: ActorDetailsViewDelegate?
    weak var delegate: ActorDetailsViewDelegate?
    private var listItem: [KnownForActor] = []

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: CastCrewCell.className, bundle: nil), forCellWithReuseIdentifier: CastCrewCell.className)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(_ value: [KnownForActor]) {
        self.listItem = value
        self.collectionView.reloadData()
    }
}

extension CastCrewSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCrewCell.className, for: indexPath) as! CastCrewCell
        cell.configData(item: listItem[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.delegate?.clickPushDetail(id: self.listItem[indexPath.row].id ?? 0)
        
        switch self.listItem[indexPath.row].checkType {
            
        case .movie:
            self.delegate?.clickPushDetail(id: self.listItem[indexPath.row].id ?? 0)
        case .tvshow:
            self.delegateTV?.clickPushDetailTV(id: self.listItem[indexPath.row].id ?? 0)
        }
    }
    
}

extension CastCrewSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 127 - 8, height: 230)
    }
}

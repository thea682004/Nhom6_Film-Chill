//
//  TrendingSearchSection.swift
//  PUP001
//
//  Created by chuottp on 30/06/2023.
//

import UIKit

class TrendingSearchSection: UICollectionViewCell {

    private var listItem: [ItemMovies] = []
    private var checkSeleted: checkTypeSearch = .movie
    weak var delegate: SearchAddWatchlistDelegate?
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SearchAddWatchlistSection.className, bundle: nil), forCellWithReuseIdentifier: SearchAddWatchlistSection.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configData(item: [ItemMovies]) {
        self.listItem = item
        self.collectionView.reloadData()
        self.checkSeleted = .movie
    }

}

extension TrendingSearchSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchAddWatchlistSection.className, for: indexPath) as! SearchAddWatchlistSection
        cell.configData(item: listItem[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.pushAddWatchlist(id: self.listItem[indexPath.row].id ?? 0, checkType: .movie)
    }
    
}

extension TrendingSearchSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 32) / 3, height: 185)
    }
}

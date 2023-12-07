//
//  UpcomingMovieSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit

class UpcomingMovieSection: UICollectionViewCell {
    private var listItem: [ItemMovies] = []
    private var listItemTv: [ItemTVShow] = []
    private var checkTypeData: checkDataMovieOrTV = .movie
    weak var delegate: MovieViewDelegate?
    weak var delegateTV: TVShowViewDelegate?

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
    
    
    @IBAction func btnNext(_ sender: Any) {
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushNowplaying(.Upcoming)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.UpcomingTV)
        }
    }
    
}

extension UpcomingMovieSection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.checkTypeData {
            
        case .movie:
            return self.listItem.count
        case .tvShow:
            return self.listItemTv.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingCell.className, for: indexPath) as! NowPlayingCell
        switch self.checkTypeData {
            
        case .movie:
            cell.configData(item: listItem[indexPath.row])
        case .tvShow:
            cell.configDataTv(item: listItemTv[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.checkTypeData {
            
        case .movie:
            self.delegate?.clickPushDetail(id: self.listItem[indexPath.row].id ?? 0)
        case .tvShow:
            self.delegateTV?.clickPushTVDetail(id: self.listItemTv[indexPath.row].id ?? 0)
        }
    }
    
}
extension UpcomingMovieSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: collectionView.frame.height)
    }
    
}

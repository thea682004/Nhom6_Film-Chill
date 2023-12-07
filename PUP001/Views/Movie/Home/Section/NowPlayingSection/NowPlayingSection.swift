//
//  NowPlayingSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit

class NowPlayingSection: UICollectionViewCell {
    
    weak var delegate: MovieViewDelegate?
    weak var delegateTV: TVShowViewDelegate?
    private var listItem: [ItemMovies] = []
    private var listItemTv: [ItemTVShow] = []
    private var checkTypeData: checkDataMovieOrTV = .movie
    
    @IBOutlet weak var btnNext: UIButton! {
        didSet {
            btnNext.addTarget(self, action: #selector(pushNowplaying), for: .touchUpInside)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: NowPlayingCell.className, bundle: nil), forCellWithReuseIdentifier: NowPlayingCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
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
    
    @IBAction func pushNowplaying(_ sender: Any) {
        //tạo delegate khi click vào button next thì push sang một ViewController
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushNowplaying(.NowPlaying)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.NowPlayingTV)
        }
    }
}

extension NowPlayingSection: UICollectionViewDelegate, UICollectionViewDataSource {
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
        switch  self.checkTypeData {
            
        case .movie:
            self.delegate?.clickPushDetail(id: self.listItem[indexPath.row].id ?? 0)
          //  self.delegate?.clickPushNowplaying(.NowPlaying)
        case .tvShow:
            self.delegateTV?.clickPushTVDetail(id: self.listItemTv[indexPath.row].id ?? 0)
          //  self.delegateTV?.clickPushNowplayingTV(.NowPlaying)
        }
    }
}

extension NowPlayingSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 154, height: collectionView.frame.height)
    }
}

//
//  PopularMoviesSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit
import CollectionViewPagingLayout

class PopularMoviesSection: UICollectionViewCell , CollectionViewPagingLayoutDelegate{
    
    weak var delegateTV: TVShowViewDelegate?
    weak var delegate: MovieViewDelegate?
    private var listItem: [ItemMovies] = []
    private var listItemTv: [ItemTVShow] = []
    private var checkTypeData: checkDataMovieOrTV = .movie
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.register(UINib(nibName: PopularMovieCell.className, bundle: nil), forCellWithReuseIdentifier: PopularMovieCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var brnNext: UIButton!
    
    func configure(listItems: [ItemMovies]) {
        self.checkTypeData = .movie
        self.listItem = listItems
        let layout = CollectionViewPagingLayout()
        //set data hien thi
        layout.numberOfVisibleItems = 10
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        self.collectionView.reloadData()
    }
    
    func configureTv(listItems: [ItemTVShow]) {
        self.checkTypeData = .tvShow
        self.listItemTv = listItems
        let layout = CollectionViewPagingLayout()
        //set data hien thi
        layout.numberOfVisibleItems = 10
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        self.collectionView.reloadData()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        switch self.checkTypeData {
            
        case .movie:
            self.delegate?.clickPushNowplaying(.PopularMovies)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.PopularMoviesTV)
        }
    }
    
    func onCurrentPageChanged(layout: CollectionViewPagingLayout, currentPage: Int) {
        print(currentPage)
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

extension PopularMoviesSection : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.checkTypeData {
            
        case .movie:
            return self.listItem.count
        case .tvShow:
            return self.listItemTv.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMovieCell.className, for: indexPath) as! PopularMovieCell
        switch self.checkTypeData {
            
        case .movie:
            cell.configData(item: listItem[indexPath.row])
        case .tvShow:
            cell.configDataTv(item: listItemTv[indexPath.row])
            
        }
        return cell
    }
}

extension PopularMoviesSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height)
    }
    
}

//
//  GenresSection.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit

class GenresSection: UICollectionViewCell {
    
    weak var delegate: MovieViewDelegate?
    weak var delegateTV: TVShowViewDelegate?
    private var listItem: [Genre] = []
    private var listItemTv: [Genre] = []
    private var checkTypeData: checkDataMovieOrTV = .movie

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.register(UINib(nibName: GenresCell.className, bundle: nil), forCellWithReuseIdentifier: GenresCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(_ value: [Genre]) {
        self.checkTypeData = .movie
        self.listItem = value
        self.collectionView.reloadData()
    }
    
    func configDataTv(_ value: [Genre]) {
        self.checkTypeData = .tvShow
        self.listItemTv = value
        self.collectionView.reloadData()
    }
    
    
    @IBAction func btnNext(_ sender: Any) {
        switch self.checkTypeData {
        case .movie:
            self.delegate?.clickPushNowplaying(.Genres)
        case .tvShow:
            self.delegateTV?.clickPushNowplayingTV(.GenresTV)
        }
    }
    
}
extension GenresSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.checkTypeData {
            
        case .movie:
            return self.listItem.count
        case .tvShow:
            return self.listItemTv.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresCell.className, for: indexPath) as! GenresCell
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
            self.delegate?.clickPushShowAllGenres(id: self.listItem[indexPath.row].id, name:  self.listItem[indexPath.row].name)
        case .tvShow:
            self.delegateTV?.clickShowAllGenresTv(id: self.listItemTv[indexPath.row].id, name: self.listItemTv[indexPath.row].name)
        }
    }
    
}

extension GenresSection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(4.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.checkTypeData {
            
        case .movie:
            let genres = listItem[indexPath.row]
            let nameGenres = genres.name
            let widthName = nameGenres.widthText(height: 17, font: UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14))
            return CGSize(width: 80 + widthName + 5.0, height: 60)
        case .tvShow:
            let genres = listItemTv[indexPath.row]
            let nameGenres = genres.name
            let widthName = nameGenres.widthText(height: 17, font: UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14))
            return CGSize(width: 80 + widthName + 5.0, height: 60)

        }
        
    }
    
}

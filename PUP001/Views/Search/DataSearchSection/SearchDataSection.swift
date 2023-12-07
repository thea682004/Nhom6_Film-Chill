//
//  SearchDataSection.swift
//  PUP001
//
//  Created by chuottp on 26/05/2023.
//

import UIKit

enum TypeSearch {
    case movie
    case tv
    case actor
}

class SearchDataSection: UICollectionViewCell {
    
    weak var delegate: SearchProtocol?
    private var checkSeleted: TypeSearch = .movie
    private var itemSearchMovie: [ItemSearchMovie] = []
    private var itemSearchTV: [ItemSearchTV] = []
    private var itemSearchActor: [ItemSearchActor] = []
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var centerX: NSLayoutConstraint!
    @IBOutlet weak var lblActors: UILabel! {
        didSet {
            lblActors.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actorTap))
            lblActors.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var centerXLineView: NSLayoutConstraint!
    @IBOutlet weak var lblTVShow: UILabel! {
        didSet {
            lblTVShow.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tvShowTap))
            lblTVShow.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var lblMovies: UILabel! {
        didSet {
            lblMovies.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.movieTap))
            lblMovies.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SearchDataCell.className, bundle: nil), forCellWithReuseIdentifier: SearchDataCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @objc func actorTap() {
        self.setUpAnimation(.actor)
        self.delegate?.changeSearch(.actor)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpAnimation(checkSeleted)
    }
    
    @objc func tvShowTap() {
        self.setUpAnimation(.tv)
        self.delegate?.changeSearch(.tv)
    }
    
    @objc func movieTap() {
        self.setUpAnimation(.movie)
        self.delegate?.changeSearch(.movie)
    }
    
    private func setColorUI(_ check: TypeSearch) {
        switch check {
        case .movie:
            self.lblMovies.textColor = UIColor(rgb: 0xF35C56)
            self.lblActors.textColor = UIColor(rgb: 0x8E8888)
            self.lblTVShow.textColor = UIColor(rgb: 0x8E8888)
            self.lblMovies.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.lblActors.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.lblTVShow.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            
        case .tv:
            self.lblTVShow.textColor = UIColor(rgb: 0xF35C56)
            self.lblMovies.textColor = UIColor(rgb: 0x8E8888)
            self.lblActors.textColor = UIColor(rgb: 0x8E8888)
            self.lblTVShow.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.lblMovies.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.lblActors.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        case .actor:
            self.lblActors.textColor = UIColor(rgb: 0xF35C56)
            self.lblMovies.textColor = UIColor(rgb: 0x8E8888)
            self.lblTVShow.textColor = UIColor(rgb: 0x8E8888)
            self.lblActors.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.lblMovies.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.lblTVShow.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }
    }
    
    private func setUpAnimation(_ check: TypeSearch) {
        self.checkSeleted = check
        let estimateLayout = self.lineView.frame.width / 2
        switch check {
        case .movie:
            self.centerXLineView.constant = self.lblMovies.center.x - estimateLayout
            self.setColorUI(check)
        case .tv:
            self.centerXLineView.constant = self.lblTVShow.center.x - estimateLayout - 2.5
            self.setColorUI(check)
        case .actor:
            self.centerXLineView.constant = self.lblActors.center.x - estimateLayout
            self.setColorUI(check)
        }
    }
    
    func configDataMovie(item: [ItemSearchMovie]) {
        self.checkSeleted = .movie
        self.itemSearchMovie = item
        layoutIfNeeded()
        self.collectionView.reloadData()
    }
    
    func configDataTV(item: [ItemSearchTV]) {
        self.checkSeleted = .tv
        self.itemSearchTV = item
        layoutIfNeeded()
        self.collectionView.reloadData()
    }
    
    func configDataActor(item: [ItemSearchActor]) {
        self.checkSeleted = .actor
        self.itemSearchActor = item
        layoutIfNeeded()
        self.collectionView.reloadData()
    }
    
}

extension SearchDataSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkSeleted {
            
        case .movie:
            return itemSearchMovie.count
        case .tv:
            return itemSearchTV.count
        case .actor:
            return itemSearchActor.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDataCell.className, for: indexPath) as! SearchDataCell
        switch checkSeleted {
            
        case .movie:
            cell.configDataMovie(item: itemSearchMovie[indexPath.row])
            cell.viewVote.isHidden = false
        case .tv:
            cell.configDataTV(item: itemSearchTV[indexPath.row])
            cell.viewVote.isHidden = false
        case .actor:
            cell.configDataActor(item: itemSearchActor[indexPath.row])
            cell.viewVote.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch checkSeleted {
            
        case .movie:
            self.delegate?.pushDetailMovie(id: self.itemSearchMovie[indexPath.row].id ?? 0)
        case .tv:
            self.delegate?.pushDetailTV(id: self.itemSearchTV[indexPath.row].id ?? 0)
        case .actor:
            self.delegate?.pushDetailActor(id: self.itemSearchActor[indexPath.row].id ?? 0)
        }
    }
    
}

extension SearchDataSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        print(collectionView.frame, self.frame)
        var width = (collectionView.frame.width - 16.0 * 2 - 12 * 2) / 3.0 - 0.00001
        if width < 0 {
            width = 0
        }
        switch checkSeleted {
        case .actor:
            return CGSize(width: width, height: width + 8.0 + 15.0)
        default:
            return CGSize(width: width, height: width / 2 * 3 + 8.0 + 14.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(12)
        //space item dọc
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
        //space item ngang
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
    }
    
    
}

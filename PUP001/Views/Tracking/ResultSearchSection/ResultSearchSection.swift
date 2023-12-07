//
//  ResultSearchSection.swift
//  PUP001
//
//  Created by chuottp on 30/06/2023.
//

import UIKit
enum checkTypeSearch {
    case movie
    case tv
}

class ResultSearchSection: UICollectionViewCell {
    
    weak var delegate: SearchAddWatchlistDelegate?
    private var checkSeleted: checkTypeSearch = .movie
    private var itemSearchMovie: [ItemSearchMovie] = []
    private var itemSearchTV: [ItemSearchTV] = []
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
    
    @IBOutlet weak var centerXLineView: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SearchAddWatchlistSection.className, bundle: nil), forCellWithReuseIdentifier: SearchAddWatchlistSection.className)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setUpAnimation(checkSeleted)
    }
    
    @objc func tvShowTap() {
        if self.checkSeleted != .tv {
            self.setUpAnimation(.tv)
            self.checkSeleted = .tv
        }
    }
    
    @objc func movieTap() {
        if self.checkSeleted != .movie {
            self.setUpAnimation(.movie)
            self.checkSeleted = .movie
        }
    }
    
    func configDataMovie(item: [ItemSearchMovie]) {
        self.itemSearchMovie = item
        self.collectionView.reloadData()
    }
    
    func configDataTV(item: [ItemSearchTV]) {
        self.itemSearchTV = item
        self.collectionView.reloadData()
    }
    
    private func setColorUI(_ check: checkTypeSearch) {
        switch check {
        case .movie:
            self.lblMovies.textColor = UIColor(rgb: 0xF35C56)
            self.lblTVShow.textColor = UIColor(rgb: 0x8E8888)
            self.lblMovies.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblTVShow.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            
        case .tv:
            self.lblTVShow.textColor = UIColor(rgb: 0xF35C56)
            self.lblMovies.textColor = UIColor(rgb: 0x8E8888)
            self.lblTVShow.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblMovies.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    private func setUpAnimation(_ check: checkTypeSearch) {
        self.checkSeleted = check
        switch check {
        case .movie:
            UIView.animate(withDuration: 0.1, delay: 0) {
                self.lineView.center.x = self.lblMovies.center.x
                self.setColorUI(check)
                self.lineView.isHidden = false
            } completion: { _ in
                self.collectionView.reloadData()
            }
        case .tv:
            UIView.animate(withDuration: 0.1, delay: 0) {
                self.lineView.center.x = self.lblTVShow.center.x
                self.layoutIfNeeded()
                self.setColorUI(check)
                self.lineView.isHidden = false
            } completion: { _ in
                self.collectionView.reloadData()
            }
        }
    }

}

extension ResultSearchSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkSeleted {
            
        case .movie:
            return itemSearchMovie.count
        case .tv:
            return itemSearchTV.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchAddWatchlistSection.className, for: indexPath) as! SearchAddWatchlistSection
        switch checkSeleted {
        case .movie:
            cell.configDataSearchMovie(item: itemSearchMovie[indexPath.row])
        case .tv:
            cell.configDataSearchTV(item: itemSearchTV[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch checkSeleted {
        case .movie:
            self.delegate?.pushAddWatchlist(id: itemSearchMovie[indexPath.row].id ?? 0, checkType: .movie)
        case .tv:
            self.delegate?.pushAddWatchlist(id: itemSearchTV[indexPath.row].id ?? 0, checkType: .tv)
        }
    }
}

extension ResultSearchSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 32) / 3, height: 185)
    }
}

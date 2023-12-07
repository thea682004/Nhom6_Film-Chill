//
//  NoDataCell.swift
//  PUP001
//
//  Created by chuottp on 11/06/2023.
//

import UIKit

class NoDataCell: UICollectionViewCell {
    
    weak var delegate: FavoriteDelegate?
    
    @IBOutlet weak var btnAddFavorite: UIButton! {
        didSet {
            btnAddFavorite.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 16
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 1, height: 0)
            view.layer.shadowOpacity = 0.05
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
        }
    }
    
    @IBAction func btnAddFavorite(_ sender: Any) {
        self.delegate?.clickPushHomeMovies()
    }
}

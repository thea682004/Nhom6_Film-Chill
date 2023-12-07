//
//  AllNowPlayingSection.swift
//  PUP001
//
//  Created by chuottp on 08/06/2023.
//

import UIKit

class AllNowPlayingSection: UICollectionViewCell {

    @IBOutlet weak var btnAddWatchlist: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvartar: UIImageView! {
        didSet {
            imgAvartar.layer.cornerRadius = 5.0
            imgAvartar.layer.masksToBounds = true
        }
    }
    
    func configuraData(item: ItemMovies) {
        self.imgAvartar.loadImage(link: item.posterPath)
        self.lblName.text = item.originalTitle
    }
    
    func configuraDataTV(item: ItemTVShow) {
        self.imgAvartar.loadImage(link: item.posterPath)
        self.lblName.text = item.name
    }
    
    func configuraGenresMovie(item: ItemGenresID) {
        self.imgAvartar.loadImage(link: item.poster_path)
        self.lblName.text = item.title
    }
    
    func configuraGenresTV(item: ItemGenresIDTV) {
        self.imgAvartar.loadImage(link: item.poster_path)
        self.lblName.text = item.name
    }
    
}

//
//  SearchAddWatchlistSection.swift
//  PUP001
//
//  Created by chuottp on 28/06/2023.
//

import UIKit

class SearchAddWatchlistSection: UICollectionViewCell {

    
    @IBOutlet weak var lblVote: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 5
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: ItemMovies) {
        self.imgAvatar.loadImage(link: item.posterPath)
        self.lblName.text = item.title
        self.lblVote.text = String(format: "%.1f", item.voteAverage ?? 0)
    }
    
    func configDataSearchMovie(item: ItemSearchMovie) {
        self.imgAvatar.loadImage(link: item.poster_path)
        self.lblName.text = item.title
        self.lblVote.text = String(format: "%.1f", item.vote_average ?? 0)
    }
    
    func configDataSearchTV(item: ItemSearchTV) {
        self.imgAvatar.loadImage(link: item.poster_path)
        self.lblName.text = item.name
        self.lblVote.text = String(format: "%.1f", item.vote_average ?? 0)
    }

}

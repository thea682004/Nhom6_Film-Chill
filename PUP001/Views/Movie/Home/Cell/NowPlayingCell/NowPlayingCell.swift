//
//  NowPlayingCell.swift
//  PUP001
//
//  Created by chuottp on 04/05/2023.
//

import UIKit
import SDWebImage

class NowPlayingCell: UICollectionViewCell {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgMovie: UIImageView! {
        didSet {
            imgMovie.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var voteLbl: UILabel! {
        didSet {
            voteLbl.layer.cornerRadius = 4
            voteLbl.clipsToBounds = true
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: ItemMovies) {
        self.imgMovie.loadImage(link: item.posterPath)
        self.nameLbl.text = item.originalTitle
        self.voteLbl.text = String(format: "%.1f", item.voteAverage ?? 0)
    }
    
    
    func configDataTv(item: ItemTVShow) {
        self.imgMovie.loadImage(link: item.posterPath)
        self.nameLbl.text = item.name
        self.voteLbl.text = String(format: "%.1f", item.voteAverage ?? 0)
    }
    
    func configDataDetail(item: ResultRecommendation) {
        self.imgMovie.loadImage(link: item.poster_path)
        self.nameLbl.text = item.original_title
        self.voteLbl.text = String(format: "%.1f", item.vote_average ?? 0.0)
    }
    
    func configDataDetailTV(item: ResultRecommendationTVDetail) {
        self.imgMovie.loadImage(link: item.poster_path)
        self.nameLbl.text = item.name
        self.voteLbl.text = String(format: "%.1f", item.vote_average ?? 0.0)
    }

}

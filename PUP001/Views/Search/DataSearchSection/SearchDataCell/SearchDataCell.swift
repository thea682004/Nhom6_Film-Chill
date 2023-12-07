//
//  SearchDataCell.swift
//  PUP001
//
//  Created by chuottp on 26/05/2023.
//

import UIKit

class SearchDataCell: UICollectionViewCell {

    @IBOutlet weak var lblVote: UILabel!
    @IBOutlet weak var viewVote: UIView! {
        didSet {
            viewVote.layer.cornerRadius = 4
            viewVote.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgSearch: UIImageView! {
        didSet {
            imgSearch.layer.cornerRadius = 5
            imgSearch.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configDataMovie(item: ItemSearchMovie) {
        self.lblName.text = item.title
        self.imgSearch.loadImage(link: item.poster_path)
        self.lblVote.text = String(format: "%.1f", item.vote_average ?? 0.0)
    }
    
    func configDataTV(item: ItemSearchTV) {
        self.lblName.text = item.name
        self.imgSearch.loadImage(link: item.poster_path)
        self.lblVote.text = String(format: "%.1f", item.vote_average ?? 0.0)
    }
    func configDataActor(item: ItemSearchActor) {
        self.lblName.text = item.name
        self.imgSearch.loadImage(link: item.profile_path)
    }

}

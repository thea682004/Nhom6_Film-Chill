//
//  HaveDataCell.swift
//  PUP001
//
//  Created by chuottp on 11/06/2023.
//

import UIKit

class HaveDataCell: UICollectionViewCell {

    weak var delege: FavoriteDelegate?
    private var id: Int = 0
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var btnFavorite: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(with movie: MovieRealm) {
        self.imgAvatar.loadImage(link: movie.image)
        self.lblName.text = movie.name
        self.id = movie.id ?? 0
        }

    @IBAction func btnFavorite(_ sender: Any) {
        self.delege?.deleteFavorite(id: id)
    }
}

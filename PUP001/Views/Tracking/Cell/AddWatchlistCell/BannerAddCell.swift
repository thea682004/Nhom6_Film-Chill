//
//  BannerAddCell.swift
//  PUP001
//
//  Created by chuottp on 07/07/2023.
//

import UIKit

class BannerAddCell: UICollectionViewCell {
    
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configDataDetailMovie(item: ItemMoviesDetail?) {
        self.imgAvatar.loadImage(link: item?.backdropPath)
        self.lblTitle.text = item?.title
        var itemsGenres: [String] = []
        item?.genre?.forEach({ item in
            itemsGenres.append(item.name ?? "")
        })
        lblGenre.text = GenresService.shared.getString(array: itemsGenres , maxCount: 1)
    }
    
    func configDataDetailTV(item: ItemTVShowDetails?) {
        self.imgAvatar.loadImage(link: item?.backdrop_path)
        self.lblTitle.text = item?.name
        var itemGenres: [String] = []
        item?.genres?.forEach({item in
            itemGenres.append(item.name ?? "")
        })
        lblGenre.text = GenresService.shared.getString(array: itemGenres, maxCount: 1)
    }
}

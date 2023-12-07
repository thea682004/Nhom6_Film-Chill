//
//  AllPopularActors.swift
//  PUP001
//
//  Created by chuottp on 08/06/2023.
//

import UIKit

class AllPopularActors: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 5
        }
    }
    
    func configureData(item: ItemActors) {
        self.imgAvatar.loadImage(link: item.profilePath)
        self.lblName.text = item.name
    }

}

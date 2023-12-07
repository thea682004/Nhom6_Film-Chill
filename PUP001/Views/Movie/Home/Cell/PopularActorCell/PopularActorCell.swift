//
//  PopularActorCell.swift
//  PUP001
//
//  Created by chuottp on 05/05/2023.
//

import UIKit
import SDWebImage

class PopularActorCell: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgActor: UIImageView! {
        didSet {
            self.imgActor.clipsToBounds = true
            self.imgActor.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configData(item: ItemActors) {
        self.imgActor.loadImage(link: item.profilePath)
        self.lblName.text = item.name
    }
    
    func configDataTv(item: ItemActors) {
        self.imgActor.loadImage(link: item.profilePath)
        self.lblName.text = item.name
    }
}

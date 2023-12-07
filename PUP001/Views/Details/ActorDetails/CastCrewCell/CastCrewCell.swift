//
//  CastCrewCell.swift
//  PUP001
//
//  Created by chuottp on 13/06/2023.
//

import UIKit

class CastCrewCell: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 10
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configData(item: KnownForActor) {
        self.lblName.text = item.name
        self.imgAvatar.loadImage(link: item.poster_path)
    }

}

//
//  GenresCell.swift
//  PUP001
//
//  Created by chuottp on 05/05/2023.
//

import UIKit

class GenresCell: UICollectionViewCell {

    
    @IBOutlet weak var viewGenres: UIView! {
        didSet{
            viewGenres.layer.cornerRadius = 10
            viewGenres.layer.shadowColor = UIColor(rgb: 0x000000, alpha: 0.1).cgColor
            viewGenres.layer.shadowOpacity = 0.1
            viewGenres.layer.shadowOffset = CGSize(width: 4, height: 4.5)
            viewGenres.layer.shadowRadius = 0
            viewGenres.layer.masksToBounds = false
            viewGenres.layer.shadowPath = UIBezierPath(rect: viewGenres.bounds).cgPath
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgGenres: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: Genre) {
        self.lblName.text = item.name
    }
    
    func configDataTv(item: Genre) {
        self.lblName.text = item.name
    }

}

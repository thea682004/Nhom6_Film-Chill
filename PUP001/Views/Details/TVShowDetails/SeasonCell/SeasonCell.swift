//
//  SeasonCell.swift
//  PUP001
//
//  Created by chuottp on 24/05/2023.
//

import UIKit

class SeasonCell: UICollectionViewCell {

    private var item: Season?
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEpisode: UILabel!
    @IBOutlet weak var imgEpisode: UIImageView! {
        didSet {
            imgEpisode.layer.cornerRadius = 8
            imgEpisode.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 1
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: ItemEpisode) {
        self.imgEpisode.loadImage(link: item.still_path)
        if let overview = item.overview, !overview.isEmpty {
            self.lblDescription.text = "Description:\n\(overview)"
            self.lblDescription.isHidden = false
        } else {
            self.lblDescription.text = nil
            self.lblDescription.isHidden = true
        }

        self.lblName.text = item.name
        self.lblEpisode.text = "Episode \(String(item.episode_number ?? 0))"
    }
}


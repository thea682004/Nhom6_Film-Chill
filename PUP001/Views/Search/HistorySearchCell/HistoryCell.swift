//
//  HistoryCell.swift
//  PUP001
//
//  Created by chuottp on 24/05/2023.
//

import UIKit

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var uiView: UIView! {
        didSet {
            uiView.layer.cornerRadius = 5
            uiView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgArrowUp: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: String) {
        self.lblName.text = item
    }
}

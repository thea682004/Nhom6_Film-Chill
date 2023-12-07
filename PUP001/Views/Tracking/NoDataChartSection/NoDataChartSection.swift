//
//  NoDataChartSection.swift
//  PUP001
//
//  Created by chuottp on 16/06/2023.
//

import UIKit

class NoDataChartSection: UICollectionViewCell {
    weak var delegate: TrackingDelegate?

    @IBOutlet weak var btnAdd: UIButton! {
        didSet {
            btnAdd.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var uiview: UIView! {
        didSet {
            uiview.layer.cornerRadius = 16
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnAddWatchlist(_ sender: Any) {
        self.delegate?.pushSearchAddWatchlist()
    }
}

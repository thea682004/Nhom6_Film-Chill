//
//  ShowDateCell.swift
//  PUP001
//
//  Created by chuottp on 26/06/2023.
//

import UIKit

class ShowDateCell: UICollectionViewCell {

    @IBOutlet weak var lblYear: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureDataYear(year: Int) {
        self.lblYear.text = "\(year)"
    }
    
    func configureDataMonth(month: Int) {
        self.lblYear.text = StringUtils.shared.convertMonthToText(value: month)
    }
    
    func configureDataWeek(week: Int) {
        self.lblYear.text = "Week \(week)"
    }
}

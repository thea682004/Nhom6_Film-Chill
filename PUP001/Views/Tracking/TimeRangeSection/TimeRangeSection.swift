//
//  TimeRangeSection.swift
//  PUP001
//
//  Created by chuottp on 16/06/2023.
//

import UIKit

class TimeRangeSection: UICollectionViewCell {


    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    weak var delegate : TrackingDelegate?
    
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var viewWeek: UIView! {
        didSet {
            viewWeek.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var viewMonth: UIView! {
    didSet {
        viewMonth.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var viewYear: UIView! {
        didSet {
            viewYear.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var btnAdd: UIButton! {
        didSet {
            btnAdd.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var btnShowWeek: UIButton!
    
    func setTextYear(year: Int?, month: Int? = nil, week: Int? = nil) {
        if let year = year {
            self.lblYear.text = "\(year)"
            self.lblYear.textColor = UIColor(rgb: 0x272459)
            
        } else {
            self.lblYear.text = "Choose year"
        }
        
        if let month = month {
            self.lblMonth.text = StringUtils.shared.convertMonthToText(value: month)
            self.lblMonth.textColor = UIColor(rgb: 0x272459)
            
            self.viewWeek.alpha = 1.0
            self.btnShowWeek.isUserInteractionEnabled = true
        } else {
            self.lblMonth.text = "Choose month"
            self.lblMonth.textColor = UIColor(rgb: 0x8E8888)
            
            self.viewWeek.alpha = 0.5
            self.btnShowWeek.isUserInteractionEnabled = false
        }
        
        if let week = week {
           
            self.lblWeek.text = "Week \(week)"
            self.lblWeek.textColor = UIColor(rgb: 0x272459)
        } else {
            
            self.lblWeek.text = "Choose week"
            self.lblWeek.textColor = UIColor(rgb: 0x8E8888)
        }
    }
    
    @IBAction func showWeek(_ sender: Any) {
        self.delegate?.showWeek()
        
    }
    
    @IBAction func showMonth(_ sender: Any) {
        self.delegate?.showMonth()
    }
    
    @IBAction func showYear(_ sender: Any) {
        self.delegate?.showYear()
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        self.delegate?.pushSearchAddWatchlist()
    }
    
}

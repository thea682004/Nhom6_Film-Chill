//
//  OverviewTrailerSection.swift
//  PUP001
//
//  Created by chuottp on 15/05/2023.
//

import UIKit


enum TapType {
    case overview
    case trailer
    case season
}

class OverviewTrailerSection: UICollectionViewCell {
    
    private var checkSelected: TapType = .overview
    weak var delegate: TVDetailProtocol?
    weak var delegateMovie: MovieDetailProtocol?
    
    @IBOutlet weak var centerX: NSLayoutConstraint!
    @IBOutlet weak var lblSeason: UILabel! {
        didSet {
            lblSeason.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.seasonTap))
            lblSeason.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var lblTrailer: UILabel! {
        didSet {
            lblTrailer.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.trailerTap))
            lblTrailer.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var lblOverview: UILabel! {
        didSet {
            lblOverview.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.overviewTap))
            lblOverview.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var overviewView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setColorUI(.overview)
        //set uicolor mặc định khi nhấn vào màn detail
    }

    func setIsHiden() {
        self.lblSeason.isHidden = true
    }
    
    @objc func trailerTap() {
        if self.checkSelected != .trailer {
            self.checkSelected = .trailer
            self.setUpAnimation(.trailer)
        }
    }
    
    @objc func overviewTap() {
        if self.checkSelected != .overview {
            self.checkSelected = .overview
            self.setUpAnimation(.overview)
        }
    }
    
    @objc func seasonTap() {
        if self.checkSelected != .season {
            self.checkSelected = .season
            self.setUpAnimation(.season)
        }
    }

    private func setColorUI(_ check: TapType) {
        switch check {
        case .overview:
            self.lblOverview.textColor = UIColor(rgb: 0xF35C56)
            self.lblTrailer.textColor = UIColor(rgb: 0x8E8888)
            self.lblSeason.textColor = UIColor(rgb: 0x8E8888)
            self.lblOverview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblTrailer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblSeason.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        case .trailer:
            self.lblOverview.textColor = UIColor(rgb: 0x8E8888)
            self.lblTrailer.textColor = UIColor(rgb: 0xF35C56)
            self.lblSeason.textColor = UIColor(rgb: 0x8E8888)
            self.lblTrailer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblOverview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblSeason.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        case .season:
            self.lblSeason.textColor = UIColor(rgb: 0xF35C56)
            self.lblOverview.textColor = UIColor(rgb: 0x8E8888)
            self.lblTrailer.textColor = UIColor(rgb: 0x8E8888)
            self.lblSeason.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblOverview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lblTrailer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    private func setUpAnimation(_ check: TapType) {
        switch check {
        case .overview:
            UIView.animate(withDuration: 0.1,
                           delay: 0) {
                self.centerX.constant = (self.lblOverview.frame.minX - self.overviewView.frame.width) + (self.lblOverview.frame.width / 2)
                self.layoutIfNeeded()
                self.setColorUI(check)
            } completion: { _ in
                self.delegate?.changeSection(.overview)
                self.delegateMovie?.changeSection(.overview)
            }
        case .trailer:
            UIView.animate(withDuration: 0.1,
                           delay: 0) {
//                self.overviewView.frame.origin.x = self.lblTrailer.frame.origin.x
                self.centerX.constant = (self.lblTrailer.frame.minX - self.overviewView.frame.width) + (self.lblTrailer.frame.width / 2)
                self.layoutIfNeeded()
                self.setColorUI(check)
            } completion: { _ in
                self.delegate?.changeSection(.trailer)
                self.delegateMovie?.changeSection(.trailer)
            }
        case . season:
            UIView.animate(withDuration: 0.1,
                           delay: 0) {
                self.centerX.constant = (self.lblSeason.frame.minX - self.overviewView.frame.width) + (self.lblSeason.frame.width / 2)
                self.layoutIfNeeded()
                self.setColorUI(check)
            } completion: { _ in
                self.delegate?.changeSection(.season)
            }
        }
    }
}


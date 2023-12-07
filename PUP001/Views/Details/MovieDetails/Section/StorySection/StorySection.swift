//
//  StorySection.swift
//  PUP001
//
//  Created by chuottp on 12/05/2023.
//

import UIKit
import SwiftUI

class StorySection: UICollectionViewCell {
    
    private var stateSeemore: Bool = true
    weak var delegate: MovieDetailProtocol?
    weak var delegateTV: TVDetailProtocol?
    private var heightText: CGFloat = 0.0
    
    @IBOutlet weak var lblOverview: UILabel! {
        didSet {
            lblOverview.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            lblOverview.addGestureRecognizer(tap)
            
        }
    }
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.delegate?.tapSeemore(state: self.stateSeemore)
        self.delegateTV?.tapSeemore(state: self.stateSeemore)
        self.stateSeemore.toggle()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configSeemoreMovie(item: ItemMoviesDetail, stateSeemore: Bool = true) {
        guard let text = item.overview else {
            return
        }
        if stateSeemore == true {
            self.heightText = item.overview?.heightText(width: self.frame.width - 32, font: UIFont.systemFont(ofSize: 12)) ?? 0.0
            //set truong hop duoi 4 dong
            if heightText <= 80 {
                self.lblOverview.isUserInteractionEnabled = false
                self.lblOverview.text = text
                self.lblOverview.numberOfLines = 0
            } else {
                self.lblOverview.numberOfLines = 4
                self.lblOverview.text = text
                DispatchQueue.main.async {
                    self.lblOverview.addTrailing(with: "... ", moreText: "More", moreTextFont: UIFont.systemFont(ofSize: 12.0), moreTextColor: UIColor(rgb: 0xF35C56), stateSeeMore: true)
                }
            }
        } else {
            self.isUserInteractionEnabled = true
            //truong hop show full text
            self.lblOverview.text = text
            self.lblOverview.numberOfLines = 0
            DispatchQueue.main.async {
                self.lblOverview.addTrailing(with: "", moreText: "Less", moreTextFont: UIFont.systemFont(ofSize: 12.0), moreTextColor: UIColor(rgb: 0xF35C56), stateSeeMore: false)
            }
        }
    }
    
    func configSeemoreTV(item: ItemTVShowDetails, stateSeemore: Bool = true) {
        guard let text = item.overview else {
            return
        }
        if stateSeemore == true {
            self.heightText = item.overview?.heightText(width: self.frame.width - 32, font: UIFont.systemFont(ofSize: 12)) ?? 0.0
            //set truong hop duoi 4 dong
            if heightText <= 80 {
                self.lblOverview.isUserInteractionEnabled = false
                self.lblOverview.text = text
                self.lblOverview.numberOfLines = 0
            } else {
                self.lblOverview.numberOfLines = 4
                self.lblOverview.text = text
                DispatchQueue.main.async {
                    self.lblOverview.addTrailing(with: "... ", moreText: "More", moreTextFont: UIFont.systemFont(ofSize: 12.0), moreTextColor: UIColor(rgb: 0xF35C56), stateSeeMore: true)
                }
            }
        } else {
            //truong hop show full text
            self.lblOverview.isUserInteractionEnabled = true
            self.lblOverview.text = text
            self.lblOverview.numberOfLines = 0
            DispatchQueue.main.async {
                self.lblOverview.addTrailing(with: "", moreText: "Less", moreTextFont: UIFont.systemFont(ofSize: 12.0), moreTextColor: UIColor(rgb: 0xF35C56), stateSeeMore: false)
            }
        }
    }
    
    
}



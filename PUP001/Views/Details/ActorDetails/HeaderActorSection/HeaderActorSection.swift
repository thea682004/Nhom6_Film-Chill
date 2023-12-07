//
//  HeaderActorSection.swift
//  PUP001
//
//  Created by chuottp on 09/06/2023.
//

import UIKit

class HeaderActorSection: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lblOverview: UITextView! {
        didSet {
            lblOverview.contentInset = .zero
        }
    }
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblNameActor: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!{
        didSet {
            imgAvatar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            imgAvatar.layer.cornerRadius = 30.0
        }
    }
   
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.gradient()
    }
    
    func configData(item: ItemActorDetails?) {
        self.imgAvatar.loadImage(link: item?.profile_path)
        self.lblType.text = item?.known_for_department
        self.lblNameActor.text = item?.name
        self.lblOverview.text = item?.biography
    }
    
    func gradient() {
        let layer0 = CAGradientLayer()
        
        layer0.frame = self.imgAvatar.frame
        layer0.colors = [
            UIColor(rgb: 0x000000, alpha: 0).cgColor,
            UIColor(rgb: 0x000000, alpha: 0.5).cgColor
        ]
        layer0.startPoint = CGPoint(x: 0, y: 0)
        layer0.endPoint = CGPoint(x: 0, y: 1)
        imgAvatar.layer.addSublayer(layer0)
    }

}

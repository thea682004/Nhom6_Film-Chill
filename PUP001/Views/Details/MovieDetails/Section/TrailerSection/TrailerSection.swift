//
//  TrailerSection.swift
//  PUP001
//
//  Created by chuottp on 18/05/2023.
//

import UIKit
import YouTubePlayer
import SDWebImage

class TrailerSection: UICollectionViewCell {
    private var keyYT: String = ""
    var playVideoYTB: ((String) -> (Void))?
    @IBOutlet weak var imgPlayTrailer: UIImageView!
    @IBOutlet weak var imgTrailer: UIImageView!{
        didSet {
            imgTrailer.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.playTrailer(_:)))
            imgTrailer.addGestureRecognizer(tap)
            imgTrailer.layer.cornerRadius = 7.0
            imgTrailer.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc func playTrailer(_ sender: UITapGestureRecognizer? = nil) {
        print("Tap")
        self.playVideoYTB?(self.keyYT)
        
    }

    func configureTrailer(key: String) {
        let url = URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
        self.imgTrailer.sd_setImage(with: url)
        self.keyYT = key
    }
        

}

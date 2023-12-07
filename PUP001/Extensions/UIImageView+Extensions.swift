//
//  UIImageView+Extensions.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import SDWebImage

extension UIImageView {
    
    func loadImage(link: String?) {
        let imageDefault = UIImage(named: "ic_default")
        let baseLink = "https://image.tmdb.org/t/p/w500"
        guard let link = link , let url = URL(string: baseLink + link) else {
            self.image = imageDefault
            return
        }
        self.sd_setImage(with: url, placeholderImage: imageDefault)
    }
}



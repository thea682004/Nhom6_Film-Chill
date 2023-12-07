//
//  AdNativeShowBelowGenres.swift
//  PUP001
//
//  Created by chuottp on 18/07/2023.
//

import UIKit
import AdMobManager

class AdNativeShowBelowGenres: UICollectionViewCell {

    @IBOutlet weak var nativeAdView: Size11NativeAdView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpAdNative() {
            nativeAdView.register(id: AppText.keyAds.native)
           // nativeAdView.changeFont()
            nativeAdView.changeLoading(color: .black)
            nativeAdView.changeColor(border: .black, title: .black, ad: .white, adBackground: .black, body: .black)
    }

}

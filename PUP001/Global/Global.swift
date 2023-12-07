//
//  Global.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import Foundation
import AdMobManager

final class Global {
    static let shared = Global()
    var isStateShowAds: Bool = false
    var countShowAds: Int = 0
    let dateShowAds = "26-08-2023".asDate() ?? Date()
    
    private func saveStartDate() {
        let defaults = UserDefaults.standard
        let now = Date()
        defaults.set(now, forKey: "FirstOpenApp")
    }
    
    func checkSaveStartDate() {
        guard UserDefaults.standard.object(forKey: "FirstOpenApp") == nil else {
            return
        }
        saveStartDate()
    }
    
    func setUpDateShowAds() {
        AdMobManager.shared.showFullFeature(from: self.dateShowAds)
        AdMobManager.shared.register(key: AppText.nameAds.open, type: .appOpen, id: AppText.keyAds.appOpen)
        AdMobManager.shared.register(key: AppText.nameAds.splashInter, type: .interstitial, id: AppText.keyAds.splash)
    }
}

//
//  PlayTrailerView.swift
//  PUP001
//
//  Created by chuottp on 23/05/2023.
//

import UIKit
import YouTubePlayer
import SnapKit

class PlayTrailerView: UIView {

    private let exitBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_exit"), for: .normal)
        button.setTitle("", for: .normal)
        return button
    }()
    
    private let ytbView: YouTubePlayerView = {
        let custtomView = YouTubePlayerView()
        return custtomView
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addSubview(ytbView)
        self.setLayOut()
        self.setUpUI()
    }

    @objc func popView() {
        self.removeFromSuperview()
    }
   
    private func setUpUI() {
        exitBtn.frame = CGRect(x: self.frame.width - 16 - 24, y: self.frame.minY + self.safeAreaInsets.top + 22, width: 24, height: 24)
        exitBtn.isUserInteractionEnabled = true
        exitBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        self.addSubview(self.exitBtn)
    }

    func setLayOut() {
        self.ytbView.snp.makeConstraints { make in
            make.centerX.equalTo(self.center.x)
            make.centerY.equalTo(self.center.y)
            make.width.equalToSuperview()
            make.height.equalTo(300)
        }
    }

    func loadView(key: String) {
        self.ytbView.loadVideoID(key)
    }
}


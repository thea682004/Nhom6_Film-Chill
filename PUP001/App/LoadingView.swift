//
//  LoadingView.swift
//  PUP001
//
//  Created by chuottp on 13/07/2023.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class LoadingView: UIView {
    private let viewLoading: UIView = {
        let view = UIView()
        return view
    }()
    
    let styleLoading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .ballTrianglePath, color: UIColor(rgb: 0xF35C56, alpha: 1), padding: 0)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = UIColor(rgb: 0xF0F3F8)
        self.addSubview(viewLoading)
        self.setUpLayout()
        self.viewLoading.addSubview(styleLoading)
        self.styleLoading.startAnimating()
    }
    
    private func setUpLayout() {
        self.viewLoading.snp.makeConstraints { make in
            make.center.equalTo(self.center)
            make.height.width.equalTo(50)
        }
    }
}

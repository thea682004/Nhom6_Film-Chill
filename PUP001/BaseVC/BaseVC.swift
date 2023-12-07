//
//  BaseVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit

class BaseVC: UIViewController {
    
    let viewLoading = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewLoading.frame = self.view.frame
    }
    
    func setUpViewLoading() {
        self.view.addSubview(viewLoading)
        self.viewLoading.backgroundColor = UIColor(rgb: 0xF0F3F8)
    }
    
    func remoteViewLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.viewLoading.removeFromSuperview()
        })
    }
}

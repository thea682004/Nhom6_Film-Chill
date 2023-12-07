//
//  SplashScreenViewController.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import ALProgressView
import AdMobManager

class SplashScreenViewController: UIViewController {
    
    private var timer = Timer()
    private var progress: Double = 0.0
    private var targetProgress: Double = 30.0
    
    @IBOutlet weak var progressView: ALProgressBar! {
        didSet {
            progressView.startColor = UIColor(rgb: 0xF35C56)
            progressView.endColor = UIColor(rgb: 0xFFCA5B)
            progressView.duration = 2 //đặt thời gian chuyển tiếp từ màu bắt đầu đến màu kết thúc
            progressView.timingFunction = .easeOutSine
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.setProgress(0, animated: true)
        self.setUpProgress()
    }
    
    func setUpProgress() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeProgress), userInfo: nil, repeats: true)
    }
    
    @objc func timeProgress() {
        
        if Global.shared.isStateShowAds == true {
            if let isReady = AdMobManager.shared.isReady(key: AppText.nameAds.splashInter), isReady {
                progress += Double.random(in: 3...5.7)
                let a = progress / targetProgress
                progressView.setProgress(Float(a), animated: true)
                
                if progress >= targetProgress {
                    timer.invalidate()
                    AdMobManager.shared.show(key: AppText.nameAds.splashInter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.pushTabBar()
                    }
                }
            } else {
                
                let dateNow = Date()
                if Global.shared.dateShowAds > dateNow {
                    progress += 5
                } else {
                    progress += 1
                }
                let b = progress / targetProgress
                progressView.setProgress(Float(b), animated: true)
                
                if progress >= targetProgress {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.pushTabBar()
                    }
                }
            }
        } else {
            progress += 1
            
            let b = progress / targetProgress
            progressView.setProgress(Float(b), animated: true)
            
            if progress >= targetProgress {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.pushTabBar()
                }
            }
        }
    }
    
    func pushTabBar() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: TabBarViewController.className) as! TabBarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

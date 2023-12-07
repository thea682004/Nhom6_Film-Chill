//
//  SettingViewController.swift
//  PUP001
//
//  Created by chuottp on 25/04/2023.
//

import UIKit
import MessageUI
import StoreKit

class SettingViewController: BaseVC, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PrivacyCell.className, bundle: nil), forCellWithReuseIdentifier: PrivacyCell.className)
            collectionView.register(UINib(nibName: ShareCell.className, bundle: nil), forCellWithReuseIdentifier: ShareCell.className)
            collectionView.register(UINib(nibName: RatingCell.className, bundle: nil), forCellWithReuseIdentifier: RatingCell.className)
            collectionView.register(UINib(nibName: FeedBackCell.className, bundle: nil), forCellWithReuseIdentifier: FeedBackCell.className)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.layer.cornerRadius = 12
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SettingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkTypeSetting.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkTypeSetting.allCases[section] {
            
        case .privacy:
            return 1
        case .share:
            return 1
        case .rating:
            return 1
        case .feedback:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkTypeSetting.allCases[indexPath.section] {
            
        case .privacy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrivacyCell.className, for: indexPath) as! PrivacyCell
            return cell
        case .share:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareCell.className, for: indexPath) as! ShareCell
            return cell
        case .rating:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatingCell.className, for: indexPath) as! RatingCell
            return cell
        case .feedback:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedBackCell.className, for: indexPath) as! FeedBackCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch checkTypeSetting.allCases[indexPath.section] {
            
        case .privacy:
            self.openPrivacyPolicy()
        case .share:
            self.shareApp()
        case .rating:
            self.rateApp()
        case .feedback:
            self.sendFeedback()
        }
    }
    
    private func shareApp() {
        let appID = "6462053366"
        guard let url = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appID)?ls=1&mt=8") else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
        ]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func rateApp() {
        let appID = "6462053366"
        let appStoreURL = "https://apps.apple.com/app/id\(appID)?action=write-review"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["nawelaosaarp@hotmail.com"])
            composeVC.setSubject("App Feedback")
            
            present(composeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Email Not Configured", message: "Please configure your email account to send feedback.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func openPrivacyPolicy() {
        guard let appID = Bundle.main.bundleIdentifier else {
            return
        }
        
        let reviewURLString = "https://nawelaosaarpstudio.github.io/mosire/privacy.html"
        
        guard let reviewURL = URL(string: reviewURLString) else {
            return
        }
        
        UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
    }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        switch checkTypeSetting.allCases[indexPath.section] {
        case .privacy:
            return CGSize(width: width, height: 79)
        case .share:
            return CGSize(width: width, height: 87)
        case .rating:
            return CGSize(width: width, height: 87)
        case .feedback:
            return CGSize(width: width, height: 78)
        }
    }
}

extension SplashScreenViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

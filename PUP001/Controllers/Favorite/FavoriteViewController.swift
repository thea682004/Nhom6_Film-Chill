//
//  FavoriteViewController.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

protocol FavoriteDelegate: AnyObject {
    func clickPushHomeMovies()
    func deleteFavorite(id: Int)
}

class FavoriteViewController: BaseVC {
    
    private var listItem: [MovieRealm] = []
    private var checkFavorite: checkTypeFavorite = .noData
    
    @IBOutlet weak var heightConstraintAd: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: Size11NativeAdView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: HaveDataCell.className, bundle: nil), forCellWithReuseIdentifier: HaveDataCell.className)
            collectionView.register(UINib(nibName: NoDataCell.className, bundle: nil), forCellWithReuseIdentifier: NoDataCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isScrollEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    func setUpNativeAd() {
        if Global.shared.isStateShowAds == true {
            if listItem.count >= 2 {
                nativeAdView.register(id: AppText.keyAds.native)
                nativeAdView.changeLoading(color: .black)
                nativeAdView.changeColor(border: .black, title: .black, ad: .white, adBackground: .black, body: .black)
                nativeAdView.isHidden = false
                self.heightConstraintAd.constant = Size11NativeAdView.adHeight()
            } else {
                nativeAdView.isHidden = true
                self.heightConstraintAd.constant = 0
            }
        } else {
            nativeAdView.isHidden = true
            self.heightConstraintAd.constant = 0
        }
    }
    
    private func getData() {
        self.listItem = RealmManager.shared.getAllObjects(MovieRealm.self).reversed()
        self.collectionView.reloadData()
        setUpNativeAd()
    }
}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkTypeFavorite.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkTypeFavorite.allCases[section] {
            
        case .noData:
            return self.listItem.isEmpty == true ? 1 : 0
        case .haveData:
            return self.listItem.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkTypeFavorite.allCases[indexPath.section] {
            
        case .noData:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoDataCell.className, for: indexPath) as! NoDataCell
            cell.delegate = self
            return cell
        case .haveData:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HaveDataCell.className, for: indexPath) as! HaveDataCell
            cell.configure(with: self.listItem[indexPath.row])
            cell.delege = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch checkTypeFavorite.allCases[indexPath.section] {
        case .noData:
            break
        case .haveData:
            let check = self.listItem[indexPath.row].checkType
            let id = self.listItem[indexPath.row].id ?? 0
            switch check {
                
            case true:
                let vc = TVShowDetailVC()
                vc.getIdTVDetail(id: id)
                self.navigationController?.pushViewController(vc, animated: true)
            case false:
                let vc = MovieDetailVC()
                vc.getIdMovie(id: id )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch checkTypeFavorite.allCases[indexPath.section] {
            
        case .noData:
            return CGSize(width: collectionView.frame.width - 48, height: 351)
        case .haveData:
            let width = (collectionView.frame.width - 75) - 000000.1
            return CGSize(width: width / 3, height: (width / 3) * 3 / 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch checkTypeFavorite.allCases[section] {
            
        case .noData:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        case .haveData:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        }
    }
}

extension FavoriteViewController: FavoriteDelegate {
    func deleteFavorite(id: Int) {
        guard let item = RealmManager.shared.getById(ofType: MovieRealm.self, id: id)
        else  { return }
        RealmManager.shared.delete(object: item)
        self.getData()
    }
    
    func clickPushHomeMovies() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: TabBarViewController.className) as! TabBarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

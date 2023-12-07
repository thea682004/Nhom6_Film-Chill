//
//  AllEpisodeVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

class AllEpisodeVC: BaseVC {
    
    private var listEpisode: [ItemEpisode] = []
    private var item: ItemTVShowDetails?
    private var index: Int = 0
    private var indexSelected: Int = 0
    private var season = [Season]()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SeasonSection.className, bundle: nil), forCellWithReuseIdentifier: SeasonSection.className)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isScrollEnabled = true
            collectionView.layer.cornerRadius = 10
            collectionView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var heightAdNative: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        self.getDataEpisode(season: self.season[self.indexSelected].season_number ?? 0)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configData(item: ItemTVShowDetails?,indexSelected: Int) {
        self.item = item
        self.season = item?.seasons ?? []
        self.indexSelected = indexSelected
    }
    
    func getDataEpisode(season: Int) {
        NetworkManager.shared.getDataEpisode(endPoint: .episode(id: self.item?.id ?? 0, seasonNumber: season)) { [weak self] result, _ in
            guard let self = self, let result = result else { return }
            self.listEpisode = result
            self.collectionView.reloadData()
            self.remoteViewLoading()
        }
    }
}

extension AllEpisodeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.season.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonSection.className, for: indexPath) as! SeasonSection
        let season = self.season[indexPath.row]
        let seasonNumber = season.season_number ?? 0
        let episodeCount = season.episode_count ?? 0
        if let item = self.item {
            cell.configData(item: item, index: indexPath.row, listEpisode: self.listEpisode, indexSelected: self.indexSelected)
        }
        cell.btnSeemore.isHidden = true
        cell.heightSeemore.constant = 0
        cell.imgGradient.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.indexSelected == indexPath.row {
            self.indexSelected = -1
        } else {
            self.indexSelected = indexPath.row
        }
        
        if self.indexSelected != -1 {
            let seasonNumber = self.season[self.indexSelected].season_number ?? 0
            self.getDataEpisode(season: seasonNumber)
        }
        self.collectionView.reloadData()
    }
}

extension AllEpisodeVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.indexSelected == indexPath.row {
            let heightCell: CGFloat = CGFloat(125 * self.listEpisode.count) + 50
            return CGSize (width: collectionView.frame.width - 32, height: heightCell)
        } else {
            return CGSize (width: collectionView.frame.width - 32, height: 24)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

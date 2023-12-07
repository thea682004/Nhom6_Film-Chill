//
//  SeasonSection.swift
//  PUP001
//
//  Created by chuottp on 23/05/2023.
//

import UIKit
protocol SeasonsTvCollectionViewDelegate: AnyObject {
    func showAllSeasonButtonTapped()
}

class SeasonSection: UICollectionViewCell {
    private var indexSelected: Int = 0
    private var listSeason: [Season] = []
    private var listEpisode: [ItemEpisode] = []
    weak var delegate: TVDetailProtocol?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SeasonCell.className, bundle: nil), forCellWithReuseIdentifier: SeasonCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isScrollEnabled = false
            collectionView.layer.cornerRadius = 10
            collectionView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var btnShow: UIButton! {
        didSet {
            self.btnShow.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var imgGradient: UIImageView! {
        didSet {
            imgGradient.isHidden = true
        }
    }
    @IBOutlet weak var lblSeason: UILabel!
    @IBOutlet weak var btnSeemore: UIButton! {
        didSet {
            btnSeemore.layer.cornerRadius = 10
            btnSeemore.layer.masksToBounds = true
            self.btnSeemore.isHidden = true
            
        }
    }
    
    @IBOutlet weak var heightSeemore: NSLayoutConstraint!

    func configData(item: ItemTVShowDetails, index: Int, listEpisode: [ItemEpisode], indexSelected: Int) {
        lblSeason.customLabel(textFirst: "Season \(item.seasons?[index].season_number ?? 0)/", fontFirst: UIFont.init(name: "Poppins-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 15), textEnd: "\(item.seasons?[index].episode_count ?? 0) episode", colorFirst: UIColor(rgb: 0x272459),fontEnd: UIFont.init(name: "Poppins-SemiBold", size: 12) ?? UIFont.systemFont(ofSize: 20), colorEnd: UIColor(rgb: 0x808080))
        if listEpisode.count >= 5 {
            self.imgGradient.isHidden = false
        }else {
            imgGradient.isHidden = true
        }
        if indexSelected == index {
            self.btnSeemore.isHidden = false
            self.btnShow.setImage(UIImage(named: "showdown"), for: .normal)
//            self.imgGradient.isHidden = false
            if listEpisode.count <= 5 {
                self.btnSeemore.isHidden = true
                self.heightSeemore.constant = 0
            } else {
                self.btnSeemore.isHidden = false
                self.heightSeemore.constant = 42
            }
            self.layoutIfNeeded()
        } else {
            self.btnSeemore.isHidden = true
            self.btnShow.setImage(UIImage(named: "showup"), for: .normal)
            self.imgGradient.isHidden = true
        }
        self.listEpisode = listEpisode
        self.collectionView.reloadData()
        self.indexSelected = indexSelected
    }
    
    @IBAction func btnShow(_ sender: UIButton) {
        collectionView.isHidden = false
    }
    
    @IBAction func btnSeemore(_ sender: UIButton) {
        //action của button push viewcontroller
        self.delegate?.getAllSeason(index: self.indexSelected)
    }
}

extension SeasonSection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listEpisode.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonCell.className, for: indexPath)as! SeasonCell
        cell.configData(item: listEpisode[indexPath.row])
        return cell
    }
}

extension SeasonSection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width: collectionView.frame.width - 32 , height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 13, left: 16, bottom: 0, right: 16)
    }
}

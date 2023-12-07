//
//  SearchAddWatchlistVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

protocol SearchAddWatchlistDelegate: AnyObject {
    func pushAddWatchlist(id: Int, checkType: checkType)
}

class SearchAddWatchlistVC: BaseVC {
    
    private var checkSearch: checkType = .movie
    private var checkType: checkTypeAddWatchlist = .trending
    private var listItemTrending: [ItemMovies] = []
    private var listItemSearchMovie: [ItemSearchMovie] = []
    private var listItemSearchTV: [ItemSearchTV] = []
    private var page: Int = 1
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.backgroundImage = UIImage()
            searchBar.barTintColor = .white
            searchBar.backgroundColor = .white
            searchBar.searchTextField.backgroundColor = .clear
            searchBar.setImage(UIImage(named: "search"), for: .search, state: .normal)
            searchBar.layer.shadowColor = UIColor(rgb: 0x000000, alpha: 0.5).cgColor
            searchBar.layer.shadowOpacity = 0.2
            searchBar.layer.shadowOffset = .zero
            searchBar.layer.shadowRadius = 5
            searchBar.layer.cornerRadius = 25
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Movie, TV Show", attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xA1A1A1), NSAttributedString.Key.font: UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)])
            let inset: CGFloat = 10.0
            searchBar.searchTextPositionAdjustment = UIOffset(horizontal: inset, vertical: 0)
            searchBar.setPositionAdjustment(UIOffset(horizontal: inset - 5, vertical: 0), for: .search)
        }
    }
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerAdView: BannerAdMobView!
    @IBOutlet weak var imgNoData: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: ResultSearchSection.className, bundle: nil), forCellWithReuseIdentifier: ResultSearchSection.className)
            collectionView.register(UINib(nibName: TrendingSearchSection.className, bundle: nil), forCellWithReuseIdentifier: TrendingSearchSection.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        self.getData()
        setUpBannerAd()
        searchBar.delegate = self
        self.imgNoData.isHidden = true
        
    }
    
    private func setUpBannerAd() {
        if Global.shared.isStateShowAds == true {
            self.bannerAdView.register(id: AppText.keyAds.banner)
            self.heightConstraint.constant = BannerAdMobView.adHeightMinimum()
        } else {
            self.bannerAdView.isHidden = true
            self.heightConstraint.constant = 0
        }
    }
    
    private func isHiddenBannerWithListItem() {
        switch self.checkType {
            
        case .trending:
            self.bannerAdView.isHidden = false
        case .resultSearch:
            switch self.checkSearch {
                
            case .movie:
                if self.listItemSearchMovie.count >= 2 {
                    self.bannerAdView.isHidden = false
                    self.heightConstraint.constant = BannerAdMobView.adHeightMinimum()
                } else {
                    self.bannerAdView.isHidden = true
                    self.heightConstraint.constant = 0
                }
            case .tv:
                if self.listItemSearchTV.count >= 2 {
                    self.bannerAdView.isHidden = false
                    self.heightConstraint.constant = BannerAdMobView.adHeightMinimum()
                } else {
                    self.bannerAdView.isHidden = true
                    self.heightConstraint.constant = 0
                }
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getData() {
        NetworkManager.shared.getDataMovie(endPoint: .topRate(page: 1)) { [weak self] respone, _  in
            guard let self = self else { return }
            guard let respone = respone else { return }
            self.listItemTrending.append(contentsOf: respone)
            self.collectionView.reloadData()
            self.remoteViewLoading()
            self.isHiddenBannerWithListItem()
        }
    }
    
    func getDataMovie(query: String) {
        NetworkManager.shared.getDataSearchMovie(endPoint: .searchMovie(query: query, page: 1)) { [weak self] respone, error in
            guard let respone = respone else {
                return
            }
            self?.listItemSearchMovie = respone
            self?.collectionView.reloadData()
            self?.isHiddenBannerWithListItem()
        }
    }
    
    func getDataTV(query: String) {
        NetworkManager.shared.getDataSearchTV(endPoint: .searchTv(query: query, page: 1)) { [weak self] respone, error in
            guard let respone = respone else {
                return
            }
            self?.listItemSearchTV = respone
            self?.collectionView.reloadData()
            self?.isHiddenBannerWithListItem()
        }
    }
    
    func changeSearch(_ check: checkType) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        self.checkSearch = check
        switch checkSearch {
        case .movie:
            if listItemSearchMovie.count == 0 {
                imgNoData.isHidden = false
            } else {
                imgNoData.isHidden = true
            }
        case .tv:
            if listItemSearchTV.count == 0 {
                imgNoData.isHidden = false
            } else {
                imgNoData.isHidden = true
            }
            self.collectionView.reloadData()
            self.isHiddenBannerWithListItem()
        }
    }
}

extension SearchAddWatchlistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkTypeAddWatchlist.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkTypeAddWatchlist.allCases[section] {
            
        case .trending:
            return self.checkType == .trending ? 1 : 0
        case .resultSearch:
            return self.checkType == .resultSearch ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkTypeAddWatchlist.allCases[indexPath.section] {
            
        case .trending:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingSearchSection.className, for: indexPath) as! TrendingSearchSection
            cell.configData(item: listItemTrending)
            cell.delegate = self
            return cell
        case .resultSearch:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultSearchSection.className, for: indexPath) as! ResultSearchSection
            cell.delegate = self
            cell.configDataMovie(item: listItemSearchMovie)
            cell.configDataTV(item: listItemSearchTV)
            changeSearch(checkSearch)
            return cell
        }
    }
}

extension SearchAddWatchlistVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch checkTypeAddWatchlist.allCases[indexPath.section] {
        case .trending:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 24)
        case .resultSearch:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 48)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch checkTypeAddWatchlist.allCases[section] {
            
        case .trending:
            return UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        case .resultSearch:
            return UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        }
    }
}

extension SearchAddWatchlistVC: SearchAddWatchlistDelegate {
    func pushAddWatchlist(id: Int, checkType: checkType) {
        let vc = AddWatchlistVC()
        vc.getByID(id: id, typeData: checkType)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchAddWatchlistVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        if searchText != "" {
            self.checkType = .resultSearch
            RecentlyText.add(text: searchText)
            self.getDataMovie(query: searchText)
            self.getDataTV(query: searchText)
            // Tắt bàn phím
            self.searchBar.resignFirstResponder()
            collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.checkType = .trending
        self.collectionView.reloadData()
    }
}


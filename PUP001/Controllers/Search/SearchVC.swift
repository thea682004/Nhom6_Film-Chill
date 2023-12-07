//
//  SearchVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

protocol SearchProtocol: AnyObject {
    func changeSearch(_ check: TypeSearch)
    func pushDetailMovie(id: Int)
    func pushDetailTV(id: Int)
    func pushDetailActor(id: Int)
}

enum CheckTypeSearch: Int, CaseIterable{
    case history
    case searchData
}

class SearchVC: BaseVC {
    
    private var checkSearch: TypeSearch = .movie
    private var checkType: CheckTypeSearch = .history
    private var listItemSearchMovie: [ItemSearchMovie] = []
    private var listItemSearchTV: [ItemSearchTV] = []
    private var listItemSearchActor: [ItemSearchActor] = []
    private var isSearching: Bool = false
    
    weak var delegate: SearchProtocol?
    
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    @IBOutlet weak var imgNoData: UIImageView!
    @IBOutlet weak var topLblHistory: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: HistoryCell.className, bundle: nil), forCellWithReuseIdentifier: HistoryCell.className)
            collectionView.register(UINib(nibName: SearchDataSection.className, bundle: nil), forCellWithReuseIdentifier: SearchDataSection.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var lblClear: UILabel! {
        didSet {
            lblClear.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapClear(_:)))
            lblClear.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblCancel: UILabel! {
        didSet {
            lblCancel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapCancle(_:)))
            lblCancel.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapCancle(_ sender: UITapGestureRecognizer? = nil) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
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
            searchBar.layer.cornerRadius = 20
            
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Movie, TV Show, Actor", attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xA1A1A1), NSAttributedString.Key.font: UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)])
            let inset: CGFloat = 10.0
            searchBar.searchTextPositionAdjustment = UIOffset(horizontal: inset, vertical: 0)
            searchBar.setPositionAdjustment(UIOffset(horizontal: inset - 5, vertical: 0), for: .search)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.showAdsInter()
        }
        searchBar.delegate = self
        imgNoData.isHidden = true
        self.remoteViewLoading()
    }
    
    //add inter
    private func showAdsInter() {
        if Global.shared.isStateShowAds == true {
            AdMobManager.shared.show(key: AppText.nameAds.splashInter)
        }
    }
    
    @objc func tapClear(_ sender: UITapGestureRecognizer? = nil) {
        RecentlyText.delete(model: RecentlyText.getAll())
        collectionView.reloadData()
        
    }
    
    func getDataMovie(query: String) {
        self.listItemSearchMovie.removeAll()
        NetworkManager.shared.getDataSearchMovie(endPoint: .searchMovie(query: query, page: 1)) { [weak self] respone, error in
            guard let respone = respone else {
                return
            }
            self?.listItemSearchMovie = respone
            self?.collectionView.reloadData()
        }
    }
    
    func getDataTV(query: String) {
        self.listItemSearchTV.removeAll()
        NetworkManager.shared.getDataSearchTV(endPoint: .searchTv(query: query, page: 1)) { [weak self] respone, error in
            guard let respone = respone else {
                return
            }
            self?.listItemSearchTV = respone
            self?.collectionView.reloadData()
        }
    }
    
    func getDataActor(query: String) {
        self.listItemSearchActor.removeAll()
        NetworkManager.shared.getDataSearchActor(endPoint: .searchActor(query: query, page: 1)) { [weak self] respone, error in
            guard let respone = respone else {
                return
            }
            self?.listItemSearchActor = respone
            self?.collectionView.reloadData()
        }
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.checkType {
        case .history:
            return RecentlyText.getAll().count
        case .searchData:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkType {
        case .history:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.className, for: indexPath) as! HistoryCell
            cell.configData(item: RecentlyText.getAll().reversed()[indexPath.row].text ?? "")
            return cell
        case .searchData:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDataSection.className, for: indexPath) as! SearchDataSection
            cell.delegate = self
            switch checkSearch {
            case .movie:
                if listItemSearchMovie.count == 0 {
                    imgNoData.isHidden = false
                } else {
                    imgNoData.isHidden = true
                }
                cell.configDataMovie(item: listItemSearchMovie)
            case .tv:
                cell.configDataTV(item: listItemSearchTV)
                if listItemSearchTV.count == 0 {
                    imgNoData.isHidden = false
                } else {
                    imgNoData.isHidden = true
                }
            case .actor:
                cell.configDataActor(item: listItemSearchActor)
                if listItemSearchActor.count == 0 {
                    imgNoData.isHidden = false
                } else {
                    imgNoData.isHidden = true
                }
            }
            return cell
        }
    }
    // nhấn vào lịch sử tìm kiếm hiện lên thanh search
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearching {
            return
        }
        if checkType == .history {
            let searchText = RecentlyText.getAll().reversed()[indexPath.row].text ?? ""
            searchBar.text = searchText
            searchBarSearchButtonClicked(searchBar)
        }
    }
}

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch checkType {
        case .history:
            return CGSize(width: estimatedWidth(indexPath: indexPath),
                          height: 29.0)
        case .searchData:
            return CGSize(width: self.collectionView.frame.width, height: collectionView.frame.height - 60 - 24)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch checkType {
        case .history:
            return UIEdgeInsets(top: 16, left: 16.0, bottom: 24, right: 16)
        case .searchData:
            return UIEdgeInsets(top: 0, left: 0, bottom: 60 + 24 , right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        if(searchText != ""){
            self.checkType = .searchData
            self.lblClear.isHidden = true
            self.lblHistory.isHidden = true
            RecentlyText.add(text: searchText)
            self.getDataMovie(query: searchText)
            self.getDataTV(query: searchText)
            self.getDataActor(query: searchText)
            self.searchBar.resignFirstResponder()
            self.isSearching = false
            collectionView.reloadData()
            updateUI()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.checkType = .history
        self.imgNoData.isHidden = true
        self.lblClear.isHidden = false
        self.lblHistory.isHidden = false
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        self.isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.checkType = .history
            self.imgNoData.isHidden = true
            self.lblClear.isHidden = false
            self.lblHistory.isHidden = false
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            self.isSearching = false
            updateUI()
        } else {
            self.isSearching = true
        }
    }
    
    func updateUI() {
        heightConstraint.constant = self.checkType == .history ? 123.0 : (view.frame.height - 142.0)
        view.layoutIfNeeded()
    }
}

extension SearchVC: SearchProtocol {
    func pushDetailTV(id: Int) {
        let vc = TVShowDetailVC()
        vc.getIdTVDetail(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushDetailActor(id: Int) {
        let vc = ActorDetailsVC()
        vc.getIdActor(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushDetailMovie(id: Int) {
        let vc = MovieDetailVC()
        vc.getIdMovie(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func changeSearch(_ check: TypeSearch) {
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
        case .actor:
            if listItemSearchActor.count == 0 {
                imgNoData.isHidden = false
            } else {
                imgNoData.isHidden = true
            }
        }
        self.collectionView.reloadData()
    }
}

extension SearchVC {
    private func estimatedWidth(indexPath: IndexPath) -> CGFloat {
        print(indexPath)
        let maxWidth = collectionView.frame.width - 16.0 * 2
        let groupSpace = 10.0
        var sumWidth = 0.0
        var resultWidth = 0.0
        for index in 0...indexPath.item {
            let minWidth = minWidth(index: index)
            if sumWidth == 0.0 || sumWidth + minWidth + groupSpace > maxWidth {
                sumWidth = minWidth
            } else {
                sumWidth = sumWidth + minWidth + groupSpace
            }
            if index == indexPath.item {
                resultWidth = minWidth
            }
        }
        if indexPath.item == RecentlyText.getAll().count - 1 {
            return resultWidth
        }
        let nextWidth = minWidth(index: indexPath.item + 1)
        if sumWidth + nextWidth + groupSpace <= maxWidth {
            return resultWidth
        } else {
            return resultWidth + (maxWidth - sumWidth) - 0.0001
        }
    }
    
    private func minWidth(index: Int) -> CGFloat {
        let recently = RecentlyText.getAll().reversed()[index].text ?? String()
        let width = recently.widthText(height: 17.0, font: AppFont.getFont(fontName: .interMedium, size: 14.0)) + 38.0
        let maxWidth = collectionView.frame.width - 16.0 * 2
        return width <= maxWidth ? width : maxWidth
    }
}


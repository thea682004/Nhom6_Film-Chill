//
//  AddWatchlistVC.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
enum checkType {
    case movie
    case tv
}
protocol AddWatchlistDelegate: AnyObject {
    func pushAddSuccess()
    func popVC()
}

class AddWatchlistVC: BaseVC {
    
    var id: Int = 0
    private var type: checkType = .movie
    private var itemMovieDetail: ItemMoviesDetail?
    private var itemTVDetail: ItemTVShowDetails?
    private var listItem: AddWatchListRealm?
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: BannerAddCell.className, bundle: nil), forCellWithReuseIdentifier: BannerAddCell.className)
            collectionView.register(UINib(nibName: AddNoteCell.className, bundle: nil), forCellWithReuseIdentifier: AddNoteCell.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        self.remoteViewLoading()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            collectionView.contentInset.bottom = keyboardSize.height
            collectionView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        collectionView.contentInset = .zero
        collectionView.verticalScrollIndicatorInsets = .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func buttonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getByID(id: Int, typeData: checkType) {
        self.id = id
        self.type = typeData
        DispatchQueue.main.async {
            switch typeData {
                
            case .movie:
                self.getDataMovie()
            case .tv:
                self.getDataTV()
            }
        }
    }
    
    func configDataMovie(item: ItemMoviesDetail) {
        self.itemMovieDetail = item
        self.type = .movie
    }
    
    func configDataTV(item: ItemTVShowDetails) {
        self.itemTVDetail = item
        self.type = .tv
    }
    
    func getDataMovie() {
        NetworkManager.shared.getDataMovieDetails(endPoint: .movieDetails(id: id)) {
            item, _ in
            if let item = item {
                self.itemMovieDetail = item
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        }
    }
    
    func getDataTV() {
        NetworkManager.shared.getDataTVDetails(endPoint: .tvDetails(id: id)) {
            item, _ in
            if let item = item {
                self.itemTVDetail = item
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        }
    }
    
    func addWatchlistRealm() {
        guard let itemMovieDetail = self.itemMovieDetail,
              let id = itemMovieDetail.id
        else { return }
        let listGenres = self.convertGenres(value: itemMovieDetail.genre ?? [])
        let date = Date().asStringTime()
        let title = getTVTitle()
        let description = getTVDescription()
        let item = AddWatchListRealm(id: id,
                                     name: itemMovieDetail.title,
                                     date: date,
                                     time: itemMovieDetail.runtime,
                                     poster: itemMovieDetail.posterPath,
                                     genres: listGenres ,
                                     checkType: false,
                                     title: title,
                                     descriptionAdd: description
        )
        RealmManager.shared.create(object: item)
    }
    
    func addWatchlistRealmTV() {
        guard let itemTVDetail = self.itemTVDetail,
              let id = itemTVDetail.id
        else { return }
        let listGenres = self.convertGenres(value: itemTVDetail.genres ?? [])
        let date = Date().asStringTime()
        let time = itemTVDetail.episode_run_time?.first ?? 30
        let title = getTVTitle()
        let description = getTVDescription()
        let item = AddWatchListRealm(id: id,
                                     name: itemTVDetail.name,
                                     date: date, time: time,
                                     poster: itemTVDetail.poster_path,
                                     genres: listGenres,
                                     checkType: true,
                                     title: title,
                                     descriptionAdd: description)
        RealmManager.shared.create(object: item)
    }
    
    func convertGenres(value: [Genres]) -> [String] {
        var listName: [String] = []
        value.forEach { item in
            listName.append(item.name ?? "")
        }
        return listName
    }
}

extension AddWatchlistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkTypeAddWatchlistVC.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkTypeAddWatchlistVC.allCases[section] {
        case .bannerAdd:
            return 1
        case .addNote:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkTypeAddWatchlistVC.allCases[indexPath.section] {
        case .bannerAdd:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerAddCell.className, for: indexPath) as! BannerAddCell
            if type == .movie {
                cell.configDataDetailMovie(item: itemMovieDetail)
            } else {
                cell.configDataDetailTV(item: itemTVDetail)
            }
            return cell
        case .addNote:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNoteCell.className, for: indexPath) as! AddNoteCell
            cell.delegate = self
            cell.configData(item: listItem)
            return cell
        }
    }
}

extension AddWatchlistVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch checkTypeAddWatchlistVC.allCases[section] {
        case .bannerAdd:
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        case .addNote:
            return UIEdgeInsets(top: 32, left: 16, bottom: 0, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthVC = collectionView.frame.width - 32
        switch checkTypeAddWatchlistVC.allCases[indexPath.section] {
        case .bannerAdd:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: widthVC, height: 420)
            } else {
                return CGSize(width: widthVC, height: 210)
            }
        case .addNote:
            return CGSize(width: widthVC, height: 500)
        }
    }
}

extension AddWatchlistVC: AddWatchlistDelegate {
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pushAddSuccess() {
        let addWatchlistView = AddWatchListView.initFromNib()
        addWatchlistView.frame = self.view.frame
        view.addSubview(addWatchlistView)
        if type == .movie {
            self.addWatchlistRealm()
        } else {
            self.addWatchlistRealmTV()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.navigationController?.popViewController(animated: true)
            addWatchlistView.removeFromSuperview()
        })
    }
}

extension AddWatchlistVC: AddNoteCellDelegate {
    func getTVDescription() -> String? {
        guard let addNoteCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? AddNoteCell else {
            return nil
        }
        return addNoteCell.getTVDescription()
    }
    
    func getTVTitle() -> String? {
        guard let addNoteCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? AddNoteCell else {
            return nil
        }
        return addNoteCell.getTVTitle()
    }
}




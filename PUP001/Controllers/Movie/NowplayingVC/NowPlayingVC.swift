//
//  NowPlayingVC.swift
//  PUP001
//
//  Created by chuottp on 08/06/2023.
//

import UIKit
import AdMobManager

protocol ShowAllProtocol: AnyObject {
    func clickPushTVDetail(id: Int)
    func clickPushDetail(id: Int)
}

class NowPlayingVC: BaseVC {
    
    var id: Int = 0
    private var textHeader: String = ""
    private var page: Int = 1
    private var listItemNowPlaying: [ItemMovies] = []
    private var listItemUpComing: [ItemMovies] = []
    private var listItemTopRate: [ItemMovies] = []
    private var listItemPopularActor: [ItemActors] = []
    private var listItemPopularMovies: [ItemMovies] = []
    private var listItemGenresID: [ItemGenresID] = []
    private var listItemGenresIDTV: [ItemGenresIDTV] = []
    private var listItemTopRateTV: [ItemTVShow] = []
    private var listItemAiringTodayTV: [ItemTVShow] = []
    private var listItemGenres: [Genre] = []
    private var listItemGenresTV: [Genre] = []
    private var listItemPopularTV: [ItemTVShow] = []
    private var listItemOnTV: [ItemTVShow] = []
    
    private var checkType: AllCheckType = .NowPlaying
    
    @IBOutlet weak var heightAdNative: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: Size11NativeAdView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: AllNowPlayingSection.className, bundle: nil), forCellWithReuseIdentifier: AllNowPlayingSection.className)
            collectionView.register(UINib(nibName: GenresCell.className, bundle: nil), forCellWithReuseIdentifier: GenresCell.className)
            collectionView.register(UINib(nibName: AllPopularActors.className, bundle: nil), forCellWithReuseIdentifier: AllPopularActors.className)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    func getIdGenres(id: Int, name: String) {
        self.id = id
        self.textHeader = name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViewLoading()
        setUpAdNative()
        self.getData()
        switch checkType {
        case .Genres, .GenresTV:
            self.lblTitle.text = textHeader
            let layout = TagFlowLayout()
            layout.estimatedItemSize = CGSize(width: 140, height: 30)
            collectionView.collectionViewLayout = layout
        default:
            self.lblTitle.text = textHeader
        }
    }
    
    func setUpAdNative() {
        if Global.shared.isStateShowAds == true {
            nativeAdView.register(id: AppText.keyAds.native)
            nativeAdView.changeLoading(color: .black)
            nativeAdView.changeColor(border: .black, title: .black, ad: .white, adBackground: .black, body: .black)
            self.heightAdNative.constant = Size11NativeAdView.adHeight()
            self.nativeAdView.isHidden = false
        } else {
            self.heightAdNative.constant = 0
            self.nativeAdView.isHidden = true
        }
    }
    
    func setType(_ type: AllCheckType) {
        self.checkType = type
        switch type {
            
        case .Genres:
            self.textHeader = "Genres"
        case .PopularActor:
            self.textHeader = "Popular Actors"
        case .Upcoming:
            self.textHeader = "Upcoming"
        case .Recommend:
            self.textHeader = "Recommend"
        case .NowPlaying:
            self.textHeader = "Now Playing"
        case .PopularMovies:
            self.textHeader = "Popular Movies"
        case .PopularMoviesTV:
            self.textHeader = "Popular Movies"
        case .GenresTV:
            self.textHeader = "Genres"
        case .PopularActorTV:
            self.textHeader = "Popular Actors"
        case .UpcomingTV:
            self.textHeader = "Upcoming"
        case .RecommendTV:
            self.textHeader = "Recommend"
        case .NowPlayingTV:
            self.textHeader = "Now Playing"
        case .listGenresMovie:
            break
        case .listGenresTv:
            break
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getData(page: Int = 1) {
        switch checkType {
        case .PopularMovies:
            NetworkManager.shared.getDataMovie(endPoint: .popular(page: page)) { [weak self] respone, _ in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemPopularMovies.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .Genres:
            NetworkManager.shared.getDataGenre(endPoint: .genres){
                [weak self] respone, _ in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemGenres.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .PopularActor, .PopularActorTV:
            NetworkManager.shared.getDataActor(endPoint: .popularActor(page: page)) { [weak self] respone, _ in
                guard let self = self else { return }
                guard let respone = respone else {
                    return
                }
                self.listItemPopularActor.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .Upcoming:
            NetworkManager.shared.getDataMovie(endPoint: .upComing(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemUpComing.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .Recommend:
            NetworkManager.shared.getDataMovie(endPoint: .topRate(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemTopRate.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .NowPlaying:
            NetworkManager.shared.getDataMovie(endPoint: .nowplaying(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemNowPlaying.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .PopularMoviesTV:
            NetworkManager.shared.getDataTV(endPoint: .popularTv(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemPopularTV.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .GenresTV:
            NetworkManager.shared.getDataGenre(endPoint: .genresTv){
                [weak self] respone, _ in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemGenresTV.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .UpcomingTV:
            NetworkManager.shared.getDataTV(endPoint: .onTv(page: page)) { [weak self] respone, _ in
                guard let respone = respone else { return }
                self?.listItemOnTV.append(contentsOf: respone)
                self?.collectionView.reloadData()
                self?.remoteViewLoading()
            }
        case .RecommendTV:
            NetworkManager.shared.getDataTV(endPoint: .tvTopRate(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemTopRateTV.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .NowPlayingTV:
            NetworkManager.shared.getDataTV(endPoint: .tvAiringToday(page: page)) { [weak self] respone, _  in
                guard let self = self else { return }
                guard let respone = respone else { return }
                self.listItemAiringTodayTV.append(contentsOf: respone)
                self.collectionView.reloadData()
                self.remoteViewLoading()
            }
        case .listGenresMovie:
            NetworkManager.shared.getDataGenresID(endPoint: .genresId(page: page, withGenres: self.id)) { [weak self] respone, _ in
                guard let respone = respone else {return}
                self?.listItemGenresID.append(contentsOf: respone)
                self?.collectionView.reloadData()
                self?.remoteViewLoading()
            }
        case .listGenresTv:
            NetworkManager.shared.getDataGenresIDTV(endPoint: .genresIdTV(page: page, withGenres: self.id)) { [weak self] respone, _ in
                guard let respone = respone else {return}
                self?.listItemGenresIDTV.append(contentsOf: respone)
                self?.collectionView.reloadData()
                self?.remoteViewLoading()
            }
        }
    }
    
    func updateNextSet(){
        page += 1
        switch checkType {
        case .Genres, .GenresTV:
            break
        case .PopularActor, .Upcoming, .Recommend, .PopularMovies, .NowPlaying, .PopularMoviesTV, .PopularActorTV, .UpcomingTV, .RecommendTV, .NowPlayingTV, .listGenresMovie, .listGenresTv:
            self.getData(page: page)
        }
    }
}

extension NowPlayingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            updateNextSet()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkType {
            
        case .Genres:
            return self.listItemGenres.count
        case .PopularActor:
            return self.listItemPopularActor.count
        case .Upcoming:
            return self.listItemUpComing.count
        case .Recommend:
            return self.listItemTopRate.count
        case .NowPlaying:
            return self.listItemNowPlaying.count
        case .PopularMovies:
            return self.listItemPopularMovies.count
        case .PopularMoviesTV:
            return self.listItemPopularTV.count
        case .GenresTV:
            return self.listItemGenresTV.count
        case .PopularActorTV:
            return self.listItemPopularActor.count
        case .UpcomingTV:
            return self.listItemOnTV.count
        case .RecommendTV:
            return self.listItemTopRateTV.count
        case .NowPlayingTV:
            return self.listItemAiringTodayTV.count
        case .listGenresMovie:
            return self.listItemGenresID.count
        case .listGenresTv:
            return self.listItemGenresIDTV.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkType {
            
        case .Genres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresCell.className, for: indexPath) as! GenresCell
            cell.configData(item: self.listItemGenres[indexPath.row])
            return cell
        case .PopularActor:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllPopularActors.className, for: indexPath) as! AllPopularActors
            cell.configureData(item: self.listItemPopularActor[indexPath.row])
            return cell
        case .Upcoming:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraData(item: self.listItemUpComing[indexPath.row])
            return cell
        case .Recommend:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraData(item: self.listItemTopRate[indexPath.row])
            return cell
        case .NowPlaying:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraData(item: self.listItemNowPlaying[indexPath.row])
            return cell
        case .PopularMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraData(item: self.listItemPopularMovies[indexPath.row])
            return cell
        case .PopularMoviesTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraDataTV(item: self.listItemPopularTV[indexPath.row])
            return cell
        case .GenresTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresCell.className, for: indexPath) as! GenresCell
            cell.configData(item: self.listItemGenresTV[indexPath.row])
            return cell
        case .PopularActorTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllPopularActors.className, for: indexPath) as! AllPopularActors
            cell.configureData(item: self.listItemPopularActor[indexPath.row])
            return cell
        case .UpcomingTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraDataTV(item: self.listItemOnTV[indexPath.row])
            return cell
        case .RecommendTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraDataTV(item: self.listItemTopRateTV[indexPath.row])
            return cell
        case .NowPlayingTV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraDataTV(item: self.listItemAiringTodayTV[indexPath.row])
            return cell
        case .listGenresMovie:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraGenresMovie(item: self.listItemGenresID[indexPath.row])
            return cell
        case .listGenresTv:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNowPlayingSection.className, for: indexPath) as! AllNowPlayingSection
            cell.configuraGenresTV(item: self.listItemGenresIDTV[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch checkType {
            
        case .PopularMovies:
            let movieDetailsVC = MovieDetailVC()
            movieDetailsVC.getIdMovie(id: listItemPopularMovies[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        case .Genres:
            let showAllGenresVC = NowPlayingVC()
            showAllGenresVC.getIdGenres(id: self.listItemGenres[indexPath.row].id,
                                        name: self.listItemGenres[indexPath.row].name)
            showAllGenresVC.checkType = .listGenresMovie
            self.navigationController?.pushViewController(showAllGenresVC, animated: true)
        case .PopularActor:
            let actorDetailsVc = ActorDetailsVC()
            actorDetailsVc.getIdActor(id: listItemPopularActor[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(actorDetailsVc, animated: true)
        case .Upcoming:
            let movieDetailsVC = MovieDetailVC()
            movieDetailsVC.getIdMovie(id: listItemUpComing[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        case .Recommend:
            let movieDetailsVC = MovieDetailVC()
            movieDetailsVC.getIdMovie(id: listItemTopRate[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        case .NowPlaying:
            let movieDetailsVC = MovieDetailVC()
            movieDetailsVC.getIdMovie(id: listItemNowPlaying[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        case .PopularMoviesTV:
            let tvshowDetailsVC = TVShowDetailVC()
            tvshowDetailsVC.getIdTVDetail(id: listItemPopularTV[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(tvshowDetailsVC, animated: true)
        case .GenresTV:
            let showAllGenresVC = NowPlayingVC()
            showAllGenresVC.getIdGenres(id: self.listItemGenresTV[indexPath.row].id,
                                        name: self.listItemGenresTV[indexPath.row].name)
            showAllGenresVC.checkType = .listGenresTv
            self.navigationController?.pushViewController(showAllGenresVC, animated: true)
        case .PopularActorTV:
            let actorDetailsVc = ActorDetailsVC()
            actorDetailsVc.getIdActor(id: listItemPopularActor[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(actorDetailsVc, animated: true)
        case .UpcomingTV:
            let tvshowDetailsVC = TVShowDetailVC()
            tvshowDetailsVC.getIdTVDetail(id: listItemOnTV[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(tvshowDetailsVC, animated: true)
        case .RecommendTV:
            let tvshowDetailsVC = TVShowDetailVC()
            tvshowDetailsVC.getIdTVDetail(id: listItemTopRateTV[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(tvshowDetailsVC, animated: true)
        case .NowPlayingTV:
            let tvshowDetailsVC = TVShowDetailVC()
            tvshowDetailsVC.getIdTVDetail(id: listItemAiringTodayTV[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(tvshowDetailsVC, animated: true)
        case .listGenresMovie:
            let movieDetailsVC = MovieDetailVC()
            movieDetailsVC.getIdMovie(id: listItemGenresID[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        case .listGenresTv:
            let movieDetailsVC = TVShowDetailVC()
            movieDetailsVC.getIdTVDetail(id: listItemGenresIDTV[indexPath.row].id ?? 0)
            self.navigationController?.pushViewController(movieDetailsVC, animated: true)
        }
    }
}

extension NowPlayingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthVC = collectionView.frame.width - 26
        switch checkType {
        case .Genres:
            let genres = listItemGenres[indexPath.section]
            let nameGenres = genres.name
            let widthName = nameGenres.widthText(height: 17, font: UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14))
            return CGSize(width: 80 + widthName + 5.0 , height: 60)
        case .PopularActor:
            return CGSize(width: widthVC / 3 - 0.00001, height: 134)
        case .Upcoming:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .Recommend:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .NowPlaying:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .PopularMovies:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .PopularMoviesTV:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .GenresTV:
            let genres = listItemGenresTV[indexPath.section]
            let nameGenres = genres.name
            let widthName = nameGenres.widthText(height: 17, font: UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14))
            return CGSize(width: 80 + widthName + 5.0 , height: 60)
        case .PopularActorTV:
            return CGSize(width: widthVC / 3 - 0.00001, height: 134)
        case .UpcomingTV:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .RecommendTV:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        case .NowPlayingTV, .listGenresMovie, .listGenresTv:
            return CGSize(width: widthVC / 3 - 0.00001, height: 200)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch checkType {
            
        case .Genres:
            return CGFloat(4.0)
        case .PopularActor:
            return CGFloat(13)
        case .Upcoming:
            return CGFloat(13)
        case .Recommend:
            return CGFloat(13)
        case .NowPlaying:
            return CGFloat(13)
        case .PopularMovies:
            return CGFloat(13)
        case .PopularMoviesTV:
            return CGFloat(13)
        case .GenresTV:
            return CGFloat(4.0)
        case .PopularActorTV:
            return CGFloat(13)
        case .UpcomingTV:
            return CGFloat(13)
        case .RecommendTV:
            return CGFloat(13)
        case .NowPlayingTV , .listGenresMovie, .listGenresTv:
            return CGFloat(13)
        }
    }
}

extension NowPlayingVC: ShowAllProtocol {
    func clickPushDetail(id: Int) {
        let vc = MovieDetailVC()
        vc.getIdMovie(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPushTVDetail(id: Int) {
        let vc = TVShowDetailVC()
        vc.getIdTVDetail(id: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



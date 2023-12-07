//
//  TrackingViewController.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//

import UIKit
import AdMobManager

protocol TrackingDelegate: AnyObject {
    func deleteFavorite(id: Int)
    func pushSearchAddWatchlist()
    func showWeek()
    func showMonth()
    func showYear()
    func didSelectYear(year: Int)
    func didSelectMonth(month: Int)
    func didSelectWeek(week: Int)
}

class TrackingViewController: BaseVC {
    
    private var listItem: [ItemChart] = []
    private var checkType: CheckTypeTimeRane = .year
    private let pickDateView = ShowDateView.initFromNib() as! ShowDateView
    private var yearSelected: Int = Date().getYear()
    private var monthSelected: Int?
    private var weekSelected: Int?
    private var listXName: [Int] = []
    
    @IBOutlet weak var heightConstraintAd: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: Size11NativeAdView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: NoDataChartSection.className, bundle: nil), forCellWithReuseIdentifier: NoDataChartSection.className)
            collectionView.register(UINib(nibName: TimeRangeSection.className, bundle: nil), forCellWithReuseIdentifier: TimeRangeSection.className)
            collectionView.register(UINib(nibName: ActivityGenresSection.className, bundle: nil), forCellWithReuseIdentifier: ActivityGenresSection.className)
            collectionView.register(UINib(nibName: TotalTimeSection.className, bundle: nil), forCellWithReuseIdentifier: TotalTimeSection.className)
            collectionView.register(UINib(nibName: ItemSection.className, bundle: nil), forCellWithReuseIdentifier: ItemSection.className)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.didSelectYear(year: yearSelected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listItemFiltered()
    }
    
    func setUpNativeAd() {
        if Global.shared.isStateShowAds == true {
            self.nativeAdView.isHidden = false
            nativeAdView.register(id: AppText.keyAds.native)
            nativeAdView.changeLoading(color: .black)
            nativeAdView.changeColor(border: .black, title: .black, ad: .white, adBackground: .black, body: .black)
            self.heightConstraintAd.constant = Size11NativeAdView.adHeight()
        } else {
            self.nativeAdView.isHidden = true
            self.heightConstraintAd.constant = 0
        }
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        let vc = SearchAddWatchlistVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TrackingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkTypeTracking.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch checkTypeTracking.allCases[section] {
            
        case .noWatchlist:
            return self.getAll().isEmpty ? 1 : 0
        case .timeRange, .total, .activityGenres:
            return !self.getAll().isEmpty ? 1 : 0
        case .itemMovie:
            return self.listItem.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch checkTypeTracking.allCases[indexPath.section] {
            
        case .noWatchlist:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoDataChartSection.className, for: indexPath) as! NoDataChartSection
            cell.delegate = self
            return cell
        case .timeRange:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeRangeSection.className, for: indexPath) as! TimeRangeSection
            cell.setTextYear(year: self.yearSelected, month: self.monthSelected, week: self.weekSelected)
            cell.delegate = self
            return cell
        case .activityGenres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityGenresSection.className, for: indexPath) as! ActivityGenresSection
            cell.filterData(listItem: listXName, type: checkType)
            return cell
        case .total:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TotalTimeSection.className, for: indexPath) as! TotalTimeSection
            cell.setUpData(listXName: listXName, type: checkType)
            return cell
        case .itemMovie:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemSection.className, for: indexPath) as! ItemSection
            cell.configData(item: listItem[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

extension TrackingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCV = collectionView.frame.width - 48
        switch checkTypeTracking.allCases[indexPath.section] {
            
        case .noWatchlist:
            return CGSize(width: widthCV, height: 351)
        case .timeRange:
            return CGSize(width: widthCV, height: 300)
        case .activityGenres:
            return CGSize(width: widthCV, height: 515)
        case .total:
            return CGSize(width: widthCV, height: 409)
        case .itemMovie:
            return estimateHeightCell(listItem, widthCV, indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch checkTypeTracking.allCases[section] {
            
        case .noWatchlist:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        case .timeRange:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        case .activityGenres:
            return UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24)
        case .total:
            return UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24)
        case .itemMovie:
            return UIEdgeInsets(top: 24, left: 24, bottom: 12, right: 24)
        }
    }
}

extension TrackingViewController: TrackingDelegate {
    
    func showYear() {
        self.pickDateView.frame = self.view.frame
        let minY = self.getLocationYear()
        pickDateView.getData()
        pickDateView.setIndexSelected(value: self.yearSelected)
        pickDateView.delegate = self
        pickDateView.setTop(value: minY)
        view.addSubview(pickDateView)
    }
    
    func showWeek() {
        pickDateView.frame = self.view.frame
        let minY = self.getLocation()
        pickDateView.getData(setTypeData: .week)
        pickDateView.setIndexSelected(value: self.weekSelected)
        pickDateView.delegate = self
        pickDateView.setTop(value: minY)
        view.addSubview(pickDateView)
    }
    
    func showMonth() {
        pickDateView.frame = self.view.frame
        let minY = self.getLocationMonth()
        pickDateView.getData(setTypeData: .month)
        pickDateView.setIndexSelected(value: self.monthSelected)
        pickDateView.delegate = self
        pickDateView.setTop(value: minY)
        view.addSubview(pickDateView)
    }
    
    func pushSearchAddWatchlist() {
        let vc = SearchAddWatchlistVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteFavorite(id: Int) {
        guard let item = RealmManager.shared.getById(ofType: AddWatchListRealm.self, id: id)
        else {return}
        RealmManager.shared.delete(object: item)
        self.listItemFiltered()
    }
    
    func didSelectYear(year: Int) {
        ChartManager.shared.changeYearState(yearState: year)
        self.checkType = .year
        self.yearSelected = year
        self.monthSelected = nil
        self.weekSelected = nil
        self.listXName = ChartManager.shared.filterMonth()
        listItemFiltered()
    }
    
    func didSelectMonth(month: Int) {
        ChartManager.shared.changeMonthState(monthState: month)
        self.checkType = .month
        self.weekSelected = nil
        self.monthSelected = month
        self.listXName = ChartManager.shared.filterWeek()
        listItemFiltered()
    }
    
    func didSelectWeek(week: Int) {
        ChartManager.shared.changeWeekState(weekState: week)
        self.checkType = .week
        self.weekSelected = week
        self.listXName = ChartManager.shared.filterDay()
        listItemFiltered()
    }
}

extension TrackingViewController {
    
    private func listItemFiltered() {
        var dates: [Date] = []
        if let weekSelected = weekSelected {
            dates = ChartManager.shared.getDateByWeek(weekSelected)
            self.listItem = ChartManager.shared.filterNoteBy(dates: dates)
        } else if let monthSelected = monthSelected {
            dates = ChartManager.shared.getDateByMonth(monthSelected)
            self.listItem = ChartManager.shared.filterNoteBy(dates: dates)
        } else {
            self.listItem = ChartManager.shared.getItemInYear(yearSelected)
        }
        checkHiddenAd()
        collectionView.reloadData()
    }
    
    private func checkHiddenAd() {
        if Global.shared.isStateShowAds == true {
            if !self.listItem.isEmpty {
                setUpNativeAd()
                self.heightConstraintAd.constant = Size11NativeAdView.adHeight()
            }
            else {
                self.nativeAdView.isHidden = true
                self.heightConstraintAd.constant = 0
            }
        } else {
            self.nativeAdView.isHidden = true
            self.heightConstraintAd.constant = 0
        }
    }
    
    private func getAll() -> [AddWatchListRealm] {
        let items = RealmManager.shared.getAllObjects(AddWatchListRealm.self)
        btnAdd.isHidden = items.isEmpty
        return items
    }
}

//MARK: Estimate height cell
extension TrackingViewController {
    private func estimateHeightCell(_ listItem: [ItemChart],_ widthCV: CGFloat,_ indexPath: IndexPath) -> CGSize {
        if !listItem.isEmpty {
            let heightTitle = listItem[indexPath.row].title?.heightText(width: widthCV, font: UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)) ?? 14
            let heightNote = listItem[indexPath.row].description?.heightText(width: widthCV, font: UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)) ?? 14
            let spaceCell: CGFloat = 140
            let totalHeightCell = heightTitle + heightNote + spaceCell
            return CGSize(width: widthCV, height: totalHeightCell )
        } else {
            return CGSize()
        }
    }
    
    private func getLocation() -> CGFloat {
        let stateMinY = 44.0 + 16.0 + 51.0 + 16.0 + (223.0 - 20.0) + view.safeAreaInsets.top - collectionView.contentOffset.y
        return stateMinY
    }
    
    private func getLocationMonth() -> CGFloat {
        let stateMinY = 44.0 + 16.0 + 51.0 + 16.0 + (223.0 - 12.0 - 42.0 - 20.0) + view.safeAreaInsets.top - collectionView.contentOffset.y
        return stateMinY
    }
    
    private func getLocationYear() -> CGFloat {
        let stateMinY = 44.0 + 16.0 + 51.0 + 16.0 + (223.0 - 12.0 - 42.0 - 20.0 - 42.0 - 12.0) + view.safeAreaInsets.top - collectionView.contentOffset.y
        return stateMinY
    }
}

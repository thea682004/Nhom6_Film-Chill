//
//  ShowDateView.swift
//  PUP001
//
//  Created by chuottp on 26/06/2023.
//

import UIKit

enum CheckTypeTimeRane {
    case year
    case month
    case week
}

class ShowDateView: UIView {
    
    weak var delegate: TrackingDelegate?
    private var listItem: [Int] = []
    private var checkType: CheckTypeTimeRane = .year
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0).cgColor
            view.layer.borderWidth = 1.0
            
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: ShowDateCell.className, bundle: nil), forCellWithReuseIdentifier: ShowDateCell.className)
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    @IBOutlet weak var lblSelect: UILabel!
    
    @IBOutlet weak var imgCancle: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCancelTap))
            imgCancle.addGestureRecognizer(tapGesture)
            imgCancle.isUserInteractionEnabled = true
        }
    }
    
    @objc private func handleCancelTap() {
        self.removeFromSuperview()
        
    }
    private var indexSelected: Int = -1
    
    func setTop(value: CGFloat) {
        self.topConstraint.constant = value
        self.layoutIfNeeded()
    }
    
    func setIndexSelected(value: Int?) {
        if let index = self.listItem.firstIndex(of: value ?? 0).map({ Int($0) }) {
            self.indexSelected = index
            self.collectionView.reloadData()
        }
    }
    
    private func setTypeSelectedLabel() {
        switch checkType {
        case .year:
            lblSelect.text = "Select year"
        case .month:
            lblSelect.text = "Select month"
        case .week:
            lblSelect.text = "Select week"
        }
    }
    
    func getData(setTypeData: CheckTypeTimeRane = .year) {
        self.checkType = setTypeData
        self.listItem.removeAll()
        switch checkType {
        case .year:
            let yearNow = Date().getYear()
            ChartManager.shared.changeYearState(yearState: yearNow)
            self.listItem = ChartManager.shared.filterYear().reversed()
        case .month:
            let monthNow = Date().getMonth()
            ChartManager.shared.changeMonthState(monthState: monthNow)
            self.listItem = ChartManager.shared.filterMonth()
        case .week:
            let weekNow = Date().getWeek()
            ChartManager.shared.changeWeekState(weekState: weekNow)
            self.listItem = ChartManager.shared.filterWeek()
        }
        self.setTypeSelectedLabel()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension ShowDateView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowDateCell.className, for: indexPath) as! ShowDateCell
        
        if self.indexSelected == indexPath.row {
            cell.backgroundColor = UIColor(rgb: 0x02356E, alpha: 0.1)
        } else {
            cell.backgroundColor = .white
        }
        switch self.checkType {
            
        case .year:
            cell.configureDataYear(year: self.listItem[indexPath.row])
        case .month:
            cell.configureDataMonth(month: self.listItem[indexPath.row])
        case .week:
            cell.configureDataWeek(week: self.listItem[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.checkType {
            
        case .year:
            let selectedYear = self.listItem[indexPath.row]
            delegate?.didSelectYear(year: selectedYear)
        case .month:
            let selectedMonth = self.listItem[indexPath.row]
            delegate?.didSelectMonth(month: selectedMonth)
        case .week:
            let selectedWeek = self.listItem[indexPath.row]
            delegate?.didSelectWeek(week: selectedWeek)
        }
        self.removeFromSuperview()
    }
}

extension ShowDateView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 39)
    }
    
}



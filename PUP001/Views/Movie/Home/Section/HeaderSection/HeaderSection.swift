//
//  HeaderSection.swift
//  PUP001
//
//  Created by chuottp on 09/05/2023.
//

import UIKit

enum checkTab {
    case movie
    case tv
}

class HeaderSection: UICollectionViewCell {
    
   
    @IBOutlet weak var lblDoYou: UILabel!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    @IBAction func touchPush(_ sender: Any) {
        guard let topVC = UIApplication.topStackViewController() else {
            return
        }
        let vc = SearchVC()
        topVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setText(check: checkTab) {
        switch check {
        case .movie:
            self.lblDoYou.text = "Do you want to watch movies?"
        case .tv:
            self.lblDoYou.text = "Do you want to watch TV Show?"
        }
    }
}




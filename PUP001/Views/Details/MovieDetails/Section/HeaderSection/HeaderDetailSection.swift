//
//  HeaderDetailSection.swift
//  PUP001
//
//  Created by chuottp on 12/05/2023.
//

import UIKit
import YouTubePlayer
import SDWebImage


class HeaderDetailSection: UICollectionViewCell {
    
    private var keyYT: String = ""
    var playVideo: ((String) -> (Void))?
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lblRunTime: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVoteAverage: UILabel!
    @IBOutlet weak var lblVoteCount: UILabel!
    @IBOutlet weak var imgBanner: UIImageView! {
        didSet {
            imgBanner.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            imgBanner.layer.cornerRadius = 24.0
        }
    }
    
    @IBOutlet weak var imgPlay: UIImageView! {
        didSet {
            imgPlay.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.playTrailer(_:)))
            imgPlay.addGestureRecognizer(tap)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.gradient()
    }
    
    @objc func playTrailer(_ sender: UITapGestureRecognizer? = nil) {
        print("Tap")
        self.playVideo?(self.keyYT)
        
    }
   
    func configData(item: ItemMoviesDetail?) {
        self.keyYT = item?.videos.results.first?.key ?? ""
        self.imgBanner.loadImage(link: item?.posterPath)
        self.lblName.text = item?.title
        self.lblVoteCount.text = "(" + String(item?.voteCount ?? 0) + "K)"
        self.lblVoteAverage.text = String(format: "%0.1f", item?.voteAverage ?? 0)
        if item?.runtime?.timeString() == nil {
            lblRunTime.text = ""
        } else {
            lblRunTime.text = "•   " + (item?.runtime?.timeString() ?? "")
        }
        if let releaseDate = item?.releaseDate {
                let year = getYearFromDate(dateString: releaseDate)
                lblYear.text = (year != nil) ? "\(year!)   •" : ""
            } else {
                lblYear.text = ""
            }
        var itemsGenres: [String] = []
        item?.genre?.forEach({ item in
            itemsGenres.append(item.name ?? "")
        })
        lblGenre.text = GenresService.shared.getString(array: itemsGenres , maxCount: 2)
        
    }
    
    func configDataTV(item: ItemTVShowDetails?) {
        self.imgBanner.loadImage(link: item?.poster_path ?? "")
        self.lblName.text = item?.name
        self.lblVoteCount.text = "(" + String(item?.vote_count ?? 0) + "K)"
        self.lblVoteAverage.text = String(format: "%0.1f", item?.vote_average ?? 0)
        if item?.episode_run_time?.first?.timeString() == nil {
            lblRunTime.text = ""
        } else {
            lblRunTime.text = "•   " + (item?.episode_run_time?.first?.timeString() ?? "")
        }
        if let airDate = item?.last_episode_to_air?.air_date {
                let year = getYearFromDate(dateString: airDate)
                lblYear.text = (year != nil) ? "\(year!)   •" : ""
            } else {
                lblYear.text = ""
            }
        var itemGenre: [String] = []
        item?.genres?.forEach({item in
            itemGenre.append(item.name ?? "")
        })
        lblGenre.text = GenresService.shared.getString(array: itemGenre, maxCount: 2)
    }
    
    func getYearFromDate(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Đặt định dạng phù hợp với chuỗi ngày tháng của bạn

        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            return String(year)
        } else {
            return nil
        }
    }
    
    func gradient() {
        let layer0 = CAGradientLayer()
        
        layer0.frame = self.imgBanner.frame
        layer0.colors = [
            UIColor(rgb: 0x000000, alpha: 0).cgColor,
            UIColor(rgb: 0x000000, alpha: 0.5).cgColor
        ]
        layer0.startPoint = CGPoint(x: 0, y: 0)
        layer0.endPoint = CGPoint(x: 0, y: 1)
        imgBanner.layer.addSublayer(layer0)
    }
}

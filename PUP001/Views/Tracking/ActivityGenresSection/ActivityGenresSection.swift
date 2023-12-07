import UIKit
import Charts
import MBCircularProgressBar

class ActivityGenresSection: UICollectionViewCell {
    
    @IBOutlet weak var lblPercentPurple: UILabel!
    @IBOutlet weak var lblPercentPink: UILabel!
    @IBOutlet weak var lblPercentRed: UILabel!
    @IBOutlet weak var lblTotalFilmPurple: UILabel!
    @IBOutlet weak var lblTotalFilmPink: UILabel!
    @IBOutlet weak var lblTotalFilmRed: UILabel!
    @IBOutlet weak var lblPinkGenre: UILabel!
    @IBOutlet weak var lblPurpleGenre: UILabel!
    @IBOutlet weak var lblRedGenre: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var redProgessView: MBCircularProgressBarView!
    @IBOutlet weak var PinkProgessView: MBCircularProgressBarView!
    @IBOutlet weak var purpleProgessView: MBCircularProgressBarView!
    
    @IBOutlet weak var viewPurple: UIView! {
        didSet {
            viewPurple.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var viewPink: UIView! {
        didSet {
            viewPink.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var viewRed: UIView! {
        didSet {
            viewRed.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    private func setUpUI() {
        self.PinkProgessView.showValueString = false
            self.redProgessView.showValueString = false
            self.purpleProgessView.showValueString = false
            redProgessView.maxValue = 100.0
            PinkProgessView.maxValue = 100.0
            purpleProgessView.maxValue = 100.0
            redProgessView.transform = CGAffineTransform(rotationAngle: .pi)
            PinkProgessView.transform = CGAffineTransform(rotationAngle: .pi)
            purpleProgessView.transform = CGAffineTransform(rotationAngle: .pi)
        
    }
    
    func filterData(listItem: [Int] ,type: CheckTypeTimeRane) {
        var dates: [Date] = []
        var genresFilted: (genreItem: [(genres: EnumGenres, count: Int)], sum: Int, totalMovie: Int) = ([],0,0)
        switch type {
        case .week:
            for index in 0..<listItem.count {
                dates += ChartManager.shared.getDateByDay(listItem[index])
            }
        case .month:
            for index in 0..<listItem.count {
                dates += ChartManager.shared.getDateByWeek(listItem[index])
            }
        case .year:
            
            for index in 0..<listItem.count {
                dates += ChartManager.shared.getDateByMonth(listItem[index])
            }
        }
        print(dates)
        genresFilted = ChartManager.shared.filterGenres(dates: dates)
       
        getTotalFilm(genresFilted.totalMovie)
        let topGenres = getTopGenres(genresFilted.genreItem)
        getGenres(topGenres.0, topGenres.1, topGenres.2, genresFilted: genresFilted)
        
        let percentGenre1 = genresFilted.genreItem.indices.contains(0) ? "\(Int(Double(genresFilted.genreItem[0].count) / Double(genresFilted.sum) * 100))%" : "0"
        let percentGenre2 = genresFilted.genreItem.indices.contains(1) ? "\(Int(Double(genresFilted.genreItem[1].count) / Double(genresFilted.sum) * 100))%" : "0"
        let percentGenre3 = genresFilted.genreItem.indices.contains(2) ? "\(Int(Double(genresFilted.genreItem[2].count) / Double(genresFilted.sum) * 100))%" : "0"

        
        getPercentGenres(percentGenre1, percentGenre2, percentGenre3)
    }
    
    private func getTotalFilm(_ total: Int) {
        lblTotal.text = "\(total)"
        
    }
    
    private func getGenres(_ genres1: String, _ genres2: String, _ genres3: String, genresFilted: (genreItem: [(genres: EnumGenres, count: Int)], sum: Int, totalMovie: Int)) {
        lblPurpleGenre.text = genres3
        lblPinkGenre.text = genres2
        lblRedGenre.text = genres1
        
        let totalGenre1 = genresFilted.genreItem.first(where: { $0.genres.name == genres1 })?.count ?? 0
        let totalGenre2 = genresFilted.genreItem.first(where: { $0.genres.name == genres2 })?.count ?? 0
        let totalGenre3 = genresFilted.genreItem.first(where: { $0.genres.name == genres3 })?.count ?? 0
        
        lblTotalFilmPurple.text = "\(totalGenre3) Films"
        lblTotalFilmPink.text = "\(totalGenre2) Films"
        lblTotalFilmRed.text = "\(totalGenre1) Films"
    }
    
    
    
    private func getTopGenres(_ genreItem: [(genres: EnumGenres, count: Int)]) -> (String, String, String) {
        // Sắp xếp mảng thể loại Item theo thứ tự giảm dần dựa trên số lượng
        let sortedGenres = genreItem.sorted(by: { $0.count > $1.count })
        print(genreItem)
        
        // lấy ba thể loại top, nếu không trả về chuỗi rỗng
        let genre1 = sortedGenres.indices.contains(0) ? sortedGenres[0].genres.name : ""
        let genre2 = sortedGenres.indices.contains(1) ? sortedGenres[1].genres.name : ""
        let genre3 = sortedGenres.indices.contains(2) ? sortedGenres[2].genres.name : ""
        
        return (genre1, genre2, genre3)
    }
    
    
    private func getPercentGenres(_ percent1: String,_ percent2: String,_ percent3: String) {
        lblPercentPurple.text = percent3
        lblPercentPink.text = percent2
        lblPercentRed.text = percent1
        
        let value1 = Float(percent1.replacingOccurrences(of: "%", with: "")) ?? 0.0
        let value2 = Float(percent2.replacingOccurrences(of: "%", with: "")) ?? 0.0
        let value3 = Float(percent3.replacingOccurrences(of: "%", with: "")) ?? 0.0
        
        // giá trị phần trăm vào progressView
        purpleProgessView.value = CGFloat(value3)
        PinkProgessView.value = CGFloat(value2)
        redProgessView.value = CGFloat(value1)
    }
    
}

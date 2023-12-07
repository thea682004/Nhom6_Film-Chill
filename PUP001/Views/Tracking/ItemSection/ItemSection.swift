import UIKit

class ItemSection: UICollectionViewCell {
    
    weak var delegate: TrackingDelegate?
    private var id: Int = 0
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCalendar: UILabel!
    @IBOutlet weak var lblClock: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblNameMovie: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 10
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(red: 0.953, green: 0.361, blue: 0.337, alpha: 0.2).cgColor
        }
    }
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lineView: UIView!  {
        didSet {
            createDashedLine()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configData(item: ItemChart) {
        self.imgAvatar.loadImage(link: item.poster)
        self.lblNameMovie.text = item.name
        self.lblClock.text = item.time?.timeStringHourFormat()
        self.lblCalendar.text = item.date?.asStringTime()
        self.id = item.id ?? 0
        if item.genres.count >= 2 {
            let firstTwoGenres = Array(item.genres.prefix(2))
            let genresString = firstTwoGenres.joined(separator: "  •  ")
            self.lblGenre.text = genresString
        } else {
            let genresString = item.genres.joined(separator: "  •  ")
            self.lblGenre.text = genresString
        }
        self.lblTitle.text = item.title
        self.lblNote.text = item.description
        //MARK: Cắt chuỗi date
        if let time = item.date?.asStringTime().split(separator: " ").map({ String($0) }) {
            if let hour: String = time.last {
                let time = String(hour.prefix(5)).replacingOccurrences(of: ":", with: "h:")
                self.lblClock.text = time
            }
            
            if let date: String = time.first {
                var year: String = ""
                var month: String = ""
                var day: String = ""
                let splitDate = date.split(separator: "-").map({ String($0) })
                if splitDate.count > 0 {
                    year = splitDate[0]
                    month = self.convertMonthToText(value: splitDate[1])
                    day = splitDate[2]
                    let calendar = "\(month) \(day) \(year)"
                    self.lblCalendar.text = calendar
                    
                }
            }
        }
    }
    
    //MARK: chuyển tháng từ kiểu số sang text
    private func convertMonthToText(value: String) -> String {
        switch value {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Api"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        default:
            return "Dec"
        }
    }
    
    //MARK: chỉnh sửa nét đứt trong view
    private func createDashedLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 0.95, green: 0.36, blue: 0.34, alpha: 0.8).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 1]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: lineView.bounds.height/2), CGPoint(x: lineView.bounds.width, y: lineView.bounds.height/2)])
        shapeLayer.path = path
        
        lineView.layer.addSublayer(shapeLayer)
    }
    
    
    @IBAction func btnDelete(_ sender: Any) {
        self.delegate?.deleteFavorite(id: id)
    }
}

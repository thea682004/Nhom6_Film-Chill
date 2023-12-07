//
//  TotalTimeSection.swift
//  PUP001
//
//  Created by chuottp on 16/06/2023.
//

import UIKit

enum checkTypeTotal {
    case year
    case month
    case week
}

class TotalTimeSection: UICollectionViewCell, ChartViewDelegate {
    
    private var totalRuntime: Int = 0
    private var checkType: checkTypeTotal = .year
    private var barChart: BarChartView!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var viewChart: UIView! {
        didSet {
            viewChart.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupBarChart()
    }
    
    func setupBarChart() {
        barChart = BarChartView(frame: self.viewChart.bounds)
        barChart.isUserInteractionEnabled = false// không cho chạm vào cột
        barChart.frame = viewChart.bounds
        barChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        barChart.delegate = self
        barChart.rightAxis.drawGridLinesBehindDataEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawLimitLinesBehindDataEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.enabled = false
       
        
        let xAxis = barChart.xAxis
        xAxis.yOffset = 10
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor(rgb: 0x272459)
        xAxis.labelFont = UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        
        let yAxis = barChart.leftAxis
        barChart.leftAxis.gridColor = UIColor(rgb: 0x00000)
        yAxis.drawAxisLineEnabled = false
//        yAxis.labelCount = 6 // Số lượng nhãn trên trục y
        yAxis.labelTextColor = UIColor(rgb: 0x272459)
        yAxis.axisMinimum = 0
        yAxis.labelFont = UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        yAxis.granularity = 1
        yAxis.gridLineDashLengths = [4, 2]
        yAxis.gridLineDashPhase = 0
//        barChart.rightAxis.axisMinimum = 0// hiển thị gạch gạch ở dưới đáy
        yAxis.valueFormatter = YAxisValueFormatter() // Định dạng giá trị trục y
        yAxis.labelTextColor = UIColor(rgb: 0x272459)
        yAxis.labelFont = UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12) // Đặt font chữ cho nhãn trục y
        //  hiển thị của hình chú thích trong biểu đồ cột
        
        viewChart.addSubview(barChart)
    }
    
    func setUpData(listXName: [Int], type: CheckTypeTimeRane) {
        let xAxis = barChart.xAxis
        let legend = barChart.legend
        legend.enabled = false
        self.totalRuntime = 0
        var entries = [DataEntryBarChart]()
        for i in 0 ..< listXName.count {
            var runtime: Double = 0.0
            switch type {
            case .year:
                let date = ChartManager.shared.getDateByMonth(listXName[i])
                let listItem = ChartManager.shared.filterNoteBy(dates: date)
                let runtime = ChartManager.shared.getRuntime(from: listItem)
                let yAxis = barChart.leftAxis
                entries.append(DataEntryBarChart(x: Double(i), y: runtime))
                self.totalRuntime += Int(runtime)
                if runtime > 50  {
                    yAxis.axisMaximum = runtime + 50
                } else {
                    yAxis.axisMaximum = 50
                }
//                self.totalRuntime += Int(runtime)
//                self.lblTotalTime.text = "\(totalRuntime) Hours"
            case .month:
                let date = ChartManager.shared.getDateByWeek(listXName[i])
                let listItem = ChartManager.shared.filterNoteBy(dates: date)
                let runtime = ChartManager.shared.getRuntime(from: listItem)
                entries.append(DataEntryBarChart(x: Double(i), y: runtime))
                self.totalRuntime += Int(runtime)
                let yAxis = barChart.leftAxis
                if runtime > 50  {
                    yAxis.axisMaximum = runtime + 50
                } else {
                    yAxis.axisMaximum = 50
                }
            case .week:
                let date = ChartManager.shared.getDateByDay(listXName[i])
                let listItem = ChartManager.shared.filterNoteBy(dates: date)
                let runtime = ChartManager.shared.getRuntime(from: listItem)
                entries.append(DataEntryBarChart(x: Double(i), y: runtime))
                let yAxis = barChart.leftAxis
                self.totalRuntime += Int(runtime)
                if runtime > 50  {
                    yAxis.axisMaximum = runtime + 50
                } else {
                    yAxis.axisMaximum = 50
                }
            }
        }
        self.lblTotalTime.text = "\(self.totalRuntime) Hours"
        
        let set = DataSetBarChart(entries: entries, label: "")
        set.colors = [NSUIColor(rgb: 0xF35C56)]
        set.drawValuesEnabled = false // không hiển thị value của cột
        
        let data = DataBarChart(dataSet: set)
        data.barWidth = 0.8
        
        barChart.data = data // căn cột sát trục x
        
        // gia tri cua truc x
        xAxis.valueFormatter = FormatterIndexAxisValue(values: listXName.map( {String($0) }))
        xAxis.labelCount = listXName.count
    }
}

class YAxisValueFormatter: NSObject, FormatterAxisValue {
    func stringForValue(_ value: Double, axis: AxisBaseBarChart?) -> String {
        if value == 0 {
            return "0"
        } else {
            return "\(Int(value))h"
        }
    }
}






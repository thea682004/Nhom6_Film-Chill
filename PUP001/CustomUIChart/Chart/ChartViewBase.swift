//
//  ChartViewBase.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics
import UIKit

@objc
public protocol ChartViewDelegate
{
  
    @objc optional func chartValueSelected(_ chartView: ChartViewBase, entry: DataEntryChart, highlight: HighlightChart)
    
    @objc optional func chartViewDidEndPanning(_ chartView: ChartViewBase)
    
    @objc optional func chartValueNothingSelected(_ chartView: ChartViewBase)
    
    @objc optional func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    
    @objc optional func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)

    @objc optional func chartView(_ chartView: ChartViewBase, animatorDidStop animator: AnimatorChart)
}

open class ChartViewBase: NSUIView, DataProviderChart, AnimatorDelegate
{
    internal lazy var defaultValueFormatter: FormatterValue = FormatterDefaultValue(decimals: 0)

    @objc open var data: DataOfChart?
        {
        didSet
        {
            offsetsCalculated = false

            guard let data = data else { return }

            setupDefaultFormatter(min: data.yMin, max: data.yMax)

            for set in data where set.valueFormatter is FormatterDefaultValue
            {
                set.valueFormatter = defaultValueFormatter
            }

            notifyDataSetChanged()
        }
    }

    @objc open var dragDecelerationEnabled = true

    @objc open internal(set) lazy var xAxis = XAxisChart()
    
    @objc open lazy var chartDescription = DescriptionChart()

    @objc open internal(set) lazy var legend = LegendChart()

    @objc open weak var delegate: ChartViewDelegate?
    
    @objc open var noDataText = "No chart data available."
    
    @objc open var noDataFont = NSUIFont.systemFont(ofSize: 12)
    
    @objc open var noDataTextColor: NSUIColor = .labelOrBlack

    @objc open var noDataTextAlignment: TextAlignment = .left

    @objc open lazy var legendRenderer = LegendRender(viewPortHandler: viewPortHandler, legend: legend)

    @objc open var renderer: DataRenderBarChart?
    
    @objc open var highlighter: HighlighterChart?

    @objc open internal(set) lazy var viewPortHandler = ViewPortHandler(width: bounds.size.width, height: bounds.size.height)

    @objc open internal(set) lazy var chartAnimator: AnimatorChart = {
        let animator = AnimatorChart()
        animator.delegate = self
        return animator
    }()

    private var offsetsCalculated = false

    @objc open internal(set) var highlighted = [HighlightChart]()
    
    @objc open var drawMarkers = true
    
    @objc open var isDrawMarkersEnabled: Bool { return drawMarkers }
    
    @objc open var marker: MarkerChart?

    @objc open var extraTopOffset: CGFloat = 0.0
    
    @objc open var extraRightOffset: CGFloat = 0.0
    
    @objc open var extraBottomOffset: CGFloat = 0.0
    
    @objc open var extraLeftOffset: CGFloat = 0.0

    @objc open func setExtraOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        removeObserver(self, forKeyPath: "bounds")
        removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {
        #if os(iOS)
            self.backgroundColor = .clear
        #endif

        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
        @objc open func clear()
    {
        data = nil
        offsetsCalculated = false
        highlighted.removeAll()
        lastHighlighted = nil
    
        setNeedsDisplay()
    }
    
    @objc open func clearValues()
    {
        data?.clearValues()
        setNeedsDisplay()
    }

    @objc open func isEmpty() -> Bool
    {
        return data?.isEmpty ?? true
    }
    
    @objc open func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    internal func setupDefaultFormatter(min: Double, max: Double)
    {
        var reference = 0.0
        
        if let data = data , data.entryCount >= 2
        {
            reference = abs(max - min)
        }
        else
        {
            reference = Swift.max(abs(min), abs(max))
        }
        
    
        if let formatter = defaultValueFormatter as? FormatterDefaultValue
        {
            let digits = reference.decimalPlaces
            formatter.decimals = digits
        }
    }
    
    open override func draw(_ rect: CGRect)
    {
        guard let context = NSUIGraphicsGetCurrentContext() else { return }

        if data === nil && !noDataText.isEmpty
        {
            context.saveGState()
            defer { context.restoreGState() }

            let paragraphStyle = MutableParagraphStyle.default.mutableCopy() as! MutableParagraphStyle
            paragraphStyle.minimumLineHeight = noDataFont.lineHeight
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = noDataTextAlignment

            context.drawMultilineText(noDataText,
                                      at: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0),
                                      constrainedTo: bounds.size,
                                      anchor: CGPoint(x: 0.5, y: 0.5),
                                      angleRadians: 0.0,
                                      attributes: [.font: noDataFont,
                                                   .foregroundColor: noDataTextColor,
                                                   .paragraphStyle: paragraphStyle])

            return
        }
        
        if !offsetsCalculated
        {
            calculateOffsets()
            offsetsCalculated = true
        }
    }
    
    internal func drawDescription(in context: CGContext)
    {
        let description = chartDescription

        guard
            description.isEnabled,
            let descriptionText = description.text,
            !descriptionText.isEmpty
            else { return }
        
        let position = description.position ?? CGPoint(x: bounds.width - viewPortHandler.offsetRight - description.xOffset,
                                                       y: bounds.height - viewPortHandler.offsetBottom - description.yOffset - description.font.lineHeight)

        let attrs: [NSAttributedString.Key : Any] = [
            .font: description.font,
            .foregroundColor: description.textColor
        ]

        context.drawText(descriptionText,
                         at: position,
                         align: description.textAlign,
                         attributes: attrs)
    }
    
    open override func accessibilityChildren() -> [Any]? {
        return renderer?.accessibleChartElements
    }

    @objc open var highlightPerTapEnabled: Bool = true

    @objc open var isHighLightPerTapEnabled: Bool
    {
        return highlightPerTapEnabled
    }
    
    @objc open func valuesToHighlight() -> Bool
    {
        return !highlighted.isEmpty
    }

    @objc open func highlightValues(_ highs: [HighlightChart]?)
    {
        highlighted = highs ?? []

        lastHighlighted = highlighted.first

        // redraw the chart
        setNeedsDisplay()
    }
    
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        highlightValue(x: x, y: .nan, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: callDelegate)
    }
    
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        guard let data = data else
        {
            Swift.print("Value not highlighted because data is nil")
            return
        }

        if data.indices.contains(dataSetIndex)
        {
            highlightValue(HighlightChart(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex), callDelegate: callDelegate)
        }
        else
        {
            highlightValue(nil, callDelegate: callDelegate)
        }
    }
    
    @objc open func highlightValue(_ highlight: HighlightChart?)
    {
        highlightValue(highlight, callDelegate: false)
    }

    @objc open func highlightValue(_ highlight: HighlightChart?, callDelegate: Bool)
    {
        var high = highlight
        guard
            let h = high,
            let entry = data?.entry(for: h)
            else
        {
                high = nil
                highlighted.removeAll(keepingCapacity: false)
                if callDelegate
                {
                    delegate?.chartValueNothingSelected?(self)
                }
                setNeedsDisplay()
                return
        }

       highlighted = [h]

        if callDelegate
        {
            delegate?.chartValueSelected?(self, entry: entry, highlight: h)
        }

        setNeedsDisplay()
    }
    
    @objc open func getHighlightByTouchPoint(_ pt: CGPoint) -> HighlightChart?
    {
        guard data != nil else
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }

    @objc open var lastHighlighted: HighlightChart?
  
    internal func drawMarkers(context: CGContext)
    {
        guard
            let marker = marker,
            isDrawMarkersEnabled,
            valuesToHighlight()
            else { return }
        
        for highlight in highlighted
        {
            guard
                let set = data?[highlight.dataSetIndex],
                let e = data?.entry(for: highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            guard entryIndex <= Int(Double(set.entryCount) * chartAnimator.phaseX) else { continue }

            let pos = getMarkerPosition(highlight: highlight)

            guard viewPortHandler.isInBounds(x: pos.x, y: pos.y) else { continue }

            marker.refreshContent(entry: e, highlight: highlight)
            
            marker.draw(context: context, point: pos)
        }
    }
    
    @objc open func getMarkerPosition(highlight: HighlightChart) -> CGPoint
    {
        return CGPoint(x: highlight.drawX, y: highlight.drawY)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingX, easingY: easingY)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingOptionX, easingOptionY: easingOptionY)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easing)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, easing: easing)
    }

    @objc open func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration, easing: easing)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    @objc open func animate(yAxisDuration: TimeInterval)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration)
    }
    
    open var chartYMax: Double
    {
        return data?.yMax ?? 0.0
    }

    open var chartYMin: Double
    {
        return data?.yMin ?? 0.0
    }
    
    open var chartXMax: Double
    {
        return xAxis._axisMaximum
    }
    
    open var chartXMin: Double
    {
        return xAxis._axisMinimum
    }
    
    open var xRange: Double
    {
        return xAxis.axisRange
    }
    
    @objc open var midPoint: CGPoint
    {
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    open var centerOffsets: CGPoint
    {
        return viewPortHandler.contentCenter
    }

    @objc open var contentRect: CGRect
    {
        return viewPortHandler.contentRect
    }

    @objc open func getChartImage(transparent: Bool) -> NSUIImage?
    {
        NSUIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque || !transparent, NSUIMainScreen()?.nsuiScale ?? 1.0)
        
        guard let context = NSUIGraphicsGetCurrentContext()
            else { return nil }
        
        let rect = CGRect(origin: .zero, size: bounds.size)
        
        if isOpaque || !transparent
        {
            context.setFillColor(NSUIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = self.backgroundColor
            {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        nsuiLayer?.render(in: context)
        
        let image = NSUIGraphicsGetImageFromCurrentImageContext()
        
        NSUIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat
    {
        case jpeg
        case png
    }
    
    open func save(to path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
        guard let image = getChartImage(transparent: format != .jpeg) else { return false }
        
        let imageData: Data?
        switch (format)
        {
        case .png: imageData = NSUIImagePNGRepresentation(image)
        case .jpeg: imageData = NSUIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        }
        
        guard let data = imageData else { return false }
        
        do
        {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        catch
        {
            return false
        }
        
        return true
    }
    
    internal var _viewportJobs = [ViewPortJobBarChart]()
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "bounds" || keyPath == "frame"
        {
            let bounds = self.bounds
            
            if ((bounds.size.width != viewPortHandler.chartWidth ||
                bounds.size.height != viewPortHandler.chartHeight))
            {
                viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                notifyDataSetChanged()
                while (!_viewportJobs.isEmpty)
                {
                    let job = _viewportJobs.remove(at: 0)
                    job.doJob()
                }
            }
        }
    }
    
    @objc open func removeViewportJob(_ job: ViewPortJobBarChart)
    {
        if let index = _viewportJobs.firstIndex(where: { $0 === job })
        {
            _viewportJobs.remove(at: index)
        }
    }
    
    @objc open func clearAllViewportJobs()
    {
        _viewportJobs.removeAll(keepingCapacity: false)
    }
    
    @objc open func addViewportJob(_ job: ViewPortJobBarChart)
    {
        if viewPortHandler.hasChartDimens
        {
            job.doJob()
        }
        else
        {
            _viewportJobs.append(job)
        }
    }
    
    @objc open var isDragDecelerationEnabled: Bool
        {
            return dragDecelerationEnabled
    }
    
    @objc open var dragDecelerationFrictionCoef: CGFloat
    {
        get
        {
            return _dragDecelerationFrictionCoef
        }
        set
        {
            _dragDecelerationFrictionCoef = max(0, min(newValue, 0.999))
        }
    }
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    open var maxHighlightDistance: CGFloat = 500.0
    
    open var maxVisibleCount: Int
    {
        return .max
    }
        
    open func animatorUpdated(_ chartAnimator: AnimatorChart)
    {
        setNeedsDisplay()
    }
    
    open func animatorStopped(_ chartAnimator: AnimatorChart)
    {
        delegate?.chartView?(self, animatorDidStop: chartAnimator)
    }
        
    open override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesBegan(touches, withEvent: event)
    }
    
    open override func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesMoved(touches, withEvent: event)
    }
    
    open override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesEnded(touches, withEvent: event)
    }
    
    open override func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesCancelled(touches, withEvent: event)
    }
}


//
//  Legend.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation
import CoreGraphics
import UIKit

@objc(ChartLegend)
open class LegendChart: ComponentBaseChart
{
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        case none
        
        case empty
        
        case `default`
        
        case square
        
        case circle
        
        case line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case left
        case center
        case right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case top
        case center
        case bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case horizontal
        case vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case leftToRight
        case rightToLeft
    }
    
    @objc open var entries = [LegendEntryChart]()
    
    @objc open var extraEntries = [LegendEntryChart]()
    
    private var _isLegendCustom = false
    
    @objc open var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.left
    
    @objc open var verticalAlignment: VerticalAlignment = VerticalAlignment.bottom
    
    @objc open var orientation: Orientation = Orientation.horizontal
    
    @objc open var drawInside: Bool = false
    
    @objc open var isDrawInsideEnabled: Bool { return drawInside }
    
    @objc open var direction: Direction = Direction.leftToRight
    
    @objc open var font: NSUIFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var textColor = NSUIColor.labelOrBlack
    
    @objc open var form = Form.square
    
    @objc open var formSize = CGFloat(8.0)
    
    @objc open var formLineWidth = CGFloat(3.0)
    
    @objc open var formLineDashPhase: CGFloat = 0.0
    
    @objc open var formLineDashLengths: [CGFloat]?
    
    @objc open var xEntrySpace = CGFloat(6.0)
    @objc open var yEntrySpace = CGFloat(0.0)
    @objc open var formToTextSpace = CGFloat(5.0)
    @objc open var stackSpace = CGFloat(3.0)
    
    @objc open var calculatedLabelSizes = [CGSize]()
    @objc open var calculatedLabelBreakPoints = [Bool]()
    @objc open var calculatedLineSizes = [CGSize]()
    
    public override init()
    {
        super.init()
        
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    @objc public init(entries: [LegendEntryChart])
    {
        super.init()
        
        self.entries = entries
    }
    
    @objc open func getMaximumEntrySize(withFont font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var maxFormSize: CGFloat = 0.0
        
        for entry in entries
        {
            let formSize = entry.formSize.isNaN ? self.formSize : entry.formSize
            if formSize > maxFormSize
            {
                maxFormSize = formSize
            }
            
            guard let label = entry.label
            else { continue }
            
            let size = (label as NSString).size(withAttributes: [.font: font])
            
            if size.width > maxW
            {
                maxW = size.width
            }
            if size.height > maxH
            {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + maxFormSize + formToTextSpace,
            height: maxH
        )
    }
    
    @objc open var neededWidth = CGFloat(0.0)
    @objc open var neededHeight = CGFloat(0.0)
    @objc open var textWidthMax = CGFloat(0.0)
    @objc open var textHeightMax = CGFloat(0.0)
    
    @objc open var wordWrapEnabled = true
    
    @objc open var isWordWrapEnabled: Bool { return wordWrapEnabled }
    
    @objc open var maxSizePercent: CGFloat = 0.95
    
    @objc open func calculateDimensions(labelFont: NSUIFont, viewPortHandler: ViewPortHandler)
    {
        let maxEntrySize = getMaximumEntrySize(withFont: labelFont)
        let defaultFormSize = self.formSize
        let stackSpace = self.stackSpace
        let formToTextSpace = self.formToTextSpace
        let xEntrySpace = self.xEntrySpace
        let yEntrySpace = self.yEntrySpace
        let wordWrapEnabled = self.wordWrapEnabled
        let entries = self.entries
        let entryCount = entries.count
        
        textWidthMax = maxEntrySize.width
        textHeightMax = maxEntrySize.height
        
        switch orientation
        {
        case .vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var wasStacked = false
            
            for i in entries.indices
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                
                if !wasStacked
                {
                    width = 0.0
                }
                
                if drawingForm
                {
                    if wasStacked
                    {
                        width += stackSpace
                    }
                    width += formSize
                }
                
                if let label = e.label
                {
                    let size = (label as NSString).size(withAttributes: [.font: labelFont])
                    
                    if drawingForm && !wasStacked
                    {
                        width += formToTextSpace
                    }
                    else if wasStacked
                    {
                        maxWidth = max(maxWidth, width)
                        maxHeight += labelLineHeight + yEntrySpace
                        width = 0.0
                        wasStacked = false
                    }
                    
                    width += size.width
                    maxHeight += labelLineHeight + yEntrySpace
                }
                else
                {
                    wasStacked = true
                    width += formSize
                    
                    if i < entryCount - 1
                    {
                        width += stackSpace
                    }
                }
                
                maxWidth = max(maxWidth, width)
            }
            
            neededWidth = maxWidth
            neededHeight = maxHeight
            
        case .horizontal:
            
            let labelLineHeight = labelFont.lineHeight
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            if calculatedLabelSizes.count != entryCount
            {
                calculatedLabelSizes = [CGSize](repeating: CGSize(), count: entryCount)
            }
            
            if calculatedLabelBreakPoints.count != entryCount
            {
                calculatedLabelBreakPoints = [Bool](repeating: false, count: entryCount)
            }
            
            calculatedLineSizes.removeAll(keepingCapacity: true)
            
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for i in entries.indices
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let label = e.label
                
                calculatedLabelBreakPoints[i] = false
                
                if stackedStartIndex == -1
                {
                    requiredWidth = 0.0
                }
                else
                {
                    requiredWidth += stackSpace
                }
                
                if let label = label
                {
                    calculatedLabelSizes[i] = (label as NSString).size(withAttributes: [.font: labelFont])
                    requiredWidth += drawingForm ? formToTextSpace + formSize : 0.0
                    requiredWidth += calculatedLabelSizes[i].width
                }
                else
                {
                    calculatedLabelSizes[i] = CGSize()
                    requiredWidth += drawingForm ? formSize : 0.0
                    
                    if stackedStartIndex == -1
                    {
                        stackedStartIndex = i
                    }
                }
                
                if label != nil || i == entryCount - 1
                {
                    let requiredSpacing = currentLineWidth == 0.0 ? 0.0 : xEntrySpace
                    
                    if (!wordWrapEnabled ||
                        currentLineWidth == 0.0 ||
                        (contentWidth - currentLineWidth >= requiredSpacing + requiredWidth))
                    {
                        currentLineWidth += requiredSpacing + requiredWidth
                    }
                    else
                    {
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                        calculatedLabelBreakPoints[stackedStartIndex > -1 ? stackedStartIndex : i] = true
                        currentLineWidth = requiredWidth
                    }
                    
                    if i == entryCount - 1
                    {
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                    }
                }
                
                stackedStartIndex = label != nil ? -1 : stackedStartIndex
            }
            
            neededWidth = maxLineWidth
            neededHeight = labelLineHeight * CGFloat(calculatedLineSizes.count) +
            yEntrySpace * CGFloat(calculatedLineSizes.isEmpty ? 0 : (calculatedLineSizes.count - 1))
        }
        
        neededWidth += xOffset
        neededHeight += yOffset
    }
    
    @objc open func setCustom(entries: [LegendEntryChart])
    {
        self.entries = entries
        _isLegendCustom = true
    }
    @objc open func resetCustom()
    {
        _isLegendCustom = false
    }
    
    @objc open var isLegendCustom: Bool
    {
        return _isLegendCustom
    }
}


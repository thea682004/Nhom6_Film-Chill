//
//  BarLineChartViewBase.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics
import UIKit

open class BarLineChartViewBase: ChartViewBase, DataProviderBarLineScatterCandleBubbleChart, NSUIGestureRecognizerDelegate
{
    
    internal var _maxVisibleCount = 100
    private var _autoScaleMinMaxEnabled = false
    private var _pinchZoomEnabled = false
    private var _doubleTapToZoomEnabled = true
    private var _dragXEnabled = true
    private var _dragYEnabled = true
    private var _scaleXEnabled = true
    private var _scaleYEnabled = true
    
    @objc open var gridBackgroundColor = NSUIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    @objc open var borderColor = NSUIColor.black
    
    @objc open var borderLineWidth: CGFloat = 1.0
    
    @objc open var drawGridBackgroundEnabled = false
    
    @objc open var drawBordersEnabled = false
    
    @objc open var clipValuesToContentEnabled: Bool = false
    
    @objc open var clipDataToContentEnabled: Bool = true
    
    @objc open var minOffset = CGFloat(10.0)
    
    @objc open var keepPositionOnRotation: Bool = false
    
    @objc open internal(set) var leftAxis = YAxisChart(position: .left)
    
    @objc open internal(set) var rightAxis = YAxisChart(position: .right)
    
    @objc open lazy var leftYAxisRenderer = YAxisRenderBarChart(viewPortHandler: viewPortHandler, axis: leftAxis, transformer: _leftAxisTransformer)
    
    @objc open lazy var rightYAxisRenderer = YAxisRenderBarChart(viewPortHandler: viewPortHandler, axis: rightAxis, transformer: _rightAxisTransformer)
    
    internal var _leftAxisTransformer: TransformerBarChart!
    internal var _rightAxisTransformer: TransformerBarChart!
    
    @objc open lazy var xAxisRenderer = XAxisRenderBarChart(viewPortHandler: viewPortHandler, axis: xAxis, transformer: _leftAxisTransformer)
    
    internal var _tapGestureRecognizer: NSUITapGestureRecognizer!
    internal var _doubleTapGestureRecognizer: NSUITapGestureRecognizer!
    internal var _pinchGestureRecognizer: NSUIPinchGestureRecognizer!
    internal var _panGestureRecognizer: NSUIPanGestureRecognizer!
    
    private var _customViewPortEnabled = false
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        stopDeceleration()
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = TransformerBarChart(viewPortHandler: viewPortHandler)
        _rightAxisTransformer = TransformerBarChart(viewPortHandler: viewPortHandler)
        
        self.highlighter = ChartsHighlighter(chart: self)
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        _doubleTapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.nsuiNumberOfTapsRequired = 2
        _panGestureRecognizer = NSUIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        
        _panGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(_tapGestureRecognizer)
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
        self.addGestureRecognizer(_panGestureRecognizer)
        
        _doubleTapGestureRecognizer.isEnabled = _doubleTapToZoomEnabled
        _panGestureRecognizer.isEnabled = _dragXEnabled || _dragYEnabled
        
#if !os(tvOS)
        _pinchGestureRecognizer = NSUIPinchGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.pinchGestureRecognized(_:)))
        _pinchGestureRecognizer.delegate = self
        self.addGestureRecognizer(_pinchGestureRecognizer)
        _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
#endif
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        var oldPoint: CGPoint?
        if (keepPositionOnRotation && (keyPath == "frame" || keyPath == "bounds"))
        {
            oldPoint = viewPortHandler.contentRect.origin
            getTransformer(forAxis: .left).pixelToValuesBarChart(&oldPoint!)
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        if var newPoint = oldPoint , keepPositionOnRotation
        {
            getTransformer(forAxis: .left).pointValueToPixelBarChart(&newPoint)
            viewPortHandler.centerViewPort(pt: newPoint, chart: self)
        }
        else
        {
            viewPortHandler.refresh(newMatrix: viewPortHandler.touchMatrix, chart: self, invalidate: true)
        }
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        guard data != nil, let renderer = renderer else { return }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        drawGridBackground(context: context)
        
        
        if _autoScaleMinMaxEnabled
        {
            autoScale()
        }
        
        if leftAxis.isEnabled
        {
            leftYAxisRenderer.computeAxis(min: leftAxis._axisMinimum, max: leftAxis._axisMaximum, inverted: leftAxis.isInverted)
        }
        
        if rightAxis.isEnabled
        {
            rightYAxisRenderer.computeAxis(min: rightAxis._axisMinimum, max: rightAxis._axisMaximum, inverted: rightAxis.isInverted)
        }
        
        if xAxis.isEnabled
        {
            xAxisRenderer.computeAxis(min: xAxis._axisMinimum, max: xAxis._axisMaximum, inverted: false)
        }
        
        xAxisRenderer.renderAxisLine(context: context)
        leftYAxisRenderer.renderAxisLine(context: context)
        rightYAxisRenderer.renderAxisLine(context: context)
        
        if xAxis.drawGridLinesBehindDataEnabled
        {
            xAxisRenderer.renderGridLines(context: context)
            leftYAxisRenderer.renderGridLines(context: context)
            rightYAxisRenderer.renderGridLines(context: context)
        }
        
        if xAxis.isEnabled && xAxis.isDrawLimitLinesBehindDataEnabled
        {
            xAxisRenderer.renderLimitLines(context: context)
        }
        
        if leftAxis.isEnabled && leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            leftYAxisRenderer.renderLimitLines(context: context)
        }
        
        if rightAxis.isEnabled && rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            rightYAxisRenderer.renderLimitLines(context: context)
        }
        
        context.saveGState()
        
        if clipDataToContentEnabled {
            context.clip(to: viewPortHandler.contentRect)
        }
        
        renderer.drawData(context: context)
        
        if !xAxis.drawGridLinesBehindDataEnabled
        {
            xAxisRenderer.renderGridLines(context: context)
            leftYAxisRenderer.renderGridLines(context: context)
            rightYAxisRenderer.renderGridLines(context: context)
        }
        
        if (valuesToHighlight())
        {
            renderer.drawHighlighted(context: context, indices: highlighted)
        }
        
        context.restoreGState()
        
        renderer.drawExtras(context: context)
        
        if xAxis.isEnabled && !xAxis.isDrawLimitLinesBehindDataEnabled
        {
            xAxisRenderer.renderLimitLines(context: context)
        }
        
        if leftAxis.isEnabled && !leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            leftYAxisRenderer.renderLimitLines(context: context)
        }
        
        if rightAxis.isEnabled && !rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            rightYAxisRenderer.renderLimitLines(context: context)
        }
        
        xAxisRenderer.renderAxisLabels(context: context)
        leftYAxisRenderer.renderAxisLabels(context: context)
        rightYAxisRenderer.renderAxisLabels(context: context)
        
        if clipValuesToContentEnabled
        {
            context.saveGState()
            context.clip(to: viewPortHandler.contentRect)
            
            renderer.drawValues(context: context)
            
            context.restoreGState()
        }
        else
        {
            renderer.drawValues(context: context)
        }
        
        legendRenderer.renderLegend(context: context)
        
        drawDescription(in: context)
        
        drawMarkers(context: context)
    }
    
    private var _autoScaleLastLowestVisibleX: Double?
    private var _autoScaleLastHighestVisibleX: Double?
    
    internal func autoScale()
    {
        guard let data = data
        else { return }
        
        data.calcMinMaxY(fromX: self.lowestVisibleX, toX: self.highestVisibleX)
        
        xAxis.calculate(min: data.xMin, max: data.xMax)
        
        if leftAxis.isEnabled
        {
            leftAxis.calculate(min: data.getYMin(axis: .left), max: data.getYMax(axis: .left))
        }
        
        if rightAxis.isEnabled
        {
            rightAxis.calculate(min: data.getYMin(axis: .right), max: data.getYMax(axis: .right))
        }
        
        calculateOffsets()
    }
    
    internal func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(rightAxis.axisRange), chartYMin: rightAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(leftAxis.axisRange), chartYMin: leftAxis._axisMinimum)
    }
    
    internal func prepareOffsetMatrix()
    {
        _rightAxisTransformer.prepareMatrixOffsetBarChart(inverted: rightAxis.isInverted)
        _leftAxisTransformer.prepareMatrixOffsetBarChart(inverted: leftAxis.isInverted)
    }
    
    open override func notifyDataSetChanged()
    {
        renderer?.initBuffers()
        
        calcMinMax()
        
        leftYAxisRenderer.computeAxis(min: leftAxis._axisMinimum, max: leftAxis._axisMaximum, inverted: leftAxis.isInverted)
        rightYAxisRenderer.computeAxis(min: rightAxis._axisMinimum, max: rightAxis._axisMaximum, inverted: rightAxis.isInverted)
        
        if let data = data
        {
            xAxisRenderer.computeAxis(
                min: xAxis._axisMinimum,
                max: xAxis._axisMaximum,
                inverted: false)
            
            legendRenderer.computeLegend(data: data)
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }
    
    internal override func calcMinMax()
    {
        xAxis.calculate(min: data?.xMin ?? 0.0, max: data?.xMax ?? 0.0)
        leftAxis.calculate(min: data?.getYMin(axis: .left) ?? 0.0, max: data?.getYMax(axis: .left) ?? 0.0)
        rightAxis.calculate(min: data?.getYMin(axis: .right) ?? 0.0, max: data?.getYMax(axis: .right) ?? 0.0)
    }
    
    internal func calculateLegendOffsets(offsetLeft: inout CGFloat, offsetTop: inout CGFloat, offsetRight: inout CGFloat, offsetBottom: inout CGFloat)
    {
        if legend.isEnabled, !legend.drawInside
        {
            switch legend.orientation
            {
            case .vertical:
                
                switch legend.horizontalAlignment
                {
                case .left:
                    offsetLeft += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                    
                case .right:
                    offsetRight += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                    
                case .center:
                    
                    switch legend.verticalAlignment
                    {
                    case .top:
                        offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                        
                    case .bottom:
                        offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                        
                    default:
                        break
                    }
                }
                
            case .horizontal:
                
                switch legend.verticalAlignment
                {
                case .top:
                    offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                case .bottom:
                    offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                default:
                    break
                }
            }
        }
    }
    
    internal override func calculateOffsets()
    {
        if !_customViewPortEnabled
        {
            var offsetLeft = CGFloat(0.0)
            var offsetRight = CGFloat(0.0)
            var offsetTop = CGFloat(0.0)
            var offsetBottom = CGFloat(0.0)
            
            calculateLegendOffsets(offsetLeft: &offsetLeft,
                                   offsetTop: &offsetTop,
                                   offsetRight: &offsetRight,
                                   offsetBottom: &offsetBottom)
            
            if leftAxis.needsOffset
            {
                offsetLeft += leftAxis.requiredSize().width
            }
            
            if rightAxis.needsOffset
            {
                offsetRight += rightAxis.requiredSize().width
            }
            
            if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
            {
                let xlabelheight = xAxis.labelRotatedHeight + xAxis.yOffset
                
                if xAxis.labelPosition == .bottom
                {
                    offsetBottom += xlabelheight
                }
                else if xAxis.labelPosition == .top
                {
                    offsetTop += xlabelheight
                }
                else if xAxis.labelPosition == .bothSided
                {
                    offsetBottom += xlabelheight
                    offsetTop += xlabelheight
                }
            }
            
            offsetTop += self.extraTopOffset
            offsetRight += self.extraRightOffset
            offsetBottom += self.extraBottomOffset
            offsetLeft += self.extraLeftOffset
            
            viewPortHandler.restrainViewPort(
                offsetLeft: max(self.minOffset, offsetLeft),
                offsetTop: max(self.minOffset, offsetTop),
                offsetRight: max(self.minOffset, offsetRight),
                offsetBottom: max(self.minOffset, offsetBottom))
        }
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    internal func drawGridBackground(context: CGContext)
    {
        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.saveGState()
        }
        
        if drawGridBackgroundEnabled
        {
            context.setFillColor(gridBackgroundColor.cgColor)
            context.fill(viewPortHandler.contentRect)
        }
        
        if drawBordersEnabled
        {
            context.setLineWidth(borderLineWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.stroke(viewPortHandler.contentRect)
        }
        
        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.restoreGState()
        }
    }
    
    private enum GestureScaleAxis
    {
        case both
        case x
        case y
    }
    
    private var _isDragging = false
    private var _isScaling = false
    private var _gestureScaleAxis = GestureScaleAxis.both
    private var _closestDataSetToTouch: ProtocolChartDataSet!
    private var _panGestureReachedEdge: Bool = false
    private weak var _outerScrollView: NSUIScrollView?
    
    private var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    private var _decelerationLastTime: TimeInterval = 0.0
    private var _decelerationDisplayLink: NSUIDisplayLink!
    private var _decelerationVelocity = CGPoint()
    
    @objc private func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        if data === nil
        {
            return
        }
        
        if recognizer.state == NSUIGestureRecognizerState.ended
        {
            if !isHighLightPerTapEnabled { return }
            
            let h = getHighlightByTouchPoint(recognizer.location(in: self))
            
            if h === nil || h == self.lastHighlighted
            {
                lastHighlighted = nil
                highlightValue(nil, callDelegate: true)
            }
            else
            {
                lastHighlighted = h
                highlightValue(h, callDelegate: true)
            }
        }
    }
    
    @objc private func doubleTapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        if data === nil
        {
            return
        }
        
        if recognizer.state == NSUIGestureRecognizerState.ended
        {
            if data !== nil && _doubleTapToZoomEnabled && (data?.entryCount ?? 0) > 0
            {
                var location = recognizer.location(in: self)
                location.x = location.x - viewPortHandler.offsetLeft
                
                if isTouchInverted()
                {
                    location.y = -(location.y - viewPortHandler.offsetTop)
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - viewPortHandler.offsetBottom)
                }
                
                self.zoom(scaleX: isScaleXEnabled ? 1.4 : 1.0, scaleY: isScaleYEnabled ? 1.4 : 1.0, x: location.x, y: location.y)
                delegate?.chartScaled?(self, scaleX: scaleX, scaleY: scaleY)
            }
        }
    }
    
#if !os(tvOS)
    @objc private func pinchGestureRecognized(_ recognizer: NSUIPinchGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began
        {
            stopDeceleration()
            
            if data !== nil &&
                (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled)
            {
                _isScaling = true
                
                if _pinchZoomEnabled
                {
                    _gestureScaleAxis = .both
                }
                else
                {
                    let x = abs(recognizer.location(in: self).x - recognizer.nsuiLocationOfTouch(1, inView: self).x)
                    let y = abs(recognizer.location(in: self).y - recognizer.nsuiLocationOfTouch(1, inView: self).y)
                    
                    if _scaleXEnabled != _scaleYEnabled
                    {
                        _gestureScaleAxis = _scaleXEnabled ? .x : .y
                    }
                    else
                    {
                        _gestureScaleAxis = x > y ? .x : .y
                    }
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.ended ||
                    recognizer.state == NSUIGestureRecognizerState.cancelled
        {
            if _isScaling
            {
                _isScaling = false
                
                calculateOffsets()
                setNeedsDisplay()
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            let isZoomingOut = (recognizer.nsuiScale < 1)
            var canZoomMoreX = isZoomingOut ? viewPortHandler.canZoomOutMoreX : viewPortHandler.canZoomInMoreX
            var canZoomMoreY = isZoomingOut ? viewPortHandler.canZoomOutMoreY : viewPortHandler.canZoomInMoreY
            
            if _isScaling
            {
                canZoomMoreX = canZoomMoreX && _scaleXEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .x)
                canZoomMoreY = canZoomMoreY && _scaleYEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .y)
                if canZoomMoreX || canZoomMoreY
                {
                    var location = recognizer.location(in: self)
                    location.x = location.x - viewPortHandler.offsetLeft
                    
                    if isTouchInverted()
                    {
                        location.y = -(location.y - viewPortHandler.offsetTop)
                    }
                    else
                    {
                        location.y = -(viewPortHandler.chartHeight - location.y - viewPortHandler.offsetBottom)
                    }
                    
                    let scaleX = canZoomMoreX ? recognizer.nsuiScale : 1.0
                    let scaleY = canZoomMoreY ? recognizer.nsuiScale : 1.0
                    
                    var matrix = CGAffineTransform(translationX: location.x, y: location.y)
                    matrix = matrix.scaledBy(x: scaleX, y: scaleY)
                    matrix = matrix.translatedBy(x: -location.x, y: -location.y)
                    
                    matrix = viewPortHandler.touchMatrix.concatenating(matrix)
                    
                    viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
                    
                    if delegate !== nil
                    {
                        delegate?.chartScaled?(self, scaleX: scaleX, scaleY: scaleY)
                    }
                }
                
                recognizer.nsuiScale = 1.0
            }
        }
    }
#endif
    
    @objc private func panGestureRecognized(_ recognizer: NSUIPanGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began && recognizer.nsuiNumberOfTouches() > 0
        {
            stopDeceleration()
            
            if data === nil || !self.isDragEnabled
            {
                return
            }
            if !self.hasNoDragOffset || !self.isFullyZoomedOut
            {
                _isDragging = true
                
                _closestDataSetToTouch = getDataSetByTouchPoint(point: recognizer.nsuiLocationOfTouch(0, inView: self))
                
                var translation = recognizer.translation(in: self)
                if !self.dragXEnabled
                {
                    translation.x = 0.0
                }
                else if !self.dragYEnabled
                {
                    translation.y = 0.0
                }
                
                let didUserDrag = translation.x != 0.0 || translation.y != 0.0
                
                if didUserDrag && !performPanChange(translation: translation)
                {
                    if _outerScrollView !== nil
                    {
                        _outerScrollView = nil
                        _isDragging = false
                    }
                }
                else
                {
                    if _outerScrollView !== nil
                    {
                        _outerScrollView?.nsuiIsScrollEnabled = false
                    }
                }
                
                _lastPanPoint = recognizer.translation(in: self)
            }
            else if self.isHighlightPerDragEnabled
            {
                
                _isDragging = false
                
                _outerScrollView?.nsuiIsScrollEnabled = false
                
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            if _isDragging
            {
                let originalTranslation = recognizer.translation(in: self)
                var translation = CGPoint(x: originalTranslation.x - _lastPanPoint.x, y: originalTranslation.y - _lastPanPoint.y)
                
                if !self.dragXEnabled
                {
                    translation.x = 0.0
                }
                else if !self.dragYEnabled
                {
                    translation.y = 0.0
                }
                
                let _ = performPanChange(translation: translation)
                
                _lastPanPoint = originalTranslation
            }
            else if isHighlightPerDragEnabled
            {
                let h = getHighlightByTouchPoint(recognizer.location(in: self))
                
                let lastHighlighted = self.lastHighlighted
                
                if h != lastHighlighted
                {
                    self.lastHighlighted = h
                    self.highlightValue(h, callDelegate: true)
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.ended || recognizer.state == NSUIGestureRecognizerState.cancelled
        {
            if _isDragging
            {
                if recognizer.state == NSUIGestureRecognizerState.ended && isDragDecelerationEnabled
                {
                    stopDeceleration()
                    
                    _decelerationLastTime = CACurrentMediaTime()
                    _decelerationVelocity = recognizer.velocity(in: self)
                    
                    _decelerationDisplayLink = NSUIDisplayLink(target: self, selector: #selector(BarLineChartViewBase.decelerationLoop))
                    _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
                }
                
                _isDragging = false
            }
            
            if _outerScrollView !== nil
            {
                _outerScrollView?.nsuiIsScrollEnabled = true
                _outerScrollView = nil
            }
            
            delegate?.chartViewDidEndPanning?(self)
        }
    }
    
    private func performPanChange(translation: CGPoint) -> Bool
    {
        var translation = translation
        
        if isTouchInverted()
        {
            if self is HorizontalBarChartView
            {
                translation.x = -translation.x
            }
            else
            {
                translation.y = -translation.y
            }
        }
        
        let originalMatrix = viewPortHandler.touchMatrix
        
        var matrix = CGAffineTransform(translationX: translation.x, y: translation.y)
        matrix = originalMatrix.concatenating(matrix)
        
        matrix = viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        if matrix != originalMatrix
        {
            delegate?.chartTranslated?(self, dX: translation.x, dY: translation.y)
        }
        
        return matrix.tx != originalMatrix.tx || matrix.ty != originalMatrix.ty
    }
    
    private func isTouchInverted() -> Bool
    {
        return isAnyAxisInverted &&
        _closestDataSetToTouch !== nil &&
        getAxis(_closestDataSetToTouch.axisDependency).isInverted
    }
    
    @objc open func stopDeceleration()
    {
        if _decelerationDisplayLink !== nil
        {
            _decelerationDisplayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
            _decelerationDisplayLink = nil
        }
    }
    
    @objc private func decelerationLoop()
    {
        let currentTime = CACurrentMediaTime()
        
        _decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        _decelerationVelocity.y *= self.dragDecelerationFrictionCoef
        
        let timeInterval = CGFloat(currentTime - _decelerationLastTime)
        
        let distance = CGPoint(
            x: _decelerationVelocity.x * timeInterval,
            y: _decelerationVelocity.y * timeInterval
        )
        
        if !performPanChange(translation: distance)
        {
            _decelerationVelocity.x = 0.0
            _decelerationVelocity.y = 0.0
        }
        
        _decelerationLastTime = currentTime
        
        if abs(_decelerationVelocity.x) < 0.001 && abs(_decelerationVelocity.y) < 0.001
        {
            stopDeceleration()
            calculateOffsets()
            setNeedsDisplay()
        }
    }
    
    private func nsuiGestureRecognizerShouldBegin(_ gestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        if gestureRecognizer == _panGestureRecognizer
        {
            let velocity = _panGestureRecognizer.velocity(in: self)
            if data === nil || !isDragEnabled ||
                (self.hasNoDragOffset && self.isFullyZoomedOut && !self.isHighlightPerDragEnabled) ||
                (!_dragYEnabled && abs(velocity.y) > abs(velocity.x)) ||
                (!_dragXEnabled && abs(velocity.y) < abs(velocity.x))
            {
                return false
            }
        }
        else
        {
            if gestureRecognizer == _pinchGestureRecognizer
            {
                if data === nil || (!_pinchZoomEnabled && !_scaleXEnabled && !_scaleYEnabled)
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        if !super.gestureRecognizerShouldBegin(gestureRecognizer)
        {
            return false
        }
        
        return nsuiGestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        return nsuiGestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    open func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        if ((gestureRecognizer is NSUIPinchGestureRecognizer && otherGestureRecognizer is NSUIPanGestureRecognizer) ||
            (gestureRecognizer is NSUIPanGestureRecognizer && otherGestureRecognizer is NSUIPinchGestureRecognizer))
        {
            return true
        }
        
        if gestureRecognizer is NSUIPanGestureRecognizer,
           otherGestureRecognizer is NSUIPanGestureRecognizer,
           gestureRecognizer == _panGestureRecognizer
        {
            var scrollView = self.superview
            while scrollView != nil && !(scrollView is NSUIScrollView)
            {
                scrollView = scrollView?.superview
            }
            
            if let superViewOfScrollView = scrollView?.superview,
               superViewOfScrollView is NSUIScrollView
            {
                scrollView = superViewOfScrollView
            }
            
            var foundScrollView = scrollView as? NSUIScrollView
            
            if !(foundScrollView?.nsuiIsScrollEnabled ?? true)
            {
                foundScrollView = nil
            }
            
            let scrollViewPanGestureRecognizer = foundScrollView?.nsuiGestureRecognizers?.first {
                $0 is NSUIPanGestureRecognizer
            }
            
            if otherGestureRecognizer === scrollViewPanGestureRecognizer
            {
                _outerScrollView = foundScrollView
                
                return true
            }
        }
        
        return false
    }
    
    @objc open func zoomIn()
    {
        let center = viewPortHandler.contentCenter
        
        let matrix = viewPortHandler.zoomIn(x: center.x, y: -center.y)
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    @objc open func zoomOut()
    {
        let center = viewPortHandler.contentCenter
        
        let matrix = viewPortHandler.zoomOut(x: center.x, y: -center.y)
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    @objc open func resetZoom()
    {
        let matrix = viewPortHandler.resetZoom()
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    @objc open func zoom(
        scaleX: CGFloat,
        scaleY: CGFloat,
        x: CGFloat,
        y: CGFloat)
    {
        let matrix = viewPortHandler.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: -y)
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    @objc open func zoom(
        scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency)
    {
        let job = ZoomViewJobBarChart(
            viewPortHandler: viewPortHandler,
            scaleX: scaleX,
            scaleY: scaleY,
            xValue: xValue,
            yValue: yValue,
            transformer: getTransformer(forAxis: axis),
            axis: axis,
            view: self)
        addViewportJob(job)
    }
    
    @objc open func zoomToCenter(
        scaleX: CGFloat,
        scaleY: CGFloat)
    {
        let center = centerOffsets
        let matrix = viewPortHandler.zoom(
            scaleX: scaleX,
            scaleY: scaleY,
            x: center.x,
            y: -center.y)
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
    }
    
    @objc open func zoomAndCenterViewAnimated(
        scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let origin = valueForTouchPoint(
            point: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let job = AnimatedZoomViewJobBarChart(
            viewPortHandler: viewPortHandler,
            transformer: getTransformer(forAxis: axis),
            view: self,
            yAxis: getAxis(axis),
            xAxisRange: xAxis.axisRange,
            scaleX: scaleX,
            scaleY: scaleY,
            xOrigin: viewPortHandler.scaleX,
            yOrigin: viewPortHandler.scaleY,
            zoomCenterX: CGFloat(xValue),
            zoomCenterY: CGFloat(yValue),
            zoomOriginX: origin.x,
            zoomOriginY: origin.y,
            duration: duration,
            easing: easing)
        
        addViewportJob(job)
    }
    
    @objc open func zoomAndCenterViewAnimated(
        scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easingOption: ChartEasingOption)
    {
        zoomAndCenterViewAnimated(scaleX: scaleX, scaleY: scaleY, xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    @objc open func zoomAndCenterViewAnimated(
        scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval)
    {
        zoomAndCenterViewAnimated(scaleX: scaleX, scaleY: scaleY, xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .easeInOutSine)
    }
    
    @objc open func fitScreen()
    {
        let matrix = viewPortHandler.fitScreen()
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    @objc open func setScaleMinima(_ scaleX: CGFloat, scaleY: CGFloat)
    {
        viewPortHandler.setMinimumScaleX(scaleX)
        viewPortHandler.setMinimumScaleY(scaleY)
    }
    
    @objc open var visibleXRange: Double
    {
        return abs(highestVisibleX - lowestVisibleX)
    }
    
    @objc open func setVisibleXRangeMaximum(_ maxXRange: Double)
    {
        let xScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinimumScaleX(CGFloat(xScale))
    }
    
    @objc open func setVisibleXRangeMinimum(_ minXRange: Double)
    {
        let xScale = xAxis.axisRange / minXRange
        viewPortHandler.setMaximumScaleX(CGFloat(xScale))
    }
    
    @objc open func setVisibleXRange(minXRange: Double, maxXRange: Double)
    {
        let minScale = xAxis.axisRange / maxXRange
        let maxScale = xAxis.axisRange / minXRange
        viewPortHandler.setMinMaxScaleX(
            minScaleX: CGFloat(minScale),
            maxScaleX: CGFloat(maxScale))
    }
    
    @objc open func setVisibleYRangeMaximum(_ maxYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinimumScaleY(CGFloat(yScale))
    }
    
    @objc open func setVisibleYRangeMinimum(_ minYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / minYRange
        viewPortHandler.setMaximumScaleY(CGFloat(yScale))
    }
    
    @objc open func setVisibleYRange(minYRange: Double, maxYRange: Double, axis: YAxisChart.AxisDependency)
    {
        let minScale = getAxisRange(axis: axis) / minYRange
        let maxScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }
    
    @objc open func moveViewToX(_ xValue: Double)
    {
        let job = MoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: 0.0,
            transformer: getTransformer(forAxis: .left),
            view: self)
        
        addViewportJob(job)
    }
    
    @objc open func moveViewToY(_ yValue: Double, axis: YAxisChart.AxisDependency)
    {
        let yInView = getAxisRange(axis: axis) / Double(viewPortHandler.scaleY)
        
        let job = MoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: 0.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(forAxis: axis),
            view: self)
        
        addViewportJob(job)
    }
    
    @objc open func moveViewTo(xValue: Double, yValue: Double, axis: YAxisChart.AxisDependency)
    {
        let yInView = getAxisRange(axis: axis) / Double(viewPortHandler.scaleY)
        
        let job = MoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(forAxis: axis),
            view: self)
        
        addViewportJob(job)
    }
    
    @objc open func moveViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let bounds = valueForTouchPoint(
            point: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let yInView = getAxisRange(axis: axis) / Double(viewPortHandler.scaleY)
        
        let job = AnimatedMoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(forAxis: axis),
            view: self,
            xOrigin: bounds.x,
            yOrigin: bounds.y,
            duration: duration,
            easing: easing)
        
        addViewportJob(job)
    }
    
    @objc open func moveViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easingOption: ChartEasingOption)
    {
        moveViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    @objc open func moveViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval)
    {
        moveViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .easeInOutSine)
    }
    
    @objc open func centerViewTo(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency)
    {
        let yInView = getAxisRange(axis: axis) / Double(viewPortHandler.scaleY)
        let xInView = xAxis.axisRange / Double(viewPortHandler.scaleX)
        
        let job = MoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: xValue - xInView / 2.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(forAxis: axis),
            view: self)
        
        addViewportJob(job)
    }
    
    @objc open func centerViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let bounds = valueForTouchPoint(
            point: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let yInView = getAxisRange(axis: axis) / Double(viewPortHandler.scaleY)
        let xInView = xAxis.axisRange / Double(viewPortHandler.scaleX)
        
        let job = AnimatedMoveViewJobBarChart(
            viewPortHandler: viewPortHandler,
            xValue: xValue - xInView / 2.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(forAxis: axis),
            view: self,
            xOrigin: bounds.x,
            yOrigin: bounds.y,
            duration: duration,
            easing: easing)
        
        addViewportJob(job)
    }
    
    @objc open func centerViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval,
        easingOption: ChartEasingOption)
    {
        centerViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    @objc open func centerViewToAnimated(
        xValue: Double,
        yValue: Double,
        axis: YAxisChart.AxisDependency,
        duration: TimeInterval)
    {
        centerViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .easeInOutSine)
    }
    
    @objc open func setViewPortOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        _customViewPortEnabled = true
        
        if Thread.isMainThread
        {
            self.viewPortHandler.restrainViewPort(offsetLeft: left, offsetTop: top, offsetRight: right, offsetBottom: bottom)
            prepareOffsetMatrix()
            prepareValuePxMatrix()
        }
        else
        {
            DispatchQueue.main.async(execute: {
                self.setViewPortOffsets(left: left, top: top, right: right, bottom: bottom)
            })
        }
    }
    
    @objc open func resetViewPortOffsets()
    {
        _customViewPortEnabled = false
        calculateOffsets()
    }
    
    @objc open func getAxisRange(axis: YAxisChart.AxisDependency) -> Double
    {
        if axis == .left
        {
            return leftAxis.axisRange
        }
        else
        {
            return rightAxis.axisRange
        }
    }
    
    @objc open func getPosition(entry e: DataEntryChart, axis: YAxisChart.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y))
        
        getTransformer(forAxis: axis).pointValueToPixelBarChart(&vals)
        
        return vals
    }
    
    @objc open var dragEnabled: Bool
    {
        get
        {
            return _dragXEnabled || _dragYEnabled
        }
        set
        {
            _dragYEnabled = newValue
            _dragXEnabled = newValue
        }
    }
    
    @objc open var isDragEnabled: Bool
    {
        return dragEnabled
    }
    
    @objc open var dragXEnabled: Bool
    {
        get
        {
            return _dragXEnabled
        }
        set
        {
            _dragXEnabled = newValue
        }
    }
    
    @objc open var dragYEnabled: Bool
    {
        get
        {
            return _dragYEnabled
        }
        set
        {
            _dragYEnabled = newValue
        }
    }
    
    @objc open func setScaleEnabled(_ enabled: Bool)
    {
        if _scaleXEnabled != enabled || _scaleYEnabled != enabled
        {
            _scaleXEnabled = enabled
            _scaleYEnabled = enabled
            _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
        }
    }
    
    @objc open var scaleXEnabled: Bool
    {
        get
        {
            return _scaleXEnabled
        }
        set
        {
            if _scaleXEnabled != newValue
            {
                _scaleXEnabled = newValue
                _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
            }
        }
    }
    
    @objc open var scaleYEnabled: Bool
    {
        get
        {
            return _scaleYEnabled
        }
        set
        {
            if _scaleYEnabled != newValue
            {
                _scaleYEnabled = newValue
                _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
            }
        }
    }
    
    @objc open var isScaleXEnabled: Bool { return scaleXEnabled }
    @objc open var isScaleYEnabled: Bool { return scaleYEnabled }
    
    @objc open var doubleTapToZoomEnabled: Bool
    {
        get
        {
            return _doubleTapToZoomEnabled
        }
        set
        {
            if _doubleTapToZoomEnabled != newValue
            {
                _doubleTapToZoomEnabled = newValue
                _doubleTapGestureRecognizer.isEnabled = _doubleTapToZoomEnabled
            }
        }
    }
    
    @objc open var isDoubleTapToZoomEnabled: Bool
    {
        return doubleTapToZoomEnabled
    }
    
    @objc open var highlightPerDragEnabled = true
    
    @objc open var isHighlightPerDragEnabled: Bool
    {
        return highlightPerDragEnabled
    }
    
    @objc open var isDrawGridBackgroundEnabled: Bool
    {
        return drawGridBackgroundEnabled
    }
    
    @objc open var isDrawBordersEnabled: Bool
    {
        return drawBordersEnabled
    }
    
    @objc open func valueForTouchPoint(point pt: CGPoint, axis: YAxisChart.AxisDependency) -> CGPoint
    {
        return getTransformer(forAxis: axis).valueForTouchPointBarChart(pt)
    }
    
    @objc open func pixelForValues(x: Double, y: Double, axis: YAxisChart.AxisDependency) -> CGPoint
    {
        return getTransformer(forAxis: axis).pixelForValuesBarChart(x: x, y: y)
    }
    
    @objc open func getEntryByTouchPoint(point pt: CGPoint) -> DataEntryChart!
    {
        if let h = getHighlightByTouchPoint(pt)
        {
            return data!.entry(for: h)
        }
        return nil
    }
    
    @objc open func getDataSetByTouchPoint(point pt: CGPoint) -> ProtocolBarLineScatterCandleBubbleChartDataSet?
    {
        guard let h = getHighlightByTouchPoint(pt) else {
            return nil
        }
        
        return data?[h.dataSetIndex] as? ProtocolBarLineScatterCandleBubbleChartDataSet
    }
    
    @objc open var scaleX: CGFloat
    {
        return viewPortHandler.scaleX
    }
    
    @objc open var scaleY: CGFloat
    {
        return viewPortHandler.scaleY
    }
    
    @objc open var isFullyZoomedOut: Bool { return viewPortHandler.isFullyZoomedOut }
    
    @objc open func getAxis(_ axis: YAxisChart.AxisDependency) -> YAxisChart
    {
        if axis == .left
        {
            return leftAxis
        }
        else
        {
            return rightAxis
        }
    }
    
    @objc open var pinchZoomEnabled: Bool
    {
        get
        {
            return _pinchZoomEnabled
        }
        set
        {
            if _pinchZoomEnabled != newValue
            {
                _pinchZoomEnabled = newValue
                _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
            }
        }
    }
    
    @objc open var isPinchZoomEnabled: Bool { return pinchZoomEnabled }
    
    @objc open func setDragOffsetX(_ offset: CGFloat)
    {
        viewPortHandler.setDragOffsetX(offset)
    }
    
    @objc open func setDragOffsetY(_ offset: CGFloat)
    {
        viewPortHandler.setDragOffsetY(offset)
    }
    
    @objc open var hasNoDragOffset: Bool { return viewPortHandler.hasNoDragOffset }
    
    open override var chartYMax: Double
    {
        return max(leftAxis._axisMaximum, rightAxis._axisMaximum)
    }
    
    open override var chartYMin: Double
    {
        return min(leftAxis._axisMinimum, rightAxis._axisMinimum)
    }
    
    @objc open var isAnyAxisInverted: Bool
    {
        return leftAxis.isInverted || rightAxis.isInverted
    }
    
    @objc open var autoScaleMinMaxEnabled: Bool
    {
        get { return _autoScaleMinMaxEnabled }
        set { _autoScaleMinMaxEnabled = newValue }
    }
    
    @objc open var isAutoScaleMinMaxEnabled : Bool { return autoScaleMinMaxEnabled }
    
    @objc open func setYAxisMinWidth(_ axis: YAxisChart.AxisDependency, width: CGFloat)
    {
        if axis == .left
        {
            leftAxis.minWidth = width
        }
        else
        {
            rightAxis.minWidth = width
        }
    }
    
    @objc open func getYAxisMinWidth(_ axis: YAxisChart.AxisDependency) -> CGFloat
    {
        if axis == .left
        {
            return leftAxis.minWidth
        }
        else
        {
            return rightAxis.minWidth
        }
    }
    
    @objc open func setYAxisMaxWidth(_ axis: YAxisChart.AxisDependency, width: CGFloat)
    {
        if axis == .left
        {
            leftAxis.maxWidth = width
        }
        else
        {
            rightAxis.maxWidth = width
        }
    }
    
    @objc open func getYAxisMaxWidth(_ axis: YAxisChart.AxisDependency) -> CGFloat
    {
        if axis == .left
        {
            return leftAxis.maxWidth
        }
        else
        {
            return rightAxis.maxWidth
        }
    }
    
    @objc open func getYAxisWidth(_ axis: YAxisChart.AxisDependency) -> CGFloat
    {
        if axis == .left
        {
            return leftAxis.requiredSize().width
        }
        else
        {
            return rightAxis.requiredSize().width
        }
    }
    
    open func getTransformer(forAxis axis: YAxisChart.AxisDependency) -> TransformerBarChart
    {
        if axis == .left
        {
            return _leftAxisTransformer
        }
        else
        {
            return _rightAxisTransformer
        }
    }
    
    open override var maxVisibleCount: Int
    {
        get
        {
            return _maxVisibleCount
        }
        set
        {
            _maxVisibleCount = newValue
        }
    }
    
    open func isInverted(axis: YAxisChart.AxisDependency) -> Bool
    {
        return getAxis(axis).isInverted
    }
    
    open var lowestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom)
        
        getTransformer(forAxis: .left).pixelToValuesBarChart(&pt)
        
        return max(xAxis._axisMinimum, Double(pt.x))
    }
    
    open var highestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentRight,
            y: viewPortHandler.contentBottom)
        
        getTransformer(forAxis: .left).pixelToValuesBarChart(&pt)
        
        return min(xAxis._axisMaximum, Double(pt.x))
    }
}


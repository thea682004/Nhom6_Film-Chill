//
//  Animator.swift
//  PUP001
//
//  Created by chuottp on 19/08/2023.
//

import Foundation
import CoreGraphics
import QuartzCore

@objc(ChartAnimatorDelegate)
public protocol AnimatorDelegate
{
    func animatorUpdated(_ animator: AnimatorChart)
    
    func animatorStopped(_ animator: AnimatorChart)
}

@objc(ChartAnimator)
open class AnimatorChart: NSObject
{
    @objc open weak var delegate: AnimatorDelegate?
    @objc open var updateBlock: (() -> Void)?
    @objc open var stopBlock: (() -> Void)?
    @objc open var phaseX: Double = 1.0
    @objc open var phaseY: Double = 1.0
    
    private var startTimeX: TimeInterval = 0.0
    private var startTimeY: TimeInterval = 0.0
    private var displayLink: NSUIDisplayLink?
    
    private var durationX: TimeInterval = 0.0
    private var durationY: TimeInterval = 0.0
    
    private var _endTimeX: TimeInterval = 0.0
    private var _endTimeY: TimeInterval = 0.0
    private var _endTime: TimeInterval = 0.0
    
    private var _enabledX: Bool = false
    private var _enabledY: Bool = false
    
    private var _easingX: ChartEasingFunctionBlock?
    private var _easingY: ChartEasingFunctionBlock?

    public override init()
    {
        super.init()
    }
    
    deinit
    {
        stop()
    }
    
    @objc open func stop()
    {
        guard displayLink != nil else { return }

        displayLink?.remove(from: .main, forMode: RunLoop.Mode.common)
        displayLink = nil

        _enabledX = false
        _enabledY = false

        if phaseX != 1.0 || phaseY != 1.0
        {
            phaseX = 1.0
            phaseY = 1.0

            delegate?.animatorUpdated(self)
            updateBlock?()
        }

        delegate?.animatorStopped(self)
        stopBlock?()
    }
    
    private func updateAnimationPhases(_ currentTime: TimeInterval)
    {
        if _enabledX
        {
            let elapsedTime: TimeInterval = currentTime - startTimeX
            let duration: TimeInterval = durationX
            var elapsed: TimeInterval = elapsedTime
            if elapsed > duration
            {
                elapsed = duration
            }
           
            phaseX = _easingX?(elapsed, duration) ?? elapsed / duration
        }
        
        if _enabledY
        {
            let elapsedTime: TimeInterval = currentTime - startTimeY
            let duration: TimeInterval = durationY
            var elapsed: TimeInterval = elapsedTime
            if elapsed > duration
            {
                elapsed = duration
            }

            phaseY = _easingY?(elapsed, duration) ?? elapsed / duration
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhases(currentTime)

        delegate?.animatorUpdated(self)
        updateBlock?()
        
        if currentTime >= _endTime
        {
            stop()
        }
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        stop()
        
        startTimeX = CACurrentMediaTime()
        startTimeY = startTimeX
        durationX = xAxisDuration
        durationY = yAxisDuration
        _endTimeX = startTimeX + xAxisDuration
        _endTimeY = startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        _enabledY = yAxisDuration > 0.0
        
        _easingX = easingX
        _easingY = easingY
        
        updateAnimationPhases(startTimeX)
        
        if _enabledX || _enabledY
        {
            displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
            displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingFunctionFromOption(easingOptionX), easingY: easingFunctionFromOption(easingOptionY))
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easing, easingY: easing)
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        startTimeX = CACurrentMediaTime()
        durationX = xAxisDuration
        _endTimeX = startTimeX + xAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        
        _easingX = easing
        
        updateAnimationPhases(startTimeX)
        
        if _enabledX || _enabledY,
            displayLink == nil
        {
            displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
            displayLink?.add(to: .main, forMode: RunLoop.Mode.common)
        }
    }
    
    @objc open func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(xAxisDuration: xAxisDuration, easing: easingFunctionFromOption(easingOption))
    }

    @objc open func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        startTimeY = CACurrentMediaTime()
        durationY = yAxisDuration
        _endTimeY = startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledY = yAxisDuration > 0.0
        
        _easingY = easing
        
        updateAnimationPhases(startTimeY)
        
        if _enabledX || _enabledY,
            displayLink == nil
        {
            displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
            displayLink?.add(to: .main, forMode: RunLoop.Mode.common)
        }
    }
    
    @objc open func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
}


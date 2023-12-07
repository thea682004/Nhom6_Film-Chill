//
//  Platform+Accessibility.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    UIAccessibility.post(notification: .layoutChanged, argument: element)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    UIAccessibility.post(notification: .screenChanged, argument: element)
}

open class NSUIAccessibilityElement: UIAccessibilityElement
{
    private weak var viewContainer: UIView?
    
    final var checkIsHeader: Bool = false
    {
        didSet
        {
            accessibilityTraits = checkIsHeader ? .header : .none
        }
    }
    
    final var isSelected: Bool = false
    {
        didSet
        {
            accessibilityTraits = isSelected ? .selected : .none
        }
    }
    
    override public init(accessibilityContainer container: Any)
    {
        viewContainer = container as? UIView
        super.init(accessibilityContainer: container)
    }
    
    override open var accessibilityFrame: CGRect
    {
        get
        
        {
            return super.accessibilityFrame
        }
        
        set
        {
            guard let viewContainer = viewContainer else { return }
            super.accessibilityFrame = viewContainer.convert(newValue, to: UIScreen.main.coordinateSpace)
        }
    }
}

extension NSUIView
{
    
    @objc open func accessibilityChildren() -> [Any]?
    {
        return nil
    }
    
    public final override var isAccessibilityElement: Bool
    {
        get { return false }
        set { }
    }
    
    open override func accessibilityElementCount() -> Int
    {
        return accessibilityChildren()?.count ?? 0
    }
    
    open override func accessibilityElement(at index: Int) -> Any?
    {
        return accessibilityChildren()?[index]
    }
    
    open override func index(ofAccessibilityElement element: Any) -> Int
    {
        guard let axElement = element as? NSUIAccessibilityElement else { return NSNotFound }
        return (accessibilityChildren() as? [NSUIAccessibilityElement])?.firstIndex(of: axElement) ?? NSNotFound
    }
}

#endif

#if os(OSX)
import AppKit


internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    guard let validElement = element else { return }
    NSAccessibility.post(element: validElement, notification: .layoutChanged)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    
}

open class NSUIAccessibilityElement: NSAccessibilityElement
{
    private weak var viewContainer: NSView?
    
    final var checkIsHeader: Bool = false
    {
        didSet
        {
            setAccessibilityRole(checkIsHeader ? .staticText : .none)
        }
    }
    
    final var isSelected: Bool = false
    {
        didSet
        {
            setAccessibilitySelected(isSelected)
        }
    }
    
    open var accessibilityLabel: String
    {
        get
        {
            return accessibilityLabel() ?? ""
        }
        
        set
        {
            setAccessibilityLabel(newValue)
        }
    }
    
    open var accessibilityFrame: NSRect
    {
        get
        {
            return accessibilityFrame()
        }
        
        set
        {
            guard let viewContainer = viewContainer else { return }
            
            let bounds = NSAccessibility.screenRect(fromView: viewContainer, rect: newValue)
            
            setAccessibilityFrameInParentSpace(bounds)
            let axFrame = accessibilityFrame()
            let widthOffset = abs(axFrame.origin.x - bounds.origin.x)
            let heightOffset = abs(axFrame.origin.y - bounds.origin.y)
            let rect = NSRect(x: bounds.origin.x - widthOffset,
                              y: bounds.origin.y - heightOffset,
                              width: bounds.width,
                              height: bounds.height)
            setAccessibilityFrameInParentSpace(rect)
        }
    }
    
    public init(accessibilityContainer container: Any)
    {
        viewContainer = (container as! NSView)
        
        super.init()
        
        setAccessibilityParent(viewContainer)
        setAccessibilityRole(.row)
    }
}

extension NSUIView: NSAccessibilityGroup
{
    open override func accessibilityLabel() -> String?
    {
        return "Chart View"
    }
    
    open override func accessibilityRows() -> [Any]?
    {
        return accessibilityChildren()
    }
}

#endif


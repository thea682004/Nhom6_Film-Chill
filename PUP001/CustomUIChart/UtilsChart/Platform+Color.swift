//
//  Platform+Color.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//

#if canImport(UIKit)
import UIKit

public typealias NSUIColor = UIColor
private func getLabelColor() -> UIColor
{
    if #available(iOS 13, tvOS 13, *)
    {
        return .label
    }
    else
    {
        return .black
    }
}
private let labelColor: UIColor = getLabelColor()

extension UIColor
{
    static var labelOrBlack: UIColor { labelColor }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public typealias NSUIColor = NSColor
private func getLabelColor() -> NSColor
{
    if #available(macOS 10.14, *)
    {
        return .labelColor
    }
    else
    {
        return .black
    }
}
private let labelColor: NSColor = getLabelColor()

extension NSColor
{
    static var labelOrBlack: NSColor { labelColor }
}
#endif


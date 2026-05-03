//
//  File.swift
//  DesignInspectorKit
//
//

import UIKit

extension UIColor {
    
    /// Returns the color as an uppercase hex string.
    /// Includes alpha component (8 chars) only when `alpha < 1.0`, otherwise returns 6 chars.
    /// Example: `"FF3B30"` or `"FF3B3080"`.
    public var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        let color: UIColor
        if cgColor.colorSpace?.model == .rgb {
            color = self
        } else if let sRGB = CGColorSpace(name: CGColorSpace.sRGB),
                  let converted = cgColor.converted(to: sRGB, intent: .defaultIntent, options: nil) {
            color = UIColor(cgColor: converted)
        } else {
            color = self
        }
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        if alpha < 1 {
            let a = Int(alpha * 255)
            return String(format: "%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "%02X%02X%02X", r, g, b)
        }
    }
    
    /// Creates a `UIColor` from a hex string.
    /// Accepts 6-character (RGB) or 8-character (RGBA) hex strings, with or without a leading `#`.
    /// - Parameter hexString: A hex color string, e.g. `"#FF3B30"` or `"FF3B3080"`.
    /// - Returns: A `UIColor` instance, or `nil` if the string is invalid.
    public convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        switch length {
        case 6:
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    /// Returns `true` if the color's perceived brightness is greater than 50%.
    /// Useful for determining whether to use dark or light text on top of this color.
    public var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
}

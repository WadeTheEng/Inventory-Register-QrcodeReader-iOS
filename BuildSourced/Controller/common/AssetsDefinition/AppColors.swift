// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

extension UIColor {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension UIColor {
  enum Name {
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#18b1c7"></span>
    /// Alpha: 100% <br/> (0x18b1c7ff)
    case AppRed
    
    case AppGreen
    
    case AppBlue
    
    case AppGrey
    
    case AppLightGrey


    var rgbaValue: UInt32! {
      switch self {
      case .AppRed: return 0xf9003aff
      case .AppGreen: return 0x6daa00ff
      case .AppBlue: return 0x009beeff
      case .AppGrey: return 0x747684ff
      case .AppLightGrey: return 0xcfcfcfff
      }
    }
  }

  convenience init(named name: Name) {
    self.init(rgbaValue: name.rgbaValue)
  }
}


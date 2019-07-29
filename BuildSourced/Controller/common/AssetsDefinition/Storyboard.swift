
import Foundation
import UIKit

protocol StoryboardSceneType {
  static var storyboardName : String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return storyboard().instantiateInitialViewController()!
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
     return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType : RawRepresentable { }

extension UIViewController {
  func performSegue<S : StoryboardSegueType>(segue: S, sender: AnyObject? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum LaunchScreen : StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
    
  }

  enum Main : String, StoryboardSceneType {
    static let storyboardName = "Main"

    case SettingView = "SettingView"
    static func settingVC() -> SettingVC {
      return StoryboardScene.Main.SettingView.viewController() as! SettingVC
    }
    
    case MainView = "MainView"
    static func mainVC() -> MainVC {
        return StoryboardScene.Main.MainView.viewController() as! MainVC
    }
    
    case MaintncView = "MaintncView"
    static func maintncVC() -> MaintncVC {
        return StoryboardScene.Main.MaintncView.viewController() as! MaintncVC
    }
    
    case PendingListView = "PendingListView"
    static func pendingList() -> PendingList {
        return StoryboardScene.Main.PendingListView.viewController() as! PendingList
    }
    
    case TotalPendingView = "TotalPendingView"
    static func totalPendingVC() -> TotalPendingVC {
        return StoryboardScene.Main.TotalPendingView.viewController() as! TotalPendingVC
    }
    
    case LatLngPendingView = "LatLngPendingView"
    static func latLngPendingVC() -> LatLngPendingVC {
        return StoryboardScene.Main.LatLngPendingView.viewController() as! LatLngPendingVC
    }
    
    case ImageAddedPendingView = "ImageAddedPendingView"
    static func imageAddedPendingVC() -> ImageAddedPendingVC {
        return StoryboardScene.Main.ImageAddedPendingView.viewController() as! ImageAddedPendingVC
    }
    
    case MaintncPendingView = "MaintncPendingView"
    static func maintncPendingVC() -> MaintncPendingVC {
        return StoryboardScene.Main.MaintncPendingView.viewController() as! MaintncPendingVC
    }
    
    case ItemDetailView = "ItemDetailView"
    static func itemDetailVC() -> ItemDetailVC {
        return StoryboardScene.Main.ItemDetailView.viewController() as! ItemDetailVC
    }
    
    case TakePhotoView = "TakePhotoView"
    static func takePhotoVC() -> TakePhotoVC {
        return StoryboardScene.Main.TakePhotoView.viewController() as! TakePhotoVC
    }
    
    case WebHomeView = "WebHomeView"
    static func webHomeVC() -> WebHomeVC {
        return StoryboardScene.Main.WebHomeView.viewController() as! WebHomeVC
    }
    
    case HelpView = "HelpView"
    static func helpVC() -> HelpVC {
        return StoryboardScene.Main.HelpView.viewController() as! HelpVC
    }
    

  }
}

struct StoryboardSegue {
}


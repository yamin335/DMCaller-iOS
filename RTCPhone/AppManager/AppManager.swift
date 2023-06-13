import Foundation
import  UIKit

class AppManager {
    static var favoritesNavigationBarUtil: NavigationBarUtil?
    static var contactsNavigationBarUtil: NavigationBarUtil?
    static var callHistoryNavigationBarUtil: NavigationBarUtil?
    static var confNavigationBarUtil: NavigationBarUtil?
    static var settingsNavigationBarUtil: NavigationBarUtil?
    static var dialNavigationBarUtil: NavigationBarUtil?
    static var  companyID = "1000"
    static var  userID = "rtchubs"
    static var  platform = "ios"
    
    
    class func isValidBDPhoneNumber(trimmedNumber: String) -> Bool {
        if trimmedNumber == "0" || trimmedNumber == "01" || trimmedNumber == "011" || trimmedNumber == "013" || trimmedNumber == "014" || trimmedNumber == "015" || trimmedNumber == "016" || trimmedNumber == "017" || trimmedNumber == "018" || trimmedNumber == "019" {
            return true
        }
        else {
            return false
        }
    }
}

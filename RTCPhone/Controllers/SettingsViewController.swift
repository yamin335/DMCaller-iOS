//
//  SettingsViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var userDisplayID: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var btnEdit: UIButton!
    var settingOptions = [
        "Notifications", "Ringtone",
        "Help", "Tell a Friend"
        ]
    
    // "Kotha Dialer V-\(AppGlobalValues.appVersion)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        if let navUtil = AppManager.settingsNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        
        userDisplayName.text = UserDefaults.standard.string(forKey: "displayName")
        userDisplayID.text = UserDefaults.standard.string(forKey: "username")
    }
    
    @IBAction func editButtonTapAction(_ sender: UIButton) {
        performSegue(withIdentifier: "gotoAccountSettingsVC", sender: self)
    }
    
    @IBAction func logOutButtonTapAction(_ sender: Any) {
        logoutFromApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateBalance()
    }
    
    func goToLoginPage() {
//        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//        navigationController?.pushViewController(loginVC, animated: true)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func logoutFromApp() {
        clearUserData()
        goToLoginPage()
        self.dismiss(animated: true, completion: nil)
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "mobileNo")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "server")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.removeObject(forKey: "companyUniqueID")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
    }
    
    func shareAppLink() {
        let shareVc = UIActivityViewController(activityItems: ["Kotha Dialer https://www.bdcom.com/pages/view/corporate-office"], applicationActivities: nil)
        shareVc.popoverPresentationController?.sourceView = self.view
        self.present(shareVc, animated: true, completion: nil)
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        settingsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAccountSettingsVC" {
            
        } else if segue.identifier == "gotoAboutVersionVC" {
            
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsTableViewCell
        cell.settingsLabelTitles.text = settingOptions[indexPath.row]
//        if indexPath.row == settingOptions.count - 1 {
//            cell.separatorInset.left = cell.bounds.size.width + 200
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "showNotificationSegue", sender: self)
                break
            case 1:
                performSegue(withIdentifier: "gotoRingtoneSelectionVC", sender: self)
                break
            case 2:
                performSegue(withIdentifier: "goToHelpSegue", sender: self)
//                if let termsAndConditionsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactUSViewController") as? ContactUSViewController {
//                    self.navigationController?.show(termsAndConditionsVC, sender: nil)
//                }
                break
                
            case 3:
                shareAppLink()
                break
                //performSegue(withIdentifier: "gotoLoggedOutVC", sender: self)
                // set up activity view controller
//                let urlApp = "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8"
//                if let url = URL(string: urlApp), UIApplication.shared.canOpenURL(url) {
//                    let urlToShare = [url]
//                    let activityViewController = UIActivityViewController(activityItems: urlToShare as [Any], applicationActivities: nil)
//                    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//                    self.present(activityViewController, animated: true, completion: nil)
//                }
            case 4:
                performSegue(withIdentifier: "gotoNetworkSettingsVC", sender: self)
                break
                //print("Report an Issue")
//                let composeVC = MFMailComposeViewController()
//                composeVC.mailComposeDelegate = self
//                composeVC.setToRecipients(["address@example.com"])
//                composeVC.setSubject("Report an Issue - GoCall")
//
//                let systemVersion = UIDevice.current.systemVersion
//                let model = UIDevice.current.model
//                let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
//                let userID = UserDefaults.standard.value(forKey: "username") as? String
//                let body : String = "Platform: IOS \nOS: \(systemVersion) \nApplication Version: \(appVersion ?? "") \nUser ID: \(userID!)\nBrand: GoCall \nModel: \(model)"
//                composeVC.setMessageBody(body, isHTML: false)
//
//                self.present(composeVC, animated: true, completion: nil)
            case 5:
                logoutFromApp()
                break
                //print("Terms and Conditions")
//                if let termsAndConditionsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as? TermsAndConditionsViewController {
//                    self.navigationController?.show(termsAndConditionsVC, sender: nil)
//                }
            case 6:
                break
                //performSegue(withIdentifier: "gotoAboutVersionVC", sender: self)
            case 7:
                break
//                if let sslCommerzVc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SSLCommerzViewController") as? SSLCommerzViewController {
//                    sslCommerzVc.paymentDone = {
//                      self.updateBalance()
//                    }
//
//                    self.navigationController?.show(sslCommerzVc, sender: nil)
//                }
                
//                UserDefaults.standard.set(nil, forKey: "username")
//                UserDefaults.standard.set(nil, forKey: "password")
//                UserDefaults.standard.synchronize()
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
//                NavigationManager.setViewController(mainTabbarVC!, left: true)
            default:
                print("Error")
            }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //print(result.rawValue)
        if result == .sent{
            DispatchQueue.main.async() {
                let alert = UIAlertController(title: "Success", message: "Mail has been sent successfully", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

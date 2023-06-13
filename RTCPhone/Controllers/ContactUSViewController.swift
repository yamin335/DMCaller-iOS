//
//  ContactUSViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 27/3/19.
//  Copyright © 2019 Mamun Ar Rashid. All rights reserved.
//

import Foundation

import UIKit

class ContactUSViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let url = URL (string: "https://www.bdcom.com/pages/view/corporate-office")
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

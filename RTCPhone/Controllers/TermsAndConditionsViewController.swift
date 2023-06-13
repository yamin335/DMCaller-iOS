//
//  TermsAndConditionsViewController.swift
//  RTCPhone
//
//  Created by Ashraful Islam Masum on 1/27/19.
//  Copyright © 2019 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL (string: "https://google.com")
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

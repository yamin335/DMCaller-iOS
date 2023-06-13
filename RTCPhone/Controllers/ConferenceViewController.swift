//
//  ConferenceViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class ConferenceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Conference"
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        //create a new button
        let button = UIButton.init(type: .custom)
        
        //set image for button
        button.setImage(UIImage(named: "createGroup"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: #selector(addTapped), for: UIControl.Event.touchUpInside)
        //set frame
        button.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem()
        barButton.customView = button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        if let navUtil = AppManager.confNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        

//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(addTapped))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    

    @objc func addTapped() {
        performSegue(withIdentifier: "gotoNewConferenceVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = false
        if segue.identifier == "gotoNewConferenceVC" {
            ConferenceMemberListManager.currentConferenceList.removeAll()
            let det = segue.destination as! RTCNewConferenceVC
//            det.hidesBottomBarWhenPushed = true
        }
    }

}

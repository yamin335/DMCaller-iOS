//
//  RTCChatRoomVC.swift
//  RTCPhone
//
//  Created by Admin on 4/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class RTCNewConferenceVC: UIViewController {
    var tapGestureForConferenceContacts: UITapGestureRecognizer?
    var button = UIButton()
    var conferenceContacts: [ContactsManager] = []
    var deleteSelectedIndexPaths: [IndexPath] = []
    @IBOutlet weak var chatUserLogoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imagesForCollectionView.append(UIImage(named: "user")!)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        
        setUpButtonForNavigationTitle()
        self.navigationItem.titleView = button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        
        //Adding Long Press Gesture to collectionView Cells
        tapGestureForConferenceContacts = UITapGestureRecognizer(target: self, action: #selector(handleTapPress))
        tapGestureForConferenceContacts?.delegate = self
        //longGestureForConferenceContacts.delaysTouchesBegan = true
    self.chatUserLogoCollectionView.addGestureRecognizer(tapGestureForConferenceContacts!)
        
        let nibFile : UINib =  UINib(nibName: "StaticHostCustomCell", bundle: nil)
        
        chatUserLogoCollectionView.register(nibFile, forCellWithReuseIdentifier: "hostCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func handleTapPress(gesture : UITapGestureRecognizer) {
        let p = gesture.location(in: self.chatUserLogoCollectionView)
        guard let indexPath = self.chatUserLogoCollectionView.indexPathForItem(at: p) else {return}
        if indexPath.row == 0 {
            print("Do Nothing")
        } else {
            let cell = self.chatUserLogoCollectionView.cellForItem(at: indexPath) as! ConferenceRoomCollectionViewCell
            if !cell.isEditing {
                cell.isEditing = true
                cell.delegate = self
                deleteSelectedIndexPaths.append(indexPath)
                print("Tapped Action: \(deleteSelectedIndexPaths)")
                print("Cell Tapped")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conferenceContacts =  ConferenceMemberListManager.currentConferenceList
        chatUserLogoCollectionView.reloadData()
        
    }
    func setUpButtonForNavigationTitle() {
        button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = UIColor.clear
        
        button.setTitle("New Conference", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(clickOnButton(button:)), for: .touchUpInside)
    }
    
//MARK:- This is add barButton action
    @objc func addTapped() {
//        self.imagesForCollectionView.append(UIImage(named: "addIcon")!)
//        self.chatUserLogoCollectionView.insertItems(at: [NSIndexPath(row: imagesForCollectionView.count - 1, section: 0) as IndexPath])
        performSegue(withIdentifier: "gotoNewMembersVC", sender: self)
        
    }
    
    
    
//MARK:- This is navigationItem title button action
     @objc func clickOnButton(button: UIButton) {
            alertForNewConfarence(button: self.button)
    }
    
    
//MARK:- Alert action
    func alertForNewConfarence(button: UIButton) {
        let alertController = UIAlertController(title: "Conference Name", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "New Conference"
        }
        let saveAction = UIAlertAction(title: "Change Name", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if let name = firstTextField.text {
                if name.isEmpty {
                    
                } else {
                    button.setTitle(name, for: .normal)
                }
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoNewMembersVC" {
            let det = segue.destination as! RTCAddNewMembersVC
//            det.hidesBottomBarWhenPushed = true
        }
    }
    
    @IBAction func startConferenceCall() {
        var phoneNumbers: [String] = []
        
        for conferenceContact in conferenceContacts {
            phoneNumbers.append(conferenceContact.phoneNumber!)
        }
        
        //if let phoneNumber = phoneNumbers {
        if AppGlobalValues.isCallOngoing {
            
        } else {
            if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                //callVC.conferenceNumbers = phoneNumbers
                callVC.modalPresentationStyle = .fullScreen
                self.present(callVC, animated: true, completion: nil)
            }
        }
       // }
        
    }
}

extension RTCNewConferenceVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if conferenceContacts.count == 0 {
//            return 1
//        } else {
            return conferenceContacts.count + 1
        //}
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ConferenceRoomCollectionViewCell
        if indexPath.row == 0 {
//            cell.conferenceUserIconView.image = UIImage(named: "user")
//            cell.contactsName.text = "Host"
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "hostCell", for: indexPath) as! StaticHostCustomCell
            cell1.iconView.image = UIImage(named: "user")
            cell1.hostname.text = "Host User"
            return cell1
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ConferenceRoomCollectionViewCell
        cell.conferenceUserIconView.setImageForName(string: ConferenceMemberListManager.currentConferenceList[indexPath.row-1].names!, circular: true, textAttributes: nil)
        cell.contactsName.text = ConferenceMemberListManager.currentConferenceList[indexPath.row-1].names!
            
            // this chunk of code below is edited for resolve a critical bug at 7/07/2018
            // everytime remember where cell is creating, thats where we would edit our code
            if deleteSelectedIndexPaths.contains(indexPath) {
                print("CollectionView: \(indexPath)")
                cell.delegate = self
                cell.isEditing = true
            } else {
                cell.delegate = nil
                cell.isEditing = false
            }
            return cell

        }
//        // this chunk of code below is edited for resolve a critical bug at 7/07/2018
//        // everytime remember where cell is creating, thats where we would edit our code
//        if deleteSelectedIndexPaths.contains(indexPath) {
//            print("CollectionView: \(indexPath)")
//            cell.delegate = self
//            cell.isEditing = true
//        } else {
//            cell.delegate = nil
//            cell.isEditing = false
//        }
//        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
//            performSegue(withIdentifier: "gotoNewMembersVC", sender: self)
        }
    }
}
//MARK:- UIGestureRecognizerDelegate Goes here
extension RTCNewConferenceVC: UIGestureRecognizerDelegate {
    
}
//MARK:- PhotoCellDelegate Implementation
extension RTCNewConferenceVC: PhotoCellDelete {
    func deleteCell(cell: ConferenceRoomCollectionViewCell) {
        if cell.isEditing {
            cell.isEditing = false
            if let index = chatUserLogoCollectionView.indexPath(for: cell) {
                //1. Delete the photo from our data source
                conferenceContacts.remove(at: index.item-1)
                ConferenceMemberListManager.currentConferenceList.remove(at: index.item-1)
                //2. delete the photo cell at the index path from the collection view
                chatUserLogoCollectionView.deleteItems(at: [index])
             
                //if deleteSelectedIndexPaths.contains(index) {
                       //deleteSelectedIndexPaths.re
                    print("DeletedIndex at Delete Protocol Success")
                    var deletedIndex  = 0
                    var count  = 0
                    for i in deleteSelectedIndexPaths {
                        if i == index {
                            deletedIndex = count
                        }
                        count = count + 1
                    }
                //}
                deleteSelectedIndexPaths.remove(at: deletedIndex)
                for indexPath in deleteSelectedIndexPaths {
                    if indexPath.row > index.row {
                        var deletedIndex  = 0
                        var count  = 0
                        for i in deleteSelectedIndexPaths {
                            if i == indexPath {
                                deletedIndex = count
                            }
                            count = count + 1
                        }
                        deleteSelectedIndexPaths.remove(at: deletedIndex)
                        deleteSelectedIndexPaths.append(IndexPath(row: indexPath.row - 1, section: 0))
                    }
                }
                chatUserLogoCollectionView.reloadData()
            }
        }
        
        
    }
}


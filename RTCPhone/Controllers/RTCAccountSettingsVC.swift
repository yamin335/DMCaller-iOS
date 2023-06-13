//
//  RTCAccountSettingsVC.swift
//  RTCPhone
//
//  Created by Admin on 8/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class RTCAccountSettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextFieldX!
    @IBOutlet weak var numberField: UITextFieldX!
    @IBOutlet weak var profileImageOutlet: UIImageView! {
        didSet {
            profileImageOutlet.layer.borderWidth = 4
            profileImageOutlet.layer.borderColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
        }
    }
    @IBOutlet weak var changeAvatarOutlet: UIButton!
    

    var progressHUD: ProgressHUDManager?
    var theLinphoneManager: LinphoneManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Account Setting"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String, let server = UserDefaults.standard.value(forKey: "server") as? String {
            if !userID.isEmpty && !pass.isEmpty {
                nameField.text = userID
//                passTextField.text = pass
//                serverTextField.text = server
            }
        }
        
         if let displayName = UserDefaults.standard.value(forKey: "displayName") as? String, let username = UserDefaults.standard.value(forKey: "username") as? String  {
            nameField.text = displayName
            numberField.text = username
        }
        
        if let avatarImage = UserDefaults.standard.value(forKey: "avatarImage") as? String {
            print(avatarImage)
            let image = loadImageFromDocumentDirectory(nameOfImage: avatarImage)
            //print(image!)
            profileImageOutlet.image = image
            profileImageOutlet.isHidden = false
            profileImageOutlet.superview?.backgroundColor = UIColor.white
        }
        
        //UserDefaults.standard.set("202.4.97.11", forKey: "server")

//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self,
//                                       selector: #selector(LoginViewController.didRegistered(_:)),
//                                       name: CallStateNotificationName.registered.notificationName,
//                                       object: nil)
//        notificationCenter.addObserver(self,
//                                       selector: #selector(LoginViewController.failedRegistered(_:)),
//                                       name: CallStateNotificationName.failedRegistered.notificationName,
//                                       object: nil)
        
        
    }
    
    @objc func failedRegistered(_ sender: NSNotification) {
        //DispatchQueue.main.async {
            self.progressHUD?.isNeedShowSpinnerOnly = false
            self.progressHUD?.isNeedShowImage = true
            self.progressHUD?.isNeedWaitForUserAction = true
            self.progressHUD?.failledMessage = "User not found"
            self.progressHUD?.onFailed()
        //}
    }
    
    @objc func didRegistered(_ sender: NSNotification) {
        if let userID = self.nameField.text {
            self.progressHUD?.isNeedShowSpinnerOnly = false
            self.progressHUD?.isNeedShowImage = true
            self.progressHUD?.isNeedWaitForUserAction = false
             self.progressHUD?.successStatus = "Success"
            self.progressHUD?.successMessage = "successfully saved"
                
                UserDefaults.standard.set(userID, forKey: "username")
                UserDefaults.standard.synchronize()
        }
//        if let userID = self.nameField.text , let pass = self.passTextField.text {
//
//            self.progressHUD?.isNeedShowSpinnerOnly = false
//            self.progressHUD?.isNeedShowImage = true
//            self.progressHUD?.isNeedWaitForUserAction = false
//             self.progressHUD?.successStatus = "Success"
//            self.progressHUD?.successMessage = "successfully saved"
//
//                UserDefaults.standard.set(userID, forKey: "username")
//                UserDefaults.standard.set(pass, forKey: "password")
//                UserDefaults.standard.synchronize()
//        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        print("Touched")
        nameField.resignFirstResponder()
        numberField.resignFirstResponder()
    }

    @IBAction func saveBtn(_ sender: UIButton) {
 

    }
    
    // For Change Avatar
    var imagePicker: UIImagePickerController!
    
    @IBAction func changeAvatarAction(_ sender: UIButton) {
        
        DispatchQueue.main.async{
            
            let alert = UIAlertController(title: "Alert", message: "Choose Avatar picture from Camera or Gallery", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Take a photo", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                    DispatchQueue.main.async{
                        
                        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                            print("already authorized")
                            self.Cemara()
                        } else {
                            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                                if granted {
                                    print("access allowed")
                                    self.Cemara()
                                } else {
                                    //access denied
                                    let alertController = UIAlertController(title: "Error", message: "Camera access is denied", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            })
                        }
                            
                    }
                }))
            alert.addAction(UIAlertAction(title: "Choose from Library", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                    DispatchQueue.main.async{
                        let imagepicker = UIImagePickerController()
                        imagepicker.delegate = self
                        imagepicker.sourceType = .photoLibrary
                        self.present(imagepicker, animated: true, completion: nil)
                    }
                }))
                
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in}))
                
                self.present(alert, animated: true, completion: nil)
                
        }
        
    }
    
    // Gallery Code
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageOutlet.image = image
            profileImageOutlet.isHidden = false
            profileImageOutlet.superview?.backgroundColor = UIColor.white
            //print(imagedata)
            
            // get the documents directory url
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // choose a name for your image
            let fileName = "image_\(NSDate().timeIntervalSince1970 * 1000).jpg"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            // get your UIImage jpeg data representation and check if the destination file url already exists
            if let data = image.jpegData(compressionQuality: 1.0),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: fileURL)
                    UserDefaults.standard.set(fileName, forKey: "avatarImage")
                    UserDefaults.standard.synchronize()
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            let image    = UIImage(contentsOfFile: imageURL.path)
            // Do whatever you want with the image
            return image!
        }
        return UIImage.init()
    }
    
    // Capture image by using camera
    func Cemara(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    
}


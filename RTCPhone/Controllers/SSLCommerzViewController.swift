//
//  SSLCommerzViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 9/12/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import WebKit

class SSLCommerzViewController: UIViewController , SSLCommerzDelegate, WKUIDelegate{

    var SDKObject : SSLCommerz?
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var webView: UIWebView!
  
    var tranID: String = ""
    var paymentDone: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKObject = SSLCommerz()
        SDKObject?.delegate = self
        
        webView.isHidden = true

        // Do any additional setup after loading the view.
    }
    

    func transactionSuccessful(withCompletionhandler transactionData: TransactionDetails!){
        if(transactionData != nil){
            print(transactionData.status, transactionData.sessionkey,      transactionData.bank_tran_id, transactionData.amount, transactionData.card_type, transactionData.tran_date)
            if let transactionData = transactionData, let status = transactionData.status, status == "VALID" {
                //call api to update trasaction info
                updateTransactionInfotoAmberIT(transactionData: transactionData)
                updateTransactionInfoReveSystem(transactionData: transactionData)
            }
            
        }
    }
    func updateTransactionInfotoAmberIT(transactionData: TransactionDetails) {
        var para: [String:Any] = [:]
        //para["apikey"] = "81efa480098b0009cea8cd5a7dd5d1aa"
        para["apikey"] = "QW1CRXJQam9oZW5uQ0NIOTg0NDkzSEhAQCNDSEhNZ2dteX" // new api key
        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let mobileno = UserDefaults.standard.value(forKey: "mobileNo") as? String {
            para["username"] = userID
            para["mobileno"] = mobileno
            para["rechargeAmount"] = transactionData.amount
            para["txid"] = tranID
            
        }

        
        APIManager.requestWith(endUrl: "https://amberphone.amberit.com.bd/amberphoneapi/addRechargeInfo.php", imageData: nil, parameters: para, onCompletion: { json in
            if let json = json {
                if let statuscode = json["statuscode"] as? String, statuscode != "200OK" {
                    let errorMessage = json["message"] as? String
                    //
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                   // if let data = json["data"] as? [String:Any],  let username = data["username"] as? String,
                       // let password = data["secret"] as? String {
                        DispatchQueue.main.async {
                            
                            if let paymentDone = self.paymentDone {
                                paymentDone()
                            }
                            let alert = UIAlertController(title: "Success", message: "Payment successfully done", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                                 self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    //}
                }
            } else {
                // Server Error
                let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }, onError: { error in
            // Server Error
            let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func updateTransactionInfoReveSystem(transactionData: TransactionDetails) {
        
    }
    
  
//    @IBAction func pay(_ sender: UIButton) {
//        SDKObject?.startSSLCOMMERZinViewController(self, withStoreID: "testbox", storePassword: "qwerty", amountToPay: "10.00", amountCurrency: "BDT", applicationBundleID: "com.sslWireless.SSLCommerzSDKTest", appTransactionID: "TRANX ID", sourceDetail: "DETAIL", withCustomerEmail: "EMAIL", customerName: "NAME", customerContactNumber: "CONTACT", customerFax: "", customerAddress1: "ADDRESS", customerAddress2: "ADDRESS 2", customerCity: "CITY", customerState: "STATE", customerPostCode: "POSTCODE", customerCountry: "COUNTRY", withShipmentInfo: "INFO", shipmentAddress1: "ADDRESS", shipmentAddress2: "ADDRESS LINE 2", shipmentCity: "CITY", shipmentState: "STATE", sHipmentPostCode: "POSTCODE", shipmentCountry: "COUNTRY", withOptionalValueA: "Optional value", optionalValueB: " Optional value ", optionalValueC: " Optional value ", optionalValueD: " Optional value ", shouldRunInTestMode: true)
//    }
//
    @IBAction func pay(_ sender: UIButton) {
    
         if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String, let amount = self.amountTextField.text, !amount.isEmpty {
            var amountTextFieldValue = amount
            amountTextFieldValue = String(format: "%.2f", Float(amountTextFieldValue)!)
            var url = URL(string:"https://billing.amberit.com.bd/IPTSP_SSLCommerz/webpayment/sslCommerzSubmit.jsp?username=\(userID)&password=\(pass)&amount=\(amountTextFieldValue)")
webView.isHidden = false
            let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
        
        }
//        var amountTextFieldValue = self.amountTextField.text
//        amountTextFieldValue = String(format: "%.2f", Float(amountTextFieldValue!)!)
//        //print(amountTextFieldValue!)
//
//        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let mobileno = UserDefaults.standard.value(forKey: "mobileNo") as? String, let displayName = UserDefaults.standard.value(forKey: "displayName") as? String {
//            tranID = UUID().uuidString
//        SDKObject?.startSSLCOMMERZinViewController(self, withStoreID: "billingamberitlive", storePassword: "billingamberitlive52736", amountToPay: amountTextFieldValue, amountCurrency: "BDT", applicationBundleID: "bd.com.amberit.amberphone", appTransactionID: tranID, sourceDetail: "", withCustomerEmail: "", customerName: displayName, customerContactNumber: mobileno, customerFax: "", customerAddress1: "", customerAddress2: "", customerCity: "", customerState: "", customerPostCode: "", customerCountry: "Bangladesh", withShipmentInfo: "", shipmentAddress1: "", shipmentAddress2: "", shipmentCity: "", shipmentState: "", sHipmentPostCode: "", shipmentCountry: "Bangladesh", withOptionalValueA: userID, optionalValueB: " ", optionalValueC: "  ", optionalValueD: "", shouldRunInTestMode: false)
//    }
//        webView.isHidden = false
//        let url = URL(string: "https://www.youtube.com/")
//        let urlRequest = URLRequest(url: url!)
//        webView.load(urlRequest)
        
    }
    

}

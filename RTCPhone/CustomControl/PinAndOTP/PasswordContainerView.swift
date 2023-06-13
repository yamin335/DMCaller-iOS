//
//  PasswordView.swift
//
//  Created by rain on 4/21/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import UIKit
import LocalAuthentication

public protocol PasswordInputCompleteProtocol: class {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String)
    func didEnterInput(_ passwordContainerView: PasswordContainerView, input: String)
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?)
}

open class PasswordContainerView: UIView, UITextFieldDelegate {
    
    //MARK: IBOutlet
    @IBOutlet open var passwordInputViews: [PasswordInputView]!
    @IBOutlet open weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var touchAuthenticationButton: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    var isAddBeneficiary: Bool = false
    var exitClicked: ((String)->Void)?
    //MARK: Property
    open var deleteButtonLocalizedTitle: String = "" {
        didSet {
            deleteButton.setTitle("Delete", for: .normal)
        }
    }
    
    open weak var delegate: PasswordInputCompleteProtocol?
    fileprivate var touchIDContext = LAContext()
    
    fileprivate var inputString: String = "" {
        didSet {
            phoneNumberLabel.text = inputString
            checkInputComplete()
        }
    }
    
    open var isVibrancyEffect = false {
        didSet {
            configureVibrancyEffect()
        }
    }
    
    open override var tintColor: UIColor! {
        didSet {
            guard !isVibrancyEffect else { return }
            deleteButton.setTitleColor(tintColor, for: UIControl.State())
            //passwordDotView.strokeColor = tintColor
            //touchAuthenticationButton.tintColor = tintColor
            passwordInputViews.forEach {
                $0.textColor = tintColor
                $0.borderColor = tintColor
            }
        }
    }
    
    open var highlightedColor: UIColor! {
        didSet {
            guard !isVibrancyEffect else { return }
            //passwordDotView.fillColor = highlightedColor
            passwordInputViews.forEach {
                $0.highlightBackgroundColor = highlightedColor
            }
        }
    }
    
    open var isTouchAuthenticationAvailable: Bool {
        return touchIDContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    open var touchAuthenticationEnabled = false {
        didSet {
            let enable = (isTouchAuthenticationAvailable && touchAuthenticationEnabled)
            //touchAuthenticationButton.alpha = enable ? 1.0 : 1.0
            //touchAuthenticationButton.isUserInteractionEnabled = enable
        }
    }
    
    open var touchAuthenticationReason = "Touch to unlock"
    
    //MARK: AutoLayout
    open var width: CGFloat = 0 {
        didSet {
            self.widthConstraint.constant = width
        }
    }
    fileprivate let kDefaultWidth: CGFloat = 250
    fileprivate let kDefaultHeight: CGFloat = 380
    fileprivate var widthConstraint: NSLayoutConstraint!
    
    fileprivate func configureConstraints() {
        let ratioConstraint = widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: kDefaultWidth / kDefaultHeight)
        self.widthConstraint = widthAnchor.constraint(equalToConstant: kDefaultWidth)
        //self.widthConstraint.priority = 
        NSLayoutConstraint.activate([ratioConstraint, widthConstraint])
    }
    
    //MARK: VisualEffect
    open func rearrangeForVisualEffectView(in vc: UIViewController) {
        self.isVibrancyEffect = true
        self.passwordInputViews.forEach { passwordInputView in
            let label = passwordInputView.label
            label.removeFromSuperview()
            vc.view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.addConstraints(fromView: label, toView: passwordInputView, constraintInsets: .zero)
        }
    }
    
    //MARK: Init
    open class func create(withDigit digit: Int) -> PasswordContainerView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "PasswordContainerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! PasswordContainerView
        //view.passwordDotView.totalDotCount = digit
        return view
    }
    
    open class func create(in stackView: UIStackView, digit: Int) -> PasswordContainerView {
        let passwordContainerView = create(withDigit: digit)
        stackView.addArrangedSubview(passwordContainerView)
        return passwordContainerView
    }
    
    //MARK: Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        configureConstraints()
        backgroundColor = .clear
        passwordInputViews.forEach {
            $0.delegate = self
        }
        //deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //deleteButton.titleLabel?.minimumScaleFactor = 0.5
        touchAuthenticationEnabled = true
        //let image = touchAuthenticationButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        //touchAuthenticationButton.setImage(image, for: UIControlState())
        //touchAuthenticationButton.tintColor = tintColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PasswordContainerView.normalTap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(PasswordContainerView.longTap))
        tapGesture.numberOfTapsRequired = 1
        deleteButton.addGestureRecognizer(tapGesture)
        deleteButton.addGestureRecognizer(longGesture)
        phoneNumberLabel.delegate = self
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        // Your code here
        inputString = textField.text ?? ""
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
         inputString = textField.text ?? ""
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        inputString = textField.text ?? ""
    }
    //public func textFieldDidBeginEditing(_ textField: UITextField)
    
    @objc func normalTap(){
            
        guard inputString.characters.count > 0 else {
            return
        }
        inputString = String(inputString.characters.dropLast())
        }
        
    @objc func longTap(sender : UIGestureRecognizer){
            print("Long tap")
            if sender.state == .ended {
                print("UIGestureRecognizerStateEnded")
                 timer?.invalidate()
            }
            else if sender.state == .began {
                print("UIGestureRecognizerStateBegan.")
                //Do Whatever You want on Began of Gesture
                 timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(rapidFire), userInfo: nil, repeats: true)
            }
        }
    
    //MARK: Input Wrong
    open func wrongPassword(completion: (()->Void)? = nil) {
//        passwordDotView.shakeAnimationWithCompletion {
//            self.clearInput()
//            if let completion = completion {
//                completion()
//            }
//        }
    }
    
    open func clearInput() {
        inputString = ""
    }
    
    //MARK: IBAction
    @IBAction func deleteInputString1(_ sender: AnyObject) {
        guard inputString.characters.count > 0 else {
            return
        }
        inputString = String(inputString.characters.dropLast())
    }
    
    var timer: Timer?
     var speedAmmo = 20
    
     @IBAction func deleteInputString(_ sender: AnyObject) {
        singleFire()
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidFire), userInfo: nil, repeats: true)
    }
    @objc func rapidFire() {
        guard inputString.characters.count > 0 else {
            return
        }
        inputString = String(inputString.characters.dropLast())
    }
    func singleFire() {
        guard inputString.characters.count > 0 else {
            return
        }
        inputString = String(inputString.characters.dropLast())
    }
    
    @IBAction func buttonUp(_ sender: UIButton) {
        timer?.invalidate()
    }
    
    @IBAction func callClicked(_ sender: AnyObject) {
        if let isExit = exitClicked, inputString.count >= 11 {
            isExit(inputString)
        }
        /*} else {
            
            let refreshAlert = UIAlertController(title: "Exit", message: "Are you sure that you want to exit from login?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                //print("Handle Cancel Logic here")
            }))
            
            if let parentVC = self.parentVC {
                parentVC.present(refreshAlert, animated: true, completion: nil)
            }
        }
 */
    }
    
    @IBAction func touchAuthenticationAction(_ sender: AnyObject) {
        
        if let isExit = exitClicked, isAddBeneficiary {
            isExit(inputString)
        } else {
            let refreshAlert = UIAlertController(title: "Exit", message: "Are you sure that you want to exit from login?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                //print("Handle Cancel Logic here")
            }))
            
            if let parentVC = self.parentVC {
                parentVC.present(refreshAlert, animated: true, completion: nil)
            }
        }
    
//        guard isTouchAuthenticationAvailable else { return }
//        touchIDContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchAuthenticationReason) { (success, error) in
//            DispatchQueue.main.async {
//                if success {
//                    self.passwordDotView.inputDotCount = self.passwordDotView.totalDotCount
//                    // instantiate LAContext again for avoiding the situation that PasswordContainerView stay in memory when authenticate successfully
//                    self.touchIDContext = LAContext()
//                }
//                self.delegate?.touchAuthenticationComplete(self, success: success, error: error)
//            }
//        }
//    }
    }
    
    @IBAction func listBtnClicked(_ sender: UIButton) {
        print("List is created")
        
        
    }
}

private extension PasswordContainerView {
    func checkInputComplete() {
        delegate?.didEnterInput(self,input: inputString)
       // if inputString.characters.count == passwordDotView.totalDotCount {
            delegate?.passwordInputComplete(self, input: inputString)
        //}
    }
    func configureVibrancyEffect() {
        let whiteColor = UIColor.white
        let clearColor = UIColor.clear
        //delete button title color
        var titleColor: UIColor!
        //dot view stroke color
        var strokeColor: UIColor!
        //dot view fill color
        var fillColor: UIColor!
        //input view background color
        var circleBackgroundColor: UIColor!
        var highlightBackgroundColor: UIColor!
        var borderColor: UIColor!
        //input view text color
        var textColor: UIColor!
        var highlightTextColor: UIColor!
        
        if isVibrancyEffect {
            //delete button
            titleColor = whiteColor
            //dot view
            strokeColor = whiteColor
            fillColor = whiteColor
            //input view
            circleBackgroundColor = clearColor
            highlightBackgroundColor = whiteColor
            borderColor = clearColor
            textColor = whiteColor
            highlightTextColor = whiteColor
        } else {
            //delete button
            titleColor = tintColor
            //dot view
            strokeColor = tintColor
            fillColor = highlightedColor
            //input view
            circleBackgroundColor = whiteColor
            highlightBackgroundColor = highlightedColor
            borderColor = tintColor
            textColor = tintColor
            highlightTextColor = highlightedColor
        }
        
        //deleteButton.setTitleColor(titleColor, for: .normal)
        //passwordDotView.strokeColor = strokeColor
        //passwordDotView.fillColor = fillColor
        //touchAuthenticationButton.tintColor = strokeColor
        passwordInputViews.forEach { passwordInputView in
            passwordInputView.circleBackgroundColor = circleBackgroundColor
            passwordInputView.borderColor = borderColor
            passwordInputView.textColor = textColor
            passwordInputView.highlightTextColor = highlightTextColor
            passwordInputView.highlightBackgroundColor = highlightBackgroundColor
            passwordInputView.circleView.layer.borderColor = UIColor.white.cgColor
            //borderWidth as a flag, will recalculate in PasswordInputView.updateUI()
            passwordInputView.isVibrancyEffect = isVibrancyEffect
        }
    }
}

extension PasswordContainerView: PasswordInputViewTappedProtocol {
    public func passwordInputView(_ passwordInputView: PasswordInputView, tappedString: String) {
        guard inputString.characters.count < 16 else {
            return
        }
        inputString += tappedString
    }
}

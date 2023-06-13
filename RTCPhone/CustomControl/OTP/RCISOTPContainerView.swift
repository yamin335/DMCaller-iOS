//
//  PasswordView.swift
//
//  Created by rain on 4/21/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import UIKit
import LocalAuthentication


public protocol RCISOTPInputCompleteProtocol: class {
    func OTPCompleted(_ passwordContainerView: RCISOTPContainerView, input: String)
    func cancelOTP(_ passwordContainerView: RCISOTPContainerView, success: Bool, error: Error?)
}

open class RCISOTPContainerView: UIView {
    
    //MARK: IBOutlet
    @IBOutlet open var passwordInputViews: [PasswordInputView]!
    @IBOutlet open weak var passwordDotView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var touchAuthenticationButton: UIButton!
    var totalDotCount = 4
    
    //MARK: Property
    open var deleteButtonLocalizedTitle: String = "" {
        didSet {
            deleteButton.setTitle("Delete", for: .normal)
        }
    }
    
    open weak var delegate: RCISOTPInputCompleteProtocol?
    fileprivate var touchIDContext = LAContext()
    
    fileprivate var inputString: String = "" {
        didSet {
            //passwordDotView.inputDotCount = inputString.characters.count
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
            touchAuthenticationButton.tintColor = tintColor
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
            //touchAuthenticationButton.alpha = enable ? 1.0 : 0.0
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
    fileprivate let kDefaultWidth: CGFloat = 288
    fileprivate let kDefaultHeight: CGFloat = 410
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
    open class func create(withDigit digit: Int) -> RCISOTPContainerView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "RCISOTPContainerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! RCISOTPContainerView
        //view.passwordDotView.totalDotCount = digit
        return view
    }
    
    open class func create(in stackView: UIStackView, digit: Int) -> RCISOTPContainerView {
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
        deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        deleteButton.titleLabel?.minimumScaleFactor = 0.5
        touchAuthenticationEnabled = true
//        let image = touchAuthenticationButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
//        touchAuthenticationButton.setImage(image, for: UIControlState())
//        touchAuthenticationButton.tintColor = tintColor
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
    @IBAction func deleteInputString(_ sender: AnyObject) {
        guard inputString.characters.count > 0 else {
            return
        }
        inputString = String(inputString.characters.dropLast())
        
        if let label = passwordDotView.subviews.first?.subviews.first(where: {$0.tag == inputString.characters.count }) as? UILabel {
            DispatchQueue.main.async {
                label.text = ""
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
         //AuthManager.logout()
    
//        guard isTouchAuthenticationAvailable else { return }
//        touchIDContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchAuthenticationReason) { (success, error) in
//            DispatchQueue.main.async {
//                if success {
//                    self.passwordDotView.inputDotCount = self.passwordDotView.totalDotCount
//                    // instantiate LAContext again for avoiding the situation that PasswordContainerView stay in memory when authenticate successfully
//                    self.touchIDContext = LAContext()
//                }
                self.delegate?.cancelOTP(self, success: true, error: nil)
//            }
//        }
//    }
    }
}

private extension RCISOTPContainerView {
    func checkInputComplete() {
        if inputString.count == totalDotCount {
            delegate?.OTPCompleted(self, input: inputString)
        }
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
        
        deleteButton.setTitleColor(titleColor, for: .normal)
        //passwordDotView.strokeColor = strokeColor
        //passwordDotView.fillColor = fillColor
        touchAuthenticationButton.tintColor = strokeColor
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

extension RCISOTPContainerView: PasswordInputViewTappedProtocol {
    public func passwordInputView(_ passwordInputView: PasswordInputView, tappedString: String) {
        guard inputString.characters.count < totalDotCount else {
            return
        }
        
        
        inputString += tappedString
        
        if let label = passwordDotView.subviews.first?.subviews.first(where: {$0.tag == inputString.characters.count-1 }) as? UILabel {
            DispatchQueue.main.async {
              label.text = tappedString
            }
        }
    }
}

class RCISOTPPinLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK:- Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.gray.cgColor
        self.clipsToBounds = true
        //self.tintColor = textColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6, height: 6))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
    }
}

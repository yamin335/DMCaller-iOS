//
//  RCISDashboard.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 11/13/17.
//  Copyright © 2017 Recursion Technologies Ltd. All rights reserved.
//

import Foundation

import UIKit

open class RCISDashboard: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet open weak var headerView: UIView?
    @IBOutlet open weak var scrollView: UIScrollView?
    
   
    open var headerHeightDefault: CGFloat = 300
    
 
    open var hidesNavigationBar: Bool = true {
        didSet {
            if hidesNavigationBar {
                if let scrollView = scrollView {
                    scrollViewDidScroll(scrollView)
                }
            } else {
                navigationController?.navigationBar.alpha = 1.0
            }
        }
    }
    
    var headerHeightConstraint: NSLayoutConstraint! {
        guard let constraint = headerView?.constraints.filter({
            $0.firstItem === self.headerView &&
                $0.firstAttribute == .height
        }).first else {
            return nil
        }
        
        return constraint
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopKeyboardSupport()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureKeyboardSupport()
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        guard let scrollView = scrollView, let userInfo = notification.userInfo as? [String: AnyObject],
            let _ = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue else {
                return
        }
        
        scrollView.contentInset =
            UIEdgeInsets(top: headerHeightDefault, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y,
                                  width: scrollView.frame.size.width,
                                  height: view.frame.size.height - keyboardFrame.size.height)
    }
    
    @objc func keyboardWillBeShown(_ notification: Notification) {
        scrollView?.contentInset =
            UIEdgeInsets(top: headerHeightDefault, left: 0.0, bottom: 0.0, right: 0.0)
    }
}

private extension RCISDashboard {
    
   
    func configureViews() {
        if headerView?.superview != view {
            view.addSubview(headerView!)
        }
        
        if scrollView?.superview != view {
            view.addSubview(scrollView!)
        }
        
        if headerHeightConstraint == nil {
            if let headerView = headerView {
                let c = NSLayoutConstraint(item: headerView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: headerHeightDefault)
                headerView.addConstraint(c)
            }
        }
        
        scrollView?.contentInset = UIEdgeInsets(top: headerHeightDefault, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView?.contentOffset = CGPoint(x: 0.0, y: -headerHeightDefault)
        scrollView?.delegate = self
        
        if let scrollView = scrollView {
            scrollViewDidScroll(scrollView)
        }
    }
    
    // MARK: Keyboard
    func configureKeyboardSupport() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func stopKeyboardSupport() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Navigation bar
    func setNavigationBarAlpha(withOffset deltaUnits: CGFloat) {
        guard hidesNavigationBar else {
            navigationController?.navigationBar.alpha = 1.0
            return
        }
        
        let alpha: CGFloat
        switch deltaUnits {
        case -CGFloat.greatestFiniteMagnitude ..< headerHeightDefault - 64.0:
            alpha = 0.0
        case headerHeightDefault - 64.0 ..< headerHeightDefault:
            alpha = 1.0 - ((headerHeightDefault - deltaUnits) / 64.0)
        default:
            alpha = 1.0
        }
        
        navigationController?.navigationBar.alpha = alpha
    }
    
}

// MARK: - UIScrollViewDelegate
extension RCISDashboard {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        
        let deltaUnits = scrollView.contentOffset.y + headerHeightDefault,
        height = max(0, min(headerHeightDefault - deltaUnits, headerHeightDefault - deltaUnits))
        headerHeightConstraint.constant = height
        setNavigationBarAlpha(withOffset: deltaUnits)
    }
}

@IBDesignable class CircularBalanceView: UIView {
    
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            updateUI()
        }
    }

    
    // MARK:- Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = customBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.backgroundColor = customBackgroundColor
    }
    
    func updateUI() {
        self.setNeedsDisplay()
    }
}


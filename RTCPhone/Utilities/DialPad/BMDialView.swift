//
//  BMDialView.swift
//  DialPad
//
//  Created by Saurav Satpathy on 18/09/17.
//  Copyright © 2017 Saurav Satpathy. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreData

class BMDialView: UIView, UITextFieldDelegate {
    
    var callTapped: ((String)->())?
    var CallButtonColor = UIColor(red: 21/255.0, green: 134/255.0, blue: 88/255.0, alpha: 1.0)
    var TextColor = UIColor.black
    var BorderColor = UIColor.lightGray
    var CursorColor = UIColor(red: 21/255.0, green: 134/255.0, blue: 88/255.0, alpha: 1.0)
    
    private var padView: UIView?
    private var textField: UITextField?
    private var deleteBtnTimer: Timer?
    private var numberTimer: Timer?
    
    func setupDialPad(frame: CGRect)
    {
        self.frame = frame
        setupUI()
    }
    
    private func setupUI() -> Void {
        var width =   UIScreen.main.bounds.size.width == 320 ? self.frame.size.width/5 - 20 : self.frame.size.width/5
        width = width <= 100 ? width : 100
        let requiredKeyPadHeight = width * 7.5
        textField = UITextField()
        textField?.tintColor = CursorColor
        let gap = self.frame.size.width/5
        textField?.frame = CGRect.init(x: UIScreen.main.bounds.size.width == 320 ? -40 : 0, y: 25, width: self.frame.size.width, height: 50)
        textField?.minimumFontSize = 2
        textField?.adjustsFontSizeToFitWidth = true
        textField?.textAlignment = NSTextAlignment.center
        textField?.textColor = TextColor;
        textField?.inputView = UIView.init()
        let backspaceButton = UIButton.init(type: UIButton.ButtonType.system)
        let image = UIImage(named:"backspace")?.withRenderingMode(.alwaysOriginal)
        //backspaceButton.tintColor = TextColor
        backspaceButton.setBackgroundImage(image, for: UIControl.State.normal)
        backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: UIControl.Event.touchUpInside)
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressedDeleteBtn))
        longPress.minimumPressDuration = 0.2
        backspaceButton.addGestureRecognizer(longPress)
        backspaceButton.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        //textField?.rightView = backspaceButton
        let leftView = UIView.init()
        leftView.frame = CGRect.init(x: 0, y: 0, width: 10, height: 0)
        leftView.backgroundColor = UIColor.clear
        //textField?.leftView = leftView
        //textField?.leftViewMode = .always
        textField?.rightViewMode = UITextField.ViewMode.never
        textField?.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.medium)

        addSubview(textField!)
        textField?.sendActions(for: .allEvents)
        textField?.addTarget(self, action: #selector(textFieldChanged), for:.allEvents)
        padView = UIView()
        padView?.frame = CGRect.init(x: 40, y: 80, width: self.frame.size.width, height: requiredKeyPadHeight)
        self.addSubview(padView!)
        
        let digitsList = defaultDigits()
        
        let xGap: CGFloat = 15
        var x: CGFloat = xGap
        var y: CGFloat = 0
        let yGap:CGFloat = 15.0
        let maxX = (3 * xGap + 2 * width)
        for i in 0 ..< digitsList.count {
            let digit = digitsList[i]
            let row = Float(i / 3).rounded(.towardZero)
            y = CGFloat(row) * (width + yGap)
            let frame = CGRect.init(x: x, y: y, width: width, height: width)
            let btn = createButton(frame: frame)
            btn.tag = i + 1000
            btn.setAttributedTitle(buttonAttTitle(number: digit.number!, letter: digit.letters!),for: .normal)
            addLongPressRecogniser(btn: btn)
            x +=  xGap + width
            x = x > maxX ? xGap : x
        }
        
        let callBtn: UIButton = UIButton()
        callBtn.addTarget(self, action: #selector(call),for: .touchUpInside)
        callBtn.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Thin", size: 20)
        callBtn.setImage(UIImage.init(named: "call"),for: .normal)
        callBtn.backgroundColor = UIColor.clear
        callBtn.frame = CGRect.init(x: UIScreen.main.bounds.size.width == 320 ? ((padView?.frame.size.width)!-width)/2-150 : ((padView?.frame.size.width)!-width)/2-100, y: y + width + yGap, width: 150, height: 56)
        //callBtn.layer.cornerRadius = callBtn.frame.width/2
        callBtn.layer.masksToBounds = true
        
        var frameb = callBtn.frame
        frameb.origin.x = frameb.origin.x + 160
        frameb.origin.y = frameb.origin.y + 13
        frameb.size.width = 40
        frameb.size.height = 40
        backspaceButton.frame = frameb
        padView?.addSubview(backspaceButton)
        padView?.addSubview(callBtn)

    }
    
    private func createButton(frame: CGRect) -> UIButton {
        let btn: UIButton = UIButton(type: .system)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        btn.frame = frame;
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        btn.titleLabel?.numberOfLines = 0
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = BorderColor.cgColor
        btn.layer.borderWidth = 2
        btn.layer.masksToBounds = true
        self.padView?.addSubview(btn)
        return btn
    }
    
    @objc private func buttonTapped(btn: UIButton) {
        let index = btn.tag - 1000
        let digit = defaultDigits()[index]
        textField?.insertText(digit.number!)
        textField?.layoutIfNeeded()
        textField?.tintColor = .clear
        textField?.rightViewMode = (textField?.text?.isEmpty)! ? .never : .always
        //let soundNo = 1220 + index
        //AudioServicesPlaySystemSound(SystemSoundID(soundNo))
        
        if #available(iOS 9.0, *) {
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1105), nil)
        } else {
            AudioServicesPlaySystemSound(1105)
        }

    }
    
    var tasks: [CallLog] = []
    
    @objc private func call(btn: UIButton) {
        
        if (textField?.text)! == ""{
            
            let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
            if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callDialType = 'dial' || callDialType = 'contact' || callDialType = 'received' || callType = 'outgouning' || callType = 'incoming' || callType = 'missed'"), sortDescriptors: [sortDescriptor]) {
                if tasks.count > 0{
                    let task = tasks[0]
                    if !task.phoneNumber.isEmpty {
                        textField!.text = task.phoneNumber
                        textField?.becomeFirstResponder()
                        return
                    }
                }

            }
        }
        
        callTapped?((textField?.text)!)
    }
    
    @objc private func longPressedDeleteBtn(gesture: UILongPressGestureRecognizer) {
        if(gesture.state == .began){
            deleteBtnTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (t) in
                self.delete()
            })
        }
        else if (gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed){
            deleteBtnTimer?.invalidate()
        }
    }
    
    @objc private func backspaceTapped(btn: UIButton) {
        let color = textField?.tintColor
        delete()
        if(textField?.text?.isEmpty)!{
            textField?.tintColor = .clear
        }
        else{
            textField?.tintColor = color
        }
    }
    
    @objc private func longPressedButton(gesture: UILongPressGestureRecognizer) {
        if(gesture.state == .began){
            let btn = gesture.view as! UIButton
            let index = btn.tag - 1000
            let digit = defaultDigits()[index]
            var subList = Array((digit.letters?.characters)!)
            var i = 0
            //numberTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (t) in
                if(subList.count > i){
                    let ch = subList[i]
                    if(i > 0){
                        self.delete()
                    }
                    self.textField?.insertText(String.init(ch))
                    self.textField?.layoutIfNeeded()
                    i += 1
                }
                else{
                    self.delete()
                    i = 0
                }
            //})
        }
        else if(gesture.state == .ended || gesture.state == .failed){
            textField?.rightViewMode = (textField?.text?.isEmpty)! ? .never : .always
            numberTimer?.invalidate()
        }
    }
    
    func delete()  {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.textField?.deleteBackward()
        }, completion: { (finished: Bool) in
            self.textField?.rightViewMode = (self.textField?.text?.isEmpty)! ? .never : .always
        })
    }
    
    func buttonAttTitle(number: String, letter: String) -> NSAttributedString {
        let strokeTextAttributes = [
            NSAttributedString.Key.foregroundColor : TextColor,
            NSAttributedString.Key.font : UIFont.init(name: "HelveticaNeue-Thin", size: 40)!
            ] as [NSAttributedString.Key : Any]
        
        let numberAtt = NSMutableAttributedString.init(string: number, attributes: strokeTextAttributes)
        
        if(!letter.isEmpty){
            let strokeTextAttributes1 = [
                NSAttributedString.Key.foregroundColor : TextColor,
                NSAttributedString.Key.font : UIFont.init(name: "HelveticaNeue-Thin", size: 13)!
                ] as [NSAttributedString.Key : Any]
            
            let letterAtt = NSAttributedString.init(string: "\n" + letter, attributes: strokeTextAttributes1)
            numberAtt.append(letterAtt)
        }
        return numberAtt
    }
    
    func addLongPressRecogniser(btn: UIButton) {
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 0.2
        gesture.addTarget(self, action: #selector(longPressedButton))
        btn.addGestureRecognizer(gesture)
    }
    
    private func defaultDigits() -> [PhoneDigit] {
        var digitList: [PhoneDigit] = [PhoneDigit]()
        digitList.append(PhoneDigit.init(number: "1", letters: ""))
        digitList.append(PhoneDigit.init(number: "2", letters: ""))
        digitList.append(PhoneDigit.init(number: "3", letters: ""))
        digitList.append(PhoneDigit.init(number: "4", letters: ""))
        digitList.append(PhoneDigit.init(number: "5", letters: ""))
        digitList.append(PhoneDigit.init(number: "6", letters: ""))
        digitList.append(PhoneDigit.init(number: "7", letters: ""))
        digitList.append(PhoneDigit.init(number: "8", letters: ""))
        digitList.append(PhoneDigit.init(number: "9", letters: ""))
        digitList.append(PhoneDigit.init(number: "*", letters: ""))
        digitList.append(PhoneDigit.init(number: "0", letters: "+"))
        digitList.append(PhoneDigit.init(number: "#", letters: ""))
        return digitList
    }
    
    @objc func textFieldChanged(field: UITextField)  {
        if (field.text?.isEmpty)! {
            textField?.tintColor = UIColor.clear
        }else{
            textField?.tintColor = CursorColor
        }
        self.textField?.rightViewMode = (self.textField?.text?.isEmpty)! ? .never : .always
    }
    
    func setText(text: String) {
        textField?.text = text
    }
    
    func text() -> String? {
        return textField?.text
    }
    
}

extension UITextField {
    func setCursor(position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}





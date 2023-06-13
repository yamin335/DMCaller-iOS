//
//  RCISDateRangePicker.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 3/7/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

open class RCISDateRangePicker: UIView  {
    
    var dateFormatter: DateFormatter  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        //dateFormatter.locale = AppGlobal.isUganda ? Locale(identifier: "en_UG") : Locale(identifier: "en_BD")
        return dateFormatter
    }
    
    let fromDateLabel = AAPickerView()
    let toDatelabel = AAPickerView()
    var didSelectDateRange: ((_ fromDate: Date,_ toDate: Date)->Void)?
    var fromDate: Date?
    var toDate: Date?
    private var isNeedFutureDateEnabled: Bool = false
    private var isMinimumDateRequired: Bool = false
    
    convenience init(fromDate: Date, toDate: Date, isNeedFutureDateEnabled:Bool = false, isMinimumDateRequired: Bool = false) {
        self.init(frame: CGRect.zero)
        self.fromDate = fromDate
        self.toDate = toDate
        self.isNeedFutureDateEnabled = isNeedFutureDateEnabled
        self.isMinimumDateRequired = isMinimumDateRequired
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        self.frame = CGRect(x: 50, y: 100, width: 230, height: 40)
        fromDateLabel.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        fromDateLabel.text = dateFormatter.string(from: fromDate ?? Date())
        fromDateLabel.pickerType = .DatePicker
        fromDateLabel.datePicker?.date = fromDate ?? Date()
        fromDateLabel.datePicker?.datePickerMode = .date
        fromDateLabel.datePicker?.maximumDate = toDate ?? Date()
        fromDateLabel.dateFormatter = dateFormatter
        if isMinimumDateRequired {
            fromDateLabel.datePicker?.minimumDate =  Date()
        }
        fromDateLabel.dateDidChange = { date in
           // print("selectedDate ", date )
            self.fromDate = date
            if let didSelectDateRange = self.didSelectDateRange, let todate = self.toDate, let fromdate = self.fromDate {
                didSelectDateRange(fromdate,todate)
            }
        }
        
        fromDateLabel.translatesAutoresizingMaskIntoConstraints = false
        fromDateLabel.isUserInteractionEnabled = true
        toDatelabel.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        toDatelabel.text = dateFormatter.string(from: toDate ?? Date())
        toDatelabel.pickerType = .DatePicker
        toDatelabel.datePicker?.date = toDate ?? Date()
        toDatelabel.datePicker?.datePickerMode = .date
        if isMinimumDateRequired {
            toDatelabel.datePicker?.minimumDate =  Date()
        }
        if !isNeedFutureDateEnabled {
        toDatelabel.datePicker?.maximumDate =  Date()
        }
        toDatelabel.dateFormatter = dateFormatter
        toDatelabel.dateDidChange = { date in
           // print("selectedDate ", date )
            self.toDate = date
            self.fromDateLabel.datePicker?.maximumDate = date
            
            if let didSelectDateRange = self.didSelectDateRange, let todate = self.toDate, let fromdate = self.fromDate {
                if (date.timeIntervalSince1970 - fromdate.timeIntervalSince1970) <= 0 {
                    self.fromDate = date
                    self.fromDateLabel.datePicker?.date = date
                    self.fromDateLabel.text = self.dateFormatter.string(from: date)
                }
                didSelectDateRange(self.fromDate!,todate)
            }
        }
        toDatelabel.translatesAutoresizingMaskIntoConstraints = false
        //toDatelabel.addGestureRecognizer(toTapGuesture)
        toDatelabel.isUserInteractionEnabled = true
        
        let rightSelectionBar = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightSelectionBar.translatesAutoresizingMaskIntoConstraints = false
        
        rightSelectionBar.layer.borderWidth = 2
        rightSelectionBar.layer.borderColor = UIColor.gray.cgColor
        rightSelectionBar.layer.cornerRadius = 5
        
        self.addSubview(fromDateLabel)
        self.addSubview(toDatelabel)
        self.isUserInteractionEnabled = true
        //dateRangeView.addSubview(rightSelectionBar)
        
        fromDateLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 40)
        
        toDatelabel.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 107, heightConstant: 40)
        
        // rightSelectionBar.anchor(dateRangeView.topAnchor, left: dateRangeView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 5
    }
    
    @objc func toDateClicked(_ guesture: UITapGestureRecognizer) {
        print("Clicked")
    }
}

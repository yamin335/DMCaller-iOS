// IncrementableLabel.swift
//
// Copyright (c) 2016 Recisio (http://www.recisio.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public enum IncrementableLabelOptions {
    case linear, easeIn, easeOut, easeInOut
}

public typealias StringFormatter = (Double) -> String
public typealias AttributedTextFormatter = (Double) -> NSAttributedString
public typealias Completion = () -> Void

@IBDesignable
public class IncrementableLabel: UILabel {

    // MARK: Properties

    /// An options indicating how you want to perform the incrementation:
    public var option: IncrementableLabelOptions = .linear

    /// A callback closure which permits a greater control on how the text (attributed or not) is formatted between each incrementation.
    public var stringFormatter: StringFormatter?
    public var attributedTextFormatter: AttributedTextFormatter?

    /// The rate used when an option is used.
    @IBInspectable public var easingRate: Double = 3.0

    /// The format is used to set the text in the label. You can set the format to %f in order to display decimals.
    @IBInspectable public var format: String = "%d" {
        didSet {
            updateText()
        }
    }

    // MARK: Private properties

     var timer: Timer?
     var fromValue: Double = 0.0
     var toValue: Double = 0.0

     var duration: TimeInterval = 0.3
     var progress: TimeInterval = 0.0
     var lastUpdate: TimeInterval = 0.0
     var completion: Completion?

    // MARK: Getter

    /** The label's value during the incrementation */
    public var currentValue: Double {
        if progress >= duration {
            return toValue
        }
        let percent = progress / duration
        return fromValue + (nextValueForCurrentOption(value: percent) * (toValue - fromValue))
    }

}

// MARK: Increment launcher

extension IncrementableLabel {

    /** Starts the incrementation fromValue to toValue */
    public func increment(fromValue: Double, toValue: Double, duration: Double = 0.3, completion: Completion? = nil) {
        self.completion = completion
        startIncrementation(fromValue: fromValue, toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from the current value to toValue */
    public func incrementFromCurrentValue(toValue: Double, duration: Double = 0.3, completion: Completion? = nil) {
        self.completion = completion
        startIncrementation(fromValue: currentValue, toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from zero to toValue */
    public func incrementFromZero(toValue: Double, duration: Double = 0.3, completion: Completion? = nil) {
        self.completion = completion
        startIncrementation(fromValue: 0.0, toValue: toValue, duration: duration)
    }

}

// MARK: - Incrementation

extension IncrementableLabel {

     func startIncrementation(fromValue: Double, toValue: Double, duration: Double) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = Double(duration)
        progress = 0
        lastUpdate = NSDate.timeIntervalSinceReferenceDate

        self.timer?.invalidate()
        self.timer = nil

        let timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(incrementValue), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.add(timer, forMode: .tracking)
        self.timer = timer
    }

    @objc
     func incrementValue() {
        let now = NSDate.timeIntervalSinceReferenceDate
        progress += now - lastUpdate
        lastUpdate = now
        if progress >= duration {
            timer?.invalidate()
            timer = nil
            progress = duration
        }

        updateText()
        if progress == duration {
            completion?()
        }
    }

     func updateText() {
        
        //text = AppManager.getFormattedBalance(amount: currentValue)
        
//        if let formatStringClosure = stringFormatter {
//            text = formatStringClosure(currentValue)
//        } else if let attributedTextClosure = attributedTextFormatter {
//            attributedText = attributedTextClosure(currentValue)
//        } else {
//            let formatRange = Range<String.Index>(format.startIndex..<format.endIndex)
//            if format.range(of: "%(.*)(d|i)", options: .regularExpression, range: formatRange) == formatRange {
//                text = String(format: format, Int(currentValue))
//            } else {
//                text = String(format: format, currentValue)
//            }
//        }
    }

}

// MARK: Value helpers

extension IncrementableLabel {

     func nextValueForCurrentOption(value: Double) -> Double {
        switch option {
        case .linear: return nextValueForLinearOption(value: value)
        case .easeIn: return nextValueForEaseInOption(value: value)
        case .easeOut: return nextValueForEaseInOutOption(value: value)
        case .easeInOut: return nextValueForEaseInOutOption(value: value)
        }
    }

     func nextValueForLinearOption(value: Double) -> Double {
        return value
    }

     func nextValueForEaseInOption(value: Double) -> Double {
        return Double(powf(Float(value), Float(easingRate)))
    }

     func nextValueForEaseOutOption(value: Double) -> Double {
        return 1.0 - Double(powf(1.0 - Float(value), Float(easingRate)))
    }

     func nextValueForEaseInOutOption(value: Double) -> Double {
        var value = value
        let sign: Double = easingRate.truncatingRemainder(dividingBy: 2) == 0 ?  -1 : 1
        value *= 2
        if value < 1 {
            return 0.5 * Double(powf(Float(value), Float(easingRate)))
        }
        return sign * 0.5 * (Double(powf(Float(value) - 2, Float(easingRate))) + sign * 2)
    }

}

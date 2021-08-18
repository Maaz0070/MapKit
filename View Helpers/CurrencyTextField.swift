//
//  CurrencyTextField.swift
//  RealEstate
//
//  Created by Muhammad Umair on 20/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class CurrencyTextField : UITextField {
    
    var format_dollar = true
    var ignore_edit_event = false
    
    private var isSymbolOnRight = false

    @IBInspectable var borderColor: UIColor = .darkText {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var hintColor: UIColor = .white {
        didSet {
            updateHintText()
        }
    }
    
    @IBInspectable var hintText: String? {
        didSet {
            updateHintText()
        }
    }
    
    @IBInspectable var hintFont: String? {
        didSet {
            updateHintText()
        }
    }
    
    @IBInspectable var format_options: Bool = false { didSet {} }
    
    @IBInspectable var is_monthly: Bool = false { didSet {} }
    
    @IBInspectable var is_percentage: Bool = false { didSet {} }
    
    @IBInspectable var accessory_text: String = "% of Rent" { didSet {} }
    
    var padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    
    var segment : UISegmentedControl {
        let seg = UISegmentedControl()
        seg.frame = CGRect(x: 0, y: 7.5, width: 280, height: 30)
        if accessory_text != "% of Purchase Price" {
            seg.frame = CGRect(x: 0, y: 7.5, width: 300, height: 30)
        }
        seg.insertSegment(withTitle: Constants.currency_placeholder, at: 0, animated: true)
        seg.insertSegment(withTitle: accessory_text, at: 1, animated: true)
        let font = UIFont.systemFont(ofSize: 13)
        seg.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(didPressedStateButton), for: .valueChanged)
        return seg
    }
    
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var topPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var bottomPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    func adjustPadding() {
        padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        setNeedsLayout()
    }
    
    func updateHintText() {
        var font = UIFont.systemFont(ofSize: 14)
        if let f = hintFont {
            if let fon = UIFont(name: f, size: 14) {
                font = fon
            }
        }
        
        if let string = self.hintText {
            var place_holder = Constants.currency_placeholder
            if string == "%" {
                place_holder = ""
            }
            self.attributedPlaceholder = NSAttributedString(string: place_holder + string, attributes:[NSAttributedString.Key.foregroundColor: hintColor, NSAttributedString.Key.font: font])
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func awakeFromNib() {
        self.contentScaleFactor = 0.5
        delegate = self

        addTarget(self, action: #selector(textDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addTarget(self, action: #selector(textDidEnd), for: .editingDidEnd)
        
        updateAccessoryView()
    }
    
    @objc func didPressedDoneButton() {
        self.resignFirstResponder()
    }
    
    @objc func didPressedStateButton() {
        if format_dollar {
            format_dollar = false
        } else {
            format_dollar = true
        }
        textChanged()
    }
    
    @objc func textDidBegin() {
        text = value.stringWithoutZero
        if is_percentage {
            self.text = "\(String(format: "%.2f", value))%"
        } else {
            text = Constants.formatNumber(number: value)
        }
        if value.isZero {
            text = ""
        }
    }
    
    @objc func textChanged() {
        if !ignore_edit_event {
//            guard var txt = text else { return }
//            txt = txt.replacingOccurrences(of: Constants.currency_placeholder, with: "")
//            txt = txt.replacingOccurrences(of: "%", with: "")
//            txt = txt.replacingOccurrences(of: ",", with: "")
//            let cursorOffset = getOriginalCursorPosition()
//            let cleanNumericString = getCleanNumberString()
//            let textFieldLength = text?.count
//            let textFieldNumber = Double(cleanNumericString) ?? 0.0
//
//            value = textFieldNumber / 100
////            text = Constants.formatNumber(number: value)
//            if format_dollar {
//                text = Constants.formatNumber(number: value)
//            } else {
//                text = "\(String(format: "%.2f", value))%"
//            }
//            value = (Double(txt) ?? 0.0)/100
//            print(value)
//            setCursorOriginalPosition(cursorOffset, oldTextFieldLength: textFieldLength)

//            text = Constants.formatNumber(number: value)
            
            var cleanedAmount = ""
            
            for character in self.text ?? "" {
                if character.isNumber {
                    cleanedAmount.append(character)
                }
            }
            
            if isSymbolOnRight {
                cleanedAmount = String(cleanedAmount.dropLast())
            }
            
            //Format the number based on number of decimal digits
            if is_percentage {
                let amountAsNumber = Double(cleanedAmount) ?? 0.0
                value = amountAsNumber / 100
                self.text = "\(String(format: "%.2f", value))%"
            } else if format_dollar {
                //ie. USD
                if let vc  = self.findViewController() as? NewAddPropExpenseVC, self.tag == 1211 {
                    if let purchageAmount = proInfo["list_price"] as? Int{
                        //return in case of zero to solve inf text issue
//                        let downPayment = vc.mtg_down_payment_text_field.text?.contains(s: "%") == true ? vc.calculatePercentage(value: Double(purchageAmount), percentageVal: Double((vc.mtg_down_payment_text_field.text?.replacingOccurrences(of: "%", with: ""))!)!)  :
//                            (Double(cleanedAmount) ?? 0.0)/100
                        
//                        var downPayment: Double = vc.mtg_down_payment_text_field.value
//                        if vc.mtg_down_payment_text_field.text?.contains(s: "%") == true || vc.mtg_down_payment_text_field.text?.contains(s: "$") == true{
//                            var temp_mtg_payment_value = vc.mtg_down_payment_text_field.text?.replacingOccurrences(of: "%", with: "")
//                            temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: "$", with: "")
//                            temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: ",", with: "")
//                            if vc.mtg_down_payment_text_field.text != "$" {
//                                downPayment = vc.calculatePercentage(value: Double(purchageAmount), percentageVal: Double(temp_mtg_payment_value!)!)
//                            }
//                        }
//                        else {
//                            let txtValue = (vc.mtg_down_payment_text_field.text != "" ) ? vc.mtg_down_payment_text_field.text : "0"
//                            vc.mtg_down_payment_text_field.value = (txtValue! as NSString).doubleValue
//                            downPayment = vc.mtg_down_payment_text_field.value
//                        }
                        
                        
                        
//                            Double((vc.mtg_down_payment_text_field.text?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: ""))!) ?? 0.0//vc.mtg_down_payment_text_field.value
//                        let loanAmount = Double(purchageAmount) - downPayment
//                        guard downPayment > 0 else {
//                            return
//                        }
                        let  char = self.text!.cString(using: String.Encoding.utf8)!
                           let isBackSpace = strcmp(char, "\\b")

                           if (isBackSpace == -92) {
                               print("Backspace was pressed")
                           }else{
//                            self.text = "\(String(format: "%.0f", amountAsNumber))%"
                            
                            if ((self.text?.contains(s: "%")) == true){
                                let amount = vc.calculatePercentage(value: Double(purchageAmount), percentageVal: Double(cleanedAmount) ?? 0.0)
                                if amount > 0 {
                                self.text = Constants.formatNumber(number: amount) //"\(String(format: "%.2f", amount))"
                                }else{
                                    let amount = Double(cleanedAmount) ?? 0.0
                                    value = (amount / 100.0)
                                    
                                        self.text = Constants.formatNumber(number: value)
                                }
                                
                            }else{
                            let amount = Double(cleanedAmount) ?? 0.0
                            value = (amount / 100.0)
                            
                                self.text = Constants.formatNumber(number: value)
                            }
                           }
                    }
                  
                }else{
                let amount = Double(cleanedAmount) ?? 0.0
                value = (amount / 100.0)
                    self.text = Constants.formatNumber(number: value)

                }
            } else {
                //ie. JPY
                let amountAsNumber = Double(cleanedAmount) ?? 0.0
                
                var val: Double {
                    if let vc = self.findViewController() as? PropUnitVC {
                        if self.tag == 121 {
                            return vc.mtg_purchase_amount_value
                        }
                        
                        return is_monthly ? vc.month_income_value : vc.annual_income_value
                    }
                    
                    if let vc = self.findViewController() as? NewAddPropExpenseVC {
                        
                        if self.tag == 1211 {
                            if let purchageAmount = proInfo["list_price"] as? Int{
//                                let downPayment = ( Double((vc.mtg_down_payment_text_field.text?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))!))
//                                guard downPayment != nil else {
//                                    return 0.0
//                                }
//                                let str = "$4,102.33"

                                let formatter = NumberFormatter()
                                formatter.numberStyle = .currency

                                if let number = formatter.number(from: self.text!) {
                                    let amount = number.doubleValue
                                    print(amount)
//                                    let amount = Double(cleanedAmount) ?? 0.0
                                    let percentage = (amount * 100) / Double(purchageAmount) 
    //                                self.text =  Constants.formatNumber(number:  percentage)
                                    return percentage
                                }
                                
                                ///100
                            }
                          
                        }
                            
                        if self.tag == 121 {
                            return NewAddPropPurchaseVC.mtg_purchase_amount_value
                        }
                        
                        return is_monthly ? NewAddPropRentIncomeVC.month_income_value : NewAddPropRentIncomeVC.annual_income_value
                    }
                    
                    if let _ = self.findViewController() as? AddRentRollVC {
                        let amount = AddRentRollVC.rent_roll_model.amount
                        if amount > 0.0 {
                            return amount
                        }
                        //return AddRentRollVC.model.rent_month
                    }
                    return 0
                }
                
                if val != 0.0 {
                    if self.tag == 1211 {
                        self.text = "\(String(format: "%.0f", val))%"
                    }else{
                    let v = (val * amountAsNumber) / 100
                    value = v
                    self.text = "\(String(format: "%.0f", amountAsNumber))%"
                    }
                } else {
                    value = amountAsNumber
                    self.text = "\(String(format: "%.0f", amountAsNumber))%"
                }
            }
        }
    }

    
    var value: Double = 0.0
    
    @objc func textDidEnd() {
        var cleanedAmount = ""
        
        for character in self.text ?? "" {
            if character.isNumber {
                cleanedAmount.append(character)
            }
        }
        
        if isSymbolOnRight {
            cleanedAmount = String(cleanedAmount.dropLast())
        }

        if is_percentage {
            let amountAsNumber = Double(cleanedAmount) ?? 0.0
            value = amountAsNumber / 100

            text = "\(String(format: "%.2f", value))%"
        } else if format_dollar {
            let amount = Double(cleanedAmount) ?? 0.0
            value = (amount / 100.0)

            text = Constants.formatNumber(number: value)
        } else {
            let amountAsNumber = Double(cleanedAmount) ?? 0.0
            value = amountAsNumber

            var val: Double {
                if let vc = self.findViewController() as? PropUnitVC {
                    if self.tag == 121 {
                        return vc.mtg_purchase_amount_value
                    }
                    
                    return is_monthly ? vc.month_income_value : vc.annual_income_value
                }
                
                if let _ = self.findViewController() as? NewAddPropExpenseVC {
                    if self.tag == 121 {
                        return NewAddPropPurchaseVC.mtg_purchase_amount_value
                    }
                    
                    return is_monthly ? NewAddPropRentIncomeVC.month_income_value : NewAddPropRentIncomeVC.annual_income_value
                }
                
                if let _ = self.findViewController() as? AddRentRollVC {
                    let amount = AddRentRollVC.rent_roll_model.amount
                    if amount > 0.0 {
                        return amount
                    }
                    //return AddRentRollVC.model.rent_month
                }
                return 0
            }
            
            if val != 0.0 {
                let v = (val * value) / 100
                formatTextValue(v)
            } else {
//                formatTextValue(0.0)
            }
            
            format_dollar = true
            if let v = self.inputAccessoryView as? UIToolbar {
                if let item = v.items?[0] {
                    if let itm = item.customView {
                        if let seg = itm.subviews[0] as? UISegmentedControl {
                            seg.selectedSegmentIndex = 0
                        }
                    }
                }
            }
            self.ignore_edit_event = true
            self.sendActions(for: .editingChanged)
            self.ignore_edit_event = false
        }
    }
    
    func formatTextValue(_ v: Double) {
        value = v
        
        if is_percentage {
            text = "\(String(format: "%.2f", value))%"
        } else {
            text = Constants.formatNumber(number: value)
        }
    }
    
    func updateTextValue() {
        updateHintText()
        updateAccessoryView()
        
        
        text = Constants.formatNumber(number: value)
    }
    
    private func updateAccessoryView() {
        self.inputAccessoryView = nil
        
        let width = Constants.deviceWidth()
        
        let accessory = UIView()
        accessory.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        accessory.frame = CGRect(x: 0, y: 0, width: width - 100, height: 45)
        
       
        accessory.addSubview(segment)
        
        let bar = UIToolbar()
        bar.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        
        let flexButton = UIBarButtonItem(customView: accessory)
        let done = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(didPressedDoneButton))
        done.width = 100
        bar.items = [flexButton, done]
        bar.sizeToFit()
        
        if format_options {
            self.inputAccessoryView = bar
        }
    }
    
    func incrementValue(_ val: Double) {
        value += val
        formatTextValue(value)
    }
    
    private func setError(_ bool: Bool) {
        if bool {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.red.cgColor
            self.layer.cornerRadius = 5
            
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: UIColor.red])
        } else {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = borderColor.cgColor
            
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: hintColor ])
        }
    }
    
    func isInputValid() -> Bool {
        var bool = false
        
        if value == 0.0 {
            bool = false
            setError(true)
        } else {
            bool = true
            setError(false)
        }
        
        return bool
    }
    
    func clear() {
        text = ""
        value = 0
        setError(false)
    }
}

extension CurrencyTextField : UITextFieldDelegate {
    //BEFORE entered string is registered in the textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let lastCharacterInTextField = (textField.text ?? "").last
        
        //Note - not the most straight forward implementation but this subclass supports both right and left currencies
        if string == "" && lastCharacterInTextField!.isNumber == false {
            //For hitting backspace and currency is on the right side
            isSymbolOnRight = true
        } else {
            isSymbolOnRight = false
        }
        
        return true
    }
}

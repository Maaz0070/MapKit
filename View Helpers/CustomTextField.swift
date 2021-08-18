//
//  CustomTextField.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
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
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: hintColor])
        }
    }
    
    @IBInspectable var hintFont: String? {
        didSet {
            if let f = hintFont {
                if let font = UIFont(name: f, size: 14) {
                    self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: hintColor, NSAttributedString.Key.font: font])
                }
            }
        }
    }
    
    var padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
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

    func setError(_ bool: Bool) {
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
        
        if text?.isEmpty ?? true {
            bool = false
            setError(true)
        } else {
            bool = true
            setError(false)
        }
        
        return bool
    }
    
    func isPasswordValid() -> Bool {
        let str = text ?? ""
        return str.count >= 6
    }
    
    func clear() {
        text = ""
        setError(false)
    }
    
    func safeText() -> String? {
        if let t = text {
            if !t.isEmpty {
                return t
            }
        }
        return nil
    }
}




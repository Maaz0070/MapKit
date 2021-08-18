//
//  ProfitTextLabel.swift
//  RealEstate
//
//  Created by CodeGradients on 08/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class ProfitTextLabel: UILabel {
    
    var value: Double = -123456 {
        didSet {
            formatTextValue()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .darkText {
        didSet {
            layer.borderColor = borderColor.cgColor
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
            setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
    
    @IBInspectable var placeHolder: String = "$" {
        didSet {
            
        }
    }
    
    override func prepareForInterfaceBuilder() {
        formatTextValue()
    }
    
    override func awakeFromNib() {
        formatTextValue()
    }
    
    func formatTextValue() {
        if placeHolder == "%" {
            if value.isNaN || value.isInfinite || value == -123456 {
                text = "N/A"
            } else {
                text = String(format: "%.01f", value) + "%"
            }
        } else {
            if value.isNaN || value.isInfinite || value == -123456 {
                text = "N/A"
            } else {
                text = Constants.formatNumber(number: value)
            }
        }
        
        if text == "N/A" {
            backgroundColor = Constants.getProfitBackgroundColor(val: 0)
            textColor = Constants.getProfitForegroundColor(val: 0)
        } else {
            backgroundColor = Constants.getProfitBackgroundColor(val: value)
            textColor = Constants.getProfitForegroundColor(val: value)
        }
    }
    
    func clear() {
        value = -123456
    }
}

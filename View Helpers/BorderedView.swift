//
//  BorderedView.swift
//  RealEstate
//
//  Created by CodeGradients on 11/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {

    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
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
    
}

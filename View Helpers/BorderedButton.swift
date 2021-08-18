//
//  BorderedButton.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {

    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var tint: Bool = false {
        didSet {
            if tint {
                let image = self.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
                self.setImage(image, for: .normal)
            } else {
                let image = self.image(for: .normal)?.withRenderingMode(.alwaysOriginal)
                self.setImage(image, for: .normal)
            }
        }
    }
}

//
//  WrapButton.swift
//  RealEstate
//
//  Created by codegradients on 05/12/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class WrapButton : BorderedButton {
    
    @IBInspectable var height: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: height)
    }
}

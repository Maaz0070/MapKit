//
//  GVisibilityView.swift
//  RealEstate
//
//  Created by CodeGradients on 05/11/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class GVisibilityView: UIView {
    
    var g_state: Bool = false {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var height: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if g_state {
            self.subviews.forEach({$0.isHidden = true})
            return CGSize(width: self.frame.width, height: 0)
        } else {
            self.subviews.forEach({$0.isHidden = false})
            return CGSize(width: self.frame.width, height: height)
        }
    }
    
}

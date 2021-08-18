//
//  RoundCornerView.swift
//  RealEstate
//
//  Created by Umair on 11/06/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class RoundCornerView: UIView {
    
    var corners: CACornerMask!
    
    @IBInspectable var topRight: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var topLeft: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomRight: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomLeft: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        corners = []
        
        if topRight {
            corners.insert(.layerMaxXMinYCorner)
        } else {
            corners.remove(.layerMaxXMinYCorner)
        }
        
        if topLeft {
            corners.insert(.layerMinXMinYCorner)
        } else {
            corners.remove(.layerMinXMinYCorner)
        }
        
        if bottomRight {
            corners.insert(.layerMaxXMaxYCorner)
        } else {
            corners.remove(.layerMaxXMaxYCorner)
        }
        
        if bottomLeft {
            corners.insert(.layerMinXMaxYCorner)
        } else {
            corners.remove(.layerMinXMaxYCorner)
        }
        
        layer.maskedCorners = corners
        layer.cornerRadius = radius
    }
    
}

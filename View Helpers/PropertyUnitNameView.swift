//
//  PropertyUnitNameView.swift
//  RealEstate
//
//  Created by CodeGradients on 04/08/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class PropertyUnitNameView: UIView {
    
    var is_view_expanded = true
    
    var delegate: ExpandableViewDelegate!
    
    @IBInspectable var height: CGFloat = 0 {
        didSet {
            
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if is_view_expanded {
            return CGSize(width: UIScreen.main.bounds.width, height: height)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: 0)
    }
    
    override func awakeFromNib() {
        invalidateIntrinsicContentSize()
    }
    
    func expandSelf() {
        if !is_view_expanded {
            is_view_expanded = true
            
            for view in self.subviews {
                if view.tag != 1215 {
                    view.isHidden = false
                }
            }
            
            invalidateIntrinsicContentSize()
            
            if let d = delegate {
                d.didExpandedChanged(expand: is_view_expanded, value: height)
            }
        }
    }
    
    func collapseSelf() {
        if is_view_expanded {
            is_view_expanded = false
            
            for view in self.subviews {
                view.isHidden = true
            }
            
            invalidateIntrinsicContentSize()
            
            if let d = delegate {
                d.didExpandedChanged(expand: is_view_expanded, value: height)
            }
        }
    }
}

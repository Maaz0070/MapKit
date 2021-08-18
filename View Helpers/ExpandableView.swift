//
//  ExpandableView.swift
//  RealEstate
//
//  Created by CodeGradients on 08/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class ExpandableView: UIView {
    
    var is_view_expanded = true
    var basic_height: CGFloat = 30
    
    var delegate: ExpandableViewDelegate!
    
    @IBInspectable var height: CGFloat = 0 {
        didSet {
            
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if is_view_expanded {
            return CGSize(width: UIScreen.main.bounds.width, height: height)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: basic_height)
    }
    
    var intrinsicHeight: CGFloat {
        return is_view_expanded ? height : basic_height
    }
    
    lazy var expand_button: UIButton = {
//        let btn = UIButton(frame: CGRect(x: self.frame.width - 75, y: 0, width: 30, height: 30))
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        btn.addTarget(self, action: #selector(didPressedExpandButton), for: .touchUpInside)
        btn.tag = 212
        return btn
    }()
    
    override func awakeFromNib() {
        invalidateIntrinsicContentSize()
        
//        addSubview(expand_button)
//        expand_button.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        expand_button.rightAnchor.constraint(equalTo: rightAnchor, constant: -75).isActive = true
//        expand_button.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        expand_button.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func didPressedExpandButton() {
        if is_view_expanded {
            is_view_expanded = false
            
            expand_button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            
            for view in self.subviews {
                if view.tag != 212 {
                    view.isHidden = true
                }
            }
        } else {
            is_view_expanded = true
            
            expand_button.setImage(UIImage(systemName: "minus.circle"), for: .normal)
            
            for view in self.subviews {
                if view.tag != 212 {
                    if view.tag == 213 {
                        if let _ = self.findViewController()?.parent as? AddPropVC {
                            view.isHidden = true
                        } else {
                            view.isHidden = false
                        }
                    } else {
                        view.isHidden = false
                    }
                }
            }
        }
        
        invalidateIntrinsicContentSize()
        
        if let d = delegate {
            d.didExpandedChanged(expand: is_view_expanded, value: height - basic_height)
        }
    }
    
    func expandSelf() {
        if !is_view_expanded {
            is_view_expanded = true
            
            expand_button.setImage(UIImage(systemName: "minus.circle"), for: .normal)
            
            for view in self.subviews {
                if view.tag == 213 {
                    if let _ = self.findViewController()?.parent as? AddPropVC {
                        view.isHidden = true
                    } else {
                        view.isHidden = false
                    }
                } else {
                    view.isHidden = false
                }
            }
            
            invalidateIntrinsicContentSize()
            
            if let d = delegate {
                d.didExpandedChanged(expand: true, value: height - basic_height)
            }
        }
    }
    
    func collapseSelfAll() {
        basic_height = 0
        is_view_expanded = false
        for view in self.subviews {
            view.isHidden = true
        }
        invalidateIntrinsicContentSize()
        if let d = delegate {
            d.didExpandedChanged(expand: false, value: height - basic_height)
        }
    }
}

protocol ExpandableViewDelegate {
    func didExpandedChanged(expand: Bool, value: CGFloat)
}

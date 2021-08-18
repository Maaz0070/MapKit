//
//  SeparatorView.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    
    @IBInspectable var separatorColor: UIColor = .darkText {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var right: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var left: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        if let v = self.viewWithTag(1001) {
            v.removeFromSuperview()
        }
        
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1001
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right),
            view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

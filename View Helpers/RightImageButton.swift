//
//  RightImageButton.swift
//  RealEstate
//
//  Created by codegradients on 07/12/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class RightImageButton: BorderedButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard imageView != nil else { return }
        
        imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
//        titleEdgeInsets = UIEdgeInsets(top: 0, left: -((imageView?.bounds.width)! + 100), bottom: 0, right: 0 )
    }
}

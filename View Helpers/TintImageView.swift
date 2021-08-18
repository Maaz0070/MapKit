//
//  TintImageView.swift
//  RealEstate
//
//  Created by CodeGradients on 12/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class TintImageView: UIImageView {
    
    @IBInspectable var isTemplate: Bool {
        set {
            if newValue, let image = self.image {
                let newImage = image.withRenderingMode(.alwaysTemplate)
                self.image = newImage
                
                setNeedsLayout()
            }
        } get {
            return false
        }
    }
}

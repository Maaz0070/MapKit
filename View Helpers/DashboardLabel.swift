//
//  DashboardLabel.swift
//  RealEstate
//
//  Created by CodeGradients on 16/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class DashboardLabel: BorderedLabel {
    
    @IBInspectable var back_color: UIColor = .clear {
        didSet {
            updateBackgroundColor()
        }
    }
    
    @IBInspectable var selected_color: UIColor = .clear {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var tag: Int {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        if self.tag == 0 {
            self.backgroundColor = back_color
        } else {
            self.backgroundColor = selected_color
        }
    }
    
    func clearBackground() {
        self.backgroundColor = back_color
    }
}

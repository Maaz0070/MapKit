//
//  TooltipLabel.swift
//  RealEstate
//
//  Created by CodeGradients on 07/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import EasyTipView

class TooltipLabel: UILabel {

    @IBInspectable var tooltip_text: String = "" {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    private func initialize() {
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(didPressedLabelView))
        self.addGestureRecognizer(touchGesture)
    }
    
    @objc func didPressedLabelView() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = .darkGray
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        
        for tip in Constants.label_tip_views {
            tip.dismiss {
                Constants.label_tip_views.removeAll { (tp) -> Bool in
                    return tp == tip
                }
            }
        }

        let tipView = EasyTipView(text: tooltip_text, preferences: preferences)
        tipView.show(forView: self)
        
        Constants.label_tip_views.append(tipView)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
            tipView.dismiss()
        }
    }
}

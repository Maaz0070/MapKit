//
//  PortfolioHeaderView.swift
//  RealEstate
//
//  Created by Umair on 01/06/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

@IBDesignable
class PortfolioHeaderView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5

    lazy var top_imageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.tintColor = .white
        if let i = UIImage(systemName: "chevron.up") {
            imv.image = i
        }
        return imv
    }()
    
    lazy var bottom_imageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.tintColor = .white
        if let i = UIImage(systemName: "chevron.down") {
            imv.image = i
        }
        return imv
    }()

    override func layoutSubviews() {
        addSubview(top_imageView)
        top_imageView.frame = CGRect(x: (self.frame.width - 20) / 2, y: 0, width: 20, height: 15)
        
        addSubview(bottom_imageView)
        bottom_imageView.frame = CGRect(x: (self.frame.width - 20) / 2, y: (self.frame.height - 19), width: 20, height: 15)
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    func hideAllIndicators() {
        top_imageView.isHidden = true
        bottom_imageView.isHidden = true
        
        self.backgroundColor = .white
        for sv in self.subviews {
            if let lbl = sv as? UILabel {
                lbl.textColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
            }
        }
    }
    
    func showIndicator(pos: Int) {
        if pos == 2 {
            top_imageView.isHidden = false
            bottom_imageView.isHidden = true
        } else {
            top_imageView.isHidden = true
            bottom_imageView.isHidden = false
        }
    }
    
    func isIndicatorShown() -> Bool {
        return !top_imageView.isHidden || !bottom_imageView.isHidden
    }
}

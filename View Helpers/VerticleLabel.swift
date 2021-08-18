//
//  VerticleLabel.swift
//  RealEstate
//
//  Created by Muhammad Umair on 21/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class VerticleLabel: UILabel {

    override func draw(_ rect: CGRect) {
        guard let text = self.text else {
            return
        }

        // Drawing code
        if let context = UIGraphicsGetCurrentContext() {
            let transform = CGAffineTransform( rotationAngle: CGFloat(270 * Double.pi) / 180)
            context.concatenate(transform)
            context.translateBy(x: -rect.size.height, y: 0)
            var newRect = rect.applying(transform)
            newRect.origin = CGPoint.zero

            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.lineBreakMode = self.lineBreakMode
            textStyle.alignment = .center

            let attributeDict: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: self.font, NSAttributedString.Key.foregroundColor: self.textColor, NSAttributedString.Key.paragraphStyle: textStyle]

            let nsStr = text as NSString
            nsStr.draw(in: newRect, withAttributes: attributeDict)
        }
    }

}

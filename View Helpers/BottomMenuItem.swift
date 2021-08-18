//
//  BottomMenuItem.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class BottomMenuItem: UIView {
    
    @IBInspectable var activated: Bool = false {
        didSet {
            image_view.tintColor = activated ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
            image_container.backgroundColor = activated ? #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1) : #colorLiteral(red: 0.9098039216, green: 0.9333333333, blue: 0.9960784314, alpha: 1)
            if activated {
                if let font = UIFont(name: "SFProDisplay-Medium", size: 15) {
                    label.font = font
                }
            } else {
                if let font = UIFont(name: "SFProDisplay-Regular", size: 15) {
                    label.font = font
                }
            }
            setNeedsLayout()
        }
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            if let img = image {
                image_view.image = img.withRenderingMode(.alwaysTemplate)
                setNeedsLayout()
            }
        }
    }
    
    @IBInspectable var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    lazy var image_container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9333333333, blue: 0.9960784314, alpha: 1)
        v.layer.cornerRadius = 10
        return v
    }()
    
    lazy var image_view: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        if let im = UIImage(systemName: "cart") {
            img.image = im.withRenderingMode(.alwaysTemplate)
        }
        img.tintColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        return img
    }()
    
    lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 1
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
        lbl.backgroundColor = .clear
        lbl.textAlignment = .center
        lbl.text = "Cart"
        return lbl
    }()
    
    override func layoutSubviews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        self.isUserInteractionEnabled = true
        
        addSubview(image_container)
        image_container.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        //image_container.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        //image_container.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image_container.heightAnchor.constraint(equalToConstant: 45).isActive = true
        image_container.widthAnchor.constraint(equalToConstant: 45).isActive = true
        image_container.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        image_container.addSubview(image_view)
        image_view.centerXAnchor.constraint(equalTo: image_container.centerXAnchor).isActive = true
        image_view.centerYAnchor.constraint(equalTo: image_container.centerYAnchor).isActive = true
        
        addSubview(label)
        label.topAnchor.constraint(equalTo: image_container.bottomAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
    }
    
    override func awakeFromNib() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

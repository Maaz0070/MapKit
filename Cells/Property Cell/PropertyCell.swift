//
//  PropertyCell.swift
//  RealEstate
//
//  Created by CodeGradients on 28/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class PropertyCell : UICollectionViewCell {
    
    override var reuseIdentifier: String {
        return "\(self)"
    }
    
    lazy var prop_view: PropertyCellView = {
        let p = PropertyCellView()
        p.layer.cornerRadius = 10
        p.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.8901960784, blue: 0.9529411765, alpha: 1)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        addSubview(prop_view)
        
        prop_view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        prop_view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        prop_view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        prop_view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PropertyCellView : UIView {
    
    lazy var text_label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        if let font = UIFont(name: "SFProDisplay-Medium", size: 16) {
            label.font = font
        }
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(text_label)
        
        text_label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        text_label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        text_label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        text_label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

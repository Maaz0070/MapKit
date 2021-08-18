//
//  KMPlaceholderTextView.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class KMPlaceholderTextView: UITextView {
    
    private struct Constants {
        static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }
    public let placeholderLabel: UILabel = UILabel()
    
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    var padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var topPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    @IBInspectable var bottomPadding: CGFloat = 0 {
        didSet {
            adjustPadding()
        }
    }
    
    func adjustPadding() {
        padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        textContainerInset = padding
        setNeedsLayout()
    }
    
    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor = KMPlaceholderTextView.Constants.defaultiOSPlaceholderColor {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    override open var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override open var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override open var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: NSNotification.Name(UITextView.textDidChangeNotification.rawValue),
                                               object: nil)
        
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
    }
    
    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
        ))
        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(UITextView.textDidChangeNotification.rawValue),
                                                  object: nil)
    }
    
    public func isPlaceholderBold() -> Bool {
        if let placeholderFont = self.font {
            let descriptor = placeholderFont.fontDescriptor
            let symTraits = descriptor.symbolicTraits
            return symTraits.contains(.traitBold)
        }else{
            return false
        }
    }
    
    
    
    public func isPlaceholderItalic() -> Bool {
        if let placeholderFont = self.font {
            let descriptor = placeholderFont.fontDescriptor
            let symTraits = descriptor.symbolicTraits
            return symTraits.contains(.traitItalic)
        }else{
            return false
        }
    }
    
    func setError(_ bool: Bool) {
        if bool {
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = UIColor.red.cgColor
            self.placeholderColor = UIColor.red
        } else {
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
            self.placeholderColor = KMPlaceholderTextView.Constants.defaultiOSPlaceholderColor
        }
    }
    
    func isInputValid() -> Bool {
        var bool = false
        
        if text?.isEmpty ?? true {
            bool = false
            setError(true)
        } else {
            bool = true
            setError(false)
        }
        
        return bool
    }
    
    func clear() {
        text = ""
        setError(false)
    }
}


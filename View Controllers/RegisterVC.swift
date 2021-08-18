//
//  RegisterVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 21/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD
import IQKeyboardManagerSwift
import Toast_Swift

class RegisterVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var TandCTextView: UITextView!
    @IBOutlet weak var TandCandPrivacyCheck: UIImageView!
    @IBOutlet var termsAndPrivacyCheckTGR: UITapGestureRecognizer!
    @IBOutlet weak var nameText: CustomTextField!
    @IBOutlet weak var emailText: CustomTextField!
    @IBOutlet weak var passwordText: CustomTextField!
    
    var callback: (() -> ())?
    
    var dbRef = Database.database().reference()
    
    var didAgreeToTandCandPrivacyPolicy : Bool = false
    
    /**
     Generic loading function, sets up text and content.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
                
        TandCTextView.isSelectable = true
        TandCTextView.delegate = self
        
        //set up terms and conditions [28...43]
        let attString = NSMutableAttributedString(string: "I have read and agree to the Privacy Policy. Our Terms of Service apply.")
        attString.addAttribute(.link, value: URL(string: "https://www.rentalpropertydashboard.com/privacy-policy")!, range: NSRange(location: 29, length: 14))
        attString.addAttribute(.link, value: URL(string:"https://www.rentalpropertydashboard.com/terms-of-service")!, range: NSRange(location: 49, length: 16))
        
        TandCTextView.attributedText = attString
    }
    
    /**
     Text view should open URL
     */
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    
    /**
     Checks that user agreed to T&C.
     */
    @IBAction func termsAndPrivacyCheckTGRTapped(_ sender: Any) {
        
        if (didAgreeToTandCandPrivacyPolicy) {
            TandCandPrivacyCheck.tintColor = .opaqueSeparator
            didAgreeToTandCandPrivacyPolicy = false
        } else {
            TandCandPrivacyCheck.tintColor = .systemBlue
            didAgreeToTandCandPrivacyPolicy = true
        }
        
        
    }
    
    /**
     Dismiss VC when login button clicked.
     */
    @IBAction func didPressedLoginButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Checks all data fields are valid and creates a user using Firebase Auth.
     */
    @IBAction func didPressedRegisterButton(_ sender: UIButton) {
        let nm = nameText.isInputValid()
        let em = emailText.isInputValid()
        let ps = passwordText.isInputValid()
        
        if nm && em && ps {
            
            if !passwordText.isPasswordValid() {
                self.view.makeToast("Please Choose a password of minimum 6 characters")
                return
            }
            
            if !didAgreeToTandCandPrivacyPolicy {
                self.view.makeToast("You must agree to the Privacy Policy and the Terms and Conditions to continue.")
                return
            }
            
            IQKeyboardManager.shared.resignFirstResponder()
            
            let hud = JGProgressHUD(style: .dark)
            hud.show(in: self.view, animated: true)
            
            Auth.auth().createUser(withEmail: self.emailText.text!, password: self.passwordText.text!, completion: { (result, err) in
                if let e = err {
                    hud.dismiss()
                    AlertBuilder().buildMessage(vc: self, message: "Failed to create Account\nError: " + e.localizedDescription)
                    return
                }
                
                if let res = result, let info = res.additionalUserInfo {
                    if info.isNewUser {
                        UserDefaults.standard.set(true, forKey: "is_new_user")
                    }
                    
                    let data = ["name": self.nameText.text!, "email": self.emailText.text!]
                    self.dbRef.child("users").child(res.user.uid).updateChildValues(data) { (err, ref) in
                        hud.dismiss()
                        if let e = err {
                            AlertBuilder().buildMessage(vc: self, message: "Failed to create Account\nError: " + e.localizedDescription)
                            return
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                        self.callback?()
                    }
                    
                } else {
                    hud.dismiss()
                    AlertBuilder().buildMessage(vc: self, message: "Something went wrong")
                }
            })
        }
    }
    
}
extension RegisterVC
{
    /**
     Debugging code, should remove if not necessary.
     */
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (TandCTextView.text)!
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")

        if gesture.didTapAttributedTextInLabel(label: TandCTextView, inRange: termsRange) {
            print("Tapped terms")
        } else if gesture.didTapAttributedTextInLabel(label: TandCTextView, inRange: privacyRange)
        {
            print("Tapped privacy")
        } else {
            print("Tapped none")
        }
    }
}
extension UITapGestureRecognizer {
    /**
     Helper function to determine point where user tapped in textview.
     */
    func didTapAttributedTextInLabel(label: UITextView, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = label.lineBreakMode
//        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

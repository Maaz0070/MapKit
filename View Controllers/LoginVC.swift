//
//  LoginVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 21/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseAuth
import IQKeyboardManagerSwift

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailText: CustomTextField!
    @IBOutlet weak var passwordText: CustomTextField!
    @IBOutlet weak var rememberCheck: CheckBox!
    
    /**
     Generic loading function, sets up default text for email field.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.text = UserDefaults.standard.string(forKey: "email")
    }
    
    /**
     If successful, presents RegisterVC instance upon button click.
     */
    @IBAction func didPressedRegisterButton(_ sender: UIButton) {
        let reg = AppStoryboard.Auth.shared.instantiateViewController(withIdentifier: RegisterVC.storyboard_id) as? RegisterVC
        reg?.callback = { () in
            self.dismiss(animated: true, completion: nil)
        }
        reg?.modalPresentationStyle = .fullScreen
        self.present(reg!, animated: true, completion: nil)
    }
    
    /**
     Presents ForgotPasswordVC
     */
    @IBAction func didPressedForgotButton(_ sender: UIButton) {
        let vc = AppStoryboard.Auth.shared.instantiateViewController(withIdentifier: ForgotPasswordVC.storyboard_id) as? ForgotPasswordVC
        self.present(vc!, animated: true, completion: nil)
    }
    
    /**
     If inputs are valid, then attempts to sign in using Firebase Auth. 
     */
    @IBAction func didPressedLoginButton(_ sender: UIButton) {
        let em = emailText.isInputValid()
        let ps = passwordText.isInputValid()
        if em && ps {
            
            if rememberCheck.isChecked {
                UserDefaults.standard.set(emailText.text, forKey: "email")
            }
            
            IQKeyboardManager.shared.resignFirstResponder()
            
            let hud = JGProgressHUD(style: .dark)
            hud.show(in: self.view)
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
                
                hud.dismiss()
                if let e = error {
                    AlertBuilder().buildMessage(vc: self, message: "Failed to login\nError: " + e.localizedDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            AlertBuilder().buildMessage(vc: self, message: "Invalid Email or Password")
        }
    }
}

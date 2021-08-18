//
//  ForgotPasswordVC.swift
//  RealEstate
//
//  Created by CodeGradients on 06/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailText: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressedContinueButton(_ sender: UIButton) {
        if emailText.isInputValid() {
            let hud = JGProgressHUD(style: .dark)
            hud.show(in: self.view)
            
            Auth.auth().sendPasswordReset(withEmail: emailText.text!) { (error) in
                hud.dismiss()
                
                if let e = error {
                    AlertBuilder().buildMessage(vc: self, message: "Something went Wrong...\nError: " + e.localizedDescription)
                    return
                }
                
                let alert = AlertBuilder()
                alert.buildMessageWithCallback(vc: self, message: "Please check your mailbox and follow instructions to recover password.")
                alert.pressedOk = { () in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

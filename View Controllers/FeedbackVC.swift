//
//  FeedbackVC.swift
//  RealEstate
//
//  Created by CodeGradients on 23/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackVC: UIViewController {

    @IBOutlet weak var feedback_text_view: KMPlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     Emails the feedback text to Willie by creating a MFMailCVC instance.
     */
    @IBAction func didPressedSubmitButton(_ sender: UIButton) {
        if feedback_text_view.isInputValid() {
            if MFMailComposeViewController.canSendMail() {
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setSubject("Feedback")
                mailVC.setToRecipients(["willie@rentalpropertydashboard.com"])
                mailVC.setMessageBody(feedback_text_view.text ?? "", isHTML: false)
                
                self.present(mailVC, animated: true, completion: nil)
            } else {
                AlertBuilder().buildMessage(vc: self, message: "Please add Email account to send Email")
            }
        }
    }
    
    /**
     Dismiss self.
     */
    @IBAction func didPressedCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FeedbackVC : MFMailComposeViewControllerDelegate {
    /**
     Dismiss MFMailCVC instance
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

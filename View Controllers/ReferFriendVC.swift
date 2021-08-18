//
//  ReferFriendVC.swift
//  RealEstate
//
//  Created by codegradients on 10/12/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI

class ReferFriendVC: UIViewController {
    
    @IBOutlet weak var input_field_text: CustomTextField!
    @IBOutlet weak var option_selection_control: UISegmentedControl!
    @IBOutlet weak var contact_pick_button: UIButton!
    
    /**
     Basic loading functions, setting up basic picker views and segment controls.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        option_selection_control.addTarget(self, action: #selector(didChangedOptionSelection(_:)), for: .valueChanged)
        
        contact_pick_button.addAction {
            let picker = CNContactPickerViewController()
            picker.delegate = self
            picker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    /**
     Dismiss VC on call
     */
    @IBAction func didPressedCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
        Clear text in input field when optiosna re changed, and also change the keyboard type.
     */
    @objc func didChangedOptionSelection(_ sender: UISegmentedControl) {
        input_field_text.resignFirstResponder()
        contact_pick_button.isHidden = sender.selectedSegmentIndex == 0
        input_field_text.placeholder = sender.selectedSegmentIndex == 0 ? "Email" : "Phone"
        input_field_text.clear()
        input_field_text.keyboardType = sender.selectedSegmentIndex == 0 ? .emailAddress : .phonePad
    }
    
    /**
     Creates a text and a link to the app store page. Then opens up the activity controller to allow you to share that text.
     */
    @IBAction func didPressedDirectShareButton(_ sender: UIButton) {
        
        let textToShare = "Check out the Rental Property Dashboard App."
        
        if let url = URL(string: Constants.app_link) {
            let objectsToShare = [textToShare, url] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    /**
     Called when continue button is clicked, checks to see if all the input is valid, and then uses the respective Compose View Controllers to attempt to send that message, returning an error message if it fails.
     */
    @IBAction func didPressedContinueButton(_ sender: UIButton) {
        if input_field_text.isInputValid() {
            if option_selection_control.selectedSegmentIndex == 0 {
                if MFMailComposeViewController.canSendMail() {
                    let vc = MFMailComposeViewController()
                    vc.mailComposeDelegate = self
                    vc.setSubject("Download the Rental Property Dashboard App")
                    vc.setToRecipients([input_field_text.text!])
                    vc.setMessageBody("Check out the Rental Property Dashboard App. (\(Constants.app_link))", isHTML: false)
                    
                    self.present(vc, animated: true, completion: nil)
                } else {
                    AlertBuilder().buildMessage(vc: self, message: "Please add Email account to send Email")
                }
            } else {
                if MFMessageComposeViewController.canSendText() {
                    let vc = MFMessageComposeViewController()
                    vc.body = "Check out the Rental Property Dashboard App. (\(Constants.app_link))"
                    vc.recipients = [input_field_text.text!]
                    vc.messageComposeDelegate = self
                    self.present(vc, animated: true, completion: nil)
                } else {
                    AlertBuilder().buildMessage(vc: self, message: "Failed to send message")
                }
            }
        }
    }
}


//Additional extensions that add UI functionality, don't serve a critical role.


extension ReferFriendVC : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .failed:
            AlertBuilder().buildMessage(vc: self, message: "Message sending failed...")
        default:
            break
        }
    }
}

extension ReferFriendVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ReferFriendVC : CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
        
        let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
        self.input_field_text.text = primaryPhoneNumberStr
    }
}

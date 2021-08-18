//
//  AddRentRollVC.swift
//  RealEstate
//
//  Created by Umair on 11/06/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
//import DatePickerDialog

class AddRentRollVC: UIViewController {

    @IBOutlet weak var address_lbl: UILabel!
    @IBOutlet weak var month_year_lbl: UILabel!
    @IBOutlet weak var paid_check_box: CheckBox!
    @IBOutlet weak var rent_text_field: CurrencyTextField!
    @IBOutlet weak var late_fee_field: CurrencyTextField!
    @IBOutlet weak var date_text_field: CustomTextField!
    @IBOutlet weak var rent_roll_image_view: UIImageView!
    @IBOutlet weak var edit_button: UIButton!
    @IBOutlet weak var choose_image_button: BorderedButton!
    
    let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    static var model: RentRollUnitModel!
    static var rent_roll_model: RentRollModel!
    
    var rent_roll_image_data: Data!
    
    /**
     Setup UI relationships and intialize appropriate text fields
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = self.view.subviews[0]
        if v.tag == 121 {
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedView)))
        }
        
        disableEditables(self.view, false)
        edit_button.addTarget(self, action: #selector(didPressedEditButton(_:)), for: .touchUpInside)
        
        if let date = Constants.buildDatefromMillis(millis: AddRentRollVC.model.unit_model.rent_start) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.day], from: date)
            components.day = AddRentRollVC.model.unit_model.rent_day
            components.month = AddRentRollVC.rent_roll_model.month + 1
            components.year = AddRentRollVC.rent_roll_model.year
            if let dt = Calendar.current.date(from: components) {
                date_text_field.text = Constants.formatDate("MM/dd/YYYY", dt: dt)
            }
        }
        date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedRentStartDateField)))
        
        choose_image_button.addTarget(self, action: #selector(didPressedChooseImageButton(_:)), for: .touchUpInside)
        
        if !AddRentRollVC.rent_roll_model.image.isEmpty {
            self.choose_image_button.isHidden = true
            LoadImage().load(imageView: self.rent_roll_image_view, url: AddRentRollVC.rent_roll_model.image)
        }
        
        rent_roll_image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedImageView)))
    }
    
    /**
     Dismiss this view
     - Note: Called via selector
     */
    @objc func didTappedView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Setup text fields prior to the view appearing
     */
    override func viewWillAppear(_ animated: Bool) {
        address_lbl.text = AddRentRollVC.model.prop_model.address.replacingOccurrences(of: "#", with: " ")
        
        month_year_lbl.text = "\(months[AddRentRollVC.rent_roll_model.month]) \(AddRentRollVC.rent_roll_model.year)"
        rent_text_field.formatTextValue(AddRentRollVC.rent_roll_model.amount)
        late_fee_field.formatTextValue(AddRentRollVC.rent_roll_model.late_fee)
        paid_check_box.isChecked = AddRentRollVC.rent_roll_model.paid
    }
    
    /**
     Pull up the image picker, dispatch its completion to be run on a new thread and assign values appropriately
     - Note: Called via selector
     */
    @objc func didPressedChooseImageButton(_ sender: BorderedButton) {
        ImagePickerHandler.shared.showActionSheet(vc: self, view: sender)
        ImagePickerHandler.shared.imagePickedBlock = { (image) in
            DispatchQueue.global().async {
                sleep(2)
                DispatchQueue.main.async {
                    self.rent_roll_image_view.image = image
                    self.rent_roll_image_data = image.pngData()
                }
            }
        }
    }
    
    /**
     Show the selected image in full screen when tapped
     - Note: Called via selector
     */
    @objc func didPressedImageView() {
        if let image = self.rent_roll_image_view.image {
            let vc = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: FullScreenImageVC.storyboard_id) as? FullScreenImageVC
            vc?.img_link = image
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    /**
     Show the date picker dialog upon pressing the rent date entry field
     - Note: Called via selector
     */
    @objc func didPressedRentStartDateField(_ sender: CustomTextField) {
        var dt = Date()
        var components = Calendar.current.dateComponents([.day], from: dt)
        components.day = AddRentRollVC.model.unit_model.rent_day
        components.month = AddRentRollVC.rent_roll_model.month + 1
        components.year = AddRentRollVC.rent_roll_model.year
        if let d = Calendar.current.date(from: components) {
            dt = d
        }
        DatePickerDialog().show("Select Date", defaultDate: dt, datePickerMode: .date) { (date) in
            if let d = date {
                self.date_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: d)
            }
        }
    }
    
    /**
     Dismiss the field this controller upon the cancel button being pressed
     */
    @IBAction func didPressedCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Disable editables if the button is pressed again, otherwise upload photo data to the backend through the uploadTask
     This process also uses JGProgressHUD to show the progress of the upload
     */
    @objc func didPressedEditButton(_ sender: UIButton) {
        if edit_button.tag == 0 {
            disableEditables(self.view, true)
            edit_button.setTitle("Save", for: .normal)
            edit_button.tag = 1
        } else {
            if rent_text_field.value != 0.0 {
                guard let data = self.rent_roll_image_data else {
                    self.uploadData(img: AddRentRollVC.rent_roll_model.image)
                    return
                }
                
                let hud = JGProgressHUD(style: .dark)
                hud.indicatorView = JGProgressHUDPieIndicatorView()
                hud.textLabel.text = "Uploading photo"
                hud.show(in: self.view)
                
                let uploadTask = Storage.storage().reference().child("RentRollImages").child("\(Constants.getCurrentMillis()).png").putData(data)
                
                uploadTask.observe(.pause) { snapshot in
                    hud.textLabel.text = "Uploading Paused!"
                }
                
                uploadTask.observe(.progress) { snapshot in
                    // Upload reported progress
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    
                    hud.setProgress(Float(percentComplete) / 100, animated: true)
                }
                
                uploadTask.observe(.success) { snapshot in
                    snapshot.reference.downloadURL(completion: { (url, error) in
                        hud.dismiss()
                        if let u = url {
                            self.uploadData(img: u.absoluteString)
                        }
                    })
                }
            }
        }
    }
    
    /**
     Uploads an image to the backend, as well as the real
     */
    func uploadData(img: String) {
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        
        let data = ["amount": rent_text_field.value, "late_fee": late_fee_field.value, "year": AddRentRollVC.rent_roll_model.year,
                    "month": AddRentRollVC.rent_roll_model.month, "paid": paid_check_box.isChecked, "image": img] as [String : Any]
        
        let ref = Database.database().reference().child("properties").child(AddRentRollVC.model.prop_model.key).child("units").child(AddRentRollVC.model.unit_model.key).child("rent_rolls")
        if AddRentRollVC.rent_roll_model.key.isEmpty {
            if let key = ref.childByAutoId().key {
                ref.child(key).updateChildValues(data) { (err, ref) in
                    hud.dismiss()
                    if let e = err {
                        AlertBuilder().buildMessage(vc: self, message: "Something went Wrong...\nError: \(e.localizedDescription)")
                        return
                    }
                    
                    self.edit_button.setTitle("Edit", for: .normal)
                    self.edit_button.tag = 0
                    self.disableEditables(self.view, false)
                }
            }
        } else {
            ref.child(AddRentRollVC.rent_roll_model.key).updateChildValues(data) { (err, ref) in
                hud.dismiss()
                if let e = err {
                    AlertBuilder().buildMessage(vc: self, message: "Something went Wrong...\nError: \(e.localizedDescription)")
                    return
                }
                
                self.edit_button.setTitle("Edit", for: .normal)
                self.edit_button.tag = 0
                self.disableEditables(self.view, false)
            }
        }
    }
    
    /**
     Set the edit state of the editable fields in a view to the given state by changing the state of all of it's subviews to match the provided state
     - Parameters:
        - view: view to edit (we'll get its subviews recursively)
        - bool: the new editable state
     */
    func disableEditables(_ view: UIView, _ bool: Bool) {
        // Get the subviews of the view
        let subviews = view.subviews
        
        // Return if there are no subviews
        if subviews.count == 0 {
            return //RECURSIVE BASE CASE!
        }
        
        for subview in subviews {
            // Do what you want to do with the subview by safely casting to types we know the disable behavior for
            
            let color: UIColor = bool ? .primary : .lightGray

            if let s = subview as? UITextField { //try to cast as text field
                s.isEnabled = bool
                
                if let c = s as? CurrencyTextField { //handle different types of text fields we've declared
                    c.borderColor = color
                }
                
                if let c = s as? CustomTextField {
                    c.borderColor = color
                }
            }
            
            if let s = subview as? BorderedButton { //cast to bordered button
                s.isEnabled = bool
                
                s.borderColor = color
            }
            
            if let s = subview as? CheckBox { // cast to checkbox (disabled behavior handled natively)
                s.isEnabled = bool
            }
            
            disableEditables(subview, bool) //recursive call to go a layer deeper into the view hierarchy
        }
    }
}

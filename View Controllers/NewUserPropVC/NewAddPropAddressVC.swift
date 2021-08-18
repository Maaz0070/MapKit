//
//  NewAddPropAddressVC.swift
//  RealEstate
//
//  Created by CodeGradients on 23/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import GooglePlaces

class NewAddPropAddressVC: UIViewController {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var st_address_text_field: CustomTextField!
    @IBOutlet weak var ct_address_text_field: CustomTextField!
    @IBOutlet weak var stt_address_text_field: CustomTextField!
    @IBOutlet weak var zip_code_text_field: CustomTextField!

    /**
     Set the title accordingly, configuring the address field to be edited using the custom VC
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SplashVC.user_property_count > 0 {
            title_label.text = "Enter the property address of the rental property you want to add"
        } else {
            title_label.text = "Enter the property address of the first rental property you want to add"
        }
        
        st_address_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStreetAddressTextField(_:))))
    }
    
    /**
     Move to next page
     - Parameter sender: next button
     */
    @IBAction func didPressedNextButton(_ sender: UIButton) {
        if let p = parent as? NewAddPropVC {
            p.moveToPage(2)
        }
    }
    
    /**
     Show the acController for editing the property address
     - Parameter sender: custom address text field in the VC
     */
    @objc func didPressedStreetAddressTextField(_ sender: CustomTextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
}

extension NewAddPropAddressVC : GMSAutocompleteViewControllerDelegate {
    /**
     Handle autocompleting the address using Google Places, breaking the address into components and assigining their values into text fields accordingly
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        self.st_address_text_field.clear(); self.ct_address_text_field.clear(); self.stt_address_text_field.clear(); self.zip_code_text_field.clear()
        
        self.st_address_text_field.text = place.name
        
        if let components = place.addressComponents {
            for compo in components {
                if compo.types.contains("street_number") {
                    print(compo.name)//street
                }
                if compo.types.contains("route") {
                    print(compo.name)//street
                }
                if compo.types.contains("locality") {
//                    print(compo.name)//city
                    self.ct_address_text_field.text = compo.name
                }
                if compo.types.contains("administrative_area_level_1") {
//                    print(compo.shortName ?? compo.name)//state
                    self.stt_address_text_field.text = compo.shortName ?? compo.name
                }
                if compo.types.contains("postal_code") {
//                    print(compo.name)//zip code
                    self.zip_code_text_field.text = compo.name
                }
            }
        }
    }
    
    /**
     Print out autocomplete error
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    /**
     Dimismiss view controller on cancellation
     */
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

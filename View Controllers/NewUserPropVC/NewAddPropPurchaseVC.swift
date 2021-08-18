//
//  NewAddPropPurchaseVC.swift
//  RealEstate
//
//  Created by CodeGradients on 23/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
//import DatePickerDialog
import DropDown
var  proInfo = NSMutableDictionary()

class NewAddPropPurchaseVC: UIViewController {
    var spinner: UIActivityIndicatorView!

    @IBOutlet weak var purchase_amt_text_field: CurrencyTextField!
    @IBOutlet weak var purchase_date_lbl: UILabel!
    @IBOutlet weak var purchase_date_text_field: CustomTextField!
    @IBOutlet weak var prop_type_label: BorderedLabel!
    
    @IBOutlet weak var cash_invested_text_field: CurrencyTextField!
    @IBOutlet weak var down_payment_text_field: CurrencyTextField!
    @IBOutlet weak var closing_cost_text_field: CurrencyTextField!
    @IBOutlet weak var initial_rehab_cost_text_field: CurrencyTextField!
    
    @IBOutlet weak var bedroom_text_button: BorderedButton!
    @IBOutlet weak var bathroom_text_field: BorderedButton!
    @IBOutlet weak var square_feet_text_field: BorderedButton!
    var purchased_date: Date!
    public static var mtg_purchase_amount_value: Double = 0.0
    
    /**
     Setup and initialize UI fields and relationships
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        down_payment_text_field.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        closing_cost_text_field.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        initial_rehab_cost_text_field.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        purchase_amt_text_field.addTarget(self, action: #selector(didChangedPurchaseValue), for: .editingChanged)
        purchase_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPurchaseDateField(_:))))
        prop_type_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPropTypeField)))
        
        bedroom_text_button.addTarget(self, action: #selector(didPressedBedRoomField(_:)), for: .touchUpInside)
        bathroom_text_field.addTarget(self, action: #selector(didPressedBathRoomField(_:)), for: .touchUpInside)
        square_feet_text_field.addTarget(self, action: #selector(didPressedSquareFeetField(_:)), for: .touchUpInside)
        
    }
    
    /**
     Update UI based off data
     */
    func updateData(){
        showActivityIndicator()
        switch propertyType {
        case .IOwn:
            purchase_date_lbl.text = "Purchase Date*"
            break
        case .Researching:
            purchase_date_lbl.text = "Today’s Date*"
            purchase_date_text_field.text =  NSDate().dateStringWithFormat(format: "MM/dd/yyyy")
            break
        
        }
        if let parent = self.parent as? NewAddPropVC {
            if let address_vc = parent.children[1] as? NewAddPropAddressVC {
                var url = NSString(format: "\(api_purchase_info)%@/%@" as NSString,address_vc.stt_address_text_field.text as! CVarArg, address_vc.ct_address_text_field.text as! CVarArg )
        let escapedString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        let  parser = Parser(methodType: "get", url: escapedString as String)
        
        parser.fetchData(completionHandler: { (result, statusCode, error) in
            
            
//            self.spinner.stopAnimating()
            if error == nil{
                
                if    let dict = result[0] as? NSDictionary{
//                    print(dict)
                    if let properties = dict.value(forKeyPath: "content.properties") as? NSArray{
                        print(properties)
//                        guard properties.count > 1 else {
//                            return
//                        }
                        if let prop = properties[0] as? NSDictionary{
                            print(prop)
                            proInfo.addEntries(from: prop as! [AnyHashable : Any]) // =  //as! NSMutableDictionary
                            self.prop_type_label.text = (prop["type"] as! String)
                            self.bedroom_text_button.setTitle("\(prop["beds"] as! Int)", for: .normal)
                            self.bathroom_text_field.setTitle( "\(prop["baths"] as! Int)", for: .normal)
                            if let sqrt = (prop["sqft"] as? Int){
                            self.square_feet_text_field.setTitle("\(sqrt)", for: .normal)
                            }
                            self.purchase_amt_text_field.text = (prop["list_price_formatted"] as! String)

//                            self.purchase_date_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: Constants.formatStringDate("yyyy-MM-dd", dt: (prop["next_open_house_date"] as! String)))
                            

                            url = NSString(format: "\(api_property_info)%ld/investment?state=%@" as NSString,prop["id"] as! NSInteger, prop["state"] as! String)
                           let escapedString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                            let  parser = Parser(methodType: "get", url: escapedString as String)
                            parser.fetchData(completionHandler: { (result, statusCode, error) in
                                self.spinner.stopAnimating()
                                if error == nil{
                                    
                                    if    let dict = result[0] as? NSDictionary{
                                            print(dict)
                                        proInfo.setValue(dict.value(forKeyPath:"content.traditional"), forKey: "traditional")
                                    }
                                }else{
                                }
                            })
                            
                        }
                    }
                }
            }else{
            }
        })
            }
        }
    }
    
    /**
     Move to page 2 if there is a TCI value entered
     - Parameter sender: next button
     */
    @IBAction func didPressedNextButton(_ sender: UIButton) {
        
        if ((propertyType == .Researching && cash_invested_text_field.value != 0) || ((propertyType == .IOwn && cash_invested_text_field.value != 0 && purchase_date_text_field.text != ""))) {
            if let p = parent as? NewAddPropVC {
                p.moveToPage(3)
            }
        } else {
            AlertBuilder().buildMessage(vc: self, message: "Please insert all required value.")

//            AlertBuilder().buildMessage(vc: self, message: "Please add in a value for Total Cash Investment.")
        }
        
        
    }
    
    /**
     Show the date picker to allow the user to enter a purchase date
     - Parameter sender: custom address text field
     */
    @objc func didPressedPurchaseDateField(_ sender: CustomTextField) {
        if propertyType == .Researching{
//            NSDate().dateStringWithFormat(format: "MM/dd/yyyy")
            return
        }
        var dt = Date()
        if let d = purchased_date {
            dt = d
        }
        DatePickerDialog().show("Select Date", defaultDate: dt, datePickerMode: .date) { (date) in
            if let d = date {
                if d.isInTheFuture {
                    self.view.makeToast("Date cann't be in future...")
                    return
                }
                
                self.purchased_date = d
                self.purchase_date_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: d)
            }
        }
    }
    
    /**
     Setup and present the dropdown for selecting the property type
     */
    @objc func didPressedPropTypeField() {
        let drop = DropDown(anchorView: prop_type_label)
        drop.dataSource = ["Single Family", "Condo/Townhome", "Multi-Family Prop", "Commercial", "Other"]
        drop.selectionAction = { (index: Int, item: String) in
            self.prop_type_label.text = item
        }
        drop.show()
    }
    
    /**
     Allows the user to select # of bedrooms (between 1 and 10)
     - Parameter sender: bedrooms button, which is re-titled based on the user's selection
     */
    @objc func didPressedBedRoomField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of bedrooms", options: Constants.getBedRoomsDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
            proInfo["beds"] = i
        }
    }
    
    /**
     Allows the user to select # of bathrooms (between 1 and 10)
     - Parameter sender: bathrooms button, which is re-titled based on the user's selection
     */
    @objc func didPressedBathRoomField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of bathrooms", options: Constants.getBathRoomsDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
            proInfo["baths"] = i
        }
    }
    
    /**
     Allows the user to select # of sq. ft. (between 1 and 10)
     - Parameter sender: sq. ft. button, which is re-titled based on the user's selection
     */
    @objc func didPressedSquareFeetField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of square feets", options: Constants.getSquareFeetDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
            proInfo["sqft"] = i
        }
    }
}

/**
 update purchase value across fields
 */
extension NewAddPropPurchaseVC {
    
    func showActivityIndicator(){
        if (spinner != nil) {
        spinner.removeFromSuperview()
        }
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.color = .black
        spinner.center = self.view.center
        spinner.bounds.size = .zero
       spinner.startAnimating()
        spinner.layer.backgroundColor = UIColor.lightGray.cgColor
        self.view.addSubview(spinner)
    }
    
    
    @objc func didChangedPurchaseValue() {
        let price = purchase_amt_text_field.value
        NewAddPropPurchaseVC.mtg_purchase_amount_value = price
        proInfo["list_price"] = NewAddPropPurchaseVC.mtg_purchase_amount_value
    }
    @objc func textFieldEditingDidChange() {

        let stringValue = String(format: "%.2f", self.down_payment_text_field.value)
        let val = Float(stringValue)!
        
        print(val)
        let totalCashInvested = self.down_payment_text_field.value + self.closing_cost_text_field.value + self.initial_rehab_cost_text_field.value
        print("Total Cost = \(totalCashInvested)")
        self.cash_invested_text_field.formatTextValue(totalCashInvested) //=
//        self.cash_invested_text_field.text = "$\(String(format: "%.2f", totalCashInvested))"
        
    }
}

/**
 Format a Date into a given format
*/
extension NSDate {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
       }
}

//
//  NewAddPropRentIncomeVC.swift
//  RealEstate
//
//  Created by CodeGradients on 24/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
//import DatePickerDialog
import RSSelectionMenu
import DropDown
class NewAddPropRentIncomeVC: UIViewController {
    
    @IBOutlet weak var income_month_text_field: CurrencyTextField!
    @IBOutlet weak var income_annual_text_field: CurrencyTextField!

    @IBOutlet weak var income_stdate_text_field: CustomTextField!
    @IBOutlet weak var income_endate_text_field: CustomTextField!
    @IBOutlet weak var rent_date_text_field: CustomTextField!
    
    @IBOutlet weak var rent_due_date_lbl: UILabel!
    @IBOutlet weak var start_of_lease_lbl: UILabel!
    @IBOutlet weak var rent_term_lbl: UILabel!

    var income_start_date: Date!
    var income_end_date: Date!
    
    public static var month_income_value: Double = 0.0
    public static var annual_income_value: Double = 0.0
    
    /**
    Initialize gesture recognizers and targets for UI
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        income_month_text_field.addTarget(self, action: #selector(didChangedIncomeMonthValue), for: .editingChanged)
        
        income_annual_text_field.addTarget(self, action: #selector(didChangedAnnualValue), for: .editingChanged)
        income_stdate_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeStartDateField(_:))))
//        income_endate_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeEndDateField(_:))))
        rent_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeRentDateField(_:))))
    }
    
    /**
     Update UI fields based off of data
     */
    func updateData(){
        switch propertyType {
        case .IOwn:
            rent_due_date_lbl.text = "Rent Due Date*"//.uppercased()
            start_of_lease_lbl.text = "Start of Lease*"//.uppercased()
            rent_term_lbl.text = "Rent Term*"//.uppercased()
            break
        case .Researching:
            rent_due_date_lbl.text = "Rent Due Date"//.uppercased()
            start_of_lease_lbl.text = "Start of Lease"//.uppercased()
            rent_term_lbl.text = "Rent Term"//.uppercased()
            break
        }
        if let rent = proInfo["traditional_rental"] as? String{
               let monthly = (Double(rent) ?? 0 )/12
            self.income_month_text_field.value = monthly
            income_month_text_field.formatTextValue(monthly) //= (String(format: "$%.2f",(NewAddPropRentIncomeVC.month_income_value)))
            self.income_annual_text_field.value = Double(rent)  ?? 0
            self.income_annual_text_field.formatTextValue(Double(rent)  ?? 0)
            
        }
        
    }
    
    /**
     Move to next page on button press
     - Parameter sender: next button
     */
    @IBAction func didPressedNextButton(_ sender: UIButton) {
        if propertyType == .IOwn{
            if ( income_month_text_field.value == 0 && income_stdate_text_field.text == "")// && income_endate_text_field.text == "")
            {
                AlertBuilder().buildMessage(vc: self, message: "Please insert all required value.")
                return
            }
            
        }
        if let p = parent as? NewAddPropVC {
            p.moveToPage(4)
        }
    }
    
    /**
     Show date picker for the income start date field
     - Parameter sender: custom date text field
     - Note: called via selector
     */
    @objc func didPressedIncomeStartDateField(_ sender: CustomTextField) {
        var dt = Date()
        if let d = income_start_date {
            dt = d
        }
        DatePickerDialog().show("Select Date", defaultDate: dt, datePickerMode: .date) { (date) in
            if let d = date {
                self.income_start_date = d
                
                self.income_stdate_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: d)
            }
        }
    }
    
    /**
     Show date picker for the income end date field
     - Parameter sender: custom date text field
     - Note: called via selector
     */
    @IBAction func didPressedIncomeEndDateField(_ sender: UIButton) {
        let drop = DropDown(anchorView: sender)
        drop.dataSource = ["3-month","6-month","12-month", "Month-to-month"]
        drop.selectionAction = { (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
//            sender.text = item
           
            sender.tag = index
        }
        drop.show()
        
//        var dt = Date()
//        if let d = income_end_date {
//            dt = d
//        }
//        DatePickerDialog().show("Select Date", defaultDate: dt, datePickerMode: .date) { (date) in
//            if let d = date {
//                self.income_end_date = d
//
//                self.income_endate_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: d)
//            }
//        }
    }
    
    /**
     Setup rent due dates, trimming the ordinal for the first one
     - Parameter sender: custom date text field
     */
    @objc func didPressedIncomeRentDateField(_ sender: CustomTextField) {
        var selected = [String]()
        
        var titles: [String] {
            var t = [String]()
            
            for i in 1...31 {
                if rent_date_text_field.tag == i {
                    selected.append(i.ordinal + " of the Month")
                }
                t.append(i.ordinal + " of the Month")
            }
            return t
        }
        
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        selectionMenu.setSelectedItems(items: selected) { (s, i, b, ss) in }
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            if var item = items.first {
                item = item.replacingOccurrences(of: " of the Month", with: "")
                item = item.replacingOccurrences(of: "st", with: "")
                item = item.replacingOccurrences(of: "nd", with: "")
                item = item.replacingOccurrences(of: "rd", with: "")
                item = item.replacingOccurrences(of: "th", with: "")
                let tag = Int(item) ?? 1
                self.rent_date_text_field.tag = tag
                self.rent_date_text_field.text = tag.ordinal + " of the Month"
            }
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
    }
}

/**
 Set income field values
 */
extension NewAddPropRentIncomeVC {
    @objc func didChangedIncomeMonthValue() {
        NewAddPropRentIncomeVC.month_income_value = income_month_text_field.value
        NewAddPropRentIncomeVC.annual_income_value = NewAddPropRentIncomeVC.month_income_value * 12.0
        income_annual_text_field.formatTextValue((NewAddPropRentIncomeVC.annual_income_value))// = (String(format: "$%.2f",(NewAddPropRentIncomeVC.annual_income_value)))
        proInfo["traditional_rental"] = income_annual_text_field.value
    }
    @objc func didChangedAnnualValue() {
        NewAddPropRentIncomeVC.annual_income_value = income_annual_text_field.value
        NewAddPropRentIncomeVC.month_income_value = NewAddPropRentIncomeVC.annual_income_value / 12.0
        income_month_text_field.formatTextValue((NewAddPropRentIncomeVC.month_income_value)) //= (String(format: "$%.2f",(NewAddPropRentIncomeVC.month_income_value)))
        proInfo["traditional_rental"] = income_annual_text_field.value
    }
}

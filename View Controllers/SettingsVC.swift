//
//  SettingsVC.swift
//  RealEstate
//
//  Created by CodeGradients on 09/07/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import SDCAlertView
import JGProgressHUD
import SwiftCSVExport
import RSSelectionMenu
import StoreKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var user_name_lbl: UILabel!
    @IBOutlet weak var user_email_lbl: UILabel!
    @IBOutlet weak var user_currency_lbl: UILabel!
    
    @IBOutlet weak var notif_switch: UISwitch!
    @IBOutlet weak var prop_notif_switch: UISwitch!
    
    let dbRef = Database.database().reference()
    
    var all_users = [DataSnapshot]()
    
    let ascend_months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    /**
     Generic loading function.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notif_switch.addTarget(self, action: #selector(didChangedNotifSwitchValue), for: .valueChanged)
        prop_notif_switch.addTarget(self, action: #selector(didChangedNotifSwitchValue(_:)), for: .valueChanged)
        
        dbRef.child("users").child(Constants.mineId).observe(.value) { (snapshot) in
            self.user_name_lbl.text = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            self.user_email_lbl.text = snapshot.childSnapshot(forPath: "email").value as? String ?? ""
            self.notif_switch.isOn = snapshot.childSnapshot(forPath: "notif").value as? Bool ?? true
            self.prop_notif_switch.isOn = snapshot.childSnapshot(forPath: "prop_notif").value as? Bool ?? true
        }
        
        dbRef.child("users").observe(.value) { (snapshot) in
            for child in snapshot.children {
                let snp = (child as! DataSnapshot)
                self.all_users.append(snp)
            }
        }
        
        updateCurrencyLabel()
    }
    
    /**
     Returns an instance of this controller
     */
    class func getController() -> SettingsVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: SettingsVC.storyboard_id) as! SettingsVC
    }
    
    /**
     Switch notification
     */
    @objc func didChangedNotifSwitchValue(_ sender: UISwitch) {
        let ref = sender == notif_switch ? "notif" : "prop_notif"
        dbRef.child("users").child(Constants.mineId).child(ref).setValue(sender.isOn)
    }
    
    /**
     Updates the currency label based on the UserDefaults value.
     */
    func updateCurrencyLabel() {
        let val = UserDefaults.standard.integer(forKey: "currency")
        switch val {
        case 0:
            user_currency_lbl.text = "USD - $"
            break
        case 1:
            user_currency_lbl.text = "AUD - A$"
            break
        case 2:
            user_currency_lbl.text = "EUR - €"
            break
        case 3:
            user_currency_lbl.text = "JPY - ¥"
            break
        case 4:
            user_currency_lbl.text = "GBP - £"
            break
        default:
            break
        }
    }
    
    /**
            Presents a UIAlertController with options to edit account values.
     */
    @IBAction func didPressedEditButton(_ sender: UIButton) {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.popoverPresentationController?.sourceView = sender
        options.addAction(UIAlertAction(title: "Change Display Name", style: .default, handler: { (ac) in
            options.dismiss(animated: true) {
                let alert = AlertController(title: "Change Display Name", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Name"
                    textField.borderStyle = .roundedRect
                    textField.clearButtonMode = .whileEditing
                    textField.text = self.user_name_lbl.text ?? ""
                }
                
                alert.addAction(AlertAction(title: "Save", style: AlertAction.Style.preferred, handler: { (action) in
                    let value = alert.textFields?[0].text
                    self.dbRef.child("users").child(Constants.mineId).child("name").setValue(value)
                    alert.dismiss()
                }))
                
                alert.addAction(AlertAction(title: "Cancel", style: AlertAction.Style.preferred, handler: { (action) in
                    alert.dismiss()
                }))
                
                alert.shouldDismissHandler =  {
                    if $0?.title == "Cancel" {
                        return true
                    }
                    
                    if $0?.title == "Save" {
                        let data = alert.textFields?[0].text
                        if !data!.isEmpty{
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    return false
                }
                
                self.present(alert, animated: true, completion: nil)
            }
        }))
        //For house flipping dashboard we will not have a update email icon
        /*
        options.addAction(UIAlertAction(title: "Update Email", style: .default, handler: { (ac) in
            options.dismiss(animated: true) {
                if let user = Auth.auth().currentUser {
                    let email = user.email ?? self.user_email_lbl.text ?? "0@1.com"
                    let alert = AlertController(title: nil, message: "This action requires you to be logged in recently, so type your password so that we can authenticate you ", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Password"
                        textField.clearButtonMode = .whileEditing
                        textField.isSecureTextEntry = true
                        textField.borderStyle = .roundedRect
                    }
                    
                    alert.addAction(AlertAction(title: "Continue", style: AlertAction.Style.preferred, handler: { (action) in
                        let value = alert.textFields?[0].text ?? ""
                        let hud = JGProgressHUD(style: .dark)
                        hud.show(in: self.view)
                        
                        let credential = EmailAuthProvider.credential(withEmail: email, password: value)
                        user.reauthenticate(with: credential) { (res, err) in
                            hud.dismiss()
                            
                            if let e = err {
                                AlertBuilder().buildMessage(vc: self, message: "Failed to Login\nError: " + e.localizedDescription)
                                return
                            }
                            
                            let al = AlertController(title: "Update Email", message: "Type new email", preferredStyle: .alert)
                            al.addTextField { (textField) in
                                textField.placeholder = "Email"
                                textField.clearButtonMode = .whileEditing
                                textField.borderStyle = .roundedRect
                            }
                            al.addAction(AlertAction(title: "Save", style: .preferred, handler: { (ac) in
                                let nemail = al.textFields?[0].text ?? ""
                                
                                let hud = JGProgressHUD(style: .dark)
                                hud.show(in: self.view)
                                
                                user.updateEmail(to: nemail) { (err) in
                                    hud.dismiss()
                                    
                                    if let e = err {
                                        AlertBuilder().buildMessage(vc: self, message: "Failed to update Email\nError: \(e.localizedDescription)")
                                        return
                                    }
                                    
                                    if !Constants.admin_email.isEmpty {
                                        if Constants.admin_email == email {
                                            self.dbRef.child("admin").child("email").setValue(nemail)
                                        }
                                    }
                                    
                                    self.dbRef.child("users").child(Constants.mineId).child("email").setValue(nemail)
                                }
                            }))
                            al.addAction(AlertAction(title: "Cancel", style: .preferred, handler: { (ac) in
                                al.dismiss()
                            }))
                            al.shouldDismissHandler = {
                                if $0?.title == "Cancel" {
                                    return true
                                }
                                
                                if $0?.title == "Save" {
                                    let data = al.textFields?[0].text ?? ""
                                    return !data.isEmpty
                                }
                                
                                return false
                            }
                            self.present(al, animated: true, completion: nil)
                        }
                    }))
                    
                    alert.addAction(AlertAction(title: "Cancel", style: AlertAction.Style.preferred, handler: { (action) in
                        alert.dismiss()
                    }))
                    
                    alert.shouldDismissHandler =  {
                        if $0?.title == "Cancel" {
                            return true
                        }
                        
                        if $0?.title == "Continue" {
                            let data = alert.textFields?[0].text
                            if !data!.isEmpty{
                                return true
                            } else {
                                return false
                            }
                        }
                        
                        return false
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
 */
        options.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (ac) in
            options.dismiss(animated: true) {
                if let user = Auth.auth().currentUser {
                    let email = user.email ?? self.user_email_lbl.text ?? "0@1.com"
                    let alert = AlertController(title: nil, message: "This action requires you to be logged in recently, so type your password so that we can authenticate you ", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Password"
                        textField.isSecureTextEntry = true
                        textField.clearButtonMode = .whileEditing
                        textField.borderStyle = .roundedRect
                    }
                    
                    alert.addAction(AlertAction(title: "Continue", style: AlertAction.Style.preferred, handler: { (action) in
                        let value = alert.textFields?[0].text ?? ""
                        let hud = JGProgressHUD(style: .dark)
                        hud.show(in: self.view)
                        
                        let credential = EmailAuthProvider.credential(withEmail: email, password: value)
                        user.reauthenticate(with: credential) { (res, err) in
                            hud.dismiss()
                            
                            if let e = err {
                                AlertBuilder().buildMessage(vc: self, message: "Failed to Login\nError: " + e.localizedDescription)
                                return
                            }
                            
                            let al = AlertController(title: "Update Password", message: "Type new password", preferredStyle: .alert)
                            al.addTextField { (textField) in
                                textField.placeholder = "Password"
                                textField.isSecureTextEntry = true
                                textField.clearButtonMode = .whileEditing
                                textField.borderStyle = .roundedRect
                            }
                            al.addAction(AlertAction(title: "Save", style: .preferred, handler: { (ac) in
                                let pass = al.textFields?[0].text ?? ""
                                
                                let hud = JGProgressHUD(style: .dark)
                                hud.show(in: self.view)
                                
                                user.updatePassword(to: pass) { (err) in
                                    hud.dismiss()
                                    
                                    if let e = err {
                                        AlertBuilder().buildMessage(vc: self, message: "Failed to update Password\nError: \(e.localizedDescription)")
                                        return
                                    }
                                }
                            }))
                            al.addAction(AlertAction(title: "Cancel", style: .preferred, handler: { (ac) in
                                al.dismiss()
                            }))
                            al.shouldDismissHandler = {
                                if $0?.title == "Cancel" {
                                    return true
                                }
                                
                                if $0?.title == "Save" {
                                    let data = al.textFields?[0].text ?? ""
                                    return !data.isEmpty
                                }
                                
                                return false
                            }
                            self.present(al, animated: true, completion: nil)
                        }
                    }))
                    
                    alert.addAction(AlertAction(title: "Cancel", style: AlertAction.Style.preferred, handler: { (action) in
                        alert.dismiss()
                    }))
                    
                    alert.shouldDismissHandler =  {
                        if $0?.title == "Cancel" {
                            return true
                        }
                        
                        if $0?.title == "Continue" {
                            let data = alert.textFields?[0].text
                            if !data!.isEmpty{
                                return true
                            } else {
                                return false
                            }
                        }
                        
                        return false
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(options, animated: true, completion: nil)
    }
    
    /**
     Presents FeedbackVC
     */
    @IBAction func didPressedFeedbackButton(_ sender: UIButton) {
        let vc = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: FeedbackVC.storyboard_id)
        present(vc, animated: true, completion: nil)
    }
    
    /**
     Opens ReferFriendVC
     */
    @IBAction func didPressedReferButton(_ sender: UIButton) {
        let vc = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: ReferFriendVC.storyboard_id)
        present(vc, animated: true, completion: nil)
    }
    
    /**
     Opens App Store rate/review page.
     */
    @IBAction func didPressedRateButton(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    /**
     Switches currency based on user input.
     */
    @IBAction func didPressedCurrencyButton(_ sender: UIButton) {
        let titles = Constants.currencies
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        var selected: [String] = []
        selected.append(titles[UserDefaults.standard.integer(forKey: "currency")])
        selectionMenu.setSelectedItems(items: selected) { (s, i, b, d) in }
        
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            if let first = items.first {
                let index = titles.firstIndex(of: first)
                UserDefaults.standard.set(index, forKey: "currency")
                self.updateCurrencyLabel()
                
                switch index {
                case 0:
                    Constants.currency_code = "USD"
                    Constants.currency_placeholder = "$"
                    break
                case 1:
                    Constants.currency_code = "AUD"
                    Constants.currency_placeholder = "A$"
                    break
                case 2:
                    Constants.currency_code = "EUR"
                    Constants.currency_placeholder = "€"
                    break
                case 3:
                    Constants.currency_code = "JPY"
                    Constants.currency_placeholder = "¥"
                    break
                case 4:
                    Constants.currency_code = "GBP"
                    Constants.currency_placeholder = "£"
                    break
                default:
                    break
                }
                
                NotificationCenter.default.post(name: .currencyUpdated, object: nil)
            }
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
    }
    
    /**
     Confirms logout and then logs out.
     */
    @IBAction func didPressedLogoutButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (ac) in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch { }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Grabs the data from the properties_list and converts them into a propertyModel to be used for export.
     */
    @IBAction func didPressedExportDataButton(_ sender: UIButton) {
        let mine_email = user_email_lbl.text ?? ""
        if !Constants.admin_email.isEmpty {
            if mine_email == Constants.admin_email {
                
                let hud = JGProgressHUD(style: .dark)
                hud.show(in: self.view)
                
                dbRef.child("properties").observeSingleEvent(of: .value) { (snapshot) in
                    
                    var list = [PropertyModel]()
                    
                    for child in snapshot.children {
                        let snap = (child as! DataSnapshot)
                        
                        var model = PropertyModel()
                        
                        model.key = snap.childSnapshot(forPath: "key").value as? String ?? ""
                        model.user = snap.childSnapshot(forPath: "user").value as? String ?? ""
                        model.address = snap.childSnapshot(forPath: "address").value as? String ?? ""
                        model.purchase_date = snap.childSnapshot(forPath: "purchase_date").value as? String ?? Constants.getCurrentMillis()
                        model.purchase_amt = snap.childSnapshot(forPath: "purchase_amt").value as? Double ?? 0.0
                        model.prop_type = snap.childSnapshot(forPath: "prop_type").value as? String ?? "Single Family"
                        model.millis = snap.childSnapshot(forPath: "millis").value as? String ?? ""
                        model.deleted = snap.childSnapshot(forPath: "deleted").value as? Bool ?? false
                        model.likes = Int(snap.childSnapshot(forPath: "likes").childrenCount)

                        var units = [UnitModel]()
                        for chl in snap.childSnapshot(forPath: "units").children {
                            let snp = (chl as! DataSnapshot)
                            
                            var unit = UnitModel()
                            
                            unit.key = snp.key
                            unit.unit_name = snp.childSnapshot(forPath: "name").value as? String ?? ""
                            unit.bedrooms = snp.childSnapshot(forPath: "bedrooms").value as? Int ?? 0
                            unit.bathrooms = snp.childSnapshot(forPath: "bathrooms").value as? Int ?? 0
                            unit.square_feet = snp.childSnapshot(forPath: "square_feet").value as? Int ?? 0
                            unit.rent_month  = snp.childSnapshot(forPath: "rent_month").value as? Double ?? 0.0
                            unit.rent_annual = snp.childSnapshot(forPath: "rent_annual").value as? Double ?? 0.0
                            unit.rent_start = snp.childSnapshot(forPath: "rent_start").value as? String ?? ""
                            unit.rent_end = snp.childSnapshot(forPath: "rent_end").value as? String ?? ""
                            unit.rent_day = snp.childSnapshot(forPath: "rent_day").value as? Int ?? 1
                            unit.month_ins = snp.childSnapshot(forPath: "month_ins").value as? Double ?? 0.0
                            unit.annual_ins = snp.childSnapshot(forPath: "annual_ins").value as? Double ?? 0.0
                            unit.month_prot = snp.childSnapshot(forPath: "month_prot").value as? Double ?? 0.0
                            unit.annual_prot = snp.childSnapshot(forPath: "annual_prot").value as? Double ?? 0.0
                            unit.month_mtg = snp.childSnapshot(forPath: "month_mtg").value as? Double ?? 0.0
                            unit.annual_mtg = snp.childSnapshot(forPath: "annual_mtg").value as? Double ?? 0.0
                            unit.month_vac = snp.childSnapshot(forPath: "month_vac").value as? Double ?? 0.0
                            unit.annual_vac = snp.childSnapshot(forPath: "annual_vac").value as? Double ?? 0.0
                            unit.month_repair = snp.childSnapshot(forPath: "month_repair").value as? Double ?? 0.0
                            unit.annual_repair = snp.childSnapshot(forPath: "annual_repair").value as? Double ?? 0.0
                            unit.month_prom = snp.childSnapshot(forPath: "month_prom").value as? Double ?? 0.0
                            unit.annual_prom = snp.childSnapshot(forPath: "annual_prom").value as? Double ?? 0.0
                            unit.month_util = snp.childSnapshot(forPath: "month_util").value as? Double ?? 0.0
                            unit.annual_util = snp.childSnapshot(forPath: "annual_util").value as? Double ?? 0.0
                            unit.month_hoa = snp.childSnapshot(forPath: "month_hoa").value as? Double ?? 0.0
                            unit.annual_hoa = snp.childSnapshot(forPath: "annual_hoa").value as? Double ?? 0.0
                            unit.month_other = snp.childSnapshot(forPath: "month_other").value as? Double ?? 0.0
                            unit.annual_other = snp.childSnapshot(forPath: "annual_other").value as? Double ?? 0.0
                            unit.mtg_purchase_amt = snp.childSnapshot(forPath: "mtg_purchase").value as? Double ?? 0.0
                            unit.mtg_down_payment = snp.childSnapshot(forPath: "mtg_down").value as? Double ?? 0.0
                            unit.mtg_interest_rate = snp.childSnapshot(forPath: "mtg_interest").value as? Double ?? 0.0
                            unit.mtg_loan_term = snp.childSnapshot(forPath: "mtg_loan").value as? Double ?? 0.0
                            unit.notes = snp.childSnapshot(forPath: "notes").value as? String ?? ""
                            
                            var list = [RentRollModel]()
                            for sn in snp.childSnapshot(forPath: "rent_rolls").children {
                                let data = (sn as! DataSnapshot)
                                
                                var md = RentRollModel()
                                md.key = data.key
                                md.amount = data.childSnapshot(forPath: "amount").value as? Double ?? 0.0
                                md.late_fee = data.childSnapshot(forPath: "late_fee").value as? Double ?? 0.0
                                md.year = data.childSnapshot(forPath: "year").value as? Int ?? 2020
                                md.month = data.childSnapshot(forPath: "month").value as? Int ?? 0
                                md.paid = data.childSnapshot(forPath: "paid").value as? Bool ?? false
                                md.total_amount = md.amount + md.late_fee
                                md.image = data.childSnapshot(forPath: "image").value as? String ?? ""
                                
                                list.append(md)
                            }
                            unit.rent_roll_list = list
                            
                            units.append(unit)
                        }
                        model.units = units
                        
                        if !model.user.isEmpty {
                            let email = self.getUserEmail(id: model.user)
                            model.user = email
                        }
                        
                        list.append(model)
                    }
                    
                    hud.dismiss()
                    
                    self.createCSVFile(list: list, true)
                }
                
            } else {
                var list = [PropertyModel]()
                for var item in MainVC.properties_list {
                    item.user = mine_email
                    list.append(item)
                }
                createCSVFile(list: list, false)
            }
        } else {
            var list = [PropertyModel]()
            for var item in MainVC.properties_list {
                item.user = mine_email
                list.append(item)
            }
            createCSVFile(list: list, false)
        }
    }
    
    func getUserEmail(id: String) -> String {
        for user in all_users {
            if user.key == id {
                return user.childSnapshot(forPath: "email").value as? String ?? ""
            }
        }
        return ""
    }
    
    /**
     Creates a CSV file from the given PropertyModel that can then be exported.
     */
    func createCSVFile(list: [PropertyModel], _ admin: Bool) {
        let properties = NSMutableArray()
        for model in list {
            for unit in model.units {
                var address = model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "#", with: " ")
                if model.prop_type == "Multi-Family Prop" {
                    address = address + " Unit: " + unit.unit_name
                }
                
                let prop = NSMutableDictionary()
                prop.setObject(model.user, forKey: "Email User" as NSCopying)
                prop.setObject(address, forKey: "address" as NSCopying)
                if let s_index = model.address.indexOf(target: "\n") {
                    //st_address_text_field.text = model.address.subString(to: s_index)
                    
                    if let c_index = model.address.lastIndexOf(target: ",") {
                        prop.setObject(model.address.subStringRange(from: s_index + 1, to: c_index).trimmingCharacters(in: .whitespaces), forKey: "City" as NSCopying)
                        if let st_index = model.address.lastIndexOf(target: "#") {
                            prop.setObject(model.address.subStringRange(from: c_index + 1, to: st_index).trimmingCharacters(in: .whitespaces), forKey: "State" as NSCopying)
                            prop.setObject(model.address.subStringRange(from: st_index + 1, to: model.address.count), forKey: "Zipcode" as NSCopying)
                        }
                    }
                }
                prop.setObject(model.purchase_amt, forKey: "Purchase Amount" as NSCopying)
                prop.setObject(Constants.formatDate("MM/dd/yyyy", dt: Constants.buildDatefromMillis(millis: model.purchase_date) ?? Date()), forKey: "Purchase Date" as NSCopying)
                prop.setObject(model.prop_type, forKey: "Prop Type" as NSCopying)
                var date = "00/00/0000"
                if let dt = Constants.buildDatefromMillis(millis: model.millis) {
                    date = Constants.formatDate("MM/dd/yyyy", dt: dt)
                }
                prop.setObject(date, forKey: "Date Submitted" as NSCopying)
                prop.setObject(model.likes, forKey: "Likes" as NSCopying)
                
                if admin {
                    prop.setObject(String(model.deleted).capitalized, forKey: "Deleted" as NSCopying)
                }
                
                prop.setObject(calcMonthRent(model) - calcMonthExpenses(model), forKey: "Month Profit" as NSCopying)
                prop.setObject(calcAnnualRent(model) - calcAnnualExpenses(model), forKey: "Annual Profit" as NSCopying)
                
                prop.setObject(getBedRoomsList(unit), forKey: "Bedrooms" as NSCopying)
                prop.setObject(getBathroomList(unit), forKey: "Bathrooms" as NSCopying)
                prop.setObject(getSquareFeetList(unit), forKey: "Square Feet" as NSCopying)
                
                prop.setObject(getMAIncome(unit, month: true), forKey: "Month Income" as NSCopying)
                prop.setObject(getMAIncome(unit, month: false), forKey: "Annual Income" as NSCopying)
                
                prop.setObject(getIncomeStartEndDate(unit, start: true), forKey: "Income Start Date" as NSCopying)
                prop.setObject(getIncomeStartEndDate(unit, start: false), forKey: "Income End Date" as NSCopying)
                prop.setObject(getIncomeRentDay(unit), forKey: "Rent Payment Date" as NSCopying)
                
                prop.setObject(getMAExpenses(unit, month: true), forKey: "Month Expenses" as NSCopying)
                prop.setObject(getMAExpenses(unit, month: false), forKey: "Annual Expenses" as NSCopying)
                
                prop.setObject(getMAExpensesIns(unit, month: true), forKey: "Month Insurance" as NSCopying)
                prop.setObject(getMAExpensesIns(unit, month: false), forKey: "Annual Insurance" as NSCopying)
                
                prop.setObject(getMAExpensesProt(unit, month: true), forKey: "Month Property Tax" as NSCopying)
                prop.setObject(getMAExpensesProt(unit, month: false), forKey: "Annual Property Tax" as NSCopying)
                
                prop.setObject(getMAExpensesMtg(unit, month: true), forKey: "Month Mortgage" as NSCopying)
                prop.setObject(getMAExpensesMtg(unit, month: false), forKey: "Annual Mortgage" as NSCopying)
                
                prop.setObject(getMAExpensesVac(unit, month: true), forKey: "Month Vacancy" as NSCopying)
                prop.setObject(getMAExpensesVac(unit, month: false), forKey: "Annaul Vacancy" as NSCopying)
                
                prop.setObject(getMAExpensesRepair(unit, month: true), forKey: "Month Repair" as NSCopying)
                prop.setObject(getMAExpensesRepair(unit, month: false), forKey: "Annual Repair" as NSCopying)
                
                prop.setObject(getMAExpensesProm(unit, month: true), forKey: "Month Property Management" as NSCopying)
                prop.setObject(getMAExpensesProm(unit, month: false), forKey: "Annual Property Management" as NSCopying)
                
                prop.setObject(getMAExpensesUtil(unit, month: true), forKey: "Month Utility" as NSCopying)
                prop.setObject(getMAExpensesUtil(unit, month: false), forKey: "Annual Utility" as NSCopying)
                
                prop.setObject(getMAExpensesHoa(unit, month: true), forKey: "Month HOA" as NSCopying)
                prop.setObject(getMAExpensesHoa(unit, month: false), forKey: "Annual HOA" as NSCopying)
                
                prop.setObject(getMAExpensesOther(unit, month: true), forKey: "Month Other" as NSCopying)
                prop.setObject(getMAExpensesOther(unit, month: false), forKey: "Annual Other" as NSCopying)
                
                prop.setObject(getPropMtgPurchase(unit), forKey: "MTG Purchase Amount" as NSCopying)
                prop.setObject(getPropMtgDown(unit), forKey: "MTG Down Payment" as NSCopying)
                prop.setObject(getPropMtgInterest(unit), forKey: "MTG Interest Rate" as NSCopying)
                prop.setObject(getPropMtgLoan(unit), forKey: "MTG Loan Term" as NSCopying)
                
                prop.setObject(getPropNotes(unit), forKey: "Notes" as NSCopying)
                
                properties.add(prop)
            }
        }
        
        var header = [String]()
        
        header = ["Email User", "address", "City", "State", "Zipcode", "Purchase Amount", "Purchase Date", "Prop Type", "Date Submitted", "Likes", "Month Profit", "Annual Profit", "Bedrooms", "Bathrooms", "Square Feet", "Month Income", "Annual Income", "Income Start Date", "Income End Date", "Rent Payment Date", "Month Expenses", "Annual Expenses", "Month Insurance", "Annual Insurance", "Month Property Tax", "Annual Property Tax", "Month Mortgage", "Annual Mortgage", "Month Vacancy", "Annaul Vacancy", "Month Repair", "Annual Repair", "Month Property Management", "Annual Property Management", "Month Utility", "Annual Utility", "Month HOA", "Annual HOA", "Month Other", "Annual Other", "MTG Purchase Amount", "MTG Down Payment", "MTG Interest Rate", "MTG Loan Term", "Notes"]
        
        if admin {
            header = ["Email User", "address", "City", "State", "Zipcode", "Purchase Amount", "Purchase Date", "Prop Type", "Date Submitted", "Likes", "Deleted", "Month Profit", "Annual Profit", "Bedrooms", "Bathrooms", "Square Feet", "Month Income", "Annual Income", "Income Start Date", "Income End Date", "Rent Payment Date", "Month Expenses", "Annual Expenses", "Month Insurance", "Annual Insurance", "Month Property Tax", "Annual Property Tax", "Month Mortgage", "Annual Mortgage", "Month Vacancy", "Annaul Vacancy", "Month Repair", "Annual Repair", "Month Property Management", "Annual Property Management", "Month Utility", "Annual Utility", "Month HOA", "Annual HOA", "Month Other", "Annual Other", "MTG Purchase Amount", "MTG Down Payment", "MTG Interest Rate", "MTG Loan Term", "Notes"]
        }
        
        let rent_rolls = NSMutableArray()
        var rent_roll_headers = [String]()
        rent_roll_headers.append("Year")
        rent_roll_headers.append("Month")
        
        for i in 0..<12 {
            let year = Date().year
            
            let rent = NSMutableDictionary()
            rent.setObject("\(year)", forKey: "Year" as NSCopying)
            rent.setObject(ascend_months[i], forKey: "Month" as NSCopying)
            
            if list.count > 0 {
                var ptotal = 0.0
                var utotal = 0.0
                
                for model in list {
                    for unit in model.units {
                        for roll in unit.rent_roll_list {
                            if roll.year == year {
                                if roll.month == i {
                                    if roll.paid {
                                        ptotal += roll.total_amount
                                    }
                                }
                            }
                        }
                    }
                }
                
                rent.setObject("\(ptotal)", forKey: "Paid - Total" as NSCopying)
                if !rent_roll_headers.contains("Paid - Total") {
                    rent_roll_headers.append("Paid - Total")
                }
                
                for model in list {
                    if model.prop_type != "Multi-Family Prop" {
                        var paid = 0.0
                        
                        for unit in model.units {
                            for roll in unit.rent_roll_list {
                                if roll.year == year {
                                    if roll.month == i {
                                        if roll.paid {
                                            paid += roll.total_amount
                                        }
                                    }
                                }
                            }
                        }
                        
                        let address = model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "#", with: " ")
                        
                        
                        rent.setObject("\(paid)", forKey: "Paid - " + address as NSCopying)
                        
                        if !rent_roll_headers.contains("Paid - " + address) {
                            rent_roll_headers.append("Paid - " + address)
                        }
                    } else {
                        let address = model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "#", with: " ")
                        
                        for unit in model.units {
                            var paid = 0.0
                            
                            for roll in unit.rent_roll_list {
                                if roll.year == year {
                                    if roll.month == i {
                                        if roll.paid {
                                            paid += roll.total_amount
                                        }
                                    }
                                }
                            }
                            
                            rent.setObject("\(paid)", forKey: "Paid - " + address + " Unit: " + unit.unit_name as NSCopying)
                            
                            if !rent_roll_headers.contains("Paid - " + address + " Unit: " + unit.unit_name) {
                                rent_roll_headers.append("Paid - " + address + " Unit: " + unit.unit_name)
                            }
                        }
                    }
                }
                
                for model in list {
                    for unit in model.units {
                        if let purchase_date = Constants.buildDatefromMillis(millis: model.purchase_date) {
                            
                            var options = DateComponents()
                            options.year = year
                            options.month = i + 1
                            let current = Calendar.current.date(from: options)
                            
                            if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                let roll = getRentRollModel(model: unit, year: year, month: i)
                                if !roll.paid {
                                    utotal += roll.total_amount
                                }
                            }
                        }
                    }
                }
                
                rent.setObject("\(utotal)", forKey: "Unpaid - Total" as NSCopying)
                if !rent_roll_headers.contains("Unpaid - Total") {
                    rent_roll_headers.append("Unpaid - Total")
                }
                
                for model in list {
                    if model.prop_type != "Multi-Family Prop" {
                        var upaid = 0.0
                        
                        for unit in model.units {
                            if let purchase_date = Constants.buildDatefromMillis(millis: model.purchase_date) {
                                
                                var options = DateComponents()
                                options.year = year
                                options.month = i + 1
                                let current = Calendar.current.date(from: options)
                                
                                if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                    let roll = getRentRollModel(model: unit, year: year, month: i)
                                    if !roll.paid {
                                        upaid += roll.total_amount
                                    }
                                }
                            }
                        }
                        
                        let address = model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "#", with: " ")
                        
                        rent.setObject("\(upaid)", forKey: "Unpaid - " + address as NSCopying)
                        
                        if !rent_roll_headers.contains("Unpaid - " + address) {
                            rent_roll_headers.append("Unpaid - " + address)
                        }
                    } else {
                        let address = model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "#", with: " ")
                        for unit in model.units {
                            var upaid = 0.0
                            
                            if let purchase_date = Constants.buildDatefromMillis(millis: model.purchase_date) {
                                
                                var options = DateComponents()
                                options.year = year
                                options.month = i + 1
                                let current = Calendar.current.date(from: options)
                                
                                if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                    let roll = getRentRollModel(model: unit, year: year, month: i)
                                    if !roll.paid {
                                        upaid += roll.total_amount
                                    }
                                }
                            }
                            
                            rent.setObject("\(upaid)", forKey: "Unpaid - " + address + " Unit: " + unit.unit_name as NSCopying)
                            
                            if !rent_roll_headers.contains("Unpaid - " + address + " Unit: " + unit.unit_name) {
                                rent_roll_headers.append("Unpaid - " + address + " Unit: " + unit.unit_name)
                            }
                        }
                    }
                }
            }
            
            rent_rolls.add(rent)
        }
        
        let propWriter = CSV()
        propWriter.rows = properties
        propWriter.delimiter = DividerType.comma.rawValue
        propWriter.fields = header as NSArray
        propWriter.name = "properties_list"
        
        let rollWriter = CSV()
        rollWriter.rows = rent_rolls
        rollWriter.delimiter = DividerType.comma.rawValue
        rollWriter.fields = rent_roll_headers as NSArray
        rollWriter.name = "rent_roll_list"
        
        let result = CSVExport.export(propWriter)
        
        let roll_result = CSVExport.export(rollWriter)
        
        if result.result.isSuccess {
            guard let filePath =  result.filePath else {
                AlertBuilder().buildMessage(vc: self, message: "Export Error: \(String(describing: result.message))")
                return
            }
            print("File Path: \(filePath)")
            
            var items = [URL]()
            items.append(URL(fileURLWithPath: filePath))
            
            if roll_result.result.isSuccess {
                if let path = roll_result.filePath {
                    items.append(URL(fileURLWithPath: path))
                }
            }
            
            let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
            
            self.present(vc, animated: true)
        } else {
            print("Export Error: \(String(describing: result.message))")
            AlertBuilder().buildMessage(vc: self, message: "Export Error: \(String(describing: result.message))")
        }
    }
    
    //Helper methods for createCSVFile are below.
    
    
    func getRentRollModel(model: UnitModel, year: Int, month: Int) -> RentRollModel {
        for mod in model.rent_roll_list {
            if mod.year == year {
                if mod.month == month {
                    return mod
                }
            }
        }
        
        if let start = Constants.buildDatefromMillis(millis: model.rent_start) {
            if let end = Constants.buildDatefromMillis(millis: model.rent_end) {
                var components = DateComponents()
                components.year = year
                components.month = month + 1
                components.day = Calendar.current.component(.day, from: Date())
                
                if let current = Calendar.current.date(from: components) {
                    
                    
                    var md = RentRollModel()
                    md.key = ""
                    md.amount = model.rent_month
                    md.late_fee = 0.0
                    md.total_amount = model.rent_month
                    md.paid = false
                    md.year = year
                    md.month = month
                    
                    
                    if current.isBetween(start: start, end: end) {
                        return md
                    }
                    
                    if current.isInSameDay(date: start) {
                        return md
                    }
                    
                    if current.isInSameDay(date: end) {
                        return md
                    }
                    
                    if current.isInSameMonth(date: start) {
                        return md
                    }
                    
                    if current.isInSameMonth(date: end) {
                        return md
                    }
                }
            }
        }
        
        var md = RentRollModel()
        md.key = ""
        md.amount = 0.0
        md.late_fee = 0.0
        md.total_amount = 0.0
        md.paid = false
        md.year = year
        md.month = month
        return md
    }
    
    func getBedRoomsList(_ model: UnitModel) -> String {
        return "\(Constants.getBedRoomsDataList()[model.bedrooms])"
    }
    
    func getBathroomList(_ model: UnitModel) -> String {
        return "\(Constants.getBathRoomsDataList()[model.bathrooms])"
    }
    
    func getSquareFeetList(_ model: UnitModel) -> String {
        return "\(Constants.getSquareFeetDataList()[model.square_feet])"
    }
    
    func getMAIncome(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.rent_month : model.rent_annual)"
    }
    
    func getIncomeStartEndDate(_ model: UnitModel, start: Bool) -> String {
        var date = "00/00/0000"
        if let dt = Constants.buildDatefromMillis(millis: start ? model.rent_start : model.rent_end) {
            date = Constants.formatDate("MM/dd/yyyy", dt: dt)
        }
        return date
    }
    
    func getIncomeRentDay(_ model: UnitModel) -> String {
        return "\(model.rent_day)"
    }
    
    func getMAExpenses(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? calcMonthExpenses(model) : calcAnnualExpenses(model))"
    }
    
    func getMAExpensesIns(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_ins : model.annual_ins)"
    }
    
    func getMAExpensesProt(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_prot : model.annual_prot)"
    }
    
    func getMAExpensesMtg(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_mtg : model.annual_mtg)"
    }
    
    func getMAExpensesVac(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_vac : model.annual_vac)"
    }
    
    func getMAExpensesRepair(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_repair : model.annual_repair)"
    }
    
    func getMAExpensesProm(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_prom : model.annual_prom)"
    }
    
    func getMAExpensesUtil(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_util : model.annual_util)"
    }
    
    func getMAExpensesHoa(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_hoa : model.annual_hoa)"
    }
    
    func getMAExpensesOther(_ model: UnitModel, month: Bool) -> String {
        return "\(month ? model.month_other : model.annual_other)"
    }
    
    func getPropMtgPurchase(_ model: UnitModel) -> String {
        return "\(model.mtg_purchase_amt)"
    }
    
    func getPropMtgDown(_ model: UnitModel) -> String {
        return "\(model.mtg_down_payment)"
    }
    
    func getPropMtgInterest(_ model: UnitModel) -> String {
        return "\(model.mtg_interest_rate)%"
    }
    
    func getPropMtgLoan(_ model: UnitModel) -> String {
        return "\(model.mtg_loan_term) Years"
    }
    
    func getPropNotes(_ model: UnitModel) -> String {
        return "\(model.notes)"
    }
    
    func calcMonthExpenses(_ model: PropertyModel) -> Double {
        var amt = 0.0
        
        for unit in model.units {
            amt = amt + unit.month_ins
            amt = amt + unit.month_prot
            amt = amt + unit.month_mtg
            amt = amt + unit.month_vac
            amt = amt + unit.month_repair
            amt = amt + unit.month_prom
            amt = amt + unit.month_util
            amt = amt + unit.month_hoa
            amt = amt + unit.month_other
        }
        
        return amt
    }
    
    func calcMonthExpenses(_ unit: UnitModel) -> Double {
        var amt = 0.0
        
        amt = amt + unit.month_ins
        amt = amt + unit.month_prot
        amt = amt + unit.month_mtg
        amt = amt + unit.month_vac
        amt = amt + unit.month_repair
        amt = amt + unit.month_prom
        amt = amt + unit.month_util
        amt = amt + unit.month_hoa
        amt = amt + unit.month_other
        
        return amt
    }
    
    func calcMonthRent(_ model: PropertyModel) -> Double {
        var amt = 0.0
        
        for unit in model.units {
            amt = amt + unit.rent_month
        }
        
        return amt
    }
    
    func calcAnnualExpenses(_ model: PropertyModel) -> Double {
        var amt = 0.0
        
        for unit in model.units {
            amt = amt + unit.annual_ins
            amt = amt + unit.annual_prot
            amt = amt + unit.annual_mtg
            amt = amt + unit.annual_vac
            amt = amt + unit.annual_repair
            amt = amt + unit.annual_prom
            amt = amt + unit.annual_util
            amt = amt + unit.annual_hoa
            amt = amt + unit.annual_other
        }
        return amt
    }
    
    func calcAnnualExpenses(_ unit: UnitModel) -> Double {
        var amt = 0.0
        
        amt = amt + unit.annual_ins
        amt = amt + unit.annual_prot
        amt = amt + unit.annual_mtg
        amt = amt + unit.annual_vac
        amt = amt + unit.annual_repair
        amt = amt + unit.annual_prom
        amt = amt + unit.annual_util
        amt = amt + unit.annual_hoa
        amt = amt + unit.annual_other
        
        return amt
    }
    
    func calcAnnualRent(_ model: PropertyModel) -> Double {
        var amt = 0.0
        
        for unit in model.units {
            amt = amt + unit.rent_annual
        }
        return amt
    }
}

extension SettingsVC{
    /**
     Opens privacy policy link.
     */
    @IBAction func openPrivacyPollicy(){
        if let url = URL(string: "https://www.rentalpropertydashboard.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
        
    }
    
    /**
     Opens link to Terms of Service.
     */
    @IBAction func openTermsOfService(){
        if let url = URL(string: "https://www.rentalpropertydashboard.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
        
    }
}

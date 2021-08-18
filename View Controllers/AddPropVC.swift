//
//  AddPropVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import IQKeyboardManagerSwift
//import DatePickerDialog
import Toast_Swift
import RSSelectionMenu
import DropDown

class AddPropVC: UIViewController, ExpandableViewDelegate {
    
    @IBOutlet weak var scroll_content_view_height: NSLayoutConstraint!
    @IBOutlet weak var st_address_text_field: CustomTextField!
    @IBOutlet weak var ct_address_text_field: CustomTextField!
    @IBOutlet weak var stt_address_text_field: CustomTextField!
    @IBOutlet weak var zip_code_text_field: CustomTextField!
    
    @IBOutlet weak var cash_invested_text_field: CurrencyTextField!
    @IBOutlet weak var purchase_amt_text_field: CurrencyTextField!
    @IBOutlet weak var purchase_date_text_field: CustomTextField!
    @IBOutlet weak var prop_type_label: BorderedLabel!
    @IBOutlet weak var profit_month_text_field: ProfitTextLabel!
    @IBOutlet weak var profit_annual_text_field: ProfitTextLabel!
    @IBOutlet weak var cap_rate_text_field: ProfitTextLabel!
    @IBOutlet weak var coc_text_field: ProfitTextLabel!
    @IBOutlet weak var grm_text_field: ProfitTextLabel!
    
    @IBOutlet weak var prop_unit_name_view: PropertyUnitNameView!
    @IBOutlet weak var prop_unit_name_field: CustomTextField!
    @IBOutlet weak var child_scroll_view: UIScrollView!
    @IBOutlet weak var child_scroll_view_page: UIPageControl!
    
    @IBOutlet weak var all_units_income_view: PropertyUnitNameView!
    @IBOutlet weak var all_units_month_income_field: ProfitTextLabel!
    @IBOutlet weak var all_units_annual_income_field: ProfitTextLabel!
    
    @IBOutlet weak var all_units_expenses_view: PropertyUnitNameView!
    @IBOutlet weak var all_units_expense_month_total_lbl: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_total_lbl: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_ins_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_ins_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_prot_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_prot_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_mtg_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_mtg_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_vac_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_vac_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_repair_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_repair_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_prom_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_prom_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_util_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_util_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_hoa_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_hoa_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_month_other_field: CurrencyTextField!
    @IBOutlet weak var all_units_expense_annual_other_field: CurrencyTextField!
    
    var purchased_date: Date!
        
    var current_child_index = 0
    
    let dbRef = Database.database().reference()
    
    /**
     Set up hierarchical relationships for fields
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cash_invested_text_field.addTarget(self, action: #selector(didChangedCashInvestedValue), for: .editingChanged)
        
        purchase_amt_text_field.addTarget(self, action: #selector(didChangedPurchaseValue), for: .editingChanged)
        prop_type_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPropTypeField)))
        purchase_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPurchaseDateField(_:))))
        
        child_scroll_view.delegate = self
        child_scroll_view.isScrollEnabled = false
        
        let rsw = UISwipeGestureRecognizer(target: self, action: #selector(didScrollViewSwiped(_:)))
        rsw.direction = .right
        child_scroll_view.addGestureRecognizer(rsw)
        
        let rsw1 = UISwipeGestureRecognizer(target: self, action: #selector(didScrollViewSwiped(_:)))
        rsw1.direction = .right
        all_units_expenses_view.addGestureRecognizer(rsw1)
        
        let lsw = UISwipeGestureRecognizer(target: self, action: #selector(didScrollViewSwiped(_:)))
        lsw.direction = .left
        child_scroll_view.addGestureRecognizer(lsw)
        
        let lsw1 = UISwipeGestureRecognizer(target: self, action: #selector(didScrollViewSwiped(_:)))
        lsw1.direction = .left
        all_units_expenses_view.addGestureRecognizer(lsw1)
        
        prop_unit_name_view.collapseSelf()
        prop_unit_name_view.delegate = self
        
        all_units_income_view.delegate = self
        all_units_income_view.collapseSelf()
        
        all_units_expenses_view.delegate = self
        all_units_expenses_view.collapseSelf()
        
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PropUnitVC.storyboard_id) as? PropUnitVC
        vc?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1510)
        self.addChild(vc!)
        self.child_scroll_view.addSubview((vc?.view)!)
        vc?.didMove(toParent: self)
        vc?.updateUnitDeleteButtonVisibility(false)
        
        prop_unit_name_field.addTarget(self, action: #selector(didChangedUnitNameValue), for: .editingDidEnd)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didCurrencyUpdated), name: Notification.Name("currency"), object: nil)
    }
    
    /**
       Removes the notification observer on exit
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Config for gesture recognizer using delegate protocol
     - Parameters:
        - gestureRecognizer: gesture recognizer to modify
        - otherGestureRecognizer: recognizer to recognize with simulataneously
     - Returns: True. enabling the recognizer to be triggered alongside the other one
     */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /**
     Allows the scroll view to be swiped between child views
     - Parameter sender: UISwipeGestureRecognizer on the view
     - Note: Called via a selector
     */
    @objc func didScrollViewSwiped(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            if current_child_index > 0 {
                current_child_index -= 1
                var frame: CGRect = self.child_scroll_view.frame
                frame.origin.x = frame.size.width * CGFloat(current_child_index)
                frame.origin.y = 0
                self.child_scroll_view.scrollRectToVisible(frame, animated: true)
                
                if let vc = self.children[current_child_index] as? PropUnitVC {
                    
                    self.prop_unit_name_field.text = vc.unit_name
                    
                    self.scroll_content_view_height.constant = 570 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
                    
                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vc.calculateViewsHeight() )
                }
            }
        }
        
        if sender.direction == .left {
            if current_child_index < self.children.count && (current_child_index + 1) < self.children.count {
                current_child_index += 1
                var frame: CGRect = self.child_scroll_view.frame
                frame.origin.x = frame.size.width * CGFloat(current_child_index)
                frame.origin.y = 0
                self.child_scroll_view.scrollRectToVisible(frame, animated: true)
                
                if let vc = self.children[current_child_index] as? PropUnitVC {
                    
                    self.prop_unit_name_field.text = vc.unit_name
                    
                    self.scroll_content_view_height.constant = 570 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
                    
                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vc.calculateViewsHeight() )
                }
            }
        }
        
        child_scroll_view_page.currentPage = current_child_index
    }
    
    /**
     Expand the view by a given amount, laying it out again as needed
     - Parameters:
        - expand: true if the view was expande, false if it was contracted
        - value: value which dictates how much to expand the view
     */
    func didExpandedChanged(expand: Bool, value: CGFloat) {
        if expand {
            self.scroll_content_view_height.constant = self.scroll_content_view_height.constant + value
        } else {
            self.scroll_content_view_height.constant = self.scroll_content_view_height.constant - value
        }
        
        self.view.layoutIfNeeded()
        
        if current_child_index < self.children.count {
            if let vc = self.children[current_child_index] as? PropUnitVC {
                child_scroll_view.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: vc.calculateViewsHeight())
            }
        }
    }
    
    /**
     - Returns: an add property view controller
    */
    class func getController() -> AddPropVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: AddPropVC.storyboard_id) as! AddPropVC
    }
    
    /**
     Updates currency based text fields using helper funcs
     - Note: called via a selector
     */
    @objc func didCurrencyUpdated() {
        cash_invested_text_field.updateTextValue()
        purchase_amt_text_field.updateTextValue()
                        
        profit_month_text_field.formatTextValue()
        profit_annual_text_field.formatTextValue()
        coc_text_field.formatTextValue()
        grm_text_field.formatTextValue()
        
        all_units_month_income_field.formatTextValue()
        all_units_annual_income_field.formatTextValue()
        
        for v in self.children {
            if let vc = v as? PropUnitVC {
                vc.updateTextValues()
            }
        }
    }
    
    /**
     Allows user to select date
     - Note: Called via selector
     */
    @objc func didPressedPurchaseDateField(_ sender: CustomTextField) {
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
     Allow user to select property type
     */
    @objc func didPressedPropTypeField() {
        let drop = DropDown(anchorView: prop_type_label)
        drop.dataSource = ["Single Family", "Condo/Townhome", "Multi-Family Prop", "Commercial", "Other"]
        drop.selectionAction = { (index: Int, item: String) in
            
            if index == 2 {
                self.prop_type_label.text = item
                self.prop_type_label.superview?.viewWithTag(1223)?.isHidden = false
                
                self.prop_unit_name_view.expandSelf()
                self.all_units_income_view.expandSelf()
                self.all_units_expenses_view.expandSelf()
                
                if let v = self.children[self.current_child_index] as? PropUnitVC {
                    v.updateUnitDeleteButtonVisibility(true)
                }
            } else {
                self.prop_type_label.superview?.viewWithTag(1223)?.isHidden = true
                
                if self.children.count > 1 {
                    AlertBuilder().buildMessage(vc: self, message: "Please remove other Units manualy as \(item) Property type supports only Single Unit")
                } else {
                    if self.prop_unit_name_view.is_view_expanded {
                        self.prop_unit_name_view.collapseSelf()
                        
                        if let v = self.children[self.current_child_index] as? PropUnitVC {
                            v.updateUnitDeleteButtonVisibility(false)
                        }
                    }
                    
                    self.all_units_income_view.collapseSelf()
                    self.all_units_expenses_view.collapseSelf()
                    
                    self.prop_type_label.text = item
                }
            }
        }
        drop.show()
    }
    
    /**
     When the add unit button is pressed, instantiate and present a new VC to add a unit
     - Parameter sender: add unit button
     */
    @IBAction func didPressedAddUnitButton(_ sender: UIButton) {
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PropUnitVC.storyboard_id)
        vc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(self.children.count), y: 0, width: UIScreen.main.bounds.width, height: 1510)
        self.addChild(vc)
        self.child_scroll_view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        if current_child_index < self.children.count {
            if let vc = self.children[current_child_index] as? PropUnitVC {
                child_scroll_view.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: vc.calculateViewsHeight())
            }
        }
        
        child_scroll_view_page.numberOfPages += 1
    }
    
    /**
     When the remove unit button is pressed, instantiate and present a new VC to remove a unit
     - Parameter sender: remove unit button
     */
    @objc func didPressedRemoveUnitButton(_ sender: UIButton) {
        if let vc = self.children[current_child_index] as? PropUnitVC {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            
            if current_child_index == 0 {
                current_child_index = 0
                
                if let vvc = self.children[current_child_index] as? PropUnitVC {
                    self.scroll_content_view_height.constant = 570 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vvc.calculateViewsHeight()
                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vvc.calculateViewsHeight())
                    
                    vvc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1510)
                    
                    vvc.expandAllExpandables()
                    
                    self.prop_unit_name_field.text = vvc.unit_name
                }
                
                child_scroll_view.contentOffset.x = 0
                
                for i in current_child_index..<self.children.count {
                    if let vvc = self.children[i] as? PropUnitVC {
                        vvc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: 0, width: UIScreen.main.bounds.width, height: 1510)
                        vvc.expandAllExpandables()
                    }
                }
            } else {
                current_child_index = current_child_index - 1
                
                if let vvc = self.children[current_child_index] as? PropUnitVC {
                    self.scroll_content_view_height.constant = 570 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vvc.calculateViewsHeight()
                    child_scroll_view.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: vvc.calculateViewsHeight())
                    
                    self.prop_unit_name_field.text = vvc.unit_name
                }
                
                child_scroll_view.contentOffset.x = child_scroll_view.frame.width * CGFloat(current_child_index)
                
                for i in current_child_index..<self.children.count {
                    if let vvc = self.children[i] as? PropUnitVC {
                        vvc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: 0, width: UIScreen.main.bounds.width, height: 1510)
                        vvc.expandAllExpandables()
                    }
                }
            }
            
            child_scroll_view_page.numberOfPages = self.children.count
            child_scroll_view_page.currentPage = current_child_index
        }
    }
    
    /**
     Cancel input, first warning the user that all values will be reset
     - Parameter sender: cancel button
     */
    @IBAction func didPressedCancelButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to reset all values?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: { (ac) in
            self.clearEditables()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Validate all input, send it to the backend to be stored
     - Parameter sender: save button
     */
    @IBAction func didPressedSaveButton(_ sender: UIButton) {
       
        if st_address_text_field.isInputValid() {
            if ct_address_text_field.isInputValid() {
                if stt_address_text_field.isInputValid() {
                    if zip_code_text_field.isInputValid() {
                        if purchase_amt_text_field.isInputValid() {
                            if purchase_date_text_field.isInputValid(), let date = purchased_date {
                                
                                let address = "\(st_address_text_field.text!)\n\(ct_address_text_field.text!), \(stt_address_text_field.text!)#\(zip_code_text_field.text!)"
                                var bool = false
                                for pr in MainVC.properties_list {
                                    if pr.address == address {
                                        bool = true
                                    }
                                }
                                
                                if bool {
                                    AlertBuilder().buildMessage(vc: self, message: "Address already found. Please enter a different address")
                                    return
                                }
                                
                                let key = dbRef.child("properties").childByAutoId().key
                                if let k = key {
                                    var units: [[String : Any]] = []
                                    for v in self.children {
                                        if let vc = v as? PropUnitVC {
                                            units.append(vc.getAllValues())
                                        }
                                    }
                                    let data = ["key": k,
                                                "user": Constants.mineId,
                                                "address": "\(st_address_text_field.text!)\n\(ct_address_text_field.text!), \(stt_address_text_field.text!)#\(zip_code_text_field.text!)",
                                        "purchase_date": Constants.getMillis(date),
                                        "purchase_amt": purchase_amt_text_field.value,
                                        "cash_invested": cash_invested_text_field.value,
                                        "prop_type": prop_type_label.text!,
                                        "property_status": (propertyType == .IOwn ? "IOwen" : "Research"),
                                        "millis": Constants.getCurrentMillis(),
                                        "units": units] as [String : Any]
                                    
                                    let hud = JGProgressHUD(style: .dark)
                                    hud.show(in: self.view)
                                    
                                    dbRef.child("properties").child(k).updateChildValues(data) { (err, ref) in
                                        hud.dismiss()
                                        if let e = err {
                                            AlertBuilder().buildMessage(vc: self, message: "Something went wrong...\nError: \(e.localizedDescription)")
                                            return
                                        }
                                        
                                        let alert = AlertBuilder()
                                        alert.buildMessageWithCallback(vc: self, message: "Property Added")
                                        alert.pressedOk = { () in
                                            self.clearEditables()
                                            
                                            var mod: PropertyModel?
                                            
                                            for md in MainVC.properties_list {
                                                if md.key == k {
                                                    mod = md
                                                }
                                            }
                                            
                                            if let m = mod {
                                                if let p = self.parent as? MainVC {
                                                    p.showPropertyDetails(m)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Clear/reset all input fields
     */
    func clearEditables() {
        st_address_text_field.clear()
        ct_address_text_field.clear()
        stt_address_text_field.clear()
        zip_code_text_field.clear()
        cash_invested_text_field.clear()
        purchase_amt_text_field.clear()
        purchase_date_text_field.clear()
        
        prop_type_label.text = "Single Family"
        prop_type_label.superview?.viewWithTag(1223)?.isHidden = true
                
        profit_month_text_field.clear()
        profit_annual_text_field.clear()
        cap_rate_text_field.clear()
        coc_text_field.clear()
        grm_text_field.clear()
        
        all_units_month_income_field.clear()
        all_units_annual_income_field.clear()
        if self.all_units_income_view.is_view_expanded {
            self.all_units_income_view.collapseSelf()
        }
        
        all_units_expense_month_total_lbl.clear()
        all_units_expense_annual_total_lbl.clear()
        all_units_expense_month_ins_field.clear()
        all_units_expense_annual_ins_field.clear()
        all_units_expense_month_prot_field.clear()
        all_units_expense_annual_prot_field.clear()
        all_units_expense_month_mtg_field.clear()
        all_units_expense_annual_mtg_field.clear()
        all_units_expense_month_vac_field.clear()
        all_units_expense_annual_vac_field.clear()
        all_units_expense_month_repair_field.clear()
        all_units_expense_annual_repair_field.clear()
        all_units_expense_month_prom_field.clear()
        all_units_expense_annual_prom_field.clear()
        all_units_expense_month_util_field.clear()
        all_units_expense_annual_util_field.clear()
        all_units_expense_month_hoa_field.clear()
        all_units_expense_annual_hoa_field.clear()
        all_units_expense_month_other_field.clear()
        all_units_expense_annual_other_field.clear()
        if self.all_units_expenses_view.is_view_expanded {
            self.all_units_expenses_view.collapseSelf()
        }
        
        self.child_scroll_view.subviews.forEach({$0.removeFromSuperview()})
        for v in self.children {
            if let vc = v as? PropUnitVC {
                vc.removeFromParent()
                vc.didMove(toParent: nil)
            }
        }
        
        current_child_index = 0
        child_scroll_view_page.numberOfPages = 1
        if self.prop_unit_name_view.is_view_expanded {
            self.prop_unit_name_view.collapseSelf()
        }
        
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PropUnitVC.storyboard_id) as? PropUnitVC
        vc?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1510)
        self.addChild(vc!)
        self.child_scroll_view.addSubview((vc?.view)!)
        vc?.didMove(toParent: self)
        vc?.updateUnitDeleteButtonVisibility(false)
        
        self.scroll_content_view_height.constant = 500 + (vc?.calculateViewsHeight() ?? 0)
    }
    
    /**
     Update the unit name in the corresponding VC
     */
    @objc func didChangedUnitNameValue() {
        if current_child_index < self.children.count {
            if let vc = self.children[current_child_index] as? PropUnitVC {
                vc.unit_name = prop_unit_name_field.text ?? ""
            }
        }
    }
}

extension AddPropVC : UIScrollViewDelegate {
    /**
     Set the new child index based off where the view finished dragging
     */
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        if index < self.children.count {
            if index != current_child_index {
                current_child_index = index
                
                child_scroll_view_page.currentPage = current_child_index
                
                if let vc = self.children[index] as? PropUnitVC {
                    
                    self.prop_unit_name_field.text = vc.unit_name
                    
                    self.scroll_content_view_height.constant = 570 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
                    
                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vc.calculateViewsHeight() )
                }
            }
        }
    }
}

extension AddPropVC {
    /**
     Update child view controllers when the purchase price changes
     */
    @objc func didChangedPurchaseValue() {
        let price = purchase_amt_text_field.value

        for v in self.children {
            if let vc = v as? PropUnitVC {
                vc.mtg_purchase_amt_text_field.formatTextValue(price)
            }
        }
        
        updateProfitLabels()
    }
    
    /**
     Update profit if the amount of cash invested changes
     */
    @objc func didChangedCashInvestedValue() {
        updateProfitLabels()
    }
    
    /**
     Recalculate and update profit fields
     */
    func updateProfitLabels() {
        var monthly_income = 0.0
        var annual_income = 0.0
        
        var monthly_expenses = 0.0
        var annual_expenses = 0.0
        
        let price = purchase_amt_text_field.value

        all_units_expense_month_total_lbl.clear()
        all_units_expense_annual_total_lbl.clear()
        
        all_units_expense_month_ins_field.clear()
        all_units_expense_annual_ins_field.clear()
        all_units_expense_month_prot_field.clear()
        all_units_expense_annual_prot_field.clear()
        all_units_expense_month_mtg_field.clear()
        all_units_expense_annual_mtg_field.clear()
        all_units_expense_month_vac_field.clear()
        all_units_expense_annual_vac_field.clear()
        all_units_expense_month_repair_field.clear()
        all_units_expense_annual_repair_field.clear()
        all_units_expense_month_prom_field.clear()
        all_units_expense_annual_prom_field.clear()
        all_units_expense_month_util_field.clear()
        all_units_expense_annual_util_field.clear()
        all_units_expense_month_hoa_field.clear()
        all_units_expense_annual_hoa_field.clear()
        all_units_expense_month_other_field.clear()
        all_units_expense_annual_other_field.clear()
        
        for v in self.children {
            if let vc = v as? PropUnitVC {
                monthly_income += vc.month_income_value
                annual_income += vc.annual_income_value
                
                monthly_expenses += vc.calcMonthExpenses()
                annual_expenses += vc.calcAnnualExpenses()
                                
                all_units_expense_month_total_lbl.incrementValue(vc.calcMonthExpenses())
                all_units_expense_annual_total_lbl.incrementValue(vc.calcAnnualExpenses())
                
                all_units_expense_month_ins_field.incrementValue(vc.expense_month_ins_field.value)
                all_units_expense_annual_ins_field.incrementValue(vc.expense_annual_ins_field.value)
                all_units_expense_month_prot_field.incrementValue(vc.expense_month_prot_field.value)
                all_units_expense_annual_prot_field.incrementValue(vc.expense_annual_prot_field.value)
                all_units_expense_month_mtg_field.incrementValue(vc.expense_month_mtg_field.value)
                all_units_expense_annual_mtg_field.incrementValue(vc.expense_annual_mtg_field.value)
                all_units_expense_month_vac_field.incrementValue(vc.expense_month_vac_field.value)
                all_units_expense_annual_vac_field.incrementValue(vc.expense_annual_vac_field.value)
                all_units_expense_month_repair_field.incrementValue(vc.expense_month_repair_field.value)
                all_units_expense_annual_repair_field.incrementValue(vc.expense_annual_repair_field.value)
                all_units_expense_month_prom_field.incrementValue(vc.expense_month_prom_field.value)
                all_units_expense_annual_prom_field.incrementValue(vc.expense_annual_prom_field.value)
                all_units_expense_month_util_field.incrementValue(vc.expense_month_util_field.value)
                all_units_expense_annual_util_field.incrementValue(vc.expense_annual_util_field.value)
                all_units_expense_month_hoa_field.incrementValue(vc.expense_month_hoa_field.value)
                all_units_expense_annual_hoa_field.incrementValue(vc.expense_annual_hoa_field.value)
                all_units_expense_month_other_field.incrementValue(vc.expense_month_other_field.value)
                all_units_expense_annual_other_field.incrementValue(vc.expense_annual_other_field.value)
            }
        }
        
        all_units_month_income_field.value = monthly_income
        all_units_annual_income_field.value = annual_income
        
        let monthly = monthly_income - monthly_expenses
        profit_month_text_field.value = monthly
        
        let annually = annual_income - annual_expenses
        profit_annual_text_field.value = annually
        
        let cap = ((annual_income - annual_expenses) / price) * 100
        cap_rate_text_field.value = cap
        
        // 5958
        //let cost = getTotalCost()
        //totalCost.value = cost
        
        let coc = annually / cash_invested_text_field.value
        coc_text_field.value = coc
        
        let grm = price / annual_income
        grm_text_field.value = grm
    }
}

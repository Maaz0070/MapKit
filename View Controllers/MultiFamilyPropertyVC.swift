//
//  PropertyVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import JGProgressHUD
import Firebase
import RSSelectionMenu
//import DatePickerDialog
import DropDown
import GooglePlaces
import ScrollableSegmentedControl
class MultiFamilyPropertyVC: UIViewController, ExpandableViewDelegate {
    @IBOutlet weak var segmentedControl: ScrollableSegmentedControl!
    @IBOutlet weak var removeSegmentButton: UIBarButtonItem!
    @IBOutlet weak var fixedWidthSwitch: UISwitch!
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    
    let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                   NSAttributedString.Key.foregroundColor: UIColor.red]
    let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                            NSAttributedString.Key.foregroundColor: UIColor.blue]
    let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                         NSAttributedString.Key.foregroundColor: UIColor.orange]
    
    
    
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
    @IBOutlet weak var add_multi_unit_vc_button: BorderedButton!
    @IBOutlet weak var child_scroll_view: UIScrollView!
    @IBOutlet weak var scroll_view: UIScrollView!

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
    @IBOutlet weak var all_units_monthly_net_operating_income_label: ProfitTextLabel!
    @IBOutlet weak var all_units_annual_net_operating_income_label: ProfitTextLabel!
    
    @IBOutlet weak var edit_button: UIButton!
    @IBOutlet weak var change_button: UIButton!
    @IBOutlet weak var delete_button: WrapButton!
    let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PropUnitVC.storyboard_id) as? PropUnitVC
    var purchased_date: Date!
    
    var current_child_index = 0
    
    let dbRef = Database.database().reference()
    
    var selected_model: PropertyModel!
    var view_read_view: Bool = false
    
    /**
    Disable editing on view appearance
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disableEditables(true)
    }
    
    /**
     Setup recognizers and targets
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        disableEditables(false)
       
        self.prop_type_label.textColor = UIColor.black
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
        prop_unit_name_field.addTarget(self, action: #selector(didChangedUnitNameValue), for: .editingDidEnd)
        
        all_units_income_view.delegate = self
        all_units_income_view.collapseSelf()
        
        all_units_expenses_view.delegate = self
        all_units_expenses_view.collapseSelf()
        
        edit_button.addTarget(self, action: #selector(didPressedEditButton), for: .touchUpInside)
        change_button.addTarget(self, action: #selector(didPressedChangePropButton), for: .touchUpInside)
        delete_button.addTarget(self, action: #selector(didPressedDeleteButton(_:)), for: .touchUpInside)
        
        prop_type_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPropTypeField)))
        
        purchase_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPurchaseDateField(_:))))
        st_address_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStreetAddressTextField(_:))))
        cash_invested_text_field.addTarget(self, action: #selector(didChangedCashInvestedValue), for: .editingChanged)
        
        purchase_amt_text_field.addTarget(self, action: #selector(didChangedPurchaseValue), for: .editingChanged)
        
        
        
    }
    
    /**
     Add segments to the control
     Not sure why the titles are what they are
     - Note: This function is not used and could be deleted
     */
    func addSegment(){
        segmentedControl.segmentStyle = .textOnly
        segmentedControl.insertSegment(withTitle: "Segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "S 2", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "Segment 3.0001", image: nil, at: 2)
        segmentedControl.insertSegment(withTitle: "Seg 4", image: nil, at: 3)
        segmentedControl.insertSegment(withTitle: "Segment 5", image: nil, at: 4)
        segmentedControl.insertSegment(withTitle: "Segment 6", image: nil, at: 5)
//        segmentedControl.underlineHeight = 3.0
        
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 0
        //fixedWidthSwitch.isOn = false
//        segmentedControl.fixedSegmentWidth = fixedWidthSwitch.isOn
        
        segmentedControl.addTarget(self, action: #selector(MultiFamilyPropertyVC.segmentSelected(sender:)), for: .valueChanged)
    }
    
    /**
     Testing function, can be deleted alongside its caller, addSegment()
     */
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
    }
    
    /**
     Initialize property model using parameters passed in
     */
    func initPropertyData(_ model: PropertyModel, _ read: Bool) {
        self.selected_model = model
        self.view_read_view = read
       
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
                    
                    //                    self.scroll_content_view_height.constant = 650 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
                    let subview_height:CGFloat = (prop_unit_name_view.is_view_expanded ? 80 : 10) + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + (view_read_view ? 0 : 50)
                    
//                    self.scroll_content_view_height.constant = 535 + subview_height + vc.calculateViewsHeight()
                    
//                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: 1300 )
//                    scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: 1500 )
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
                    
                    //                    self.scroll_content_view_height.constant = 650 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
//                    let subview_height:CGFloat = (prop_unit_name_view.is_view_expanded ? 80 : 10) + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + (view_read_view ? 0 : 50)
                    
//                    self.scroll_content_view_height.constant = 535 + subview_height + vc.calculateViewsHeight()
                    
//                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vc.calculateViewsHeight() )
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
//        if expand {
//            self.scroll_content_view_height.constant = self.scroll_content_view_height.constant + value
//        } else {
//            self.scroll_content_view_height.constant = self.scroll_content_view_height.constant - value
//        }
        
        self.view.layoutIfNeeded()
        
        if current_child_index < self.children.count {
            if let vc = self.children[current_child_index] as? PropUnitVC {
                child_scroll_view.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: vc.calculateViewsHeight())
            }
        }
    }
    
    /**
     Set the edit state of the editable fields in a view to the given state by changing the state of all of it's subviews to match the provided state
     - Parameters:
        - view: view to edit (we'll get its subviews recursively)
        - bool: the new editable state
     */
    func disableEditables(_ bool: Bool) {
        
        let subviews = [/*st_address_text_field, ct_address_text_field, stt_address_text_field, zip_code_text_field,*/ purchase_amt_text_field, cash_invested_text_field, purchase_date_text_field, prop_type_label, prop_unit_name_field, add_multi_unit_vc_button]
        
        for subview in subviews {
        
            let color: UIColor = view_read_view ?  .lightGray : .primary
            
            if let s = subview as? UITextField {
                if s.tag != 1212 {
                    s.isEnabled = bool
                    
                }
                
                if let c = s as? CurrencyTextField {
                    c.borderColor = color
                   
                        c.borderWidth = 1
                    
                }
                
                if let c = s as? CustomTextField {
                    c.borderColor = color
                   
                        c.borderWidth = 1
                    
                }
            }
            
            if let s = subview as? BorderedLabel {
                s.isUserInteractionEnabled = bool
                
                s.borderColor = color
             
                    s.borderWidth = 1
                
            }
            
            if let s = subview as? BorderedButton {
                s.isHidden = !bool
                
                    s.borderWidth = 1
                
//                if prop_unit_name_view.is_view_expanded {
//                    self.prop_type_label.superview?.viewWithTag(1223)?.isHidden = false
//                } else {
//                    self.prop_type_label.superview?.viewWithTag(1223)?.isHidden = true
//                }
                
                s.borderColor = color
            }
        }
        if self.view_read_view == true{
        vc?.isEdit = false
        }else{
            vc?.isEdit = bool
        }
//        if bool == true{
//            self.cash_invested_text_field.borderWidth = 1
//            self.profit_month_text_field.borderWidth = 1
//            self.profit_annual_text_field.borderWidth = 1
//            self.cap_rate_text_field.borderWidth = 1
//            self.grm_text_field.borderWidth = 1
//            self.coc_text_field.borderWidth = 1
//            self.prop_type_label.borderWidth = 1
//
//        }else{
//            self.cash_invested_text_field.borderWidth = 0
//            self.profit_month_text_field.borderWidth = 0
//            self.profit_annual_text_field.borderWidth = 0
//            self.cap_rate_text_field.borderWidth = 0
//            self.grm_text_field.borderWidth = 0
//            self.coc_text_field.borderWidth = 0
//            self.prop_type_label.borderWidth = 0
//        }
        
    }
    
    /**
     Updates views on main view appearance
     */
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
        
        //        if MainVC.properties_list.count == 0 {
        //            let v = PaddingLabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        //            v.backgroundColor = .white
        //            v.text = #"Click the "Add Prop" icon to add your first property"#
        //            v.textColor = .darkText
        //            v.numberOfLines = 0
        //            v.leftInset = 80
        //            v.rightInset = 80
        //            v.textAlignment = .center
        //            if let font = UIFont(name: "SFProDisplay-Medium", size: 18) {
        //                v.font = font
        //            }
        //            v.tag = 2312
        //            self.view.addSubview(v)
        //        } else {
        //            if let v = self.view.viewWithTag(2312) {
        //                v.removeFromSuperview()
        //            }
        //        }
    }
    
    /**
     Update the view presented to the user based on the most recent data
     */
    func updateViews() {
        self.scroll_content_view_height.constant =  view_read_view == true ? 2650 : 2900 //

        if let model = selected_model {
//            disableEditables(false)
            disableEditables(true)

            if view_read_view {
                edit_button.setTitle(String(model.likes), for: .normal)
                edit_button.setImage(UIImage(systemName: model.liked ? "heart.fill" : "heart"), for: .normal)
                edit_button.tintColor = #colorLiteral(red: 0.8901960784, green: 0.1490196078, blue: 0.2117647059, alpha: 1)
                edit_button.tag = -1

                delete_button.height = 0
                edit_button.isHidden =  false
            } else {
                edit_button.isHidden = true
                edit_button.setTitle("Edit", for: .normal)
                edit_button.setImage(nil, for: .normal)
                edit_button.tintColor = .primary
                edit_button.tag = 0

                delete_button.height = 50
            }
            
            change_button.setImage(UIImage(systemName: "arrow.left.circle"), for: .normal)
            change_button.setTitle("", for: .normal)
            change_button.tag = 0
            
            if let s_index = model.address.indexOf(target: "\n") {
                let street = model.address.subString(to: s_index)
                
                if let c_index = model.address.indexOf(target: ",") {
                    let city = model.address.subStringRange(from: s_index + 1, to: c_index).trimmingCharacters(in: .whitespaces)
                    if let st_index = model.address.indexOf(target: "#") {
                        if view_read_view {
                            st_address_text_field.placeholder = "City"
                            st_address_text_field.text = city
                            ct_address_text_field.superview?.isHidden = true
                        } else {
                            st_address_text_field.placeholder = "Street Address"
                            st_address_text_field.text = street
                            ct_address_text_field.superview?.isHidden = false
                            ct_address_text_field.text = city
                        }
                        stt_address_text_field.text = model.address.subStringRange(from: c_index + 1, to: st_index).trimmingCharacters(in: .whitespaces)
                        zip_code_text_field.text = model.address.subStringRange(from: st_index + 1, to: model.address.count)
                    }
                }
            }
            
            cash_invested_text_field.formatTextValue(model.cash_invested)
            purchase_amt_text_field.formatTextValue(model.purchase_amt)
            
            if let date = Constants.buildDatefromMillis(millis: model.purchase_date) {
                purchase_date_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: date)
                self.purchased_date = date
            }
            
            prop_type_label.text = model.prop_type
//            prop_type_label.superview?.viewWithTag(1223)?.isHidden = true
//            if model.prop_type != "Multi-Family Prop" {
//                prop_unit_name_view.collapseSelf()
//                all_units_income_view.collapseSelf()
//                all_units_expenses_view.collapseSelf()
//            }
            
            for vc in self.children {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            
            for var unit in model.units {
            
                vc?.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(self.children.count), y: 0, width: UIScreen.main.bounds.width, height: 2300)
                self.addChild(vc!)
                self.child_scroll_view.addSubview(vc!.view)
                vc?.didMove(toParent: self)
                
//                vc?.disableEditables(false)
                vc?.disableEditables(true)

                if view_read_view {
                    unit.notes = ""
                    unit.unit_name = ""
                }
                vc?.updateViews(model: unit, purchase: model.purchase_amt, lease: view_read_view)
                vc?.updatePurchaseViews(model: model)
                
//                child_scroll_view.contentSize = CGSize(width: Int(UIScreen.main.bounds.width) * self.children.count, height: 2300)
//                scroll_view.contentSize = CGSize(width: Int(UIScreen.main.bounds.width) * self.children.count, height: 2000)

                child_scroll_view_page.numberOfPages = self.children.count
                
                let subview_height:CGFloat = (prop_unit_name_view.is_view_expanded ? 80 : 10) + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + (view_read_view ? 0 : 50)
                
//                self.scroll_content_view_height.constant = 535 + subview_height + (vc?.calculateViewsHeight() ?? 0)
//                self.scrollview
                
                if model.units.count == 1 {
                    vc?.updateUnitDeleteButtonVisibility(false)
                    if view_read_view {
                        vc?.hideNotesView()
                        self.delete_button.isHidden = true
                    }else{
                        if let v = vc?.notes_text_field.superview as? ExpandableView {
                            v.expandSelf()
                        }
                    
                        self.delete_button.isHidden = false
                    }
                } else {
                    if view_read_view {
                        vc?.updateUnitDeleteButtonVisibility(false)
                        vc?.hideNotesView()
                        self.delete_button.isHidden = true
                    }
                }
            }
            
            if model.prop_type == "Multi-Family Prop" {
                prop_unit_name_view.expandSelf()
                
                all_units_income_view.expandSelf()
                all_units_expenses_view.expandSelf()
                
                child_scroll_view_page.numberOfPages = self.children.count
                child_scroll_view_page.currentPage = current_child_index
                
                for vc in self.children {
                    if let v = vc as? PropUnitVC {
                        v.updateIncomeExpensesLabelHeading()
                    }
                }
            }
            
            if current_child_index < self.children.count {
                if let vc = self.children[current_child_index] as? PropUnitVC {
                    self.prop_unit_name_field.text = vc.unit_name
                }
            }
        } else {
            updateViewAfterDelete()
        }
    }
    
    /**
     - Returns: an MFP VC
    */
    class func getController() -> MultiFamilyPropertyVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: MultiFamilyPropertyVC.storyboard_id) as! MultiFamilyPropertyVC
    }
    
    /**
     Upon pressing the edit button, configures the view and validates input when entered as well as updating backend values such as likes and property values when edited through the PropUnitVC
     - Note: used in selector
     */
    @objc func didPressedEditButton() {
        if self.selected_model == nil {
            return
        }
        if edit_button.tag == -1 { //handle an update to the "like" status of a property
            let bool = !self.selected_model.liked
            Database.database().reference().child("properties").child(selected_model.key).child("likes").child(Constants.mineId).setValue(bool ? true : nil)
            selected_model.liked = bool
            let count = bool ? 1 : -1
            selected_model.likes += count
            edit_button.setImage(UIImage(systemName: bool ? "heart.fill" : "heart"), for: .normal)
            edit_button.setTitle(String(selected_model.likes), for: .normal)
        } else if edit_button.tag == 0 {
            disableEditables(true)
            for v in self.children {
                if let vc = v as? PropUnitVC {
                    vc.disableEditables(true)
                }
            }
            
            edit_button.setTitle("Save", for: .normal)
            edit_button.tag = 1
            
            change_button.setImage(nil, for: .normal)
            change_button.setTitle("Cancel", for: .normal)
            change_button.tag = 1
        } else {
            
            if st_address_text_field.isInputValid() {
                if ct_address_text_field.isInputValid() {
                    if stt_address_text_field.isInputValid() {
                        if zip_code_text_field.isInputValid() {
                            if purchase_amt_text_field.isInputValid() {
                                if purchase_date_text_field.isInputValid(), let date = purchased_date {
                                    let key = self.selected_model.key
                                    if !key.isEmpty {
                                        var units: [[String : Any]] = []
                                        for v in self.children {
                                            if let vc = v as? PropUnitVC {
//                                                vc.disableEditables(false)
                                                vc.disableEditables(true)
                                                units.append(vc.getAllValues())
                                            }
                                        }
                                        let data = ["key": key,
                                                    "user": Constants.mineId,
                                                    "address": "\(st_address_text_field.text!)\n\(ct_address_text_field.text!), \(stt_address_text_field.text!)#\(zip_code_text_field.text!)",
                                                    "purchase_date": Constants.getMillis(date),
                                                    "purchase_amt": purchase_amt_text_field.value,
                                                    "cash_invested": cash_invested_text_field.value,
                                                    "prop_type": prop_type_label.text!,
                                                    "property_status": (propertyType == .IOwn ? "IOwen" : "Research"),
                                                    "millis": self.selected_model.millis,
                                                    "units": units] as [String : Any]
                                        
                                        let hud = JGProgressHUD(style: .dark)
                                        hud.show(in: self.view)
                                        
                                        dbRef.child("properties").child(key).updateChildValues(data) { (err, ref) in
                                            hud.dismiss()
                                            if let e = err {
                                                AlertBuilder().buildMessage(vc: self, message: "Something went wrong...\nError: \(e.localizedDescription)")
                                                return
                                            }
                                            
                                            let alert = AlertBuilder()
                                            alert.buildMessageWithCallback(vc: self, message: "Property Updated")
                                            alert.pressedOk = { () in
//                                                self.disableEditables(false)
                                                self.disableEditables(true)
                                                    self.edit_button.isHidden = true
                                                self.edit_button.setTitle("Edit", for: .normal)
                                                self.edit_button.tag = 0
                                                
                                                self.change_button.setImage(UIImage(systemName: "arrow.left.circle"), for: .normal)
                                                self.change_button.setTitle("", for: .normal)
                                                self.change_button.tag = 0
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
                    
                    self.prop_unit_name_field.text = v.unit_name
                }
            } else {
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
     Change the property by appending an editing controller if editable
      - Note: Called via selector
     */
    @objc func didPressedChangePropButton() {
        if change_button.tag == 0 {
            if let p = self.parent as? MainVC {
                p.appendViewController(index: self.view_read_view ? 2 : 1)
            }
            
            //            var selected = [String]()
            //
            //            var titles: [String] {
            //                var t = [String]()
            //
            //                for tt in MainVC.properties_list {
            //                    t.append(tt.address.replacingOccurrences(of: "#", with: " "))
            //
            //                    if let model = MainVC.selected_property_model {
            //                        if model.address == tt.address {
            //                            selected.append(tt.address.replacingOccurrences(of: "#", with: " "))
            //                        }
            //                    }
            //                }
            //                return t
            //            }
            //
            //            let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: titles) { (cell, name, indexPath) in
            //                cell.textLabel?.text = name
            //            }
            //
            //            selectionMenu.setSelectedItems(items: selected) { (s, i, b, ss) in }
            //            selectionMenu.cellSelectionStyle = .checkbox
            //            selectionMenu.onDismiss = { (items) in
            //                for tt in MainVC.properties_list {
            //                    if let item = items.first {
            //                        if item == tt.address.replacingOccurrences(of: "#", with: " ") {
            //                            MainVC.selected_property_model = tt
            //
            //                            self.updateViews()
            //                        }
            //                    }
            //                }
            //            }
            //            selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
        } else {
//            disableEditables(false)
            self.disableEditables(true)

            for v in self.children {
                if let vc = v as? PropUnitVC {
//                    vc.disableEditables(false)
                    vc.disableEditables(true)
                }
            }
            edit_button.isHidden = true
            edit_button.setTitle("Edit", for: .normal)
            edit_button.tag = 0
            
            change_button.setImage(UIImage(systemName: "arrow.left.circle"), for: .normal)
            change_button.setTitle("", for: .normal)
            change_button.tag = 0
            
            updateViews()
        }
    }
    
    /**
     Add a new unit and corresponding child page view controller
     - Parameter sender: add unit button
     */
    @IBAction func didPressedAddUnitButton(_ sender: UIButton) {
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PropUnitVC.storyboard_id)
        vc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(self.children.count), y: 0, width: UIScreen.main.bounds.width, height: 1100)
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
     Modify the view depending on how many child views are left.
     - Postcondition: Number of pages and child index are updated reflect the unit being removed
     - Parameter sender: remove unit button
     - Note: called via selector
     */
    @objc func didPressedRemoveUnitButton(_ sender: UIButton) {
        if let vc = self.children[current_child_index] as? PropUnitVC {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            
            if current_child_index == 0 {
                current_child_index = 0
                
                if let vvc = self.children[current_child_index] as? PropUnitVC {
//                    self.scroll_content_view_height.constant = 650 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vvc.calculateViewsHeight()
                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vvc.calculateViewsHeight())
                    
                    vvc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1100)
                    
                    vvc.expandAllExpandables()
                    
                    self.prop_unit_name_field.text = vvc.unit_name
                }
                
                child_scroll_view.contentOffset.x = 0
                
                for i in current_child_index..<self.children.count {
                    if let vvc = self.children[i] as? PropUnitVC {
                        vvc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: 0, width: UIScreen.main.bounds.width, height: 1100)
                        vvc.expandAllExpandables()
                    }
                }
            } else {
                current_child_index = current_child_index - 1
                
                if let vvc = self.children[current_child_index] as? PropUnitVC {
//                    self.scroll_content_view_height.constant = 650 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vvc.calculateViewsHeight()
//                    child_scroll_view.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: vvc.calculateViewsHeight())
                    
                    self.prop_unit_name_field.text = vvc.unit_name
                }
                
                child_scroll_view.contentOffset.x = child_scroll_view.frame.width * CGFloat(current_child_index)
                
                for i in current_child_index..<self.children.count {
                    if let vvc = self.children[i] as? PropUnitVC {
                        vvc.view.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: 0, width: UIScreen.main.bounds.width, height: 1100)
                        vvc.expandAllExpandables()
                    }
                }
            }
            
            child_scroll_view_page.numberOfPages = self.children.count
            child_scroll_view_page.currentPage = current_child_index
        }
    }
    
    /**
     Delete the property from the database, first prompting the user with a confirmation alert
     - Note: this function does NOT update the view; this is done by updateViewAfterDelete()
     - Parameter sender: delete button
     */
    @objc func didPressedDeleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Property", message: "Are you sure you want to delete this property?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (ac) in
            if let model = self.selected_model {
                let hud = JGProgressHUD(style: .dark)
                hud.show(in: self.view)
                Database.database().reference().child("properties").child(model.key).child("deleted").setValue(true) { (err, ref) in
                    hud.dismiss()
                    
                    if let e = err {
                        AlertBuilder().buildMessage(vc: self, message: "Something went Wrong...\nError: \(e.localizedDescription)")
                        return
                    }
                    
                    if let p = self.parent as? MainVC {
                        p.appendViewController(index: 1)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Updates the view after a unit is deleted
     - Note: this function just lays out the view again, it does NOT do the backend work to delete the unit
     */
    func updateViewAfterDelete() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        v.backgroundColor = .white
        v.tag = 2313
        self.view.addSubview(v)
        
        //        let lbl = PaddingLabel(frame: CGRect(x: 0, y: (self.view.frame.height / 2) - 100, width: self.view.frame.width, height: 200))
        //        //        lbl.backgroundColor = .blue
        //        lbl.text = #"Click "Change Property" to view another property"#
        //        lbl.textColor = .darkText
        //        lbl.numberOfLines = 0
        //        lbl.leftInset = 80
        //        lbl.rightInset = 80
        //        lbl.textAlignment = .center
        //        if let font = UIFont(name: "SFProDisplay-Medium", size: 18) {
        //            lbl.font = font
        //        }
        //        v.addSubview(lbl)
        
        //        let btn = UIButton(frame: CGRect(x: 15, y: 10, width: 100, height: 40))
        //        btn.setTitle("Change Property", for: .normal)
        //        if let font = UIFont(name: "SFProDisplay-Medium", size: 16) {
        //            btn.titleLabel?.font = font
        //        }
        //        btn.titleLabel?.lineBreakMode = .byWordWrapping
        //        btn.setTitleColor(#colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1), for: .normal)
        //        btn.addTarget(self, action: #selector(didPressedChangePropertyAfterButton), for: .touchUpInside)
        //        v.addSubview(btn)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: self.view.frame.width - 40, height: 40)
        
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
        v.addSubview(collection)
        collection.backgroundColor = .white
        
        collection.register(PropertyCell.self, forCellWithReuseIdentifier: PropertyCell.identifier)
        //        collection.delegate = self
        //        collection.dataSource = self
    }
    
    /**
     Allow the user to change the property being viewed via a dropdown menu
     - Note: called via selector
     */
    @objc func didPressedChangePropertyAfterButton() {
        var titles: [String] {
            var t = [String]()
            
            for tt in MainVC.properties_list {
                t.append(tt.address.replacingOccurrences(of: "#", with: " "))
            }
            return t
        }
        
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            for tt in MainVC.properties_list {
                if let item = items.first {
                    if item == tt.address.replacingOccurrences(of: "#", with: " ") {
                        self.selected_model = tt
                        
                        if let v = self.view.viewWithTag(2313) {
                            v.removeFromSuperview()
                        }
                        
                        self.updateViews()
                    }
                }
            }
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
    }
    
    /**
     When the unit name field is edited, update the unit name in the VC instance as well
     - Note: called via selector
     */
    @objc func didChangedUnitNameValue() {
        if current_child_index < self.children.count {
            if let vc = self.children[current_child_index] as? PropUnitVC {
                vc.unit_name = prop_unit_name_field.text ?? ""
            }
        }
    }
    //editing
    
    /**
     Show the GPlaces autocomplete controller when editing the address field
     - Parameter sender: custom address text field
     - Note: called via selector
     */
    @objc func didPressedStreetAddressTextField(_ sender: CustomTextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    /**
     Show the Date Picker when the purchase date field is pressed
     - Parameter sender: date text field
     - Note: called via selector
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
}

extension MultiFamilyPropertyVC : GMSAutocompleteViewControllerDelegate {
    /**
     Clear and then update the text fields in the current VC from the auto complete controller
     - Note: route and street number are not stored
     - Parameters:
        - viewController: Google Places Autocomplete VC
        - place: GooglePlaces object returned by user autocomplete selection, can be broken into components to store data
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
     Handle autocomplete error
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    /**
     Animated dismiss on cancellation
     */
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MultiFamilyPropertyVC : UIScrollViewDelegate {
    /**
     Set the current child index based on where the user stops scrolling and better align the scroll view
     */
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        if index < self.children.count {
            if index != current_child_index {
                current_child_index = index
                
                child_scroll_view_page.currentPage = current_child_index
                
                if let vc = self.children[index] as? PropUnitVC {
                    
                    self.prop_unit_name_field.text = vc.unit_name
                    
//                    self.scroll_content_view_height.constant = 650 + (all_units_income_view.is_view_expanded ? 120 : 0) + (all_units_expenses_view.is_view_expanded ? 650 : 0) + vc.calculateViewsHeight()
                    
//                    child_scroll_view.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.children.count), height: vc.calculateViewsHeight())
                }
            }
        }
    }
}

extension MultiFamilyPropertyVC {
    /**
     Calculate the totaly monthly expenses by adding up relevant values in the model
     - Parameter model: model from which to source data
     */
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
    
    /**
     Calculate the totaly annual expenses by adding up relevant values in the model
     - Parameter model: model from which to source data
     */
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
    
    /**
     Calculate the total annual NOI expenses by adding up relevant values in the model
     - Parameter model: model from which to source data
     */
    func calcNOIAnnualExpenses(_ model: PropertyModel) -> Double {
        var amt = 0.0
        
        for unit in model.units {
            amt = amt + unit.annual_ins
            amt = amt + unit.annual_prot
            amt = amt + unit.annual_vac
            amt = amt + unit.annual_repair
            amt = amt + unit.annual_prom
            amt = amt + unit.annual_util
            amt = amt + unit.annual_hoa
        }
        return amt
    }
    
    /**
     Update labels upon changing purchase value
     - Note: called via selector when the field is edited
     */
    @objc func didChangedPurchaseValue() {
        updateProfitLabels()
    }
    
    /**
     Update labels upon changing purchase value
     - Note: called via selector when the field is edited
     */
    @objc func didChangedCashInvestedValue() {
        updateProfitLabels()
    }
    
    /**
     Update all fields with the proper values
     - Postcondition: all fields have values reflecting most recent data entered
     */
    @objc func updateProfitLabels() {
        var monthly_income = 0.0
        var annual_income = 0.0
        var NOIexpenses = 0.0
        
        var monthly_expenses = 0.0
        var annual_expenses = 0.0
        
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
                NOIexpenses += vc.calcNOIAnnualExpenses()
                
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
        
        let price = purchase_amt_text_field.value
        
        let tempNOI = annual_income - NOIexpenses
        
        all_units_annual_net_operating_income_label.value = tempNOI
        all_units_monthly_net_operating_income_label.value = tempNOI/12
        //Old CAP Rate Formula
//        let cap = ((annual_income - annual_expenses) / price) * 100
//        cap_rate_text_field.value = cap
        
        let cap = (tempNOI / price) * 100
        cap_rate_text_field.value =  cap //selected_model.capRate() //
        
        let coc = annually / cash_invested_text_field.value
        coc_text_field.value = coc * 100
        
        let grm = price / annual_income
        grm_text_field.value = grm
    }
}

extension MultiFamilyPropertyVC : UICollectionViewDelegate, UICollectionViewDataSource {
    /**
     Return the number of items in the section using the number of properties in the list
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainVC.properties_list.count
    }
    
    /**
     Handle item selection in the collectio view
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selected_model = MainVC.properties_list[indexPath.item]
        
        if let v = self.view.viewWithTag(2313) {
            v.removeFromSuperview()
        }
        
        self.updateViews()
    }
    
    /**
     Return the cell for a given indexPath in the collection view
     - Returns: a single cell object found at that indexPath
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCell.identifier, for: indexPath) as? PropertyCell {
            let model = MainVC.properties_list[indexPath.item]
            
            cell.prop_view.text_label.text = model.address.replacingOccurrences(of: "#", with: " ").replacingOccurrences(of: "\n", with: " ")
            
            return cell
        }
        return UICollectionViewCell()
    }
}

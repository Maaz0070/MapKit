//
//  PropUnitVC.swift
//  RealEstate
//
//  Created by CodeGradients on 04/08/2020.
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

class PropUnitVC: UIViewController, ExpandableViewDelegate {
    
    //    @IBOutlet weak var scroll_content_view_height: NSLayoutConstraint!
    
    @IBOutlet weak var bedroom_text_button: BorderedButton!
    @IBOutlet weak var bathroom_text_field: BorderedButton!
    @IBOutlet weak var square_feet_text_field: BorderedButton!
    @IBOutlet weak var rent_terms_text_button: BorderedButton!
    @IBOutlet weak var loan_bal_text_button: CurrencyTextField!
    
    //    @IBOutlet weak var unit_income_label: UILabel!
    //    @IBOutlet weak var unit_expenses_label: UILabel!
    @IBOutlet weak var market_val_text_field: CurrencyTextField!
    @IBOutlet weak var equity_val_text_field: CurrencyTextField!
    @IBOutlet weak var equity_perct_text_field: CurrencyTextField!
    @IBOutlet weak var loan_bal_text_field: CurrencyTextField!
    @IBOutlet weak var total_expenses_month_text_field: CurrencyTextField!
    @IBOutlet weak var total_expenses_annual_text_field: CurrencyTextField!
    @IBOutlet weak var total_non_expenses_month_text_field: CurrencyTextField!
    @IBOutlet weak var total_non_expenses_annual_text_field: CurrencyTextField!
    @IBOutlet weak var income_month_text_field: CurrencyTextField!
    @IBOutlet weak var income_annual_text_field: CurrencyTextField!
    @IBOutlet weak var income_stdate_text_field: CustomTextField!
    @IBOutlet weak var income_endate_text_field: CustomTextField!
    @IBOutlet weak var rent_date_text_field: CustomTextField!
    @IBOutlet weak var start_lease_button: UIButton!
    @IBOutlet weak var expense_month_total_lbl: CurrencyTextField!
    @IBOutlet weak var expense_annual_total_lbl: CurrencyTextField!
    @IBOutlet weak var expense_month_ins_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_ins_field: CurrencyTextField!
    @IBOutlet weak var expense_month_prot_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_prot_field: CurrencyTextField!
    @IBOutlet weak var expense_month_mtg_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_mtg_field: CurrencyTextField!
    @IBOutlet weak var expense_month_vac_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_vac_field: CurrencyTextField!
    @IBOutlet weak var expense_month_repair_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_repair_field: CurrencyTextField!
    @IBOutlet weak var expense_month_prom_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_prom_field: CurrencyTextField!
    @IBOutlet weak var expense_month_util_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_util_field: CurrencyTextField!
    @IBOutlet weak var expense_month_hoa_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_hoa_field: CurrencyTextField!
    @IBOutlet weak var expense_month_other_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_other_field: CurrencyTextField!
    @IBOutlet weak var notes_text_field: KMPlaceholderTextView!
    
    @IBOutlet weak var nonOperatingeXpense_month_capex_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_capex_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_month_other_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_mtg_payment_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_month_mtg_payment_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_other_field: CurrencyTextField!
    @IBOutlet weak var cash_invested_text_field: CurrencyTextField!
    @IBOutlet weak var down_payment_text_field: CurrencyTextField!
    @IBOutlet weak var closing_cost_text_field: CurrencyTextField!
    @IBOutlet weak var initial_rehab_cost_text_field: CurrencyTextField!
    @IBOutlet weak var purchase_amt_text_field: CurrencyTextField!
    @IBOutlet weak var purchase_date_lbl: UILabel!
    @IBOutlet weak var purchase_date_text_field: CustomTextField!
    @IBOutlet weak var prop_type_label: BorderedLabel!
    var purchased_date: Date!
    
    @IBOutlet weak var mtg_purchase_amt_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_down_payment_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_insurance_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_interest_rate_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_loan_term_button: BorderedButton!
    
    @IBOutlet weak var notesViewHtConstraint : NSLayoutConstraint!
    
    /**
     Var which tracks the editing state; sets the UI colors and enabled actions depending on the value using Swift's observable pattern
     - Postcondition: UI is configured correctly for the current state
     */
    public var isEdit: Bool?{
        didSet{
            
            if isEdit == true {
                guard  income_month_text_field != nil else {
                    return
                }
                loan_bal_text_field.borderWidth = 1
                loan_bal_text_field.borderColor = .blue
                loan_bal_text_field.isEnabled = true
                bedroom_text_button.borderWidth = 1
                bedroom_text_button.borderColor = .blue
                bedroom_text_button.isEnabled = true
                bathroom_text_field.borderWidth = 1
                bathroom_text_field.borderColor = .blue
                bathroom_text_field.isEnabled = true
                square_feet_text_field.borderWidth = 1
                square_feet_text_field.borderColor = .blue
                square_feet_text_field.isEnabled = true
                rent_terms_text_button.borderWidth = 1
                rent_terms_text_button.borderColor = .blue
                rent_terms_text_button.isUserInteractionEnabled  = true
                income_month_text_field.borderWidth = 1
                income_month_text_field.borderColor = .blue
                income_month_text_field.isEnabled = true
                income_annual_text_field.borderWidth = 1
                income_annual_text_field.borderColor = .blue
                income_annual_text_field.isEnabled = true
                income_stdate_text_field.borderWidth = 1
                income_stdate_text_field.borderColor = .blue
                income_stdate_text_field.isEnabled = true
                loan_bal_text_button.borderWidth = 1
                loan_bal_text_button.borderColor = .blue
                loan_bal_text_button.isEnabled = true
                //                income_endate_text_field.borderWidth = 1
                rent_date_text_field.borderWidth = 1
                rent_date_text_field.borderColor = .blue
                rent_date_text_field.isEnabled = true
                //                expense_month_total_lbl.borderWidth = 1
                //                expense_annual_total_lbl.borderWidth = 1
                expense_month_ins_field.borderWidth = 1
                expense_month_ins_field.borderColor = .blue
                expense_month_ins_field.isEnabled = true
                expense_annual_ins_field.borderWidth = 1
                expense_annual_ins_field.borderColor = .blue
                expense_annual_ins_field.isEnabled = true
                expense_month_prot_field.borderWidth = 1
                expense_month_prot_field.borderColor = .blue
                expense_month_prot_field.isEnabled = true
                expense_annual_prot_field.borderWidth = 1
                expense_annual_prot_field.borderColor = .blue
                expense_annual_prot_field.isEnabled = true
                expense_month_mtg_field.borderWidth = 1
                expense_month_mtg_field.borderColor = .blue
                expense_month_mtg_field.isEnabled = true
                expense_annual_mtg_field.borderWidth = 1
                expense_annual_mtg_field.borderColor = .blue
                expense_annual_mtg_field.isEnabled = true
                expense_month_vac_field.borderWidth = 1
                expense_month_vac_field.borderColor = .blue
                expense_month_vac_field.isEnabled = true
                expense_annual_vac_field.borderWidth = 1
                expense_annual_vac_field.borderColor = .blue
                expense_annual_vac_field.isEnabled = true
                expense_month_repair_field.borderWidth = 1
                expense_month_repair_field.borderColor = .blue
                expense_month_repair_field.isEnabled = true
                expense_annual_repair_field.borderWidth = 1
                expense_annual_repair_field.borderColor = .blue
                expense_annual_repair_field.isEnabled = true
                expense_month_prom_field.borderWidth = 1
                expense_month_prom_field.borderColor = .blue
                expense_month_prom_field.isEnabled = true
                expense_annual_prom_field.borderWidth = 1
                expense_annual_prom_field.borderColor = .blue
                expense_annual_prom_field.isEnabled = true
                expense_month_util_field.borderWidth = 1
                expense_month_util_field.borderColor = .blue
                expense_month_util_field.isEnabled = true
                expense_annual_util_field.borderWidth = 1
                expense_annual_util_field.borderColor = .blue
                expense_annual_util_field.isEnabled = true
                expense_month_hoa_field.borderWidth = 1
                expense_month_hoa_field.borderColor = .blue
                expense_month_hoa_field.isEnabled = true
                expense_annual_hoa_field.borderWidth = 1
                expense_annual_hoa_field.borderColor = .blue
                expense_annual_hoa_field.isEnabled = true
                expense_month_other_field.borderWidth = 1
                expense_month_other_field.borderColor = .blue
                expense_month_other_field.isEnabled = true
                
                
                expense_month_hoa_field.borderWidth = 1
                expense_month_hoa_field.borderColor = .blue
                expense_month_hoa_field.isEnabled = true
                expense_annual_hoa_field.borderWidth = 1
                expense_annual_hoa_field.borderColor = .blue
                expense_annual_hoa_field.isEnabled = true
                expense_month_other_field.borderWidth = 1
                expense_month_other_field.borderColor = .blue
                expense_month_other_field.isEnabled = true
                expense_annual_other_field.borderWidth = 1
                expense_annual_other_field.borderColor = .blue
                expense_annual_other_field.isEnabled = true
                notes_text_field.borderWidth = 1
                notes_text_field.borderColor = .blue
//                notesViewHtConstraint.constant = 150.0
                nonOperatingeXpense_month_capex_field.borderWidth = 1
                nonOperatingeXpense_month_capex_field.borderColor = .blue
                nonOperatingeXpense_month_capex_field.isEnabled = true
                nonOperatingeXpense_annual_capex_field.borderWidth = 1
                nonOperatingeXpense_annual_capex_field.borderColor = .blue
                nonOperatingeXpense_annual_capex_field.isEnabled = true
                nonOperatingeXpense_month_other_field.borderWidth = 1
                nonOperatingeXpense_month_other_field.borderColor = .blue
                nonOperatingeXpense_month_other_field.isEnabled = true
                nonOperatingeXpense_annual_other_field.borderWidth = 1
                nonOperatingeXpense_annual_other_field.borderColor = .blue
                nonOperatingeXpense_annual_other_field.isEnabled = true
                cash_invested_text_field.borderWidth = 0
                cash_invested_text_field.borderColor = .blue
                cash_invested_text_field.isEnabled = true
                down_payment_text_field.borderWidth = 1
                down_payment_text_field.borderColor = .blue
                down_payment_text_field.isEnabled = true
                closing_cost_text_field.borderWidth = 1
                closing_cost_text_field.borderColor = .blue
                closing_cost_text_field.isEnabled = true
                initial_rehab_cost_text_field.borderWidth = 1
                initial_rehab_cost_text_field.borderColor = .blue
                initial_rehab_cost_text_field.isEnabled = true
                purchase_amt_text_field.borderWidth = 1
                purchase_amt_text_field.borderColor = .blue
                purchase_amt_text_field.isEnabled = true
                purchase_date_text_field.borderWidth = 1
                purchase_date_text_field.borderColor = .blue
                purchase_date_text_field.isEnabled = true
                prop_type_label.borderWidth = 1
                prop_type_label.borderColor = .blue
                prop_type_label.isUserInteractionEnabled = true
                
                mtg_purchase_amt_text_field.borderWidth = 1
                mtg_purchase_amt_text_field.borderColor = .blue
                mtg_purchase_amt_text_field.isEnabled = true
                mtg_down_payment_text_field.borderWidth = 1
                mtg_down_payment_text_field.borderColor = .blue
                mtg_down_payment_text_field.isEnabled = true
                mtg_insurance_text_field.borderWidth = 0
                mtg_insurance_text_field.borderColor = .clear
                mtg_insurance_text_field.isEnabled = false
                mtg_interest_rate_text_field.borderWidth = 1
                mtg_interest_rate_text_field.borderColor = .blue
                mtg_interest_rate_text_field.isEnabled = true
            } else {
                guard  income_month_text_field != nil else {
                    return
                }
                loan_bal_text_field.borderWidth = 1
                loan_bal_text_field.borderColor = .black
                loan_bal_text_field.isEnabled = false
                bedroom_text_button.borderWidth = 1
                bedroom_text_button.borderColor = .black
                bedroom_text_button.isEnabled = false
                bathroom_text_field.borderWidth = 1
                bathroom_text_field.borderColor = .black
                bathroom_text_field.isEnabled = false
                square_feet_text_field.borderWidth = 1
                square_feet_text_field.borderColor = .black
                square_feet_text_field.isEnabled = false
                rent_terms_text_button.borderWidth = 1
                rent_terms_text_button.borderColor = .black
                rent_terms_text_button.isUserInteractionEnabled  = false
//                rent_terms_text_button.isEnabled = false
                income_month_text_field.borderWidth = 1
                income_month_text_field.borderColor = .black
                income_month_text_field.isEnabled = false
                income_annual_text_field.borderWidth = 1
                income_annual_text_field.borderColor = .black
                income_annual_text_field.isEnabled = false
                income_stdate_text_field.borderWidth = 1
                income_stdate_text_field.borderColor = .black
                income_stdate_text_field.isEnabled = false
                
                loan_bal_text_button.borderWidth = 1
                loan_bal_text_button.borderColor = .black
                loan_bal_text_button.isEnabled = false
                //                income_endate_text_field.borderWidth = 0
                rent_date_text_field.borderWidth = 1
                rent_date_text_field.borderColor = .black
                rent_date_text_field.isEnabled = false
//                expense_month_total_lbl.borderWidth = 1
//                expense_month_total_lbl.borderColor = .black
//                expense_month_total_lbl.isEnabled = false
//                expense_annual_total_lbl.borderWidth = 1
//                expense_annual_total_lbl.borderColor = .black
//                expense_annual_total_lbl.isEnabled = false
                expense_month_ins_field.borderWidth = 1
                expense_month_ins_field.borderColor = .black
                expense_month_ins_field.isEnabled = false
                expense_annual_ins_field.borderWidth = 1
                expense_annual_ins_field.borderColor = .black
                expense_annual_ins_field.isEnabled = false
                expense_month_prot_field.borderWidth = 1
                expense_month_prot_field.borderColor = .black
                expense_month_prot_field.isEnabled = false
                expense_annual_prot_field.borderWidth = 1
                expense_annual_prot_field.borderColor = .black
                expense_annual_prot_field.isEnabled = false
                expense_month_mtg_field.borderWidth = 1
                expense_month_mtg_field.borderColor = .black
                expense_month_mtg_field.isEnabled = false
                expense_annual_mtg_field.borderWidth = 1
                expense_annual_mtg_field.borderColor = .black
                expense_annual_mtg_field.isEnabled = false
                expense_month_vac_field.borderWidth = 1
                expense_month_vac_field.borderColor = .black
                expense_month_vac_field.isEnabled = false
                expense_annual_vac_field.borderWidth = 1
                expense_annual_vac_field.borderColor = .black
                expense_annual_vac_field.isEnabled = false
                expense_month_repair_field.borderWidth = 1
                expense_month_repair_field.borderColor = .black
                expense_month_repair_field.isEnabled = false
                expense_annual_repair_field.borderWidth = 1
                expense_annual_repair_field.borderColor = .black
                expense_annual_repair_field.isEnabled = false
                expense_month_prom_field.borderWidth = 1
                expense_month_prom_field.borderColor = .black
                expense_month_prom_field.isEnabled = false
                expense_annual_prom_field.borderWidth = 1
                expense_annual_prom_field.borderColor = .black
                expense_annual_prom_field.isEnabled = false
                expense_month_util_field.borderWidth = 1
                expense_month_util_field.borderColor = .black
                expense_month_util_field.isEnabled = false
                expense_annual_util_field.borderWidth = 1
                expense_annual_util_field.borderColor = .black
                expense_annual_util_field.isEnabled = false
                expense_month_hoa_field.borderWidth = 1
                expense_month_hoa_field.borderColor = .black
                expense_month_hoa_field.isEnabled = false
                expense_annual_hoa_field.borderWidth = 1
                expense_annual_hoa_field.borderColor = .black
                expense_annual_hoa_field.isEnabled = false
                expense_month_other_field.borderWidth = 1
                expense_month_other_field.borderColor = .black
                expense_month_other_field.isEnabled = false
                expense_annual_other_field.borderWidth = 1
                expense_annual_other_field.borderColor = .black
                expense_annual_other_field.isEnabled = false
                expense_month_hoa_field.borderWidth = 1
                expense_month_hoa_field.borderColor = .black
                expense_month_hoa_field.isEnabled = false
                expense_annual_hoa_field.borderWidth = 1
                expense_annual_hoa_field.borderColor = .black
                expense_annual_hoa_field.isEnabled = false
                expense_month_other_field.borderWidth = 1
                expense_month_other_field.borderColor = .black
                expense_month_other_field.isEnabled = false
                expense_annual_other_field.borderWidth = 1
                expense_annual_other_field.borderColor = .black
                expense_annual_other_field.isEnabled = false
                notes_text_field.borderWidth = 1
                notes_text_field.borderColor = .black
//                notesViewHtConstraint.constant = 0
                nonOperatingeXpense_month_capex_field.borderWidth = 1
                nonOperatingeXpense_month_capex_field.borderColor = .black
                nonOperatingeXpense_month_capex_field.isEnabled = false
                nonOperatingeXpense_annual_capex_field.borderWidth = 1
                nonOperatingeXpense_annual_capex_field.borderColor = .black
                nonOperatingeXpense_annual_capex_field.isEnabled = false
                nonOperatingeXpense_month_other_field.borderWidth = 1
                nonOperatingeXpense_month_other_field.borderColor = .black
                nonOperatingeXpense_month_other_field.isEnabled = false
                nonOperatingeXpense_annual_other_field.borderWidth = 1
                nonOperatingeXpense_annual_other_field.borderColor = .black
                nonOperatingeXpense_annual_other_field.isEnabled = false
                
                cash_invested_text_field.borderWidth = 0
                cash_invested_text_field.borderColor = .black
                cash_invested_text_field.isEnabled = false
                down_payment_text_field.borderWidth = 1
                down_payment_text_field.borderColor = .black
                down_payment_text_field.isEnabled = false
                closing_cost_text_field.borderWidth = 1
                closing_cost_text_field.borderColor = .black
                closing_cost_text_field.isEnabled = false
                initial_rehab_cost_text_field.borderWidth = 1
                initial_rehab_cost_text_field.borderColor = .black
                initial_rehab_cost_text_field.isEnabled = false
                purchase_amt_text_field.borderWidth = 1
                purchase_amt_text_field.borderColor = .black
                purchase_amt_text_field.isEnabled = false
                purchase_date_text_field.borderWidth = 1
                purchase_date_text_field.borderColor = .black
                purchase_date_text_field.isEnabled = false
                prop_type_label.borderWidth = 1
                prop_type_label.borderColor = .black
                prop_type_label.isUserInteractionEnabled = false
                
                mtg_purchase_amt_text_field.borderWidth = 1
                mtg_purchase_amt_text_field.borderColor = .black
                mtg_purchase_amt_text_field.isEnabled = false
                mtg_down_payment_text_field.borderWidth = 1
                mtg_down_payment_text_field.borderColor = .black
                mtg_down_payment_text_field.isEnabled = false
                mtg_insurance_text_field.borderWidth = 0
                mtg_insurance_text_field.borderColor = .clear
                mtg_insurance_text_field.isEnabled = false
                mtg_interest_rate_text_field.borderWidth = 1
                mtg_interest_rate_text_field.borderColor = .black
                mtg_interest_rate_text_field.isEnabled = false
                mtg_loan_term_button.borderWidth = 1
                mtg_loan_term_button.borderColor = .black
                mtg_loan_term_button.isEnabled = false
                
                
                
                
            }
            
        }
    }
    //    @IBOutlet weak var unit_delete_button: BorderedButton!
    
    var unit_name = ""
    var unit_key = ""
    var income_start_date: Date!
    var income_end_date: Date!
    
    var month_income_value: Double = 0.0
    var annual_income_value: Double = 0.0
    var mtg_purchase_amount_value: Double = 0.0
    
    var rent_roll_list = [RentRollModel]()
    
    /**
     Setup UI and make calculations
     - Note: this is done after the view is loaded
     - Parameter animated: bool of whether to animate the appearance animation
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mtg_down_payment_text_field.tag = 1211
        self.updateTextValues()
        updateMonthAnnualExpenses()
        calculate_mortgage_value()
    }
    
    /**
     Configure UI interaction
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchase_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPurchaseDateField(_:))))
        
        bedroom_text_button.addTarget(self, action: #selector(didPressedBedRoomField(_:)), for: .touchUpInside)
        bathroom_text_field.addTarget(self, action: #selector(didPressedBathRoomField(_:)), for: .touchUpInside)
        square_feet_text_field.addTarget(self, action: #selector(didPressedSquareFeetField(_:)), for: .touchUpInside)
        
//        income_month_text_field.addTarget(self, action: #selector(didChangedIncomeMonthValue), for: .editingChanged)
//        income_annual_text_field.addTarget(self, action: #selector(didChangedIncomeAnnualValue), for: .editingChanged)
        
        expense_month_ins_field.addTarget(self, action: #selector(didChangedInsMonthValue), for: .editingChanged)
        expense_annual_ins_field.addTarget(self, action: #selector(didChangedInsAnnualValue), for: .editingChanged)
        
        expense_month_prot_field.addTarget(self, action: #selector(didChangedProTaxMonthValue), for: .editingChanged)
        expense_annual_prot_field.addTarget(self, action: #selector(didChangedProTaxAnnualValue), for: .editingChanged)
        
        expense_month_mtg_field.addTarget(self, action: #selector(didChangedMTGMonthValue), for: .editingChanged)
        expense_annual_mtg_field.addTarget(self, action: #selector(didChangedMTGAnnualValue), for: .editingChanged)
        expense_month_mtg_field.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didScrollToMortgageView)))
        expense_annual_mtg_field.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didScrollToMortgageView)))
        
        expense_month_vac_field.addTarget(self, action: #selector(didChangedVACMonthValue), for: .editingChanged)
        expense_annual_vac_field.addTarget(self, action: #selector(didChangedVACAnnualValue), for: .editingChanged)
        
        expense_month_repair_field.addTarget(self, action: #selector(didChangedRepairMonthValue), for: .editingChanged)
        expense_annual_repair_field.addTarget(self, action: #selector(didChangedRepairAnnualValue), for: .editingChanged)
        
        expense_month_prom_field.addTarget(self, action: #selector(didChangedPropMonthValue), for: .editingChanged)
        expense_annual_prom_field.addTarget(self, action: #selector(didChangedPropAnnualValue), for: .editingChanged)
        
        expense_month_util_field.addTarget(self, action: #selector(didChangedUtilMonthValue), for: .editingChanged)
        expense_annual_util_field.addTarget(self, action: #selector(didChangedUtilAnnualValue), for: .editingChanged)
        
        expense_month_hoa_field.addTarget(self, action: #selector(didChangedHoaMonthValue), for: .editingChanged)
        expense_annual_hoa_field.addTarget(self, action: #selector(didChangedHoaAnnualValue), for: .editingChanged)
        
        nonOperatingeXpense_month_other_field.addTarget(self, action: #selector(didChangedNonOperatingOtherMonthValue), for: .editingChanged)
        nonOperatingeXpense_annual_other_field.addTarget(self, action: #selector(didChangedNonOperatingOtherAnnualValue), for: .editingChanged)
        
        expense_month_other_field.addTarget(self, action: #selector(didChangedOtherMonthValue), for: .editingChanged)
        expense_annual_other_field.addTarget(self, action: #selector(didChangedOtherAnnualValue), for: .editingChanged)
        
        nonOperatingeXpense_month_capex_field.addTarget(self, action: #selector(didChangedCapitalExpendituresMonthValue), for: .editingChanged)
        nonOperatingeXpense_annual_capex_field.addTarget(self, action: #selector(didChangedCapitalExpendituresAnnualValue), for: .editingChanged)
        
        
        income_stdate_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeStartDateField(_:))))
//                income_endate_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeEndDateField(_:))))
        rent_date_text_field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedIncomeRentDateField(_:))))
        
//        if let v = income_month_text_field.superview?.superview?.superview?.superview as? ExpandableView {
//            v.delegate = self
//        }
        
        if let v = expense_month_ins_field.superview?.superview?.superview?.superview as? ExpandableView {
            v.delegate = self
        }
        
        if let v = notes_text_field.superview as? ExpandableView {
            v.delegate = self
        }
        
        if let v = mtg_purchase_amt_text_field.superview?.superview?.superview?.superview as? ExpandableView {
            v.delegate = self
        }
        
        mtg_purchase_amt_text_field.addTarget(self, action: #selector(calculate_mortgage_value), for: .editingChanged)
        mtg_down_payment_text_field.addTarget(self, action: #selector(calculate_mortgage_value), for: .editingChanged)
        mtg_interest_rate_text_field.addTarget(self, action: #selector(calculate_mortgage_value), for: .editingChanged)
        mtg_loan_term_button.addTarget(self, action: #selector(didPressedMtgLoanTermButton(_:)), for: .touchUpInside)
        
        //        unit_delete_button.addTarget(self, action: #selector(didPressedDeleteUnitButton(_:)), for: .touchUpInside)
        
        start_lease_button.addTarget(self, action: #selector(didPressedStartLeaseButton(_:)), for: .touchUpInside)
        
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
    
    /**
     Handle the view being expanded and shrunk by a certain amount
    - Parameters:
        - expand: true if the view is expanded; false if the view is shrunk
        - value: amount by which the view size is changed (CGFloat)
     */
    func didExpandedChanged(expand: Bool, value: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            //            if expand {
            //                self.scroll_content_view_height.constant = self.scroll_content_view_height.constant + value
            //            } else {
            //                self.scroll_content_view_height.constant = self.scroll_content_view_height.constant - value
            //            }
            self.view.layoutIfNeeded()
        }
        
        if let p = self.parent as? AddPropVC {
            p.didExpandedChanged(expand: expand, value: value)
        }
        
        if let p = self.parent as? PropertyVC {
            p.didExpandedChanged(expand: expand, value: value)
        }
    }
    
    /**
     To show the delete button, expand the view by calling the appropriate function
     */
    func updateUnitDeleteButtonVisibility(_ visible: Bool) {
        //        unit_delete_button.isHidden = !visible
        didExpandedChanged(expand: visible, value: 80)
    }
    
    /**
     Collapse the notes view
     */
    func hideNotesView() {
        if let v = notes_text_field.superview as? ExpandableView {
            v.collapseSelfAll()
        }
    }
    
    /**
     Not used!
     */
    func updateIncomeExpensesLabelHeading() {
        //        unit_income_label.text = "UNIT INCOME"
        //        unit_expenses_label.text = "UNIT EXPENSES"
    }
    
    /**
     Iterating through the subviews, expand the ones that are members of ExpandableSubview
     */
    func expandAllExpandables() {
        if let vv = self.view.viewWithTag(1212) {
            for view in vv.subviews {
                if let v = view as? ExpandableView {
                    v.expandSelf()
                }
            }
        }
    }
    
    /**
     Ask the user for confirmation of deleting a unit if they have 1 or more units
     Actually deleting the unit is passed off to didPressedRemoveUnitButton()
     */
    @objc func didPressedDeleteUnitButton(_ sender: UIButton) {
        if let p = self.parent as? AddPropVC {
            if p.children.count > 1 {
                let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this Unit? You won't be able to undo this, and all your data will be lost.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (ac) in
                    p.didPressedRemoveUnitButton(sender)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.parent?.view.makeToast("Minimum of 1 Unit is required", position: .bottom)
            }
        }
        
        if let p = self.parent as? PropertyVC {
            if p.children.count > 1 {
                let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this Unit? You won't be able to undo this, and all your data will be lost.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (ac) in
                    p.didPressedRemoveUnitButton(sender)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.parent?.view.makeToast("Minimum of 1 Unit is required", position: .bottom)
            }
        }
    }
    
    /**
     Calculate the view height by iterating through and counting non-hidden views
     */
    func calculateViewsHeight() -> CGFloat {
        var height: CGFloat = 100
        
        if let vv = self.view.viewWithTag(1212) {
            for view in vv.subviews {
                if let v = view as? ExpandableView {
                    //                    if v.is_view_expanded {
                    //                        height += v.height
                    //                    } else {
                    //                        height += v.basic_height
                    //                    }
                    height += v.intrinsicHeight
                } else if view is UIButton {
                    if !view.isHidden {
                        height += 65
                    }
                } else {
                    height += 80
                }
            }
        }
        
        return height
    }
    
    /**
     Setup the view to see the mortage
     */
    @objc func didScrollToMortgageView() {
        if let p = self.parent as? AddPropVC {
            if let v = p.view.viewWithTag(1211) as? UIScrollView {
                v.scrollToBottom(animated: true)
                
                if let vv = mtg_purchase_amt_text_field.superview?.superview?.superview?.superview as? ExpandableView {
                    vv.backgroundColor = .primary
                    UIView.animate(withDuration: 4.0) {
                        vv.backgroundColor = .white
                    }
                }
            }
        }
        
        if let p = self.parent as? PropertyVC {
            if let v = p.view.viewWithTag(1211) as? UIScrollView {
                v.scrollToBottom(animated: true)
                
                if let vv = mtg_purchase_amt_text_field.superview?.superview?.superview?.superview as? ExpandableView {
                    vv.backgroundColor = .primary
                    UIView.animate(withDuration: 4.0) {
                        vv.backgroundColor = .white
                    }
                }
            }
        }
    }
    
    //working
    /**
     Show the menu that lets you set the number of bedrooms
     */
    @objc func didPressedBedRoomField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of bedrooms", options: Constants.getBedRoomsDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
        }
    }
    
    /**
     Show the menu that lets you set the number of bathrooms
     */
    @objc func didPressedBathRoomField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of bathrooms", options: Constants.getBathRoomsDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
        }
    }
    
    /**
     Show the menu that lets you set the # of square feet
     */
    @objc func didPressedSquareFeetField(_ sender: UIButton) {
        PickerDialog().show(title: "Select number of square feets", options: Constants.getSquareFeetDataList(), selected: sender.tag) { (v, i) in
            sender.setTitle(v, for: .normal)
            sender.tag = i
        }
    }
    
    /**
     Lets you select the income start date via a custom text field
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
     Lets you select the income end date via a custom text field
     */
    @IBAction func didPressedIncomeEndDateField(_ sender: UIButton) {
        
        //    @objc func didPressedIncomeEndDateField(_ sender: CustomTextField) {
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
     Lets you select the rent due date via a custom text field
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
    
    /**
     Allow the user to start a new lease on the property; gives confirmation first
     */
    @objc func didPressedStartLeaseButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "START NEW LEASE", message: "Starting a new lease will clear all entries in 'INCOME'. Entries in Rent Roll will stay as-is. Are you sure you want to START NEW LEASE?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (ac) in
            if let p = self.parent as? PropertyVC {
                if let model = p.selected_model {
                    if !self.unit_key.isEmpty {
                        let data = ["rent_month": 0.0, "rent_annual": 0.0, "rent_start": "", "rent_end": "", "rent_day": 1] as [String : Any]
                        
                        let hud = JGProgressHUD(style: .dark)
                        hud.show(in: self.view)
                        
                        Database.database().reference().child("properties").child(model.key).child("units").child(self.unit_key).updateChildValues(data) { (err, ref) in
                            hud.dismiss()
                            
                            if let er = err {
                                AlertBuilder().buildMessage(vc: self, message: "Something went wrong.\nError: \(er)")
                                return
                            }
                            
                            self.income_month_text_field.clear()
                            self.income_annual_text_field.clear()
                            
                            self.income_stdate_text_field.clear()
                            self.income_start_date = nil
                            
                            //                            self.income_endate_text_field.clear()
                            self.income_end_date = nil
                            
                            self.rent_date_text_field.tag = 1
                            self.rent_date_text_field.text = 1.ordinal + " of the Month"
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (ac) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Let the user set the loan term from a drop-down
     */
    @objc func didPressedMtgLoanTermButton(_ sender: UIButton) {
        let drop = DropDown(anchorView: sender)
        drop.dataSource = ["10 Years", "15 Years", "30 Years"]
        drop.selectionAction = { (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            var tag: Int {
                if index == 1 {
                    return 15
                }
                
                if index == 2 {
                    return 30
                }
                
                return 10
            }
            sender.tag = tag
            
            self.calculate_mortgage_value()
        }
        drop.show()
    }
    
}

/**
 Updates relevant fields and calculations when values are entered
 */
extension PropUnitVC {
    /**
     Not used!
     */
    func updateMonthAnnualIncomeValues() {
//        month_income_value = income_month_text_field.value
//        annual_income_value = income_annual_text_field.value
    }
    
    /**
     Update all relevant fields when the monthly income changes
     */
    @objc func didChangedIncomeMonthValue() {
        let number = income_month_text_field.value
        income_annual_text_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualIncomeValues()
        
        if let p = self.parent as? AddPropVC {
            p.updateProfitLabels()
        }
        
        if let p = self.parent as? PropertyVC {
            p.updateProfitLabels()
        }
    }
    
    /**
     Update all relevant fields when the annual income changes
     */
    @objc func didChangedIncomeAnnualValue() {
        let number = income_annual_text_field.value
        income_month_text_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualIncomeValues()
        
        if let p = self.parent as? AddPropVC {
            p.updateProfitLabels()
        }
        
        if let p = self.parent as? PropertyVC {
            p.updateProfitLabels()
        }
    }
    
    /**
     Update expenses
     */
    func updateMonthAnnualExpenses() {
        //        expense_month_total_lbl.value = calcMonthExpenses()
        //        expense_month_total_lbl.formatTextValue(expense_month_total_lbl.value)
        expense_month_total_lbl.formatTextValue(calcMonthExpenses())
        expense_annual_total_lbl.formatTextValue(calcAnnualExpenses())
        
        let totalForMonth = calcMonthExpenses() + calcNonOperationMonthExpenses() //nonOperatingeXpense_month_capex_field.value
        let totalForAnnual = calcAnnualExpenses() + calcNonOperationAnnualExpenses()
        
        total_expenses_month_text_field.formatTextValue(totalForMonth)
        total_expenses_annual_text_field.formatTextValue(totalForAnnual)
        //        total_expenses_month_text_field.text = (String(format: "%.2f",totalForMonth))
        //        total_expenses_annual_text_field.text = (String(format: "%.2f",totalForAnnual))
        
        if let p = self.parent as? AddPropVC {
            p.updateProfitLabels()
        }
        
        if let p = self.parent as? PropertyVC {
            p.updateProfitLabels()
        }
    }
    
    @objc func didChangedInsMonthValue() {
        let number = expense_month_ins_field.value
        expense_annual_ins_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedInsAnnualValue() {
        let number = expense_annual_ins_field.value
        expense_month_ins_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedCapitalExpendituresMonthValue() {
        let number = nonOperatingeXpense_month_capex_field.value
        nonOperatingeXpense_annual_capex_field.formatTextValue(number * 12.0)
    
        total_non_expenses_month_text_field.formatTextValue( nonOperatingeXpense_month_capex_field.value + nonOperatingeXpense_month_other_field.value + nonOperatingeXpense_month_mtg_payment_field.value)
        
        total_non_expenses_annual_text_field.formatTextValue(nonOperatingeXpense_annual_capex_field.value + nonOperatingeXpense_annual_other_field.value + nonOperatingeXpense_annual_mtg_payment_field.value)
        
        let totalForMonth = calcMonthExpenses() + total_non_expenses_month_text_field.value
        let totalForAnnual = calcAnnualExpenses() + total_non_expenses_annual_text_field.value
        total_expenses_month_text_field.formatTextValue(totalForMonth) //text = (String(format: "%.2f",totalForMonth))
        total_expenses_annual_text_field.formatTextValue(totalForAnnual)  //text = (String(format: "%.2f",totalForAnnual))
    }
    
    @objc func didChangedCapitalExpendituresAnnualValue() {
        let number = nonOperatingeXpense_annual_capex_field.value
        nonOperatingeXpense_month_capex_field.formatTextValue(number / 12.0)
        
//        total_non_expenses_month_text_field.value = calcNonOperationMonthExpenses()
//        total_non_expenses_annual_text_field.value = calcNonOperationAnnualExpenses()
        
        total_non_expenses_month_text_field.formatTextValue( nonOperatingeXpense_month_capex_field.value + nonOperatingeXpense_month_other_field.value + nonOperatingeXpense_month_mtg_payment_field.value)
        
        total_non_expenses_annual_text_field.formatTextValue(nonOperatingeXpense_annual_capex_field.value + nonOperatingeXpense_annual_other_field.value + nonOperatingeXpense_annual_mtg_payment_field.value)
        
        let totalForMonth = calcMonthExpenses() + total_non_expenses_month_text_field.value
        let totalForAnnual = calcAnnualExpenses() + total_non_expenses_annual_text_field.value
        total_expenses_month_text_field.formatTextValue(totalForMonth) //text = (String(format: "%.2f",totalForMonth))
        total_expenses_annual_text_field.formatTextValue(totalForAnnual)
        
        
        
        //text = (String(format: "%.2f",totalForAnnual))
//        let totalForMonth = calcMonthExpenses() + nonOperatingeXpense_month_capex_field.value
//        let totalForAnnual = calcAnnualExpenses() + nonOperatingeXpense_annual_capex_field.value
//        total_expenses_month_text_field.text = (String(format: "%.2f",totalForMonth))
//        total_expenses_annual_text_field.text = (String(format: "%.2f",totalForAnnual))
        
    }
    
    
    @objc func didChangedProTaxMonthValue() {
        let number = expense_month_prot_field.value
        expense_annual_prot_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedProTaxAnnualValue() {
        let number = expense_annual_prot_field.value
        expense_month_prot_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedMTGMonthValue() {
        let number = expense_month_mtg_field.value
        expense_annual_mtg_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedMTGAnnualValue() {
        let number = expense_annual_mtg_field.value
        expense_month_mtg_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedVACMonthValue() {
        let number = expense_month_vac_field.value
        expense_annual_vac_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedVACAnnualValue() {
        let number = expense_annual_vac_field.value
        expense_month_vac_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedRepairMonthValue() {
        let number = expense_month_repair_field.value
        expense_annual_repair_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedRepairAnnualValue() {
        let number = expense_annual_repair_field.value
        expense_month_repair_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedPropMonthValue() {
        let number = expense_month_prom_field.value
        expense_annual_prom_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedPropAnnualValue() {
        let number = expense_annual_prom_field.value
        expense_month_prom_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedUtilMonthValue() {
        let number = expense_month_util_field.value
        expense_annual_util_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedUtilAnnualValue() {
        let number = expense_annual_util_field.value
        expense_month_util_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedHoaMonthValue() {
        let number = expense_month_hoa_field.value
        expense_annual_hoa_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedHoaAnnualValue() {
        let number = expense_annual_hoa_field.value
        expense_month_hoa_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    
    @objc func didChangedOtherMonthValue() {
        let number = expense_month_other_field.value
        expense_annual_other_field.formatTextValue(number * 12.0)
        
        updateMonthAnnualExpenses()
    }
    @objc func didChangedOtherAnnualValue() {
        let number = expense_annual_other_field.value
        expense_month_other_field.formatTextValue(number / 12.0)
        
        updateMonthAnnualExpenses()
    }
    
    @objc func didChangedNonOperatingOtherMonthValue() {
        let number = nonOperatingeXpense_month_other_field.value  //+ nonOperatingeXpense_month_capex_field.value + nonOperatingeXpense_month_mtg_payment_field.value
        nonOperatingeXpense_annual_other_field.formatTextValue(number * 12.0)
        
        total_non_expenses_month_text_field.formatTextValue( nonOperatingeXpense_month_capex_field.value + nonOperatingeXpense_month_other_field.value + nonOperatingeXpense_month_mtg_payment_field.value)
        
        total_non_expenses_annual_text_field.formatTextValue(nonOperatingeXpense_annual_capex_field.value + nonOperatingeXpense_annual_other_field.value + nonOperatingeXpense_annual_mtg_payment_field.value)
        
        let totalForMonth = calcMonthExpenses() + total_non_expenses_month_text_field.value
        let totalForAnnual = calcAnnualExpenses() + total_non_expenses_annual_text_field.value
        total_expenses_month_text_field.formatTextValue(totalForMonth) //text = (String(format: "%.2f",totalForMonth))
        total_expenses_annual_text_field.formatTextValue(totalForAnnual)

    }
    @objc func didChangedNonOperatingOtherAnnualValue() {
        let number = nonOperatingeXpense_annual_other_field.value
        nonOperatingeXpense_month_other_field.formatTextValue(number / 12.0)
        
        total_non_expenses_month_text_field.formatTextValue( nonOperatingeXpense_month_capex_field.value + nonOperatingeXpense_month_other_field.value + nonOperatingeXpense_month_mtg_payment_field.value)
        
        total_non_expenses_annual_text_field.formatTextValue(nonOperatingeXpense_annual_capex_field.value + nonOperatingeXpense_annual_other_field.value + nonOperatingeXpense_annual_mtg_payment_field.value)
        
        let totalForMonth = calcMonthExpenses() + total_non_expenses_month_text_field.value
        let totalForAnnual = calcAnnualExpenses() + total_non_expenses_annual_text_field.value
        total_expenses_month_text_field.formatTextValue(totalForMonth) //text = (String(format: "%.2f",totalForMonth))
        total_expenses_annual_text_field.formatTextValue(totalForAnnual) //text = (String(format: "%.2f",totalForAnnual))
    }
    
    func calcNonOperationMonthExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + nonOperatingeXpense_month_capex_field.value
        amt = amt + nonOperatingeXpense_month_other_field.value
        amt = amt + nonOperatingeXpense_month_mtg_payment_field.value
        
        return amt
    }
    func calcNonOperationAnnualExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + nonOperatingeXpense_annual_capex_field.value
        amt = amt + nonOperatingeXpense_annual_other_field.value
//        amt = amt + expense_annual_mtg_field.value
        amt = amt + nonOperatingeXpense_annual_mtg_payment_field.value

        return amt
    }
    
    func calcMonthExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + expense_month_ins_field.value
        amt = amt + expense_month_prot_field.value
        amt = amt + expense_month_mtg_field.value
        amt = amt + expense_month_vac_field.value
        amt = amt + expense_month_repair_field.value
        amt = amt + expense_month_prom_field.value
        amt = amt + expense_month_util_field.value
        amt = amt + expense_month_hoa_field.value
        amt = amt + expense_month_other_field.value
        
        return amt
    }
    
    func calcAnnualExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + expense_annual_ins_field.value
        amt = amt + expense_annual_prot_field.value
        amt = amt + expense_annual_mtg_field.value
        amt = amt + expense_annual_vac_field.value
        amt = amt + expense_annual_repair_field.value
        amt = amt + expense_annual_prom_field.value
        amt = amt + expense_annual_util_field.value
        amt = amt + expense_annual_hoa_field.value
        amt = amt + expense_annual_other_field.value
        
        
        
        return amt
    }
    
    func calcRent() -> Double {
        
        return 0.0
    }
    
    func calcNOIAnnualExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + expense_annual_ins_field.value
        amt = amt + expense_annual_prot_field.value
        amt = amt + expense_annual_vac_field.value
        amt = amt + expense_annual_repair_field.value
        amt = amt + expense_annual_prom_field.value
        amt = amt + expense_annual_util_field.value
        amt = amt + expense_annual_hoa_field.value
        
        return amt
    }
}

extension PropUnitVC {
    /**
     Calculate mortage value
     */
    @objc func calculate_mortgage_value() {
        
        expense_month_mtg_field.formatTextValue(0)
        expense_annual_mtg_field.formatTextValue(0)
        
        mtg_insurance_text_field.clear()
        
        mtg_purchase_amount_value = mtg_purchase_amt_text_field.value
        
        let p_amount = mtg_purchase_amt_text_field.value
        if p_amount.isZero {
            return
        }
        
        let d_payment = mtg_down_payment_text_field.value
        if d_payment.isZero {
            return
        }
        
        let loanAmount = p_amount - d_payment
        if loanAmount.isZero {
            return
        }
        
        var ins: Double {
            let percentage = (100 * d_payment) / p_amount
            
            if percentage >= 20 {
                return 0.0
            }
            
            if 15..<20 ~= percentage {
                return 0.50
            }
            
            if 10..<15 ~= percentage {
                return 0.75
            }
            
            if 5..<10 ~= percentage {
                return 1.0
            }
            
            if percentage < 5 {
                return 1.25
            }
            
            return 0.0
        }
        
        mtg_insurance_text_field.formatTextValue(ins)
        
        let interestRate = mtg_interest_rate_text_field.value
        if interestRate.isZero {
            return
        }
        
        let numberOfYears = Double(mtg_loan_term_button.tag)
        
        let interestRateDecimal = interestRate / (12 * 100);
        let months = numberOfYears * 12;
        let rPower = pow(1+interestRateDecimal,months);
        var result = loanAmount * ((rPower * interestRateDecimal) / (rPower - 1))
        
        let insurance = (ins * p_amount) / 100
        
        result = result + insurance
        
        expense_month_mtg_field.formatTextValue(result)
        expense_annual_mtg_field.formatTextValue(result * 12.0)
        
        updateMonthAnnualExpenses()
    }
}

extension PropUnitVC {
    
    /**
     Compile all values in the rent roll into a dictionary
     */
    func getAllValues() -> [String : Any] {
        var list: [[String : Any]] = []
        for rent in rent_roll_list {
            let rr = ["amount": rent.amount, "late_fee": rent.late_fee, "year": rent.year,
                      "month": rent.month, "paid": rent.paid, "image": rent.image] as [String : Any]
            list.append(rr)
        }
        
        let data = ["name": unit_name,
                    "bedrooms": bedroom_text_button.tag,
                    "bathrooms": bathroom_text_field.tag,
                    "square_feet": square_feet_text_field.tag,
                    "rent_month": income_month_text_field.value,
                    "rent_annual": income_annual_text_field.value,
                    "rent_start": Constants.getMillis(income_start_date),
                    "rent_end": Constants.getMillis(income_end_date),
                    "rent_day": rent_date_text_field.tag,
                    "month_ins": expense_month_ins_field.value,
                    "annual_ins": expense_annual_ins_field.value,
                    "month_prot": expense_month_prot_field.value,
                    "annual_prot": expense_annual_prot_field.value,
                    "month_mtg": expense_month_mtg_field.value,
                    "annual_mtg": expense_annual_mtg_field.value,
                    "month_vac": expense_month_vac_field.value,
                    "annual_vac": expense_annual_vac_field.value,
                    "month_repair": expense_month_repair_field.value,
                    "annual_repair": expense_annual_repair_field.value,
                    "month_prom": expense_month_prom_field.value,
                    "annual_prom": expense_annual_prom_field.value,
                    "month_util": expense_month_util_field.value,
                    "annual_util": expense_annual_util_field.value,
                    "month_hoa": expense_month_hoa_field.value,
                    "annual_hoa": expense_annual_hoa_field.value,
                    "month_other": expense_month_other_field.value,
                    "annual_other": expense_annual_other_field.value,
                    "mtg_purchase": mtg_purchase_amt_text_field.value,
                    "mtg_down": mtg_down_payment_text_field.value,
                    "mtg_interest": mtg_interest_rate_text_field.value,
                    "mtg_loan": Double(mtg_loan_term_button.tag),
                    "notes": notes_text_field.text ?? "",
                    "rent_rolls": list] as [String : Any]
        
        return data
    }
    
    /**
     Clear all values
     */
    func clearValues() {
        bedroom_text_button.tag = 0
        bedroom_text_button.setTitle("1", for: .normal)
        
        bathroom_text_field.tag = 0
        bathroom_text_field.setTitle("0.5", for: .normal)
        
        square_feet_text_field.tag = 0
        square_feet_text_field.setTitle("0 - 100", for: .normal)
        
        income_month_text_field.clear()
        income_annual_text_field.clear()
        
        income_stdate_text_field.clear()
        income_start_date = nil
        
        //        income_endate_text_field.clear()
        income_end_date = nil
        
        rent_date_text_field.tag = 1
        rent_date_text_field.text = 1.ordinal + " of the Month"
        
        month_income_value = 0.0
        annual_income_value = 0.0
        
        expense_month_total_lbl.clear()
        expense_annual_total_lbl.clear()
        expense_month_ins_field.clear()
        expense_annual_ins_field.clear()
        expense_month_prot_field.clear()
        expense_annual_prot_field.clear()
        expense_month_mtg_field.clear()
        expense_annual_mtg_field.clear()
        expense_month_vac_field.clear()
        expense_annual_vac_field.clear()
        expense_month_repair_field.clear()
        expense_annual_repair_field.clear()
        expense_month_prom_field.clear()
        expense_annual_prom_field.clear()
        expense_month_util_field.clear()
        expense_annual_util_field.clear()
        expense_month_hoa_field.clear()
        expense_annual_hoa_field.clear()
        expense_month_other_field.clear()
        expense_annual_other_field.clear()
        
        mtg_purchase_amt_text_field.clear()
        mtg_down_payment_text_field.clear()
        mtg_interest_rate_text_field.clear()
        mtg_loan_term_button.setTitle("10 Years", for: .normal)
        mtg_loan_term_button.tag = 10
        
        notes_text_field.clear()
    }
}

extension PropUnitVC {
    /**
     Disable or enable the editing of all fields
     */
    func disableEditables(_ bool: Bool) {
        
        let subviews = [bedroom_text_button, bathroom_text_field, square_feet_text_field, income_month_text_field, income_annual_text_field, income_stdate_text_field, income_endate_text_field, rent_date_text_field, expense_month_ins_field, expense_annual_ins_field, expense_month_prot_field, expense_annual_prot_field, expense_month_mtg_field, expense_annual_mtg_field, expense_month_vac_field, expense_annual_vac_field, expense_month_repair_field, expense_annual_repair_field, expense_month_prom_field, expense_annual_prom_field, expense_month_util_field, expense_annual_util_field, expense_month_hoa_field, expense_annual_hoa_field, expense_month_other_field, expense_annual_other_field, mtg_purchase_amt_text_field, mtg_down_payment_text_field, mtg_interest_rate_text_field, mtg_loan_term_button, notes_text_field]
        
        for subview in subviews {
            
            let color: UIColor = bool ? .primary : .lightGray
            if let s = subview as? UITextField {
                //                if s.tag != 1212 {
                s.isEnabled = true
                s.isUserInteractionEnabled = true
                //                }
                
                if let c = s as? CurrencyTextField {
                    c.borderColor = color
                    //                    c.borderWidth = 0
                }
                
                if let c = s as? CustomTextField {
                    c.borderColor = color
                    //                    c.borderWidth = 0
                }
            }
            
            if let s = subview as? KMPlaceholderTextView {
                //                s.isEditable = bool
                s.isSelectable = bool
                
                s.borderColor = color
                //                s.borderWidth = 0
            }
            
            if let s = subview as? BorderedButton {
                //                s.isEnabled = bool
                s.setTitleColor(.darkText, for: .disabled)
                
                s.borderColor = color
                //                s.borderWidth = 0
            }
        }
    }
    
    /**
     Update text for all views
     */
    func updateTextValues() {
        
        let subviews = [income_month_text_field, income_annual_text_field, expense_month_ins_field, expense_annual_ins_field, expense_month_prot_field, expense_annual_prot_field, expense_month_mtg_field, expense_annual_mtg_field, expense_month_vac_field, expense_annual_vac_field, expense_month_repair_field, expense_annual_repair_field, expense_month_prom_field, expense_annual_prom_field, expense_month_util_field, expense_annual_util_field, expense_month_hoa_field, expense_annual_hoa_field, expense_month_other_field, expense_annual_other_field, mtg_purchase_amt_text_field, mtg_down_payment_text_field, purchase_amt_text_field, cash_invested_text_field,down_payment_text_field,closing_cost_text_field,initial_rehab_cost_text_field,total_non_expenses_month_text_field,total_expenses_annual_text_field,nonOperatingeXpense_month_capex_field,nonOperatingeXpense_month_other_field,nonOperatingeXpense_annual_capex_field,nonOperatingeXpense_annual_other_field,total_expenses_month_text_field,mtg_insurance_text_field,loan_bal_text_button,loan_bal_text_field,total_non_expenses_month_text_field,total_non_expenses_annual_text_field, market_val_text_field, equity_val_text_field, equity_perct_text_field]
        
        for subview in subviews {
            
            if let s = subview {
                s.updateTextValue()
            }
        }
    }

    /**
     Update values based on time passed
     */
    func updatePurchaseViews(model: PropertyModel){
        
        purchase_amt_text_field.value = model.purchase_amt
        
        if let date = Constants.buildDatefromMillis(millis: model.purchase_date) {
            purchase_date_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: date)
        }
        income_month_text_field.value = model.calcAnnualRent()/12
        
        income_annual_text_field.value = model.calcAnnualRent()
        
    }
    
    /**
     Update views with most recent data
     */
    func updateViews(model: UnitModel, purchase: Double, lease: Bool = false) {
        unit_key = model.key
        unit_name = model.unit_name
        rent_roll_list = model.rent_roll_list
        
        start_lease_button.isHidden = lease
        
        mtg_purchase_amt_text_field.formatTextValue(purchase)
        
        if let date = Constants.buildDatefromMillis(millis: model.rent_start) {
            income_stdate_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: date)
            income_start_date = date
        }
        
        if let date = Constants.buildDatefromMillis(millis: model.rent_end) {
            //            income_endate_text_field.text = Constants.formatDate("MM/dd/yyyy", dt: date)
            income_end_date = date
        }
        
        bedroom_text_button.setTitle(Constants.getBedRoomsDataList()[model.bedrooms], for: .normal)
        bedroom_text_button.tag = model.bedrooms
        
        bathroom_text_field.setTitle(Constants.getBathRoomsDataList()[model.bathrooms], for: .normal)
        bathroom_text_field.tag = model.bathrooms
        
        square_feet_text_field.setTitle(Constants.getSquareFeetDataList()[model.square_feet], for: .normal)
        square_feet_text_field.tag = model.square_feet
        
//        income_month_text_field.formatTextValue(model.rent_month)
//        income_annual_text_field.formatTextValue(model.rent_annual)
        rent_date_text_field.text = model.rent_day.ordinal + " of the Month"
        
        expense_month_ins_field.formatTextValue(model.month_ins)
        expense_annual_ins_field.formatTextValue(model.annual_ins)
        
        expense_month_prot_field.formatTextValue(model.month_prot)
        expense_annual_prot_field.formatTextValue(model.annual_prot)
        
        expense_month_mtg_field.formatTextValue(model.month_mtg)
        expense_annual_mtg_field.formatTextValue(model.annual_mtg)
        
        expense_month_vac_field.formatTextValue(model.month_vac)
        expense_annual_vac_field.formatTextValue(model.annual_vac)
        
        expense_month_repair_field.formatTextValue(model.month_repair)
        expense_annual_repair_field.formatTextValue(model.annual_repair)
        
        expense_month_prom_field.formatTextValue(model.month_prom)
        expense_annual_prom_field.formatTextValue(model.annual_prom)
        
        expense_month_util_field.formatTextValue(model.month_util)
        expense_annual_util_field.formatTextValue(model.annual_util)
        
        expense_month_hoa_field.formatTextValue(model.month_hoa)
        expense_annual_hoa_field.formatTextValue(model.annual_hoa)
        
        expense_month_other_field.formatTextValue(model.month_other)
        expense_annual_other_field.formatTextValue(model.annual_other)
        
        mtg_purchase_amt_text_field.formatTextValue(model.mtg_purchase_amt)
        down_payment_text_field.formatTextValue(model.mtg_down_payment)
        mtg_down_payment_text_field.formatTextValue(model.mtg_down_payment)
        
        var ins: Double {
            let percentage = (100 * model.mtg_down_payment) / model.mtg_purchase_amt
            
            if percentage >= 20 {
                return 0.0
            }
            
            if 15..<20 ~= percentage {
                return 0.50
            }
            
            if 10..<15 ~= percentage {
                return 0.75
            }
            
            if 5..<10 ~= percentage {
                return 1.0
            }
            
            if percentage < 5 {
                return 1.25
            }
            
            return 0.0
        }
        mtg_insurance_text_field.formatTextValue(ins)
        
        mtg_interest_rate_text_field.formatTextValue(model.mtg_interest_rate)
        mtg_loan_term_button.tag = Int(model.mtg_loan_term)
        mtg_loan_term_button.setTitle("\(mtg_loan_term_button.tag) Years", for: .normal)
        
        notes_text_field.text = model.notes
        
        total_expenses_month_text_field.formatTextValue(model.operating_expenses_other_month)
        total_expenses_annual_text_field.formatTextValue(model.operating_expenses_other_annual)
        
        total_non_expenses_month_text_field.formatTextValue(model.total_non_operating_expenses_month)
        total_non_expenses_annual_text_field.formatTextValue(model.total_non_operating_expenses_annual)
        
        expense_month_other_field.formatTextValue(model.operating_expenses_other_month)
        expense_annual_other_field.formatTextValue(model.operating_expenses_other_annual)
        
        nonOperatingeXpense_month_capex_field.formatTextValue(model.capex_month)
        nonOperatingeXpense_annual_capex_field.formatTextValue(model.capex_annual)
        
        nonOperatingeXpense_month_other_field.formatTextValue(model.non_operating_expenses_other_month)
        nonOperatingeXpense_annual_other_field.formatTextValue(model.non_operating_expenses_other_annual)
        
        loan_bal_text_field.formatTextValue(model.loan_balance)
        
        updateMonthAnnualIncomeValues()
        updateMonthAnnualExpenses()
        
        
        cash_invested_text_field.value = model.mtg_down_payment + closing_cost_text_field.value + initial_rehab_cost_text_field.value

        
    }
}

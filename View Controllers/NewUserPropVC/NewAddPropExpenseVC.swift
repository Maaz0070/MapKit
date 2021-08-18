//
//  NewAddPropExpenseVC.swift
//  RealEstate
//
//  Created by CodeGradients on 24/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import IQKeyboardManagerSwift
import DropDown

class NewAddPropExpenseVC: UIViewController {
    
//    @IBOutlet weak var scroll_view_content_height: NSLayoutConstraint!
    
    @IBOutlet weak var expense_month_ins_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_ins_field: CurrencyTextField!
    @IBOutlet weak var expense_month_prot_field: CurrencyTextField!
    @IBOutlet weak var expense_annual_prot_field: CurrencyTextField!
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
    @IBOutlet weak var nonOperatingeXpense_month_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_field: CurrencyTextField!

    @IBOutlet weak var nonOperatingeXpense_month_capex_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_capex_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_month_other_field: CurrencyTextField!
    @IBOutlet weak var nonOperatingeXpense_annual_other_field: CurrencyTextField!
    @IBOutlet weak var operatingeXpense_month_other_field: CurrencyTextField!
    @IBOutlet weak var operatingeXpense_annual_other_field: CurrencyTextField!
    @IBOutlet weak var totalXpense_month: CurrencyTextField!
    @IBOutlet weak var totalXpense_annual: CurrencyTextField!
    
    @IBOutlet weak var mortgage_toggle_button: BorderedButton!
    @IBOutlet weak var mtg_down_payment_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_interest_rate_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_loan_term_button: BorderedButton!
    @IBOutlet weak var mtg_mortgage_insurance_text_field: CurrencyTextField!
    @IBOutlet weak var mtg_loan_balance_text_field: CurrencyTextField!
    @IBOutlet weak var addUnitBtn: BorderedButton!
    @IBOutlet weak var addProBtn: BorderedButton!
    var loanTenure = 10
    
    @IBOutlet weak var non_operating_mortgage_payment_monthly: CurrencyTextField!
    @IBOutlet weak var non_operating_mortgage_payment_annual: CurrencyTextField!
    var  unitArray = NSMutableArray()
    @IBOutlet weak var headerTitle: UILabel!
    let vc = AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: AddPropUnitVC.storyboard_id) as? AddPropUnitVC
    let dbRef = Database.database().reference()
    
    /**
     Prompt user to enter new data if neccesary; update calculations
     */
    func updateData(){
        if let parent = self.parent! as? NewAddPropVC {
            if let purchase_vc = parent.children[2] as? NewAddPropPurchaseVC, purchase_vc.prop_type_label.text == "Multi-Family Prop" {
                self.addUnitBtn.isHidden = false
                self.addProBtn.isHidden = true
                headerTitle.text = "Now enter entire PROPERTY EXPENSES you will be able to add UNIT EXPENSES later"
            } else {
                self.addUnitBtn.isHidden = true
                headerTitle.text = "Lastly, enter expenses"
            }
        }
        if let rent = proInfo["traditional_rental"] as? String{
               let monthly = (Double(rent) ?? 0 )/12
//            self.income_month_text_field.value = monthly
//            income_month_text_field.formatTextValue(monthly) //= (String(format: "$%.2f",(NewAddPropRentIncomeVC.month_income_value)))
//            self.income_annual_text_field.value = Double(rent)  ?? 0
//            self.income_annual_text_field.formatTextValue(Double(rent)  ?? 0)

        }
        if let traditional = proInfo["traditional"] as? NSDictionary{
            if let tax = traditional["traditional_property_tax"] as? String{
                expense_month_prot_field.formatTextValue( Double(tax)!/12)
                expense_annual_prot_field.formatTextValue( Double(tax)!)
            }
        }

        
    }
//    func mortgageCalculation() {
//            let loanAmount = Double(mtg_loan_balance_text_field.text!) ?? .zero
//            let numberOfPayments = Double(valueB.text!) ?? .zero
//            let interestRate = Double(valueC.text!) ?? .zero
//            let rate = interestRate / 100 / 12
//            let answer = loanAmount * rate / (1 - pow(1 + rate, -numberOfPayments))
//            results.text = Formatter.currency.string(for: answer)
//        }
    
    /**
     Setup UI field targets
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mtg_loan_balance_text_field.format_dollar = true
        updateMortgageViewVisibility()
        
//        totalXpense_month.updateTextValue()
//        totalXpense_annual.updateTextValue()
        expense_month_ins_field.addTarget(self, action: #selector(didChangedInsMonthValue), for: .editingChanged)
        expense_annual_ins_field.addTarget(self, action: #selector(didChangedInsAnnualValue), for: .editingChanged)
        
        expense_month_prot_field.addTarget(self, action: #selector(didChangedProTaxMonthValue), for: .editingChanged)
        expense_annual_prot_field.addTarget(self, action: #selector(didChangedProTaxAnnualValue), for: .editingChanged)
        
        expense_month_vac_field.addTarget(self, action: #selector(didChangedVACMonthValue), for: .editingChanged)
        expense_annual_vac_field.addTarget(self, action: #selector(didChangedVACAnnualValue), for: .editingChanged)
        
        expense_month_repair_field.addTarget(self, action: #selector(didChangedRepairMonthValue), for: .editingChanged)
        expense_annual_repair_field.addTarget(self, action: #selector(didChangedRepairAnnualValue), for: .editingChanged)
        
        expense_month_prom_field.addTarget(self, action: #selector(didChangedPropMonthValue), for: .editingChanged)
        expense_annual_prom_field.addTarget(self, action: #selector(didChangedPropAnnualValue), for: .editingChanged)
        
        nonOperatingeXpense_month_capex_field.addTarget(self, action: #selector(didChangedCapexValue), for: .editingChanged)
        nonOperatingeXpense_annual_capex_field.addTarget(self, action: #selector(didChangedCapexAnnualValue), for: .editingChanged)
        
        nonOperatingeXpense_month_other_field.addTarget(self, action: #selector(didChangedNonOperatingeXpenseOtherMonthValue), for: .editingChanged)
        nonOperatingeXpense_annual_other_field.addTarget(self, action: #selector(didChangedNonOperatingeXpenseOtherAnnualValue), for: .editingChanged)
        expense_month_util_field.addTarget(self, action: #selector(didChangedUtilMonthValue), for: .editingChanged)
        expense_annual_util_field.addTarget(self, action: #selector(didChangedUtilAnnualValue), for: .editingChanged)
        
        expense_month_hoa_field.addTarget(self, action: #selector(didChangedHoaMonthValue), for: .editingChanged)
        expense_annual_hoa_field.addTarget(self, action: #selector(didChangedHoaAnnualValue), for: .editingChanged)
        
        expense_month_other_field.addTarget(self, action: #selector(didChangedOtherMonthValue), for: .editingChanged)
        expense_annual_other_field.addTarget(self, action: #selector(didChangedOtherAnnualValue), for: .editingChanged)
        
        mortgage_toggle_button.addTarget(self, action: #selector(didPressedMortgageToggleButton(_:)), for: .touchUpInside)
        
        mtg_loan_term_button.addTarget(self, action: #selector(didPressedMtgLoanTermButton(_:)), for: .touchUpInside)
        
        
        non_operating_mortgage_payment_monthly.addTarget(self, action: #selector(didChangedNonOpMortgagePaymentValue), for: .editingChanged)
        non_operating_mortgage_payment_annual.addTarget(self, action: #selector(didChangedNonOpMortgagePaymentAnnualValue), for: .editingChanged)
        
        
        
        mtg_down_payment_text_field.addTarget(self, action: #selector(didChangedMgtDownPaymentValue), for: .editingChanged)
        mtg_interest_rate_text_field.addTarget(self, action: #selector(didChangedMgtInterestValue), for: .editingChanged)
        

    }
//    func accessorViewForDownpayment(){
//        let width = Constants.deviceWidth()
//
//        let accessory = UIView()
//        accessory.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
//        accessory.frame = CGRect(x: 0, y: 0, width: width - 100, height: 45)
//
//        var segment : UISegmentedControl {
//            let seg = UISegmentedControl()
//            seg.frame = CGRect(x: 0, y: 7.5, width: 280, height: 30)
////            if accessory_text != "% of Purchase Price" {
////                seg.frame = CGRect(x: 0, y: 7.5, width: 300, height: 30)
////            }
//            seg.insertSegment(withTitle: Constants.currency_placeholder, at: 0, animated: true)
//            seg.insertSegment(withTitle: "$", at: 0, animated: true)
//            seg.insertSegment(withTitle: "% of Purchase Price", at: 1, animated: true)
//            let font = UIFont.systemFont(ofSize: 13)
//            seg.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
//            seg.selectedSegmentIndex = 0
//            seg.addTarget(self, action: #selector(didPressedStateButton(segment:)), for: .valueChanged)
//            return seg
//        }
//        accessory.addSubview(segment)
//        mtg_down_payment_text_field.inputView = accessory
//    }
//    @objc func didPressedStateButton(segment:UISegmentedControl) {
//        switch segment.selectedSegmentIndex {
//        case 0:
//            mtg_down_payment_text_field.formatTextValue(mtg_down_payment_text_field.value)
//            break
//        case 1:
//            break
//
//        default:
//            break
//        }
//    }
    
    /**
     Constrain the height of the scrollview depending on if we want to show the mortage value or not
     */
    func updateMortgageViewVisibility() {
        if mortgage_toggle_button.tag == 0 {
            if let v = mtg_down_payment_text_field.superview?.superview?.superview?.superview as? GVisibilityView {
                v.g_state = true
                
//                scroll_view_content_height.constant = scroll_view_content_height.constant - v.height
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            if let v = mtg_down_payment_text_field.superview?.superview?.superview?.superview as? GVisibilityView {
                v.g_state = false
                
//                scroll_view_content_height.constant = scroll_view_content_height.constant + v.height
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    /**
     Set the mortage view and visibility
     - Parameter sender: mortage toggle button
     */
    @objc func didPressedMortgageToggleButton(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setTitle("YES", for: .normal)
        } else {
            sender.tag = 0
            sender.setTitle("NO", for: .normal)
        }
        
        updateMortgageViewVisibility()
    }
    
    /**
     Configure and show mortage term dropdown
     */
    @objc func didPressedMtgLoanTermButton(_ sender: UIButton) {
        let drop = DropDown(anchorView: sender)
        drop.dataSource = ["10 Years", "15 Years", "30 Years"]
        drop.selectionAction = { [self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            var tag: Int {
                if index == 1 {
                    loanTenure = 15
                    return 15
                }
                
                if index == 2 {
                    
                    loanTenure = 30
                    return 30
                }
                
                loanTenure = 10
                return 10
            }
            sender.tag = tag
            calculateMortgage()
        }
        drop.show()
    }
    
    /**
     Calculate the price of the mortage, if the user has one
     */
    func calculateMortgage(){
        if let purchageAmount = proInfo["list_price"] as? Double{
            
            var downPayment: Double = 0.0
            if self.mtg_down_payment_text_field.text?.contains(s: "$") == false {
//                var temp_mtg_payment_value = self.mtg_down_payment_text_field.text?.replacingOccurrences(of: "%", with: "")
//                temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: "$", with: "")
//                temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: ",", with: "")
                if self.mtg_down_payment_text_field.text != "$" {
                    downPayment = self.calculatePercentage(value: Double(purchageAmount), percentageVal:mtg_interest_rate_text_field.value)
                }
            }
            else {
                downPayment = self.mtg_down_payment_text_field.value
            }
        
            
//            let downPayment = self.mtg_down_payment_text_field.text?.contains(s: "%") == true ? self.calculatePercentage(value: Double(purchageAmount), percentageVal: Double(temp1!)!)  : self.mtg_down_payment_text_field.value
            let loanAmount = Double(purchageAmount) - downPayment
        
            let mtg = self.calculateEmi(loanAmount, loanTenure: Double(loanTenure), interestRate: self.mtg_interest_rate_text_field.value)
            if (mtg.isNaN == false){
//            non_operating_mortgage_payment_monthly.value = mtg
//            non_operating_mortgage_payment_annual.value = mtg * 12
                
                non_operating_mortgage_payment_monthly.formatTextValue(mtg)
                non_operating_mortgage_payment_annual.formatTextValue(mtg*12)
                
                calculateNonOperatingeXpense()
                
            }
            
          
        }
        updateInsuranceAmount()
    }
    
    /**
     Present the add unit VC to add a unit upon button press
     - Parameter sender: add unit button
     */
    @IBAction func didPressedAddUnitButton(_ sender: BorderedButton) {
        IQKeyboardManager.shared.resignFirstResponder()
        
    
//        vc?.modalPresentationStyle = .currentContext
//        vc?.modalTransitionStyle = .coverVertical
        vc?.completionHandler = addUnitCompletionHandler()
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    /**
     Completion handler for adding a unit
     */
    func addUnitCompletionHandler()->((Int) -> Void){
        let completionHandler: (Int)->Void = { [self]
            (arg: Int) -> Void in
            unitArray.add(vc!.getAllValues())
            if arg == 0{
                self.didPressedAddUnitButton(self.addUnitBtn)
                self.parent?.view.makeToast("Unit added successfully.", position: .bottom)
            }else{
                self.didPressedAddProprtyButton(self.addProBtn)
            }
        }
        return completionHandler
    }
    
    /**
     Show alert if the user did not enter expenses
     - Parameter sender: bordered add property button
     */
    @IBAction func didPressedAddProprtyButton(_ sender: BorderedButton) {
        IQKeyboardManager.shared.resignFirstResponder()

        
        if ((calcAnnualExpenses() == 0.0) || (calcMonthExpenses() == 0.0)) {
            
            var customActions:[UIAlertAction] = []
            
            let newAction = UIAlertAction.init(title: "Confirm", style: .cancel, handler: {(alert: UIAlertAction!) in
                self.validateAndAddProperty() //continue and add the property as requested
            })
            let newAction2 = UIAlertAction.init(title: "Go Back", style: .default, handler: nil)
                //do nothing
            
            customActions.append(newAction)
            customActions.append(newAction2)
            
            AlertBuilder().buildMessageWithMulipleCallbacksAndCustomTitle(vc: self, message: "You forgot to enter expenses! Click GO BACK to enter expenses or CONFIRM to submit your property.", title: "Oops.", actions: customActions)
            return
        }else{
            self.validateAndAddProperty()
        }
        
        
    }
    
    /**
     Validate that the property fields are all valid (this could likely be refactored using an array of fields and a for loop)
     Input the new data into Firebase
     Handle invalid input accordingly
     */
    func validateAndAddProperty() {
        if let parent = self.parent as? NewAddPropVC {
            if let address_vc = parent.children[1] as? NewAddPropAddressVC {
                if address_vc.st_address_text_field.isInputValid() {
                    if address_vc.ct_address_text_field.isInputValid() {
                        if address_vc.stt_address_text_field.isInputValid() {
                            if address_vc.zip_code_text_field.isInputValid() {
                                
                                let address = "\(address_vc.st_address_text_field.text!)\n\(address_vc.ct_address_text_field.text!), \(address_vc.stt_address_text_field.text!)#\(address_vc.zip_code_text_field.text!)"
                                
                                if let purchase_vc = parent.children[2] as? NewAddPropPurchaseVC {
                                    if purchase_vc.purchase_amt_text_field.isInputValid() {
                                        if purchase_vc.purchase_date_text_field.isInputValid(), let date = purchase_vc.purchased_date {
                                            
                                            if let rent_vc = parent.children[3] as? NewAddPropRentIncomeVC {
                                                
                                                if let expense_vc = parent.children[4] as? NewAddPropExpenseVC {
                                                    
                                                    var month_mtg = 0.0
                                                    var annual_mtg = 0.0
                                                    
                                                    let p_amount = purchase_vc.purchase_amt_text_field.value
                                                    if !p_amount.isZero {
                                                        let d_payment = mtg_down_payment_text_field.value
                                                        if !d_payment.isZero {
                                                            let loanAmount = p_amount - d_payment
                                                            if !loanAmount.isZero {
                                                                let interestRate = mtg_interest_rate_text_field.value
                                                                if !interestRate.isZero {
                                                                    let numberOfYears = Double(mtg_loan_term_button.tag)
                                                                    
                                                                    let interestRateDecimal = interestRate / (12 * 100);
                                                                    let months = numberOfYears * 12;
                                                                    let rPower = pow(1+interestRateDecimal,months);
                                                                    let result = loanAmount * ((rPower * interestRateDecimal) / (rPower - 1))
                                                                    
                                                                    month_mtg = result
                                                                    annual_mtg = result * 12
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    var units: [[String : Any]] = []
//                                                    var units: NSMutableArray = NSMutableArray()

                                                    let unit = ["name": "",
                                                                "bedrooms": purchase_vc.bedroom_text_button.tag,
                                                                "bathrooms": purchase_vc.bathroom_text_field.tag,
                                                                "square_feet": purchase_vc.square_feet_text_field.tag,
                                                                "rent_month": rent_vc.income_month_text_field.value,
                                                                "rent_annual": NewAddPropRentIncomeVC.annual_income_value,
                                                                "rent_start": Constants.getMillis(rent_vc.income_start_date),
                                                                "rent_end": Constants.getMillis(rent_vc.income_end_date),
                                                                "rent_day": rent_vc.rent_date_text_field.tag,
                                                                "month_ins": expense_vc.expense_month_ins_field.value,
                                                                "annual_ins": expense_vc.expense_annual_ins_field.value,
                                                                "month_prot": expense_vc.expense_month_prot_field.value,
                                                                "annual_prot": expense_vc.expense_annual_prot_field.value,
                                                                "month_mtg": month_mtg,
                                                                "annual_mtg": annual_mtg,
                                                                "month_vac": expense_vc.expense_month_vac_field.value,
                                                                "annual_vac": expense_vc.expense_annual_vac_field.value,
                                                                "month_repair": expense_vc.expense_month_repair_field.value,
                                                                "annual_repair": expense_vc.expense_annual_repair_field.value,
                                                                "month_prom": expense_vc.expense_month_prom_field.value,
                                                                "annual_prom": expense_vc.expense_annual_prom_field.value,
                                                                "month_util": expense_vc.expense_month_util_field.value,
                                                                "annual_util": expense_vc.expense_annual_util_field.value,
                                                                "month_hoa": expense_vc.expense_month_hoa_field.value,
                                                                "annual_hoa": expense_vc.expense_annual_hoa_field.value,
                                                                "month_other": expense_vc.expense_month_other_field.value,
                                                                "annual_other": expense_vc.expense_annual_other_field.value,
                                                                "mtg_purchase": purchase_vc.purchase_amt_text_field.value,
                                                                "mtg_down": mtg_down_payment_text_field.value,
                                                                "mtg_interest": mtg_interest_rate_text_field.value,
                                                                "mtg_loan": Double(mtg_loan_term_button.tag),
                                                                "notes": "",
                                                                "total_operating_expenses_month": operatingeXpense_month_other_field.value,
                                                                "operating_expenses_other_month": expense_month_other_field.value,
                                                                "total_non_operating_expenses_month": nonOperatingeXpense_month_field.value,
                                                                "non_operating_expenses_other_month": nonOperatingeXpense_month_other_field.value,
                                                                "capex_month": nonOperatingeXpense_month_capex_field.value,
                                                                "total_operating_expenses_annual": operatingeXpense_annual_other_field.value,
                                                                "operating_expenses_other_annual": expense_annual_other_field.value,
                                                                "total_non_operating_expenses_annual": nonOperatingeXpense_annual_field.value,
                                                                "non_operating_expenses_other_annual": nonOperatingeXpense_annual_other_field.value,
                                                                "capex_annual": nonOperatingeXpense_annual_capex_field.value,
                                                                "loan_balance": mtg_loan_balance_text_field.value] as [String : Any]
                                                    units.append(unit)
//                                                    units.add(expense_vc.unitArray)
                                                    let key = dbRef.child("properties").childByAutoId().key
                                                    if let k = key {
                                                        let data = ["key": k,
                                                                    "user": Constants.mineId,
                                                                    "address": "\(address)",
                                                            "purchase_date": Constants.getMillis(date),
                                                            "purchase_amt": purchase_vc.purchase_amt_text_field.value,
                                                            "cash_invested": purchase_vc.cash_invested_text_field.value,
                                                            "property_status": (propertyType == .IOwn ? "IOwen" : "Research"),
                                                            "prop_type": purchase_vc.prop_type_label.text!,
                                                            "millis": Constants.getCurrentMillis(),
                                                            "units": (unitArray.count > 0 ? unitArray : units)] as [String : Any]
                                                        
                                                        let hud = JGProgressHUD(style: .dark)
                                                        hud.show(in: self.view)
                                                        print(data)
                                                        print(k)
                                                        dbRef.child("properties").child(k).updateChildValues(data) { (err, ref) in
                                                            hud.dismiss()
                                                            if let e = err {
                                                                AlertBuilder().buildMessage(vc: self, message: "Something went wrong...\nError: \(e.localizedDescription)")
                                                                return
                                                            }
                                                            
                                                            UserDefaults.standard.set(false, forKey: "is_new_user")

                                                            var message = "You've added your first property"
                                                            if SplashVC.user_property_count > 0 {
                                                                message = "Your property has been added."
                                                            }
                                                            
                                                            let alert = UIAlertController(title: "Congratulations!", message: message, preferredStyle: .alert)
                                                            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (ac) in
                                                                parent.dismiss(animated: true) {
                                                                    parent.delegate.didAddedNewProperty(key: k)
                                                                }
                                                            }))
                                                            parent.present(alert, animated: true, completion: nil)
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            parent.view.makeToast("Please type valid Purchase Date")
                                            parent.moveToPage(1)
                                        }
                                    } else {
                                        parent.view.makeToast("Please type valid Purchase Amount")
                                        parent.moveToPage(1)
                                    }
                                }
                            } else {
                                parent.view.makeToast("Please type valid Zip Code")
                                parent.moveToPage(0)
                            }
                        } else {
                            parent.view.makeToast("Please type valid State Address")
                            parent.moveToPage(0)
                        }
                    } else {
                        parent.view.makeToast("Please type valid City Address")
                        parent.moveToPage(0)
                    }
                } else {
                    parent.view.makeToast("Please type valid Street Address")
                    parent.moveToPage(0)
                }
            }
        }
    }
}

/**
 Helper extensions to extrapolate data and calculate derived monthly and annual expense values
 */
extension NewAddPropExpenseVC {
    @objc func didChangedMgtDownPaymentValue() {
        self.calculateMortgage()
    }
    @objc func didChangedMgtInterestValue() {
        self.calculateMortgage()

    }
    
    
    @objc func didChangedInsMonthValue() {
        let number = expense_month_ins_field.value
        expense_annual_ins_field.formatTextValue(number * 12.0)
        
       //.value)) =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
        updateOperatingData()
    }
    func updateOperatingData(){
        operatingeXpense_month_other_field.formatTextValue(calcMonthExpenses()) //=  String(format: "%.2f",(calcMonthExpenses()))
        operatingeXpense_annual_other_field.formatTextValue((calcMonthExpenses()*12)) // =  String(format: "%.2f",(calcMonthExpenses()*12))
        
        
        totalXpense_month.formatTextValue((calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value)) //=  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
        totalXpense_annual.formatTextValue(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value)
    }
    
    @objc func didChangedInsAnnualValue() {
        let number = expense_annual_ins_field.value
        expense_month_ins_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedProTaxMonthValue() {
        let number = expense_month_prot_field.value
        expense_annual_prot_field.formatTextValue(number * 12.0)
        
        updateOperatingData()
//        operatingeXpense_month_other_field.text =  String(format: "%.2f",(calcMonthExpenses()))
//        operatingeXpense_annual_other_field.text =  String(format: "%.2f",(calcMonthExpenses()*12))
//
//        totalXpense_month.text =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.text =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    
    @objc func didChangedProTaxAnnualValue() {
        let number = expense_annual_prot_field.value
        expense_month_prot_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    @objc func didChangedVACMonthValue() {
        let number = expense_month_vac_field.value
        expense_annual_vac_field.formatTextValue(number * 12.0)
        updateOperatingData()
    }
    
    @objc func didChangedVACAnnualValue() {
        let number = expense_annual_vac_field.value
        expense_month_vac_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedRepairMonthValue() {
        let number = expense_month_repair_field.value
        expense_annual_repair_field.formatTextValue(number * 12.0)
        
        updateOperatingData()
//        operatingeXpense_month_other_field.text =  String(format: "%.2f",(calcMonthExpenses()))
//        operatingeXpense_annual_other_field.text =  String(format: "%.2f",(calcMonthExpenses()*12))
//
//        totalXpense_month.text =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.text =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    
    @objc func didChangedRepairAnnualValue() {
        let number = expense_annual_repair_field.value
        expense_month_repair_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedPropMonthValue() {
        let number = expense_month_prom_field.value
        expense_annual_prom_field.formatTextValue(number * 12.0)
        updateOperatingData()
    }
    @objc func didChangedCapexValue() {
        let number = nonOperatingeXpense_month_capex_field.value
        nonOperatingeXpense_annual_capex_field.formatTextValue(number * 12.0)
        
        nonOperatingeXpense_month_field.formatTextValue(number) //=  String(format: "%.2f",(number))
        nonOperatingeXpense_annual_field.formatTextValue((number * 12.0)) //=  String(format: "%.2f",(number * 12.0))
        calculateNonOperatingeXpense()
//        totalXpense_month.formatTextValue((calcMonthExpenses()+nonOperatingeXpense_month_field.value))// =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.formatTextValue((calcAnnualExpenses()+nonOperatingeXpense_annual_field.value))// =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    @objc func didChangedCapexAnnualValue() {
        let number = nonOperatingeXpense_annual_capex_field.value
        nonOperatingeXpense_month_capex_field.formatTextValue(number / 12.0)
        
        nonOperatingeXpense_annual_field.formatTextValue(number) //=  String(format: "%.2f",(number))
        nonOperatingeXpense_month_field.formatTextValue((number / 12.0)) //=  String(format: "%.2f",(number * 12.0))
        
        calculateNonOperatingeXpense()
    }
    func calculateNonOperatingeXpense(){
        nonOperatingeXpense_month_field.formatTextValue(nonOperatingeXpense_month_capex_field.value    + non_operating_mortgage_payment_monthly.value + nonOperatingeXpense_month_other_field.value)// =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
        nonOperatingeXpense_annual_field.formatTextValue((nonOperatingeXpense_annual_capex_field.value+non_operating_mortgage_payment_annual.value + nonOperatingeXpense_annual_other_field.value))
        
        totalXpense_month.formatTextValue((calcMonthExpenses()+nonOperatingeXpense_month_field.value))// =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
        totalXpense_annual.formatTextValue((calcAnnualExpenses()+nonOperatingeXpense_annual_field.value))
    }
    @objc func didChangedNonOpMortgagePaymentValue() {
        let number = non_operating_mortgage_payment_monthly.value
        non_operating_mortgage_payment_annual.formatTextValue(number * 12.0)
        
        non_operating_mortgage_payment_monthly.formatTextValue(number) //=  String(format: "%.2f",(number))
        non_operating_mortgage_payment_annual.formatTextValue((number * 12.0)) //=  String(format: "%.2f",(number * 12.0))
        
        calculateNonOperatingeXpense()
    }
    @objc func didChangedNonOpMortgagePaymentAnnualValue() {
        let number = non_operating_mortgage_payment_annual.value
        non_operating_mortgage_payment_monthly.formatTextValue(number / 12.0)
        
        non_operating_mortgage_payment_annual.formatTextValue(number) //=  String(format: "%.2f",(number))
        non_operating_mortgage_payment_monthly.formatTextValue((number / 12.0)) //=  String(format: "%.2f",(number * 12.0))
        
        calculateNonOperatingeXpense()
    }
    @objc func didChangedNonOperatingeXpenseOtherMonthValue() {
        let number = nonOperatingeXpense_month_other_field.value
        nonOperatingeXpense_annual_other_field.formatTextValue(number * 12.0)
        
        calculateNonOperatingeXpense()
        
    }
    @objc func didChangedNonOperatingeXpenseOtherAnnualValue() {
        let number = nonOperatingeXpense_annual_other_field.value
        nonOperatingeXpense_month_other_field.formatTextValue(number / 12.0)
        calculateNonOperatingeXpense()
    }
    @objc func didChangedPropAnnualValue() {
        let number = expense_annual_prom_field.value
        expense_month_prom_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedUtilMonthValue() {
        let number = expense_month_util_field.value
        expense_annual_util_field.formatTextValue(number * 12.0)
        updateOperatingData()
//        operatingeXpense_month_other_field.text =  String(format: "%.2f",(calcMonthExpenses()))
//        operatingeXpense_annual_other_field.text =  String(format: "%.2f",(calcMonthExpenses()*12))
//
//        totalXpense_month.text =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.text =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    
    @objc func didChangedUtilAnnualValue() {
        let number = expense_annual_util_field.value
        expense_month_util_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedHoaMonthValue() {
        let number = expense_month_hoa_field.value
        expense_annual_hoa_field.formatTextValue(number * 12.0)
        updateOperatingData()
//        operatingeXpense_month_other_field.text =  String(format: "%.2f",(calcMonthExpenses()))
//        operatingeXpense_annual_other_field.text =  String(format: "%.2f",(calcMonthExpenses()*12))
//        totalXpense_month.text =  String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.text =  String(format: "%.2f",(calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    
    @objc func didChangedHoaAnnualValue() {
        let number = expense_annual_hoa_field.value
        expense_month_hoa_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    
    @objc func didChangedOtherMonthValue() {
        let number = expense_month_other_field.value
        expense_annual_other_field.formatTextValue(number * 12.0)
        
        updateOperatingData()
//        operatingeXpense_month_other_field.text = String(format: "%.2f",(calcMonthExpenses()))
//        operatingeXpense_annual_other_field.text = String(format: "%.2f",(calcMonthExpenses()*12))
//        totalXpense_month.text = String(format: "%.2f",(calcMonthExpenses()+nonOperatingeXpense_month_capex_field.value))
//        totalXpense_annual.text =  String(format: "%.2f", (calcAnnualExpenses()+nonOperatingeXpense_annual_capex_field.value))
    }
    
    @objc func didChangedOtherAnnualValue() {
        let number = expense_annual_other_field.value
        expense_month_other_field.formatTextValue(number / 12.0)
        updateOperatingData()
    }
    
    func calcMonthExpenses() -> Double {
        var amt = 0.0
        
        amt = amt + expense_month_ins_field.value
        amt = amt + expense_month_prot_field.value
        amt = amt + expense_month_vac_field.value
        amt = amt + expense_month_repair_field.value
        amt = amt + expense_month_prom_field.value
        amt = amt + expense_month_util_field.value
        amt = amt + expense_month_hoa_field.value
        amt = amt + expense_month_other_field.value
        
        return amt
    }
    
    func calcAnnualExpenses() -> Double { //calcAnnualProfit
       // annualProfit = (totalCost/sellPrice) * 100
        //return annualProfit
        
        var amt = 0.0
        
        amt = amt + expense_annual_ins_field.value
        amt = amt + expense_annual_prot_field.value
        amt = amt + expense_annual_vac_field.value
        amt = amt + expense_annual_repair_field.value
        amt = amt + expense_annual_prom_field.value
        amt = amt + expense_annual_util_field.value
        amt = amt + expense_annual_hoa_field.value
        amt = amt + expense_annual_other_field.value
        
        return amt
        //return (totalCost / sellPrice) * 100
    }
    func updateInsuranceAmount()
    {
        if let parent = self.parent! as? NewAddPropVC {
            
            if  let p_amount = proInfo["list_price"] as? Double {
                
                //            let p_amount = NewAddPropPurchaseVC.mtg_purchase_amount_value
                //    if p_amount.isZero {
                //        return
                //    }
                //
                var d_payment = 0.0
                d_payment = mtg_down_payment_text_field.value
                if self.mtg_down_payment_text_field.text?.contains(s: "%") == true || self.mtg_down_payment_text_field.text?.contains(s: "$") == true{
                    var temp_mtg_payment_value = self.mtg_down_payment_text_field.text?.replacingOccurrences(of: "%", with: "")
                    temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: "$", with: "")
                    temp_mtg_payment_value = temp_mtg_payment_value!.replacingOccurrences(of: ",", with: "")
                    if self.mtg_down_payment_text_field.text != "$" {
                        d_payment = Double(temp_mtg_payment_value!)!
                    }
                }
                
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
                
                mtg_mortgage_insurance_text_field.formatTextValue(ins)
            }
        }
    }
}
extension NewAddPropExpenseVC{
    @IBAction func operationExpensesMonthDidChange(_ sender: Any) {

        var total = expense_month_ins_field.value+expense_month_prot_field.value+expense_month_vac_field.value
        total += self.expense_month_repair_field.value + self.expense_month_hoa_field.value + self.expense_month_util_field.value
        total = total   + self.expense_month_other_field.value
        
//        self.cash_invested_text_field.text = "\(String(format: "%.2f", total))"
        
    }
    @IBAction func operationExpensesYearDidChange(_ sender: Any) {
        var total = expense_annual_ins_field.value+expense_annual_prot_field.value+expense_annual_vac_field.value
        total += self.expense_annual_repair_field.value + self.expense_annual_hoa_field.value + self.expense_annual_util_field.value
        total = total   + self.expense_annual_other_field.value
        
//        self.cash_invested_text_field.text = "\(String(format: "%.2f", totalCashInvested))"
        
    }
    @IBAction func nonOperationExpensesMonthDidChange(_ sender: Any) {
        var total = expense_annual_ins_field.value+expense_annual_prot_field.value+expense_annual_vac_field.value
//        let totalCashInvested = self.down_payment_text_field.value+self.closing_cost_text_field.value+self.initial_rehab_cost_text_field.value
//        self.cash_invested_text_field.value = totalCashInvested
//        self.cash_invested_text_field.text = "\(String(format: "%.2f", totalCashInvested))"
        
    }
    @IBAction func nonOperationExpensesYearDidChange(_ sender: Any) {

//        let totalCashInvested = self.down_payment_text_field.value+self.closing_cost_text_field.value+self.initial_rehab_cost_text_field.value
//        self.cash_invested_text_field.value = totalCashInvested
//        self.cash_invested_text_field.text = "\(String(format: "%.2f", totalCashInvested))"
        
    }
}
extension NewAddPropExpenseVC{
    
    // MARK: Business Logic
    func calculateEmi(_ loanAmount : Double, loanTenure : Double, interestRate : Double) -> Double {
        let interestRateVal = interestRate / 1200
        let loanTenureVal = loanTenure * 12
        return loanAmount * interestRateVal / (1 - (pow(1/(1 + interestRateVal), loanTenureVal)))
    }
    //Calucate percentage based on given values
     func calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    func calculatePercentageOfValue(value:Double,value2:Double)->Double{
//       let val = value * percentageVal
       return (100*value) / value2
   }
}

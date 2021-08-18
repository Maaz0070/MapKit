//
//  HFDPropertyModel.swift
//  RealEstate
//
//  Created by Akshat Channashetti on 7/9/21.
//  Copyright © 2021 Code Gradients. All rights reserved.
//

import Foundation

struct HFDPropertyModel {
    /*
     Street_Address, String
     City, String
     State, String
     Zipcode, String
     Image_URL, String
     Image_URL_Date, Integer
     Property_Type, String
     Bedroom, Integer
     Bathroom, Float
     Square_Feet, Integer
     Purchase_Price, Float
     Purchase_Date, Integer
     Did_you_use_a_loan, Boolean
     Loan_amount, Float
     Loan_rate, Float
     Loan_term, Integer
     Down_payment, Float
     Monthly_loan_payment_amount, Integer
     Number_of_payments_paid, Integer
     Floor_Estimate, Float
     Floor_Actual, Float
     Roof_Estimate, Float
     Roof_Actual, Float
     Kitchen_Estimate, Float
     Kitchen_Actual, Float
     Bedroom_Estimate, Float
     Bedroom_Actual, Float
     Bathroom_Estimate, Float
     Bathroom_Actual, Float
     Foundation_Estimate, Float
     Foundation_Actual, Float
     Paint_Estimate, Float
     Paint_Actual, Float
     HVAC_Estimate, Float
     HVAC_Actual, Float
     Other_Estimate, Float
     Other_Actual, Float
     Date_submitted, Integer
     Last_updated, integer
     User_Id, Integer

     */

    //Generic information
    var proType : PropertyType
    var key: String
    var user: String
    var bedroom: Int
    var bathroom: Float
    var square_feet: Int
    var address: String
    var city: String
    var state: String
    var zipcode: String
    var purchase_date: String
    var cash_invested: Double
    var purchase_amt: Double
    var prop_type: String
    var date_submitted: Int
    var last_updated: Int
    var user_id: Int
    
    //Social information
    var millis: String
    var likes: Int
    var liked: Bool
    var deleted: Bool
    
    //Image data
    var image_URL: String
    var image_URL_Date: Int
    
    //Loan information
    var used_a_loan: Bool
    var loan_amount: Float
    var loan_rate: Float
    var loan_term: Int
    var down_payment: Float
    var monthly_loan_payment_amount: Int
    var number_of_payments_paid: Int
    
    //Expenses information
    var floor_estimate: Float
    var floor_actual: Float
    var roof_estimate: Float
    var roof_actual: Float
    var kitchen_estimate: Float
    var kitchen_actual: Float
    var bedroom_estimate: Float
    var bedroom_actual: Float
    var bathroom_estimate: Float
    var bathroom_actual: Float
    var foundation_estimate: Float
    var foundation_actual: Float
    var paint_estimate: Float
    var paint_actual: Float
    var HVAC_estimate: Float
    var HVAC_actual: Float
    var other_estimate: Float
    var other_actual: Float
    var total_expenses_estimate: Float
    var total_expenses_actual: Float
    
    init() {
        self.proType = .IOwn
        self.key = ""
        self.user = ""
        self.bedroom = 0
        self.bathroom = 0
        self.square_feet = 0
        self.address = ""
        self.city = ""
        self.state = ""
        self.zipcode = ""
        self.purchase_date = ""
        self.purchase_amt = 0.0
        self.cash_invested = 0.0
        self.prop_type = ""
        self.date_submitted = 0
        self.last_updated = 0
        self.user_id = 0
        
        self.millis = ""
        self.likes = 0
        self.liked = false
        self.deleted = false
        
        self.image_URL = ""
        self.image_URL_Date = 0
        
        self.used_a_loan = false
        self.loan_amount = 0
        self.loan_rate = 0
        self.loan_term = 0
        self.down_payment = 0
        self.monthly_loan_payment_amount = 0
        self.number_of_payments_paid = 0
        
        self.floor_estimate = 0
        self.floor_actual = 0
        self.roof_estimate = 0
        self.roof_actual = 0
        self.kitchen_estimate = 0
        self.kitchen_actual = 0
        self.bedroom_estimate = 0
        self.bedroom_actual = 0
        self.bathroom_estimate = 0
        self.bathroom_actual = 0
        self.foundation_estimate = 0
        self.foundation_actual = 0
        self.paint_estimate = 0
        self.paint_actual = 0
        self.HVAC_estimate = 0
        self.HVAC_actual = 0
        self.other_estimate = 0
        self.other_actual = 0
        self.total_expenses_actual = 0
        self.total_expenses_estimate = 0
    }
    
    init(_ key: String, _ address: String) {
        self.proType = .IOwn
        self.key = key
        self.user = ""
        self.bedroom = 0
        self.bathroom = 0
        self.square_feet = 0
        self.address = address
        self.city = ""
        self.state = ""
        self.zipcode = ""
        self.purchase_date = ""
        self.purchase_amt = 0.0
        self.cash_invested = 0.0
        self.prop_type = ""
        self.date_submitted = 0
        self.last_updated = 0
        self.user_id = 0
        
        self.millis = ""
        self.likes = 0
        self.liked = false
        self.deleted = false
        
        self.image_URL = ""
        self.image_URL_Date = 0
        
        self.used_a_loan = false
        self.loan_amount = 0
        self.loan_rate = 0
        self.loan_term = 0
        self.down_payment = 0
        self.monthly_loan_payment_amount = 0
        self.number_of_payments_paid = 0
        
        self.floor_estimate = 0
        self.floor_actual = 0
        self.roof_estimate = 0
        self.roof_actual = 0
        self.kitchen_estimate = 0
        self.kitchen_actual = 0
        self.bedroom_estimate = 0
        self.bedroom_actual = 0
        self.bathroom_estimate = 0
        self.bathroom_actual = 0
        self.foundation_estimate = 0
        self.foundation_actual = 0
        self.paint_estimate = 0
        self.paint_actual = 0
        self.HVAC_estimate = 0
        self.HVAC_actual = 0
        self.other_estimate = 0
        self.other_actual = 0
        self.total_expenses_estimate = 0
        self.total_expenses_actual = 0
    }
}

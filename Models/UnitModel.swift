//
//  UnitModel.swift
//  RealEstate
//
//  Created by CodeGradients on 06/08/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import Foundation

struct UnitModel {
    
    var key: String
    var unit_name: String
    var bedrooms: Int
    var bathrooms: Int
    var square_feet: Int
    var rent_month : Double
    var rent_annual: Double
    var rent_start: String
    var rent_end: String
    var rent_day: Int
    var month_ins: Double
    var annual_ins: Double
    var month_prot: Double
    var annual_prot: Double
    var month_mtg: Double
    var annual_mtg: Double
    var month_vac: Double
    var annual_vac: Double
    var month_repair: Double
    var annual_repair: Double
    var month_prom: Double
    var annual_prom: Double
    var month_util: Double
    var annual_util: Double
    var month_hoa: Double
    var annual_hoa: Double
    var month_other: Double
    var annual_other: Double
    var mtg_purchase_amt: Double
    var mtg_down_payment: Double
    var mtg_interest_rate: Double
    var mtg_loan_term: Double
    var notes: String
    
    var rent_roll_list: [RentRollModel]
    
    var total_operating_expenses_month: Double
    var operating_expenses_other_month: Double
    var total_non_operating_expenses_month: Double
    var non_operating_expenses_other_month: Double
    var capex_month: Double
    var total_operating_expenses_annual: Double
    var operating_expenses_other_annual: Double
    var total_non_operating_expenses_annual: Double
    var non_operating_expenses_other_annual: Double
    var capex_annual: Double
    var loan_balance: Double

    init() {
        self.key = ""
        self.unit_name = ""
        self.bedrooms = 0
        self.bathrooms = 0
        self.square_feet = 0
        self.rent_month  = 0.0
        self.rent_annual = 0.0
        self.rent_start = ""
        self.rent_end = ""
        self.rent_day = 1
        self.month_ins = 0.0
        self.annual_ins = 0.0
        self.month_prot = 0.0
        self.annual_prot = 0.0
        self.month_mtg = 0.0
        self.annual_mtg = 0.0
        self.month_vac = 0.0
        self.annual_vac = 0.0
        self.month_repair = 0.0
        self.annual_repair = 0.0
        self.month_prom = 0.0
        self.annual_prom = 0.0
        self.month_util = 0.0
        self.annual_util = 0.0
        self.month_hoa = 0.0
        self.annual_hoa = 0.0
        self.month_other = 0.0
        self.annual_other = 0.0
        self.mtg_purchase_amt = 0.0
        self.mtg_down_payment = 0.0
        self.mtg_interest_rate = 0.0
        self.mtg_loan_term = 0.0
        self.notes = ""
        
        self.rent_roll_list = []
        
        self.total_operating_expenses_month = 0.0
        self.operating_expenses_other_month = 0.0
        self.total_non_operating_expenses_month = 0.0
        self.non_operating_expenses_other_month = 0.0
        self.capex_month = 0.0
        self.total_operating_expenses_annual = 0.0
        self.operating_expenses_other_annual = 0.0
        self.total_non_operating_expenses_annual = 0.0
        self.non_operating_expenses_other_annual = 0.0
        self.capex_annual = 0.0
        self.loan_balance = 0.0
    }
}

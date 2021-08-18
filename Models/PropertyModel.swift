//
//  PropertyModel.swift
//  RealEstate
//
//  Created by Muhammad Umair on 21/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import Foundation

struct PropertyModel {
    var proType : PropertyType
    var key: String
    var user: String
    var address: String
    var purchase_date: String
    var cash_invested: Double
    var purchase_amt: Double
    var prop_type: String
    var millis: String
    var likes: Int
    var liked: Bool
    var deleted: Bool
    
    var units: [UnitModel]
    
    init() {
        self.proType = .IOwn
        self.key = ""
        self.user = ""
        self.address = ""
        self.purchase_date = ""
        self.purchase_amt = 0.0
        self.cash_invested = 0.0
        self.prop_type = ""
        self.millis = ""
        self.likes = 0
        self.liked = false
        self.deleted = false
        
        self.units = []
    }
    
    init(_ key: String, _ address: String) {
        self.key = key
        self.user = ""
        self.address = address
        self.purchase_date = ""
        self.purchase_amt = 0.0
        self.cash_invested = 0.0
        self.prop_type = ""
        self.millis = ""
        self.likes = 0
        self.liked = false
        self.deleted = false
        
        self.units = []
        self.proType = .IOwn
    }
}

//
//  RentRollModel.swift
//  RealEstate
//
//  Created by Umair on 11/06/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import Foundation

struct RentRollModel {
    
    var key: String
    var year: Int
    var month: Int
    var amount: Double
    var late_fee: Double
    var total_amount: Double
    var paid: Bool
    var image: String

    init() {
        self.key = ""
        self.year = 2020
        self.month = 0
        self.amount = 0.0
        self.late_fee = 0.0
        self.total_amount = 0.0
        self.paid = false
        self.image = ""
    }
}

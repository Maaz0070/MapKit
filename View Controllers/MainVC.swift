//
//  MainVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase

/**
 Main VC that controls all the different views.
 */
class MainVC: UIViewController {
    
    @IBOutlet weak var segment_scroll: UIScrollView!
    @IBOutlet weak var rent_view: BottomMenuItem!
    @IBOutlet weak var portfolio_view: BottomMenuItem!
    @IBOutlet weak var news_view: BottomMenuItem!
    @IBOutlet weak var prop_view: BottomMenuItem!
    @IBOutlet weak var add_prop_view: BottomMenuItem!
    @IBOutlet weak var settings_view: BottomMenuItem!
    
    var bottom_views: [BottomMenuItem]!
    
    static var properties_list = [PropertyModel]()
    static var all_properties_list = [PropertyModel]()
    
    /**
     Database Reference
     */
    let dbRef = Database.database().reference()
    
    var should_send_events = false
    
    fileprivate lazy var viewControllers: [UIViewController] = {
        return self.preparedViewControllers()
    }()
    
    /**
     Generic loading function.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segment_scroll.isScrollEnabled = false
        setupScrollView()
        
        updateCurrencyConstants()
        
        bottom_views = [rent_view, portfolio_view, news_view, settings_view]
        rent_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedBottomMenuItem(_:))))
        portfolio_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedBottomMenuItem(_:))))
        news_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedBottomMenuItem(_:))))
        add_prop_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedBottomMenuItem(_:))))
        settings_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedBottomMenuItem(_:))))
        
        setupDatabase()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let token = result?.token {
                self.dbRef.child("users").child(Constants.mineId).child("token").setValue(token)
            }
        }
    }
    
    /**
     Setting up some gradients and aesthetics.
     */
    override func viewDidAppear(_ animated: Bool) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        gradient.locations = [0.0 , 1.0]
        //        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        //        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    /**
     Returns an array of the VCs that can be selected using the bottom item buttons.
     */
    fileprivate func preparedViewControllers() -> [UIViewController] {
        return [RentRollVC.getController(), PortfolioVC.getController(), NewsFeedVC.getController(), SettingsVC.getController(), PropertyVC.getController()]
    }
    
    /**
     Calls appendViewController on MainVC instance
     */
    @objc func didPressedBottomMenuItem(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            self.appendViewController(index: view.tag)
        }
    }
    
    /**
     Switch current view that is shown.
     */
    func appendViewController(index: Int) {
        
        if index == 5 {
            let vc = AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropVC.storyboard_id) as! NewAddPropVC
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            present(vc, animated: true, completion: nil)
            
            return
        }
        
        for i in 0..<bottom_views.count {
            if i == index {
                bottom_views[i].activated = true
            } else {
                bottom_views[i].activated = false
            }
        }
        
        self.segment_scroll.subviews.forEach({ $0.removeFromSuperview() })
        let vc = self.children[index]
        vc.view.frame = CGRect(x: 0, y: 0, width: segment_scroll.frame.width, height: segment_scroll.frame.height)
        self.segment_scroll.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    /**
     Deactivates all bottom views. Also removes all subviews from segment scroll. Finds PropertyVC child instance, inits all the data as provided by the parameters, then adds as a subview.
     */
    func showPropertyDetails(_ model: PropertyModel, _ read: Bool = false) {
        bottom_views.forEach({ $0.activated = false })
        self.segment_scroll.subviews.forEach({ $0.removeFromSuperview() })
        if let vc = self.children[4] as? PropertyVC {
            vc.initPropertyData(model, read)
            vc.view.frame = CGRect(x: 0, y: 0, width: segment_scroll.frame.width, height: segment_scroll.frame.height)
            self.segment_scroll.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
    }
    
    /**
     Scroll view sizing and then loads the first VC in the VC array. Also calls setNextVC
     */
    fileprivate func setupScrollView() {
        segment_scroll.contentSize = CGSize(
            width: UIScreen.main.bounds.width * CGFloat(viewControllers.count),
            height: segment_scroll.frame.height
        )
        let vc = viewControllers[0]
        addChild(vc)
        vc.view.frame = CGRect(
            x: 0,
            y: 0,
            width: segment_scroll.frame.width,
            height: segment_scroll.frame.height
        )
        segment_scroll.addSubview(vc.view)
        vc.didMove(toParent: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.setNextVC()
        })
    }
    
    /**
     Adds all child controllers by cycling through an enum.
     */
    fileprivate func setNextVC() {
        for (index, viewController) in viewControllers.enumerated() {
            if(index != 0) {
                viewController.view.frame = CGRect(
                    x: UIScreen.main.bounds.width * CGFloat(index),
                    y: 0,
                    width: segment_scroll.frame.width,
                    height: segment_scroll.frame.height
                )
                addChild(viewController)
                //                scrollView.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }
        }
    }
    
    /**
     Switches the currency based on the settings placed in UserDefaults.
     */
    func updateCurrencyConstants() {
        let val = UserDefaults.standard.integer(forKey: "currency")
        switch val {
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
    }
    
    /**
     Removes all properties from MainVC.properties_list.
     */
    func setupDatabase() {
        MainVC.properties_list.removeAll(); MainVC.all_properties_list.removeAll();
        
        dbRef.child("admin").child("email").observe(.value) { (snapshot) in
            let email = snapshot.value as? String ?? ""
            Constants.admin_email = email
        }
        
        //        dbRef.child("properties").queryOrdered(byChild: "user").queryEqual(toValue: Constants.mineId)
        
        dbRef.child("properties").observe(.childAdded) { (snap) in
            var model = PropertyModel()
            if let proType = snap.childSnapshot(forPath: "property_status").value as? String {
                model.proType = proType == "Research" ? .Researching : .IOwn
            }
            model.key = snap.childSnapshot(forPath: "key").value as? String ?? ""
            model.user = snap.childSnapshot(forPath: "user").value as? String ?? ""
            model.address = snap.childSnapshot(forPath: "address").value as? String ?? ""
            model.purchase_date = snap.childSnapshot(forPath: "purchase_date").value as? String ?? Constants.getCurrentMillis()
            model.cash_invested = snap.childSnapshot(forPath: "cash_invested").value as? Double ?? 0.0
            model.purchase_amt = snap.childSnapshot(forPath: "purchase_amt").value as? Double ?? 0.0
            model.prop_type = snap.childSnapshot(forPath: "prop_type").value as? String ?? "Single Family"
            model.millis = snap.childSnapshot(forPath: "millis").value as? String ?? ""
            model.likes = Int(snap.childSnapshot(forPath: "likes").childrenCount)
            model.liked = snap.childSnapshot(forPath: "likes").childSnapshot(forPath: Constants.mineId).value as? Bool ?? false
            model.deleted = snap.childSnapshot(forPath: "deleted").value as? Bool ?? false
            
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
            
            if !model.deleted {
                MainVC.all_properties_list.append(model)
                if model.user == Constants.mineId {
                    MainVC.properties_list.append(model)
                    if self.should_send_events {
                        NotificationCenter.default.post(name: .minePropertyAdded, object: nil, userInfo: ["model": model])
                    }
                }
                
                //5958
                if self.should_send_events {
                    let rent = self.calcAnnualRent(model: model)
                    let expense = self.calcAnnualExpenses(model: model)
                    //
                    let price = model.purchase_amt
                    let cap = ((rent - expense) / price) * 100
                    
                    if !(cap.round(to: 1).isZero) {
                        NotificationCenter.default.post(name: .propertyAdded, object: nil)
                    }
                }
            }
        }
        
        dbRef.child("properties").observe(.childChanged) { (snap) in
            var model = PropertyModel()
            if let proType = snap.childSnapshot(forPath: "property_status").value as? String {
                model.proType = proType == "Research" ? .Researching : .IOwn
            }
            model.key = snap.childSnapshot(forPath: "key").value as? String ?? ""
            model.user = snap.childSnapshot(forPath: "user").value as? String ?? ""
            model.address = snap.childSnapshot(forPath: "address").value as? String ?? ""
            model.purchase_date = snap.childSnapshot(forPath: "purchase_date").value as? String ?? Constants.getCurrentMillis()
            model.cash_invested = snap.childSnapshot(forPath: "cash_invested").value as? Double ?? 0.0
            model.purchase_amt = snap.childSnapshot(forPath: "purchase_amt").value as? Double ?? 0.0
            model.prop_type = snap.childSnapshot(forPath: "prop_type").value as? String ?? "Single Family"
            model.millis = snap.childSnapshot(forPath: "millis").value as? String ?? ""
            model.likes = Int(snap.childSnapshot(forPath: "likes").childrenCount)
            model.liked = snap.childSnapshot(forPath: "likes").childSnapshot(forPath: Constants.mineId).value as? Bool ?? false
            model.deleted = snap.childSnapshot(forPath: "deleted").value as? Bool ?? false
            
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

            if let index = MainVC.all_properties_list.firstIndex(where: {$0.key == model.key}) {
                MainVC.all_properties_list[index] = model
            }
            
            if let index = MainVC.properties_list.firstIndex(where: {$0.key == model.key}) {
                MainVC.properties_list[index] = model
            }
            
            if model.deleted {
                MainVC.all_properties_list.removeAll(where: {$0.key == model.key})
                MainVC.properties_list.removeAll(where: {$0.key == model.key})
                NotificationCenter.default.post(name: .propertyRemoved, object: nil, userInfo: ["model": model])
            } else {
                NotificationCenter.default.post(name: .propertyChanged, object: nil, userInfo: ["model": model])
            }
        }
        
        dbRef.child("properties").observeSingleEvent(of: .value) { (snapshot) in
            self.should_send_events = true
            NotificationCenter.default.post(name: .didLoadInitialy, object: nil)
        }
    }
}

extension MainVC : PropertyAddedDelegate {
    func didAddedNewProperty(key: String) {
        for prop in MainVC.properties_list {
            if prop.key == key {
                let rent = self.calcAnnualRent(model: prop)
                let expense = calcAnnualExpenses(model: prop)
                let price = prop.purchase_amt
                let cap = ((rent - expense) / price) * 100
                
                if !(cap.round(to: 1).isZero) {
                    var tokens = [String]()
                    dbRef.child("users").observeSingleEvent(of: .value) { (snapshot) in
                        for snap in snapshot.children {
                            let data = (snap as! DataSnapshot)
                            let notif = data.childSnapshot(forPath: "prop_notif").value as? Bool ?? true
                            let token = data.childSnapshot(forPath: "token").value as? String ?? ""
                            if notif && !token.isEmpty {
                                if data.key != Constants.mineId {
                                    if !tokens.contains(token) {
                                        tokens.append(token)
                                    }
                                }
                            }
                        }
                        
                        let set = Set(tokens)
                        let filtered = Array(set)
                        
                        var city = ""
                        if let s_index = prop.address.indexOf(target: "\n") {
                            if let c_index = prop.address.indexOf(target: ",") {
                                city = prop.address.subStringRange(from: s_index + 1, to: c_index).trimmingCharacters(in: .whitespaces)
                            }
                        }
                        
                        if !tokens.isEmpty {
                            if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                                let notification = ["title" : "New Property - (\(city))", "body" : "A new property has been added to your News."]
                                let paramString: [String : Any] = ["registration_ids" : filtered, "notification" : notification]
                                let request = NSMutableURLRequest(url: url as URL)
                                
                                request.httpMethod = "POST"
                                request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
                                
                                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.setValue("key=AAAA2pXI43o:APA91bHtGBNNgygvr2drTdtp1cVfo8g5sFpbf6sCbG2uk9JyFPNc5D7-EZcq3x1vQ5jc0X_XOcpuNHIMiE98pILZ79DiAp-SXICE4zc_3pvyn9D9-DNzrUsSjN9WuGaetgNZl2234jo3", forHTTPHeaderField: "Authorization")
                                
                                let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                                    do {
                                        if let jsonData = data {
                                            if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                                                NSLog("Received data:\n\(jsonDataDict))")
                                            }
                                        }
                                    } catch let err as NSError {
                                        print(err.debugDescription)
                                    }
                                }
                                
                                task.resume()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Calculate annual expenses given a Property Model.
     */
    func calcAnnualExpenses(model: PropertyModel) -> Double {
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
     Calculate annual rent given a Property Model.
     */
    func calcAnnualRent(model: PropertyModel) -> Double {
        var rent = 0.0
        
        for unit in model.units {
            rent = rent + unit.rent_annual
        }
        
        return rent
    }
}

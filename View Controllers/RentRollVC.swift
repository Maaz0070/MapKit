
//
//  RentRollVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import RSSelectionMenu
import Firebase

class RentRollVC: UIViewController {
    
    @IBOutlet weak var rent_due_this_month_lbl: DashboardLabel!
    @IBOutlet weak var rent_due_last_month_lbl: DashboardLabel!
    @IBOutlet weak var rent_due_last_three_month_lbl: DashboardLabel!
    
    @IBOutlet weak var month_stack_view: UIStackView!
    @IBOutlet weak var month_lbl_topImage: UIImageView!
    @IBOutlet weak var month_lbl_bottomImage: UIImageView!
    @IBOutlet weak var month_label: UILabel!
    @IBOutlet weak var year_button: UIButton!
    @IBOutlet weak var select_button: UIButton!
    @IBOutlet weak var cells_collection: UICollectionView!
    
    var did_filtered = false
    
    var section_list = [RentRollUnitModel]()
    var temp_section_list = [RentRollUnitModel]()
    
    var selected_filter_model: FilterModel!

    let ascend_months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    let descend_months = ["DEC", "NOV", "OCT", "SEP", "AUG", "JUL", "JUN", "MAY", "APR", "MAR", "FEB", "JAN"]
    var months_list = [String]()
    
    var is_sorting_active = false
    
    var selected_dashboard_view: DashboardLabel!
    
    var collection_selected_cells = [IndexPath]()
    //940 scroll height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.months_list = self.descend_months
        
        cells_collection.delegate = self
        cells_collection.dataSource = self
        cells_collection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCollectionSelection(_:))))
        
        year_button.setTitle(String(Date().year), for: .normal)
        year_button.addTarget(self, action: #selector(didPressedYearButton(_:)), for: .touchUpInside)
        select_button.tag = 0
        select_button.addTarget(self, action: #selector(didPressedSelectButton), for: .touchUpInside)
                
        rent_due_this_month_lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedDashboardViews(_:))))
        rent_due_last_month_lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedDashboardViews(_:))))
        rent_due_last_three_month_lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedDashboardViews(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataSource), name: Notification.Name("properties"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .currencyUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .didLoadInitialy, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .minePropertyAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyRemoved, object: nil)
    }
    
    class func getController() -> RentRollVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: RentRollVC.storyboard_id) as! RentRollVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setupDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cells_collection.reloadData()
        
        updateDashboardViewsData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc func didReceiveNotificationCallback(_ notification: Notification) {
        if notification.name == .currencyUpdated {
            updateDashboardViewsData()
            cells_collection.reloadData()
        }
        
        if notification.name == .didLoadInitialy {
            setupDataSource()
        }
        
        if notification.name == .minePropertyAdded, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                for unit in model.units {
                    self.section_list.append(RentRollUnitModel(unit_model: unit, prop_model: model))
                    self.temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: model))
                }
                self.cells_collection.reloadData()
                self.updateDashboardViewsData()
            }
        }
        
        if notification.name == .propertyChanged, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                for unit in model.units {
                    if let index = self.section_list.firstIndex(where: {$0.prop_model.key == model.key && $0.unit_model.key == unit.key}) {
                        self.section_list[index] = RentRollUnitModel(unit_model: unit, prop_model: model)
                    } else {
                        if model.user == Constants.mineId {
                            self.section_list.append(RentRollUnitModel(unit_model: unit, prop_model: model))
                        }
                    }
                    
                    if let index = self.temp_section_list.firstIndex(where: {$0.prop_model.key == model.key && $0.unit_model.key == unit.key}) {
                        self.temp_section_list[index] = RentRollUnitModel(unit_model: unit, prop_model: model)
                    } else {
                        if model.user == Constants.mineId {
                            self.temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: model))
                        }
                    }
                }
                self.cells_collection.reloadData()
                self.updateDashboardViewsData()
            }
        }
        
        if notification.name == .propertyRemoved, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                self.section_list.removeAll(where: {$0.prop_model.key == model.key})
                self.temp_section_list.removeAll(where: {$0.prop_model.key == model.key})
                self.cells_collection.reloadData()
                self.updateDashboardViewsData()
            }
        }
    }
    
    @objc func setupDataSource() {
        section_list.removeAll(); temp_section_list.removeAll()
        
        for prop in MainVC.properties_list {
            for unit in prop.units {
                section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
                temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
            }
        }
        //section_list = MainVC.properties_list
        section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
        temp_section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
        cells_collection.reloadData()
        
        updateDashboardViewsData()
    }
    
    @objc func updateDataSource () {
        if !did_filtered {
            setupDataSource()
            return
        }
        var total_present = false
        self.section_list.removeAll { (pm) -> Bool in
            if pm.prop_model.key == "initial" {
                total_present = true
            }
            return pm.prop_model.key == "initial"
        }
        self.temp_section_list.removeAll { (pm) -> Bool in
            return pm.prop_model.key == "initial"
        }
        
        let list = self.section_list
        self.section_list.removeAll(); self.temp_section_list.removeAll()
        for prop in MainVC.properties_list {
            for unit in prop.units {
                section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
                temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
            }
        }
        //self.section_list = MainVC.properties_list
        let temp_list = MainVC.properties_list
        temp_list.forEach { (pm) in
            let index = list.firstIndex(where: { (md) -> Bool in
                return md.prop_model.key == pm.key
            })
            
            if index == nil {
                self.section_list.removeAll { (pmd) -> Bool in
                    return pmd.prop_model.key == pm.key
                }
                self.temp_section_list.removeAll { (pmd) -> Bool in
                    return pmd.prop_model.key == pm.key
                }
            }
        }
        
        if total_present {
            section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
            temp_section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
        }
        cells_collection.reloadData()
        
        updateDashboardViewsData()
    }
    
    @objc func didPressedYearButton(_ sender: UIButton) {
        var years = [String]()
        var selected = [String]()
        
        let current = Date().year
        
        years.append(String(current + 1))
        if sender.title(for: .normal) == "\(current + 1)" {
            selected.append(String(current + 1))
        }
        
        for i in 0...1 {
            let year = String(current - i)
            years.append(year)
            
            if sender.title(for: .normal) == year {
                selected.append(year)
            }
        }
        
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: years) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        selectionMenu.setSelectedItems(items: selected) { (s, i, b, d) in }
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            if let item = items.first {
                self.year_button.setTitle(item, for: .normal)
            }
            self.cells_collection.reloadData()
            
            self.updateDashboardViewsData()
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: 150), from: self)
    }
    
    @IBAction func didPressedFilterButton(_ sender: UIButton) {
        var selected = [String]()
        
        var titles: [String] {
            var t = [String]()
//            t.append("Total")
//            if self.section_list.contains(where: { (model) -> Bool in
//                return model.prop_model.address == "Total"}) {
//                selected.append("Total")
//            }
            
            for tt in MainVC.properties_list {
                t.append(tt.address)
                
                if self.section_list.contains(where: { (model) -> Bool in
                    return model.prop_model.address == tt.address}) {
                    selected.append(tt.address)
                }
            }
            return t
        }
        
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: SelectionVC.storyboard_id) as? SelectionVC
        vc?.items = titles
        vc?.selected = selected
        vc?.onDismiss = { (items) in
            self.section_list.removeAll(); self.temp_section_list.removeAll()
            
            self.did_filtered = true
            
            let list = items.sorted { (a, b) -> Bool in
                guard let first = titles.firstIndex(of: a) else {
                    return false
                }
                
                guard let second = titles.firstIndex(of: b) else {
                    return false
                }
                
                return first < second
            }
            
            for item in list {
                for md in MainVC.properties_list {
                    if md.address == item {
                        for unit in md.units {
                            self.section_list.append(RentRollUnitModel(unit_model: unit, prop_model: md))
                            self.temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: md))
                        }
                    }
                }
            }
            
//            if items.contains("Total") {
                self.section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
                self.temp_section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
//            }
            
            self.cells_collection.reloadData()
            
            self.updateDashboardViewsData()
        }
        
//        let v = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: FilterVC.storyboard_id) as! FilterVC
//        v.to_be_filtered_properties = MainVC.properties_list
//        if let mod = self.selected_filter_model {
//            v.to_be_filtered_filter_model = mod
//        } else {
//            v.to_be_filtered_filter_model = FilterModel()
//        }
//        v.onDismiss = { (items, filter) in
//            self.section_list.removeAll()
//            self.temp_section_list.removeAll()
//
//            self.selected_filter_model = filter
//
//            for prop in items {
//                for unit in prop.units {
//                    self.section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
//                    self.temp_section_list.append(RentRollUnitModel(unit_model: unit, prop_model: prop))
//                }
//            }
//
//            self.section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
//            self.temp_section_list.insert(RentRollUnitModel(unit_model: UnitModel(), prop_model: PropertyModel("initial", "Total")), at: 0)
//
//            self.cells_collection.reloadData()
//            self.updateDashboardViewsData()
//        }
        
        let nav = UINavigationController(rootViewController: vc!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func didPressedSelectButton() {
        if select_button.tag == 0 {
            select_button.tag = 1
            select_button.setTitle("Mark Paid", for: .normal)
            
            cells_collection.reloadData()
        } else {
            select_button.tag = 0
            select_button.setTitle("Select", for: .normal)
            
            let list = self.section_list
            for indexPath in collection_selected_cells {
                let model = list[indexPath.section - 1]
                let year = Int(year_button.title(for: .normal) ?? "\(Date().year)") ?? Date().year
                let month = self.mapMonthtoMonthIndex(mon: self.months_list[indexPath.item - 1])
                if let mod = getRentRollModel(model: model.unit_model, year: year, month: month) {
                    if mod.key.isEmpty {
                        let data = ["amount": mod.amount, "late_fee": 0.0, "year": mod.year,
                                    "month": mod.month, "paid": true, "image": ""] as [String : Any]
                        
                        let ref = Database.database().reference().child("properties").child(model.prop_model.key).child("units").child(model.unit_model.key).child("rent_rolls")
                        
                        if let key = ref.childByAutoId().key {
                            ref.child(key).updateChildValues(data)
                        }
                    } else {
                        Database.database().reference().child("properties").child(model.prop_model.key).child("units").child(model.unit_model.key).child("rent_rolls").child(mod.key).child("paid").setValue(true)
                    }
                }
            }
            
            collection_selected_cells.removeAll()
            cells_collection.reloadData()
        }
    }
    
    @objc func didPressedDashboardViews(_ sender: UITapGestureRecognizer) {
        self.section_list.removeAll()
        
        if let v = sender.view as? DashboardLabel {
            
            if let prev = self.selected_dashboard_view {
                let dshs = [rent_due_this_month_lbl, rent_due_last_month_lbl, rent_due_last_three_month_lbl]
                for dsh in dshs {
                    if prev != v {
                        dsh?.tag = 0
                    }
                }
            }
            
            if v == rent_due_this_month_lbl {
                if v.tag == 0 {
                    v.tag = 1
                    
                    let month = Date().month - 1
                    for section in self.temp_section_list {
                        if section.prop_model.key == "initial" {
                            self.section_list.append(section)
                        } else {
                            if let rent = getRentRollModel(model: section.unit_model, year: Date().year, month: month) {
                                if !rent.paid {
                                    self.section_list.append(section)
                                }
                            }
                        }
                    }
                    
                    self.selected_dashboard_view = rent_due_this_month_lbl
                    
                    self.months_list.removeAll { (mon) -> Bool in
                        return mon != mapMonthtoMonthString(index: month)
                    }
                    
                } else {
                    v.tag = 0
                    
                    self.selected_dashboard_view = nil
                    
                    for section in self.temp_section_list {
                        self.section_list.append(section)
                    }
                    
                    self.months_list = descend_months
                }
            }
            
            if v == rent_due_last_three_month_lbl {
                if v.tag == 0 {
                    v.tag = 1
                    
                    let month = Date().month - 1
                    var months = [String]()
                    
                    for i in 3..<9 {
                        let mon = month - i
                        if mon >= 0 {
                            months.append(mapMonthtoMonthString(index: mon))

                            for section in self.temp_section_list {
                                if section.prop_model.key == "initial" {
                                    if !propertyExists(section) {
                                        self.section_list.append(section)
                                    }
                                } else {
                                    if let rent = getRentRollModel(model: section.unit_model, year: Date().year, month: mon) {
                                        if !rent.paid {
                                            if !propertyExists(section) {
                                                self.section_list.append(section)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    self.months_list.removeAll { (mon) -> Bool in
                        return !months.contains(mon)
                    }
                    
                    self.selected_dashboard_view = rent_due_last_three_month_lbl
                    
                } else {
                    v.tag = 0
                    
                    self.selected_dashboard_view = nil
                    
                    for section in self.temp_section_list {
                        self.section_list.append(section)
                    }
                    
                    self.months_list = descend_months
                }
            }
            
            if v == rent_due_last_month_lbl {
                if v.tag == 0 {
                    v.tag = 1
                    
                    let month = Date().month - 1
                    var months = [String]()
                    
                    for i in 0..<3 {
                        let mon = month - i
                        if mon >= 0 {
                            months.append(mapMonthtoMonthString(index: mon))
                            
                            for section in self.temp_section_list {
                                if section.prop_model.key == "initial" {
                                    if !propertyExists(section) {
                                        self.section_list.append(section)
                                    }
                                } else {
                                    if let rent = getRentRollModel(model: section.unit_model, year: Date().year, month: mon) {
                                        if !rent.paid {
                                            if !propertyExists(section) {
                                                self.section_list.append(section)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    self.months_list.removeAll { (mon) -> Bool in
                        return !months.contains(mon)
                    }
                    
                    self.selected_dashboard_view = rent_due_last_month_lbl
                    
                } else {
                    v.tag = 0
                    
                    self.selected_dashboard_view = nil
                    for section in self.temp_section_list {
                        self.section_list.append(section)
                    }
                    
                    self.months_list = descend_months
                }
            }
        }
        
        cells_collection.reloadData()
    }
    
    func updateDashboardViewsData() {
        let year = Date().year
        let month = Date().month - 1
        
        var this_month = 0.0
        for prop in self.section_list {
            if prop.prop_model.key != "initial" {
                if let roll = getRentRollModel(model: prop.unit_model, year: year, month: month) {
                    if !roll.paid {
                        this_month += roll.total_amount
                    }
                }
            }
        }
        rent_due_this_month_lbl.text = Constants.formatNumber(number: this_month)
        rent_due_this_month_lbl.back_color = this_month.isZero ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        rent_due_this_month_lbl.isUserInteractionEnabled = !this_month.isZero
        
        var last_months = 0.0
        for prop in self.section_list {
            if prop.prop_model.key != "initial" {
                for i in 1..<4 {
                    let mon = month - i
                    if mon >= 0 {
                        if let purchase_date = Constants.buildDatefromMillis(millis: prop.prop_model.purchase_date) {
                            
                            var options = DateComponents()
                            options.year = year
                            options.month = mon + 1
                            let current = Calendar.current.date(from: options)
                            
                            if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                if let roll = getRentRollModel(model: prop.unit_model, year: year, month: mon) {
                                    if !roll.paid {
                                        last_months += roll.total_amount
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        rent_due_last_month_lbl.text = Constants.formatNumber(number: last_months)
        rent_due_last_month_lbl.back_color = last_months.isZero ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        rent_due_last_month_lbl.isUserInteractionEnabled = !last_months.isZero
        
        var three_months = 0.0
        for prop in self.section_list {
            if prop.prop_model.key != "initial" {
                for i in 4..<10 {
                    
                    let mon = month - i
                    if mon >= 0 {
                        if let purchase_date = Constants.buildDatefromMillis(millis: prop.prop_model.purchase_date) {
                            
                            var options = DateComponents()
                            options.year = year
                            options.month = mon + 1
                            let current = Calendar.current.date(from: options)
                            
                            if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                if let roll = getRentRollModel(model: prop.unit_model, year: year, month: mon) {
                                    if !roll.paid {
                                        three_months += roll.total_amount
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        rent_due_last_three_month_lbl.text = Constants.formatNumber(number: three_months)
        rent_due_last_three_month_lbl.back_color = three_months.isZero ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 0.8, blue: 0.8039215686, alpha: 1)
        rent_due_last_three_month_lbl.isUserInteractionEnabled = !three_months.isZero
    }
        
    func propertyExists(_ model: RentRollUnitModel) -> Bool {
        for mod in self.section_list {
            if (mod.prop_model.key == model.prop_model.key) && (mod.unit_model.key == model.unit_model.key) {
                return true
            }
        }
        return false
    }
}

extension RentRollVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.months_list.count + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return section_list.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        var height = collectionView.frame.height - 90
        //        height = height / 12
        
        var width = 120
        var height = 50
        
        if indexPath.section == 0 {
            width = 90
        }
        
        if indexPath.item == 0 {
            height = 85
        }
        
        return CGSize(width: width, height: height)
    }
    
    @objc func handleCollectionSelection(_ sender: UITapGestureRecognizer)  {
        if let indexPath = self.cells_collection.indexPathForItem(at: sender.location(in: self.cells_collection)) {
            if indexPath.section == 0 {
                if indexPath.item == 0 {
                    let list = self.months_list
                    self.months_list = list.reversed()
                    self.cells_collection.reloadData()
                    self.cells_collection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                    
                    self.is_sorting_active = !self.is_sorting_active
                }
            } else {
                let model = self.section_list[indexPath.section - 1]
                if model.prop_model.key != "initial" {
                    if indexPath.item == 0 {
                        if let p = self.parent as? MainVC {
                            p.showPropertyDetails(model.prop_model)
                        }
                    } else {
                        if let purchase_date = Constants.buildDatefromMillis(millis: model.prop_model.purchase_date) {
                            let year = Int(year_button.title(for: .normal) ?? "\(Date().year)") ?? Date().year
                            let month = self.mapMonthtoMonthIndex(mon: self.months_list[indexPath.item - 1])
                            
                            var options = DateComponents()
                            options.year = year
                            options.month = month + 1
                            let current = Calendar.current.date(from: options)
                            
                            if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                if select_button.tag == 0 {
                                    guard let mod = getRentRollModel(model: model.unit_model, year: year, month: month) else { return }
                                    
                                    let rent = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: AddRentRollVC.storyboard_id) as? AddRentRollVC
                                    rent?.modalPresentationStyle = .custom
                                    AddRentRollVC.model = model
                                    AddRentRollVC.rent_roll_model = mod
                                    self.present(rent!, animated: true, completion: nil)
                                } else {
                                    if self.collection_selected_cells.contains(indexPath) {
                                        self.collection_selected_cells.removeAll { (ind) -> Bool in
                                            return ind.section == indexPath.section && ind.item == indexPath.item
                                        }
                                        self.cells_collection.reloadItems(at: [indexPath])
                                    } else {
                                        self.collection_selected_cells.append(indexPath)
                                        self.cells_collection.reloadItems(at: [indexPath])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RentRollCell.identifier, for: indexPath) as? RentRollCell {
            
            cell.textLabel.text = ""
            cell.textLabel.textColor = .darkText
            cell.contentView.backgroundColor = .white
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.cornerRadius = 0
            
            cell.contentView.isHidden = false
            
            cell.contentView.viewWithTag(1212)?.removeFromSuperview()
            
            if indexPath.section == 0 {
                if indexPath.item == 0 {
                    cell.textLabel.text = "Month"
                    
                    if self.is_sorting_active {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.tag = 1212
                        view.tintColor = .darkText
                        if let image = UIImage(systemName: "arrow.up") {
                            view.image = image
                        }
                        cell.contentView.addSubview(view)
                        NSLayoutConstraint.activate([
                            view.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                            view.widthAnchor.constraint(equalToConstant: 20),
                            view.heightAnchor.constraint(equalToConstant: 20),
                            view.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: -20)
                        ])
                    } else {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.tag = 1212
                        view.tintColor = .darkText
                        if let image = UIImage(systemName: "arrow.down") {
                            view.image = image
                        }
                        cell.contentView.addSubview(view)
                        NSLayoutConstraint.activate([
                            view.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                            view.widthAnchor.constraint(equalToConstant: 20),
                            view.heightAnchor.constraint(equalToConstant: 20),
                            view.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: 20)
                        ])
                    }
                } else {
                    cell.textLabel.text = self.months_list[indexPath.item - 1]
                }
                
                return cell
            }
            
            let model = self.section_list[indexPath.section - 1]
            if model.prop_model.key == "initial" {
                if indexPath.item == 0 {
                    cell.textLabel.text = "Total"
                    cell.contentView.backgroundColor = .white
                } else {
                    var total = 0.0
                    let year = Int(year_button.title(for: .normal) ?? "\(Date().year)") ?? Date().year
                    let month = self.mapMonthtoMonthIndex(mon: self.months_list[indexPath.item - 1])
                    
                    for mod in self.section_list {
                        if mod.prop_model.key != "initial" {
                            if let purchase_date = Constants.buildDatefromMillis(millis: mod.prop_model.purchase_date) {
                                
                                var options = DateComponents()
                                options.year = year
                                options.month = month + 1
                                let current = Calendar.current.date(from: options)
                                
                                if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                                    if let rent = self.getRentRollModel(model: mod.unit_model, year: year, month: month) {
                                        if let _ = selected_dashboard_view {
                                            if !rent.paid {
                                                total = total + rent.total_amount
                                            }
                                        } else {
                                            total = total + rent.total_amount
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    cell.textLabel.text = Constants.formatNumber(number: total)
                    cell.textLabel.textColor = .white
                    cell.contentView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7019607843, blue: 1, alpha: 1)
                    cell.contentView.layer.cornerRadius = 8
                    
                    if total == 0.0 {
                        cell.textLabel.textColor = .darkText
                        cell.contentView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
                        cell.contentView.layer.borderWidth = 1
                        cell.contentView.layer.borderColor = #colorLiteral(red: 0.3333333333, green: 0.3529411765, blue: 0.4, alpha: 1).cgColor
                    }
                }
            } else {
                if indexPath.item == 0 {
                    let address = model.prop_model.address.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "#", with: " ")
                    if model.prop_model.prop_type == "Multi-Family Prop" {
                        cell.textLabel.text = address + "\nUnit : " + model.unit_model.unit_name
                    } else {
                        cell.textLabel.text = address
                    }
                    cell.textLabel.textColor = .darkText
                    cell.contentView.backgroundColor = .white
                    cell.contentView.layer.cornerRadius = 0
                } else {
                    let year = Int(year_button.title(for: .normal) ?? "\(Date().year)") ?? Date().year
                    let month = self.mapMonthtoMonthIndex(mon: self.months_list[indexPath.item - 1])
                    
                    if let purchase_date = Constants.buildDatefromMillis(millis: model.prop_model.purchase_date) {
                        
                        var options = DateComponents()
                        options.year = year
                        options.month = month + 1
                        let current = Calendar.current.date(from: options)
                        
                        if current!.timeIntervalSince1970 > purchase_date.timeIntervalSince1970 {
                            if let rent = getRentRollModel(model: model.unit_model, year: year, month: month) {
                                cell.textLabel.text = Constants.formatNumber(number: rent.total_amount)
                                
                                cell.contentView.layer.cornerRadius = 8
                                
                                if collection_selected_cells.contains(indexPath) {
                                    cell.textLabel.textColor = .white
                                    cell.contentView.backgroundColor = #colorLiteral(red: 0.03137254902, green: 0.6941176471, blue: 0.4117647059, alpha: 1)
                                    cell.contentView.layer.borderWidth = 0
                                } else {
                                    if rent.paid {
                                        cell.textLabel.textColor = .white
                                        cell.contentView.backgroundColor = #colorLiteral(red: 0.03137254902, green: 0.6941176471, blue: 0.4117647059, alpha: 1)
                                        
                                        if let _ = selected_dashboard_view {
                                            cell.contentView.isHidden = true
                                        }
                                    } else {
                                        if rent.total_amount == 0.0 {
                                            cell.contentView.backgroundColor = .white
                                            cell.contentView.layer.borderWidth = 1
                                            cell.contentView.layer.borderColor = #colorLiteral(red: 0.3333333333, green: 0.3529411765, blue: 0.4, alpha: 1).cgColor
                                        } else {
                                            cell.contentView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
                                            cell.contentView.layer.borderWidth = 1
                                            cell.contentView.layer.borderColor = #colorLiteral(red: 0.3333333333, green: 0.3529411765, blue: 0.4, alpha: 1).cgColor
                                        }
                                    }
                                }
                            } else {
                                cell.contentView.isHidden = true
                            }
                        } else {
                            cell.contentView.isHidden = true
                        }
                    }
                }
            }
            
            if select_button.tag == 1 {
                if indexPath.item != 0 {
                    cell.contentView.layer.borderWidth = 1
                    cell.contentView.layer.borderColor = #colorLiteral(red: 0.3607843137, green: 0.7019607843, blue: 1, alpha: 1)
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func mapMonthtoMonthIndex(mon: String) -> Int {
        switch mon {
        case "DEC":
            return 11
        case "NOV":
            return 10
        case "OCT":
            return 9
        case "SEP":
            return 8
        case "AUG":
            return 7
        case "JUL":
            return 6
        case "JUN":
            return 5
        case "MAY":
            return 4
        case "APR":
            return 3
        case "MAR":
            return 2
        case "FEB":
            return 1
        case "JAN":
            return 0
        default:
            return 0
        }
    }
    
    func mapMonthtoMonthString(index: Int) -> String {
         switch index {
         case 0:
            return "JAN"
         case 1:
             return "FEB"
         case 2:
             return "MAR"
         case 3:
             return "APR"
         case 4:
             return "MAY"
         case 5:
             return "JUN"
         case 6:
             return "JUL"
         case 7:
             return "AUG"
         case 8:
             return "SEP"
         case 9:
             return "OCT"
         case 10:
             return "NOV"
         case 11:
             return "DEC"
         default:
             return ""
         }
     }
    
    func mapIndextoMonth(index: Int) -> Int {
        switch index {
        case 1:
            return 11
        case 2:
            return 10
        case 3:
            return 9
        case 4:
            return 8
        case 5:
            return 7
        case 6:
            return 6
        case 7:
            return 5
        case 8:
            return 4
        case 9:
            return 3
        case 10:
            return 2
        case 11:
            return 1
        case 12:
            return 0
        default:
            return 0
        }
    }
    
    func getRentRollModel(model: UnitModel, year: Int, month: Int) -> RentRollModel? {
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
        return nil
    }
}

class RentRollCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
}

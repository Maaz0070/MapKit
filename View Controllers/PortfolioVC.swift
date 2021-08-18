//
//  PortfolioVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 18/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import RSSelectionMenu
import Firebase

class PortfolioVC: UIViewController {
    
    @IBOutlet weak var portfolio_collection: UICollectionView!
    @IBOutlet weak var cap_rate_button: PortfolioHeaderView!
    @IBOutlet weak var cash_flow_button: PortfolioHeaderView!
    @IBOutlet weak var income_button: PortfolioHeaderView!
    @IBOutlet weak var expenses_button: PortfolioHeaderView!
    @IBOutlet weak var segmentController: UISegmentedControl!

    
    var dataSource = [PropertyModel](){
        didSet{
            if dataSource.count>0{
//            dataSource.insert(PropertyModel("initial", "Total"), at: 0)
            }
        }
    }
    var section_list = [PropertyModel]()
    var selected_filter_model: FilterModel!
    var selected_prop_type = "ALL"
    
    var addProText = "Add a property you own to start building your rental property portfolio"
    let addPro = "Add a property"
    let addProLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portfolio_collection.delegate = self
        portfolio_collection.dataSource = self
        portfolio_collection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedPortfolioCollectionItem(_:))))
        
        cap_rate_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        cash_flow_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        income_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        expenses_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        
        cap_rate_button.hideAllIndicators()
        cash_flow_button.hideAllIndicators()
        income_button.hideAllIndicators()
        expenses_button.hideAllIndicators()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .currencyUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .didLoadInitialy, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .minePropertyAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyRemoved, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if cap_rate_button.isIndicatorShown() {
            applySorting(v: cap_rate_button)
        }
        
        if cash_flow_button.isIndicatorShown() {
            applySorting(v: cash_flow_button)
        }
        
        if income_button.isIndicatorShown() {
            applySorting(v: income_button)
        }
        
        if expenses_button.isIndicatorShown() {
            applySorting(v: expenses_button)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        portfolio_collection.collectionViewLayout.invalidateLayout()
        setupDataSource()
    }
    
    /// Check which defined notification executes a callback and display portfolio view accrodingly
    /// - Parameter notification: notification defined on portfolio screen
    @objc func didReceiveNotificationCallback(_ notification: Notification) {
        if notification.name == .currencyUpdated {
            self.portfolio_collection.reloadData()
        }
        
        if notification.name == .didLoadInitialy {
            setupDataSource()
        }
        
        if notification.name == .minePropertyAdded, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                self.section_list.append(model)
                self.portfolio_collection.reloadData()
            }
        }
        
        if notification.name == .propertyChanged, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                if let index = self.section_list.firstIndex(where: {$0.key == model.key}) {
                    self.section_list[index] = model
                }
                self.portfolio_collection.reloadData()
            }
        }
        
        if notification.name == .propertyRemoved, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                self.section_list.removeAll(where: {$0.key == model.key})
                self.portfolio_collection.reloadData()
            }
        }
    }
    
    /// Pull data from Main property models
    @objc func setupDataSource() {
        section_list.removeAll()
        
        section_list = MainVC.properties_list
//        section_list.insert(PropertyModel("initial", "Total"), at: 0)
        if segmentController.selectedSegmentIndex == 0{
        dataSource = section_list.filter{$0.proType == .IOwn}
        }else{
            dataSource = section_list.filter{$0.proType == .Researching}
        }
        dataSource.insert(PropertyModel("initial", "Total"), at: 0)

        portfolio_collection.reloadData()
    }
    
    class func getController() -> PortfolioVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: PortfolioVC.storyboard_id) as! PortfolioVC
    }
    
    /// Triggered when any button on the stackview is pressed. Sorts and displays the properties in the appropiate fashion.
    /// - Parameter sender: Tap Gesture Recognizer on the buttons in Portfolio VC
    @objc func didPressedStackViews(_ sender: UITapGestureRecognizer) {
        if let v = sender.view {
            
            var total_present = false
            self.dataSource.removeAll { (pm) -> Bool in
                if pm.key == "initial" {
                    total_present = true
                }
                return pm.key == "initial"
            }
            
            cap_rate_button.hideAllIndicators()
            cash_flow_button.hideAllIndicators()
            income_button.hideAllIndicators()
            expenses_button.hideAllIndicators()
            
            if v == cap_rate_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.capRate() < pml.capRate()
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.capRate() > pml.capRate()
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshList()
                    if total_present {
                        dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                    }
                    self.portfolio_collection.reloadData()
                    return
                }
                
                cap_rate_button.showIndicator(pos: v.tag)
            }
            
            if v == cash_flow_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) < (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshList()
                    if total_present {
                        let initial = dataSource.filter{$0.key == "initial"}
                        if initial.count==0{
                        dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                        }
                    }
                    self.portfolio_collection.reloadData()
                    return
                }
                
                cash_flow_button.showIndicator(pos: v.tag)
            }
            
            if v == income_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualRent() < pml.calcAnnualRent()
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualRent() > pml.calcAnnualRent()
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshList()
                    if total_present {
                        let initial = dataSource.filter{$0.key == "initial"}
                        if initial.count==0{
                        dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                        }                    }
                    self.portfolio_collection.reloadData()
                    return
                }
                
                income_button.showIndicator(pos: v.tag)
            }
            
            if v == expenses_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualExpenses() < pml.calcAnnualExpenses()
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualExpenses() > pml.calcAnnualExpenses()
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshList()
                    if total_present {
                        let initial = dataSource.filter{$0.key == "initial"}
                        if initial.count==0{
                        dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                        }                    }
                    self.portfolio_collection.reloadData()
                    return
                }
                
                expenses_button.showIndicator(pos: v.tag)
            }
            
            v.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
            for sv in v.subviews {
                if let lbl = sv as? UILabel {
                    lbl.textColor = .white
                }
            }
            
            if total_present {
                let initial = dataSource.filter{$0.key == "initial"}
                if initial.count==0{
                dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                }            }
            
            self.portfolio_collection.reloadData()
        }
    }
    
    /// Sorts the properties in order depending on current button and
    /// - Parameter v: header view on portfolio VC
    func applySorting(v: PortfolioHeaderView) {
        var total_present = false
        self.dataSource.removeAll { (pm) -> Bool in
            if pm.key == "initial" {
                total_present = true
            }
            return pm.key == "initial"
        }
        
        if v == cap_rate_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.capRate() < pml.capRate()
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.capRate() > pml.capRate()
                }
            }
            
            cap_rate_button.showIndicator(pos: v.tag)
        }
        
        if v == cash_flow_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) < (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                }
            }
            
            cash_flow_button.showIndicator(pos: v.tag)
        }
        
        if v == income_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualRent() < pml.calcAnnualRent()
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualRent() > pml.calcAnnualRent()
                }
            }
            
            income_button.showIndicator(pos: v.tag)
        }
        
        if v == expenses_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualExpenses() < pml.calcAnnualExpenses()
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualExpenses() > pml.calcAnnualExpenses()
                }
            }
            
            expenses_button.showIndicator(pos: v.tag)
        }
        
        if total_present {
            dataSource.insert(PropertyModel("initial", "Total"), at: 0)
        }
        
        self.portfolio_collection.reloadData()
    }
    
    /// Pressing filter button shows a view controller to select filters. Displays properties that match the selected filters
    /// - Parameter sender: Filter button on PortfolioVC
    @IBAction func didPressedFilterButton(_ sender: UIButton) {
        
        var selected = [String]()
        
        var titles: [String] {
            var t = [String]()
//            t.append("Total")
//            if self.section_list.contains(where: { (model) -> Bool in
//                return model.address == "Total"}) {
//                selected.append("Total")
//            }
            
            for tt in MainVC.properties_list {
                t.append(tt.address)
                
                if self.dataSource.contains(where: { (model) -> Bool in
                    return model.address == tt.address}) {
                    selected.append(tt.address)
                }
            }
            return t
        }
        
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: SelectionVC.storyboard_id) as? SelectionVC
        vc?.items = titles
        vc?.selected = selected
        vc?.onDismiss = { (items) in
            self.dataSource.removeAll()
            
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
                        self.dataSource.append(md)
                    }
                }
            }
            
//            if items.contains("Total") {
                self.dataSource.insert(PropertyModel("initial", "Total"), at: 0)
//            }
            
            self.portfolio_collection.reloadData()
            self.portfolio_collection.collectionViewLayout.invalidateLayout()
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
//
//            self.selected_filter_model = filter
//
//            for prop in items {
//                self.section_list.append(prop)
//            }
//
//            self.section_list.insert(PropertyModel("initial", "Total"), at: 0)
//            self.portfolio_collection.reloadData()
//        }
        
        let nav = UINavigationController(rootViewController: vc!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didPressedTypeFilterButton(_ sender: UIButton) {
        //var titles = ["ALL", "Single Family", "Condo/Townhome", "Multi-Family Prop", "Commercial", "Other"]
        var titles = ["ALL"]
        for prop in MainVC.properties_list {
            if !titles.contains(prop.prop_type) {
                titles.append(prop.prop_type)
            }
        }
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        var selected: [String] = []
        selected.append(selected_prop_type)
        selectionMenu.setSelectedItems(items: selected) { (s, i, b, d) in }
        
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            if let first = items.first {
                self.selected_prop_type = first
                
                if first == "ALL" {
                    self.setupDataSource()
                } else {
                    self.dataSource.removeAll()
                    
                    for prop in MainVC.properties_list {
                        if prop.prop_type == first {
                            self.dataSource.append(prop)
                        }
                    }
                    
                    self.dataSource.insert(PropertyModel("initial", "Total"), at: 0)
                    self.portfolio_collection.reloadData()
                }
            }
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
    }
    
    func refreshList() {
        let list = self.dataSource
        self.dataSource = MainVC.properties_list
        let temp_list = MainVC.properties_list
        temp_list.forEach { (pm) in
            let index = list.firstIndex(where: { (md) -> Bool in
                return md.key == pm.key
            })
            
            if index == nil {
                self.dataSource.removeAll { (pmd) -> Bool in
                    return pmd.key == pm.key
                }
            }
        }
    }
}

protocol SectionColorDelegate: UICollectionViewDelegate {
    func collectionView(sectionColorAt indexPath: IndexPath) -> UIColor
}

extension PortfolioVC : SectionColorDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if dataSource.count==0{
            if segmentController.selectedSegmentIndex == 0{
                addProText = "Add a property you own to start building your rental property portfolio"
            }else{
                addProText = "Add a property to research and potentially add to your rental property portfolio"

            }
            let formattedText = String.format(strings: [addPro],
                                                boldFont: UIFont.boldSystemFont(ofSize: 15),
                                                boldColor: UIColor.blue,
                                                inString: addProText,
                                                font: UIFont.systemFont(ofSize: 15),
                                                color: UIColor.black)
            addProLabel.attributedText = formattedText
            addProLabel.numberOfLines = 0
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
            addProLabel.addGestureRecognizer(tap)
            addProLabel.isUserInteractionEnabled = true
            addProLabel.textAlignment = .center
            collectionView.backgroundView = addProLabel
        }else{
            collectionView.restore()
        }
        return dataSource.count
//        return section_list.count
    }
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
//        let addProString = addProText as NSString
//        let addProRange = addProString.range(of: addPro)
//
//        let tapLocation = gesture.location(in: addProLabel)
//        let index = addProLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

//        if checkRange(addProRange, contain: index) == true {
            let vc = AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropVC.storyboard_id) as! NewAddPropVC
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
//        self.navigationController?.pushViewController(vc, animated: true)
            present(vc, animated: true, completion: nil)
//            return
//        }

        
    }
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(sectionColorAt indexPath: IndexPath) -> UIColor {
        let model = self.dataSource[indexPath.section]
        return model.key == "initial" ? #colorLiteral(red: 0.3607843137, green: 0.7019607843, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width - 70
        width = width / 3
        
        if indexPath.item == 0 {
            return CGSize(width: collectionView.frame.width, height: 40)
        } else if indexPath.item == 1 {
            return CGSize(width: 70, height: 40)
        }
        return CGSize(width: width - 5, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PortfolioCell.identifier, for: indexPath) as? PortfolioCell {
                        
            cell.textLabel.style { (lb) in
                lb.textAlignment = indexPath.item == 0 ? .left : .center
                lb.topInset = 0; lb.rightInset = 0; lb.bottomInset = 0; lb.leftInset = 0
            }
            
            cell.contentView.style { (v) in
                v.backgroundColor = .white
                v.layer.borderWidth = 0
                v.layer.cornerRadius = 10
                v.viewWithTag(1212)?.removeFromSuperview()
                v.viewWithTag(1213)?.removeFromSuperview()
                v.viewWithTag(1214)?.removeFromSuperview()
            }
            
            let model = self.dataSource[indexPath.section]
            if model.key == "initial" {
                cell.textLabel.text = "TOTAL"
                switch indexPath.item {
                case 0:
                    //                    cell.textLabel.text = model.address
                    cell.textLabel.textColor = .darkText
                    cell.contentView.backgroundColor = .clear
                    break
                case 1:
                    var cash = 0.0; var purchase = 0.0
                    var  rentTotal = 0.0
                    var expTotal = 0.0
                    for md in self.dataSource {
                        let exp = md.calcAnnualExpenses()
                        let rent = md.calcAnnualRent()
                        cash = cash + (rent - exp)
//                        cash =   (rent - exp)
                        purchase = purchase + md.purchase_amt
                        expTotal = expTotal + exp
                        rentTotal = rentTotal + rent
                    }
                    var cap = 0.0
                    if !purchase.isZero && !cash.isZero {
                        cap = (cash / purchase) * 100
                    }
                    cap = 0.0
                    for itemModel in self.dataSource {
                        if itemModel.capRate().isNaN == false {
                            cap = cap + itemModel.capRate()
                        }
                    }
                //
                    
                    cell.textLabel.text = String(format: "%.02f", cap) + "%"
                    cell.textLabel.textColor = cap.portfolio_cell_text_color
                    
                    cell.contentView.backgroundColor = cap.portfolio_cell_background_color
                    cell.contentView.layer.borderWidth = 0
                    
                    break
                case 2:
                    var diff = 0.0
                    var exps = 0.0
                    var rent = 0.0

//                    for md in self.dataSource {
//                        let exp = md.calcAnnualExpenses()
//                        let rent = md.calcAnnualRent()
//                        diff = diff + (rent - exp)
//                    }
                    for md in self.dataSource {
                        if let vc = md.units as? PropUnitVC {
                        
                              }
                    }
                    
                    for itemModel in self.dataSource {
                        var exp = 0.0
                        var rent = 0.0
    //                    diff = diff + (rent - exp)
                        
                        if itemModel.calcAnnualExpenses().isNaN == false {
                            exp = itemModel.calcAnnualExpenses()
                        }
                        if itemModel.calcAnnualRent().isNaN == false {
                            rent = itemModel.calcAnnualRent()
                        }
                        let difference = rent - exp
                        
                        diff = diff + difference
                    }
                    
                    cell.textLabel.text = Constants.formatNumber(number: diff)
                    cell.textLabel.textColor = diff.portfolio_cell_text_color
                    
                    cell.contentView.backgroundColor = diff.portfolio_cell_background_color
                    cell.contentView.layer.borderWidth = 0
                    
                    break
                case 3:
                    var rent = 0.0
                    for md in self.dataSource {
                        rent = rent + md.calcAnnualRent()
                    }
                    cell.textLabel.text = Constants.formatNumber(number: rent)
                    cell.textLabel.textColor = .darkText
                    
                    cell.contentView.style { (v) in
                        v.layer.borderWidth = 1
                        v.layer.borderColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
                    }
                    
                    break
                case 4:
                    var exps = 0.0
                    for md in self.dataSource {
                        exps = exps + md.calcAnnualExpenses()
                    }
                    cell.textLabel.text = Constants.formatNumber(number: exps)
                    cell.textLabel.textColor = .darkText
                    
                    cell.contentView.style { (v) in
                        v.layer.borderWidth = 1
                        v.layer.borderColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
                    }
                default:
                    break
                }
            } else {
                switch indexPath.item {
                case 0:
                    cell.textLabel.text = "   " + model.address.replacingOccurrences(of: "#", with: " ").replacingOccurrences(of: "\n", with: " ")
                    cell.textLabel.textColor = .darkText
                    cell.textLabel.rightInset = 30
                    cell.textLabel.leftInset = 20 + model.likes.stringValue.frame(size: CGSize(width: 40, height: 20), font: cell.textLabel.font).width
                                
                    let heart = Initializer<UIImageView>.initialize {
                        $0.translatesAutoresizingMaskIntoConstraints = false;
                        $0.tag = 1213; $0.tintColor = model.liked ? #colorLiteral(red: 0.8901960784, green: 0.1490196078, blue: 0.2117647059, alpha: 1) : .darkText; $0.image = UIImage(systemName: "heart.fill")
                    }
                    cell.contentView.addSubview(heart)
                    NSLayoutConstraint.activate([
                        heart.width == 20, heart.height == 20, heart.centerY == cell.contentView.centerY, heart.left == cell.contentView.left
                    ])
                    
                    let likes = Initializer<UILabel>.initialize {
                        $0.translatesAutoresizingMaskIntoConstraints = false;
                        $0.tag = 1214; $0.adjustsFontSizeToFitWidth = true; $0.font = cell.textLabel.font
                        $0.text = model.likes.stringValue
                    }
                    cell.contentView.addSubview(likes)
                    NSLayoutConstraint.activate([
                        likes.width == model.likes.stringValue.frame(size: CGSize(width: 40, height: 20), font: cell.textLabel.font).width,
                        likes.height == 20, likes.centerY == cell.contentView.centerY, likes.left == heart.right + 4
                    ])
                    
                    let arrow = Initializer<UIImageView>.initialize {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        $0.tag = 1212; $0.tintColor = .darkText; $0.image = UIImage(systemName: "arrow.right")
                    }
                    cell.contentView.addSubview(arrow)
                    NSLayoutConstraint.activate([
                        arrow.width == 20, arrow.height == 20, arrow.centerY == cell.contentView.centerY, arrow.right == cell.contentView.right - 10
                    ])
                    
                    break
                case 1:
                    let cap = model.capRate()
                    cell.textLabel.text = String(format: "%.02f", cap) + "%"
                    cell.textLabel.textColor = cap.portfolio_cell_text_color
                    
                    cell.contentView.backgroundColor = cap.portfolio_cell_background_color
                    cell.contentView.layer.borderWidth = 0
                    
                    break
                case 2:
                    let exp = model.calcAnnualExpenses()
                    let rent = model.calcAnnualRent()
//                    diff = diff + (rent - exp)
                    let diff = rent - exp
                    cell.textLabel.text = Constants.formatNumber(number: diff)
                    cell.textLabel.textColor = diff.portfolio_cell_text_color
                    
                    cell.contentView.backgroundColor = diff.portfolio_cell_background_color
                    cell.contentView.layer.borderWidth = 0
                    
                    break
                case 3, 4:
                    let value = indexPath.item == 3 ? model.calcAnnualRent() : model.calcAnnualExpenses()
                                       
                    cell.textLabel.style { (lb) in
                        lb.text = Constants.formatNumber(number: value)
                        lb.textColor = .darkText
                    }
                    
                    cell.contentView.style { (v) in
                        v.layer.borderWidth = 1
                        v.layer.borderColor = #colorLiteral(red: 0.0862745098, green: 0.3215686275, blue: 0.9411764706, alpha: 1)
                    }
                    
                    break
                default:
                    break
                }
            }
            
            //cell.contentView.backgroundColor = .random
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    @objc func didPressedPortfolioCollectionItem(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.portfolio_collection)
        if let indexPath = self.portfolio_collection.indexPathForItem(at: location) {
            var model = dataSource[indexPath.section]
            if model.key != "initial" {
                if location.x < 30 {
                    let bool = !model.liked
                    Database.database().reference().child("properties").child(model.key).child("likes").child(Constants.mineId).setValue(bool ? true : nil)
                    
                    if let index = dataSource.firstIndex(where: {$0.key == model.key}) {
                        let count = bool ? 1 : -1
                        model.likes += count
                        model.liked = bool
                        dataSource[index] = model
                    }
                    portfolio_collection.reloadItems(at: [indexPath])
                } else {
                    if indexPath.item == 0 {
                        if let p = self.parent as? MainVC {
                            p.showPropertyDetails(model, false)
                        }
                    }
                }
            }
        }
    }
}


class PortfolioCell : UICollectionViewCell {
    @IBOutlet weak var textLabel: PaddingLabel!
}

extension Double {
    var portfolio_cell_background_color: UIColor {
        
        if self > 0 {
            return #colorLiteral(red: 0.03137254902, green: 0.6941176471, blue: 0.4117647059, alpha: 1)
        }
        
        if self < 0 {
            return #colorLiteral(red: 1, green: 0.8, blue: 0.7960784314, alpha: 1)
        }
        
        if self.isZero {
            return .lightGray
        }
        
        return .clear
    }
    
    var portfolio_cell_text_color: UIColor {
        if self > 0 {
            return .white
        } else {
            return .darkText
        }
    }
}
extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
extension PropertyModel {
    func capRate() -> Double { //getTotal()
        /*
         from firebase load expenses
         total cost = sum of expenses
         return total cost
         
         */
        var annual_income : Double = 0
//        let rent = calcAnnualRent()
        let expense = calcAnnualExpenses()
        let price = self.purchase_amt
        
        let tempNOI = annual_income - expense
        
        let cap = (tempNOI / price) * 100
        
        
        
//        cap_rate_text_field.value =  cap //selected_model.capRate() //
//        let cap = ((rent - expense) / price) * 100
        
        
        //return cap
        return 5;
        //return totalExpense from data
    }
  
    func calcAnnualExpenses() -> Double {
        var amt = 0.0
        for unit in self.units {
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
    
    func calcAnnualNOIExpenses() -> Double {
        var amt = 0.0
        for unit in self.units {
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
    
    func calcAnnualRent() -> Double { //calcEstimatedProfit
        /*
         estimatedProfit = sell price/total cost
         return estimatedProfit
         */
        var rent = 0.0
        
        for unit in self.units {
            rent = rent + unit.rent_annual
        }
        
        return rent
    }

}
extension PortfolioVC : PropertyAddedDelegate {
    @IBAction func segValueDidChanged(button : UISegmentedControl){
        if button.selectedSegmentIndex == 0{
            
            dataSource = section_list.filter{$0.proType == .IOwn}
            dataSource.insert(PropertyModel("initial", "Total"), at: 0)
        }else{
            dataSource = section_list.filter{$0.proType == .Researching}
            dataSource.insert(PropertyModel("initial", "Total"), at: 0)
        }
        portfolio_collection.reloadData()
    }
    func didAddedNewProperty(key: String) {
        self.viewDidLoad()
    }
}

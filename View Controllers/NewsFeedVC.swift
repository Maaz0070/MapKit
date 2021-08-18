//
//  NewsFeedVC.swift
//  RealEstate
//
//  Created by CodeGradients on 03/12/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import Firebase


class NewsFeedVC: UIViewController {
    
    @IBOutlet weak var recent_collection: UICollectionView!
    @IBOutlet weak var new_property_label: UILabel!
    @IBOutlet weak var cap_rate_button: PortfolioHeaderView!
    @IBOutlet weak var cash_flow_button: PortfolioHeaderView!
    @IBOutlet weak var income_button: PortfolioHeaderView!
    @IBOutlet weak var expenses_button: PortfolioHeaderView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var searchBtn: UIButton!

    @IBAction func didPressMap(_ sender: Any) {
        let mapsvc = MapsVC()
        mapsvc.setMainVCRef(self)
        mapsvc.modalPresentationStyle = .overCurrentContext
        present(mapsvc, animated: true, completion: nil)
    }
    
    var lastFilteredView :  UITapGestureRecognizer!
    var dataSource = [PropertyModel]()
    var recent_sections = [PropertyModel]()

    var selected_filter_model: FilterModel!
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.refreshRecentList()
//        self.recent_collection.reloadData()
        
        recent_collection.delegate = self
        recent_collection.dataSource = self
        recent_collection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedRecentCollectionItem(_:))))
        refreshControl.tintColor = .primary
        recent_collection.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didCollectionViewRefreshed), for: .valueChanged)
                
//        cap_rate_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        let tapEvent = UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:)))
        lastFilteredView = tapEvent
        cap_rate_button.addGestureRecognizer(tapEvent)
        cash_flow_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        income_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
        expenses_button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedStackViews(_:))))
   

       
        
        cap_rate_button.hideAllIndicators()
        cash_flow_button.hideAllIndicators()
        income_button.hideAllIndicators()
        expenses_button.hideAllIndicators()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .currencyUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .didLoadInitialy, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotificationCallback(_:)), name: .propertyRemoved, object: nil)
        
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func getController() -> NewsFeedVC {
        return AppStoryboard.Main.shared.instantiateViewController(withIdentifier: NewsFeedVC.storyboard_id) as! NewsFeedVC
    }
    
    /// Notification Actions
    /// - Parameter notification: notification action
    @objc func didReceiveNotificationCallback(_ notification: Notification) {
        if notification.name == .currencyUpdated {
            self.recent_collection.reloadData()
        }
        
        if notification.name == .didLoadInitialy {
            self.segment.selectedSegmentIndex = 1
            
            setupDataSource()
        }
        
        if notification.name == .propertyAdded {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.new_property_label.alpha = 1.0
                }, completion: { (finished: Bool) in
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                        UIView.animate(withDuration: 0.5) {
                            self.new_property_label.alpha = 0.0
                        }
                    }
                })
            }
        }
        
      
        if notification.name == .propertyChanged, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                if let index = self.recent_sections.firstIndex(where: {$0.key == model.key}) {
                    self.recent_sections[index] = model
                }
                if segment.selectedSegmentIndex == 1{
                self.dataSource = self.recent_sections //.filter{$0.liked==true}
                }else{
                    self.dataSource = self.recent_sections.filter{$0.liked==true}
                }
//                self.recent_collection.reloadData()
            }
        }
        
        if notification.name == .propertyRemoved, let info = notification.userInfo {
            if let model = info["model"] as? PropertyModel {
                self.recent_sections.removeAll(where: {$0.key == model.key})
                self.recent_collection.reloadData()
            }
        }
    }
    
    
    @objc func didCollectionViewRefreshed() {
        self.setupDataSource()
        self.refreshControl.endRefreshing()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
       // super.viewWillAppear(true)
        
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
    
    
    
    
    
    
    /// DIsplay list of propertied by cap rate
    @objc func setupDataSource() {
        recent_sections.removeAll();
        
        for prop in MainVC.all_properties_list {
            let cap = prop.capRate()
            //let totalCost = prop.getTotalCost()
            
            if !(cap.round(to: 1).isZero) {
                if let _ = Constants.buildDatefromMillis(millis: prop.millis) {
                    recent_sections.insert(prop, at: 0)
                }
            }
        }
        if segment.selectedSegmentIndex == 1{
        dataSource = self.recent_sections
            searchBtn.isHidden = false
        }else{
            searchBtn.isHidden = true
        dataSource = self.recent_sections.filter{$0.liked == true}
        }
//        searchBtn.isHidden = true
        recent_collection.reloadData()
    }
    
    /// Search button is used for filtering through properties
    /// - Parameter sender: search button
    @IBAction func didPressedSearchButton(_ sender: UIButton) {
        let v = AppStoryboard.Utils.shared.instantiateViewController(withIdentifier: FilterVC.storyboard_id) as! FilterVC
        var list = [PropertyModel]()
        for prop in MainVC.all_properties_list {
            let cap = prop.capRate()
            //let total = prop.getTotalCost()
            
            if !(cap.round(to: 1).isZero) {
                if let _ = Constants.buildDatefromMillis(millis: prop.millis) {
                    list.insert(prop, at: 0)
                }
            }
        }
        v.to_be_filtered_properties = list
        v.news_feed_filter = true
        if let mod = self.selected_filter_model {
            v.to_be_filtered_filter_model = mod
        } else {
            v.to_be_filtered_filter_model = FilterModel()
        }
        v.onDismiss = { (items, filter) in
            self.dataSource.removeAll()
            
            self.selected_filter_model = filter
            
            for prop in items {
                self.dataSource.append(prop)
            }
            
            self.recent_collection.reloadData()
        }
        
        let nav = UINavigationController(rootViewController: v)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    /// Pressing a button in the stack view will trigger the program to sort the properties in the order of the button
    /// - Parameter sender: Tap gesture recognizer - detects when button in stack view is pressed
    @objc func didPressedStackViews(_ sender: UITapGestureRecognizer) {
        lastFilteredView = sender

        if let v = sender.view {
            cap_rate_button.hideAllIndicators()
            cash_flow_button.hideAllIndicators()
            income_button.hideAllIndicators()
            expenses_button.hideAllIndicators()
            
            if v.tag < 0{
                v.tag = 1
            }
            if v == cap_rate_button { //total cost cap
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.capRate() < pml.capRate()
                        //return pm.getTotal < pm1.getTotal
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.capRate() > pml.capRate()
                        //copy methd over
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshRecentList()
                    self.recent_collection.reloadData()
                    return
                }
                
                cap_rate_button.showIndicator(pos: v.tag)
            }
            
            if v == cash_flow_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) < (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                        //change functions to getsellPrice()
                        //return pm.sellPrice < pm1.sellPrice
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                        //copy formula over
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshRecentList()
                    self.recent_collection.reloadData()
                    return
                    
                }
                
                cash_flow_button.showIndicator(pos: v.tag)
            }
            
            if v == income_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualRent() < pml.calcAnnualRent()
                        //return (pm.calcEstimatedProfit()) < (pm1.calcEstimatedProfit))
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualRent() > pml.calcAnnualRent()
                        //returm copy formula over
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshRecentList()
                    self.recent_collection.reloadData()
                    return
                }
                
                income_button.showIndicator(pos: v.tag)
            }
            
            if v == expenses_button {
                if v.tag == 1 {
                    v.tag = 2
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualExpenses() < pml.calcAnnualExpenses()
                        //return (pm.calcEstimatedProfit()) < (pm1.calcEstimatedProfit))
                    }
                } else if v.tag == 2 {
                    v.tag = 3
                    self.dataSource.sort { (pm, pml) -> Bool in
                        return pm.calcAnnualExpenses() > pml.calcAnnualExpenses()
                        //copy formula over
                    }
                } else if v.tag == 3 {
                    v.tag = 1
                    self.refreshRecentList()
                    self.recent_collection.reloadData()
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
            
            self.recent_collection.reloadData()
        }
    }
    
    /// Sorting function to sort the properties in appropiate order depending on which button is pressed
    /// - Parameter v: Portfolio Header View
    func applySorting(v: PortfolioHeaderView) {        
        if v == cap_rate_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.capRate() < pml.capRate()
                    //return pm.getTotalCost < pm1.getTotalCost
                    //or change formula of capRate
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.capRate() > pml.capRate()
                    //return copy formula over
                }
            }
            
            cap_rate_button.showIndicator(pos: v.tag)
        }
        
        if v == cash_flow_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return (pm.calcAnnualRent() - pm.calcAnnualExpenses())  < (pml.calcAnnualRent() - pml.calcAnnualExpenses()) //sellPrice
                    // pm.sellPrice < pm.sellPrice
                    //return the sell price here
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
            
                    //copy formula over
                }
            }
            
            cash_flow_button.showIndicator(pos: v.tag)
        }
        
        if v == income_button { //Estimated Profit %
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualRent() < pml.calcAnnualRent()
                    //return (pm.getSellPrice/pm.totalCost()) < (pm1.getSellPric/pm1.totalCost()
                    
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualRent() > pml.calcAnnualRent()
                    //return copy formula over
                }
            }
            
            income_button.showIndicator(pos: v.tag)
        }
        
        if v == expenses_button {
            if v.tag == 2 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualExpenses() < pml.calcAnnualExpenses()
                    //return pm.getExpense < pm1.getExpense
                }
            } else if v.tag == 3 {
                self.dataSource.sort { (pm, pml) -> Bool in
                    return pm.calcAnnualExpenses() > pml.calcAnnualExpenses()
                    //copy formula over
                }
            }
            
            expenses_button.showIndicator(pos: v.tag)
        }
        
        self.recent_collection.reloadData()
    }
    
    func refreshRecentList() {
        self.dataSource.sort { (pm, pml) -> Bool in
            return pm.millis.compare(pml.millis) == .orderedDescending
        }
//        let list = self.recent_sections
//        self.recent_sections = MainVC.all_properties_list
//        let temp_list = MainVC.all_properties_list
//        temp_list.forEach { (pm) in
//            let index = list.firstIndex(where: { (md) -> Bool in
//                return md.key == pm.key
//            })
//
//            if index == nil {
//                self.recent_sections.removeAll { (pmd) -> Bool in
//                    return pmd.key == pm.key
//                }
//            }
//        }
    }
}

extension NewsFeedVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    /// Number of sections is quickly checked if it is bigger than zero or not to  appropiately show the user a message
    /// - Parameter collectionView: CollectionVIew in NewsFeedVC
    /// - Returns: number of sections in collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if dataSource.count==0{
            self.recent_collection.setEmptyMessage("Your liked properties will be shown here.")
        }else{
            self.recent_collection.restore()
        }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       
        return 4
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
    
    /// CollectionView is where cells are given characteristics to display
    /// - Parameters:
    ///   - collectionView: UICollection view for NewsFeedVC
    ///   - indexPath: which index on collection view
    /// - Returns: finalized cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsFeedCell.identifier, for: indexPath) as? NewsFeedCell {
            
            cell.textLabel.style { (lb) in
                lb.textAlignment = indexPath.item == 0 ? .left : .center
                lb.adjustsFontSizeToFitWidth = indexPath.item != 0
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
            switch indexPath.item {
            case 0:
                cell.textLabel.text = ""
                if let s_index = model.address.indexOf(target: "\n") {
                    if let c_index = model.address.indexOf(target: ",") {
                        let city = model.address.subStringRange(from: s_index + 1, to: c_index).trimmingCharacters(in: .whitespaces)
                        if let st_index = model.address.indexOf(target: "#") {
                            let state = model.address.subStringRange(from: c_index + 1, to: st_index).trimmingCharacters(in: .whitespaces)
                            let zip = model.address.subStringRange(from: st_index + 1, to: model.address.count)
                            
                            cell.textLabel.text = "   \(city), \(state) \(zip)"
                        }
                    }
                }
                cell.textLabel.textColor = .darkText
                cell.textLabel.rightInset = 30
                cell.textLabel.leftInset = 20 + model.likes.stringValue.frame(size: CGSize(width: 40, height: 20), font: cell.textLabel.font).width
                
                let heart = Initializer<UIImageView>.initialize {
                    $0.translatesAutoresizingMaskIntoConstraints = false; $0.tag = indexPath.item; $0.isUserInteractionEnabled = true
                    $0.tag = 1213; $0.tintColor = #colorLiteral(red: 0.8901960784, green: 0.1490196078, blue: 0.2117647059, alpha: 1); $0.image = UIImage(systemName: model.liked ? "heart.fill" : "heart")
                }
//                heart.tag = 10001
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
                //let total = model.capRate()
                cell.textLabel.text = String(format: "%.01f", cap) + "%"
                cell.textLabel.textColor = cap.portfolio_cell_text_color
                
                cell.contentView.style { (v) in
                    v.backgroundColor = cap.portfolio_cell_background_color
                    v.layer.borderWidth = 0
                }
                
                break
            case 2:
                let rent = model.calcAnnualRent()
                let diff = rent - model.calcAnnualExpenses()
                cell.textLabel.text = Constants.formatNumber(number: diff)
                cell.textLabel.textColor = diff.portfolio_cell_text_color
                
                cell.contentView.style { (v) in
                    v.backgroundColor = diff.portfolio_cell_background_color
                    v.layer.borderWidth = 0
                }
                
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
            return cell
            }
            

        
        return UICollectionViewCell()
    }
    
    /// Pressing Recent tab will prompt recent properties and sort them according to chosen value
    /// - Parameter sender: <#sender description#>
    @objc func didPressedRecentCollectionItem(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.recent_collection)
        if let indexPath = self.recent_collection.indexPathForItem(at: location) {
            var model = dataSource[indexPath.section]
            if location.x < 30 {
                dataSource[indexPath.section].likes = model.liked == true ? (dataSource[indexPath.section].likes - 1) : (dataSource[indexPath.section].likes + 1)
                model.likes = model.liked == true ? (model.likes - 1) : (model.likes + 1)
                dataSource[indexPath.section].liked = !model.liked
                model.liked = !model.liked
                
//                if segment.selectedSegmentIndex == 0 {
              Database.database().reference().child("properties").child(model.key).child("likes").child(Constants.mineId).setValue(model.liked ? true : nil)
//                self.recent_collection.reloadData()
                self.recent_collection.performBatchUpdates({
                    self.recent_collection.reloadItems(at: [indexPath])
                    self.recent_collection.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
               
                return
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                let v = lastFilteredView.view!
                
                
                if v == cap_rate_button {
                    if v.tag == 2{
                        v.tag = 3
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.capRate() < pml.capRate()
                            //return pm.getTotalCost< pm1.getTotalCost
                        }
                    } else if v.tag == 1 {
                        v.tag = 2
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.capRate() > pml.capRate()
                            //copy formula over
                        }
                    } else if v.tag == 3 {
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.capRate() > pml.capRate()
                            //copy forumla over
                        }
                        v.tag = 1
//                        self.refreshRecentList()
                        
//                        return
                    }
                  
//                    cap_rate_button.showIndicator(pos: v.tag)
                }
                
                if v == cash_flow_button {
                    if v.tag == 2 {
//                        v.tag = 2
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) < (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                            //return pm.sellPrice < pm1.sellPrice
                        }
                    } else if v.tag == 1 {
//                        v.tag = 3
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                            //copy forumla over
                        }
                    } else if v.tag == 3 {
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return (pm.calcAnnualRent() - pm.calcAnnualExpenses()) > (pml.calcAnnualRent() - pml.calcAnnualExpenses())
                            //copy formula over
                        }
//                        v.tag = 1
//                        self.refreshRecentList()
//                        self.recent_collection.reloadData()
//                        return
                    }
                    
                    cash_flow_button.showIndicator(pos: v.tag)
                }
                
                if v == income_button { //Estimated Profit%
                    if v.tag == 1 {
                        v.tag = 2
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.calcAnnualRent() < pml.calcAnnualRent()
                            //return (sell price)/(total cost) x 100
                        }
                    } else if v.tag == 2 {
                        v.tag = 3
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.calcAnnualRent() > pml.calcAnnualRent()
                            //return copy formula over
                        }
                    } else if v.tag == 3 {
                        v.tag = 1
                        self.refreshRecentList()
                        self.recent_collection.reloadData()
                        return
                    }
                    
                    income_button.showIndicator(pos: v.tag)
                }
                
                if v == expenses_button {
                    if v.tag == 1 {
                        v.tag = 2
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.calcAnnualExpenses() < pml.calcAnnualExpenses()
                            //return pm.calcAnnualProfit() < pm1.calcAnnualProfit
                        
                        }
                    } else if v.tag == 2 {
                        v.tag = 3
                        self.dataSource.sort { (pm, pml) -> Bool in
                            return pm.calcAnnualExpenses() > pml.calcAnnualExpenses()
                        }
                    } else if v.tag == 3 {
                        v.tag = 1
                        self.refreshRecentList()
                        self.recent_collection.reloadData()
                        return
                    }
                    
                    expenses_button.showIndicator(pos: v.tag)
                }
                
                self.recent_collection.reloadData()
                
//                }
//                segment.selectedSegmentIndex = 0
//                switch lastFilteredView.view?.tag {
//                case 1:
//                    lastFilteredView.view?.tag =  2
//                    break
//                case 2:
//                    lastFilteredView.view?.tag = 3
//                    break
//                case 3:
//                    lastFilteredView.view?.tag = 2
//                    break
//                default:
//                    break
//                }
//                if lastFilteredView.tag == 1 {
//                    lastFilteredView.tag = 2
//
//                } else if lastFilteredView.tag == 2 {
//                    v.tag = 3
//                    self.dataSource.sort { (pm, pml) -> Bool in
//                        return pm.capRate() > pml.capRate()
//                    }
//                } else if v.tag == 3 {
//                    v.tag = 1
//                    self.refreshRecentList()
//                    self.recent_collection.reloadData()
//                    return
//                }
//                lastFilteredView.view?.tag = 1
//                didPressedStackViews(lastFilteredView)
                 
//                let cell =  self.recent_collection.cellForItem(at: indexPath)
//                var heartIcon = cell?.subviews[0].viewWithTag(1213) as! UIImageView
//
//                heartIcon.image = UIImage(systemName: model.liked ? "heart.fill" : "heart")
//                heartIcon.tintColor = #colorLiteral(red: 0.8901960784, green: 0.1490196078, blue: 0.2117647059, alpha: 1)
//                self.recent_collection.reloadData()
//                if let index = recent_sections.firstIndex(where: {$0.key == model.key}) {
//                    let count = bool ? 1 : -1
//                    model.likes += count
//                    model.liked = bool
//                    recent_sections[index] = model
//                }
//                recent_collection.reloadItems(at: [indexPath])
            } else {
                if indexPath.item == 0 {
                    if let p = self.parent as? MainVC {
                        p.showPropertyDetails(model, true)
                    }
                }
            }
        }
    }
}
extension NewsFeedVC{
    /// If user toggled segment make sure it is displaying appropiate properties
    /// - Parameter button: Liked and Recent UISegmentedControl button
    @IBAction func segValueDidChanged(button : UISegmentedControl){
        if button.selectedSegmentIndex == 0{
            dataSource = self.recent_sections.filter{$0.liked == true}
            searchBtn.isHidden = true
        }else{
            dataSource = self.recent_sections
            searchBtn.isHidden = false
        }
        recent_collection.reloadData()
    }
}
class NewsFeedCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: PaddingLabel!
}
extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
//        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}

//
//  FilterVC.swift
//  RealEstate
//
//  Created by codegradients on 05/12/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import RSSelectionMenu

class FilterVC: UIViewController {
    
    @IBOutlet weak var property_button: RightImageButton!
    @IBOutlet weak var prop_type_button: RightImageButton!
    @IBOutlet weak var square_feet_button: UIButton!
    @IBOutlet weak var apply_button: UIButton!
    
    @IBOutlet weak var ct_address_text_field: CustomTextField!
    @IBOutlet weak var stt_address_text_field: CustomTextField!
    @IBOutlet weak var zip_code_text_field: CustomTextField!
    
    @IBOutlet weak var filters_collection: UICollectionView!
    @IBOutlet weak var filter_collection_height: NSLayoutConstraint!
    
    var to_be_filtered_properties = [PropertyModel]()
    var selected_properties = [PropertyModel]()
    var temp_selected_properties = [PropertyModel]()
    var to_be_filtered_filter_model: FilterModel!
    
    var selected_prop_type = [String]()
    var bedrooms_value = 0...0
    var bathrooms_value = 0
    var square_feet_value = [0, 0]
    
    var news_feed_filter = false
    var first_time_loading = true
    
    var onDismiss: (([PropertyModel], FilterModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Filters"
        let back = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didPressedBackButton(_:)))
        back.tintColor = .black
        self.navigationItem.leftBarButtonItem = back
        
        let reset = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(didPressedResetButton(_:)))
        reset.tintColor = .black
        self.navigationItem.rightBarButtonItem = reset
        
        property_button.addTarget(self, action: #selector(didPressedPropertyButton(_:)), for: .touchUpInside)
        prop_type_button.addTarget(self, action: #selector(didPressedTypeFilterButton(_:)), for: .touchUpInside)
        square_feet_button.addTarget(self, action: #selector(didPressedSquareFeetButton(_:)), for: .touchUpInside)
        apply_button.addTarget(self, action: #selector(didPressedApplyButton(_:)), for: .touchUpInside)
        
        ct_address_text_field.addTarget(self, action: #selector(didChangedAddressTextFields(_:)), for: .editingChanged)
        stt_address_text_field.addTarget(self, action: #selector(didChangedAddressTextFields(_:)), for: .editingChanged)
        zip_code_text_field.addTarget(self, action: #selector(didChangedAddressTextFields(_:)), for: .editingChanged)
        
        let layout = JEKScrollableSectionCollectionViewLayout()
        layout.minimumInteritemSpacing = 0
        layout.defaultScrollViewConfiguration.showsHorizontalScrollIndicator = false
        layout.defaultScrollViewConfiguration.isScrollEnabled = false
        filters_collection.isScrollEnabled = false
        filters_collection.collectionViewLayout = layout
        
        filters_collection.register(FilterCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        filters_collection.delegate = self
        filters_collection.dataSource = self
                
        self.temp_selected_properties = self.to_be_filtered_properties
        
        self.updateFilterDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if first_time_loading {
            first_time_loading = false
            
            if news_feed_filter {
                if let v = property_button.superview as? GVisibilityView {
                    v.g_state = true
                }
            } else {
                if let v = zip_code_text_field.superview?.superview as? GVisibilityView {
                    v.g_state = true
                }
            }
            
            if let mod = to_be_filtered_filter_model {
                if let city = mod.city {
                    self.ct_address_text_field.text = city
                }
                
                if let state = mod.state {
                    self.stt_address_text_field.text = state
                }
                
                if let zip = mod.zipCode {
                    self.zip_code_text_field.text = zip
                }
                
                self.selected_prop_type = mod.type
                self.bedrooms_value = mod.bedrooms
                self.bathrooms_value = mod.bathrooms
                
                self.square_feet_value = mod.squareFeet
                var data = [String]()
                for i in stride(from: 50, to: 5100, by: 50) {
                    data.append("\(i)")
                }
                data.insert("Any", at: 0)
                self.square_feet_button.setTitle("\(data[self.square_feet_value.first!]) - \(data[self.square_feet_value.last!])", for: .normal)
            }
            
            updateFilterDataSource()
        }
        
        let size = UIScreen.main.bounds.width - 40
        let item = size / 6
        let height = (item * 2) + 120
        self.filter_collection_height.constant = height
        self.view.setNeedsLayout()
    }
    
    @objc func didPressedBackButton(_ sender: UIBarButtonItem) {
        if let mod = to_be_filtered_filter_model {
            self.selected_prop_type = mod.type
            self.bedrooms_value = mod.bedrooms
            self.bathrooms_value = mod.bathrooms
            
            self.square_feet_value = mod.squareFeet
            
            self.ct_address_text_field.text = mod.city
            self.stt_address_text_field.text = mod.state
            self.zip_code_text_field.text = mod.zipCode
        }
        
        updateFilterDataSource()

        self.dismiss(animated: true) {
            self.onDismiss?(self.selected_properties, self.to_be_filtered_filter_model)
        }
    }
    
    @objc func didPressedResetButton(_ sender: UIBarButtonItem) {
        self.selected_properties.removeAll(); self.temp_selected_properties = self.to_be_filtered_properties
        self.ct_address_text_field.text = nil
        self.stt_address_text_field.text = nil
        self.zip_code_text_field.text = nil
        self.bedrooms_value = 0...0
        self.bathrooms_value = 0
        self.selected_prop_type = ["ALL"]
        self.filters_collection.reloadData()
        self.square_feet_button.setTitle("Any - Any", for: .normal)
        self.square_feet_value = [0, 0]
        self.updateFilterDataSource()
    }
    
    @objc func didPressedPropertyButton(_ sender: UIButton) {
        var selected_titles = [String]()
        
        var titles: [String] {
            var t = [String]()
            
            for tt in to_be_filtered_properties {
                t.append(tt.address.replacingOccurrences(of: "#", with: " "))
                
                if let _ = self.selected_properties.first(where: {$0.address == tt.address}) {
                    selected_titles.append(tt.address.replacingOccurrences(of: "#", with: " "))
                }
            }
            return t
        }
        
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
//        let all = selected_titles.containsSameElements(as: titles)
//        selectionMenu.addFirstRowAs(rowType: .custom(value: all ? "Deselect All" : "Select All"), showSelected: all) { (text, bool) in
//            if bool {
//                selected_titles = titles
//                selectionMenu.setSelectedItems(items: selected_titles) { (s, i, b, ss) in }
//                selectionMenu.dismiss()
//            } else {
//                selected_titles.removeAll()
//                selectionMenu.setSelectedItems(items: selected_titles) { (s, i, b, ss) in }
//                selectionMenu.dismiss()
//            }
//        }
        
        selectionMenu.setSelectedItems(items: selected_titles) { (s, i, b, ss) in }
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
            self.selected_properties.removeAll(); self.temp_selected_properties.removeAll();
            
            for item in items {
                if let prop = self.to_be_filtered_properties.first(where: {$0.address.replacingOccurrences(of: "#", with: " ") == item}) {
                    self.selected_properties.append(prop)
                    self.temp_selected_properties.append(prop)
                }
            }
            
            self.updateFilterDataSource()
        }
//        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
        let vc = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: SelectionVC.storyboard_id) as! SelectionVC
        vc.items = titles
        vc.selected = selected_titles
//        vc.onSelectAll = { () in
//            self.didPressedResetButton(UIBarButtonItem())
//        }
//        vc.onDismiss = { (items) in
//            self.selected_properties.removeAll(); self.temp_selected_properties.removeAll();
//
//            for item in items {
//                if let prop = self.to_be_filtered_properties.first(where: {$0.address.replacingOccurrences(of: "#", with: " ") == item}) {
//                    self.selected_properties.append(prop)
//                    self.temp_selected_properties.append(prop)
//                }
//            }
//
//            self.updateFilterDataSource()
//        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func didPressedTypeFilterButton(_ sender: UIButton) {
        //var titles = ["ALL", "Single Family", "Condo/Townhome", "Multi-Family Prop", "Commercial", "Other"]
        var titles = [String]()
        var items = [PropertyModel]()
        if news_feed_filter {
            items = self.temp_selected_properties
        } else {
            items = self.temp_selected_properties
        }
        for prop in items {
            if !titles.contains(prop.prop_type) {
                titles.append(prop.prop_type)
            }
        }
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: titles) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        
        var selected = [String]()
        for prop in self.selected_properties {
            if !selected.contains(prop.prop_type) {
                selected.append(prop.prop_type)
            }
        }
        
        selectionMenu.setSelectedItems(items: selected) { (s, i, b, d) in }
        
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.onDismiss = { (items) in
        
            self.selected_properties.removeAll()
            self.selected_prop_type = items
            
            for prop in self.temp_selected_properties {
                if items.contains(prop.prop_type) {
                    self.selected_properties.append(prop)
                }
            }
            
            self.updateFilterDataSource()
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: nil, height: nil), from: self)
    }
    
    @objc func didPressedSquareFeetButton(_ sender: UIButton) {
        var data = [String]()
        
        for i in stride(from: 50, to: 3050, by: 50) {
            data.append("\(i)")
        }
        
        data.insert("Any", at: 0)
        data.append("3000+")
//        PickerDialog().show(title: "Select number of square feets", options: data, selected: sender.tag) { [self] (v, i) in
//            sender.setTitle(v, for: .normal)
//            sender.tag = i
//
//            self.updateFilterDataSource()
//        }
        MultiPickerdialog().show(title: "Select number of square feets", options: data, selected: self.square_feet_value) { (string, int) in
            if string.contains("Any") {
                sender.setTitle("Any - Any", for: .normal)
                self.square_feet_value = [0, 0]
            } else {
                let first = int.first!
                let last = int.last!
                if last >= first {
                    sender.setTitle(string.joined(separator: " - "), for: .normal)
                    self.square_feet_value = [int.first!, int.last!]
                } else {
                    self.view.makeToast("Invalid range")
                }
            }
            
            self.updateFilterDataSource()
        }
    }
    
    @objc func didPressedApplyButton(_ sender: UIButton) {
        var mod = FilterModel()
        mod.type = self.selected_prop_type
        mod.bedrooms = self.bedrooms_value
        mod.bathrooms = self.bathrooms_value
        mod.squareFeet = self.square_feet_value
        if let cityText = ct_address_text_field.safeText() {
            mod.city = cityText
        }
        
        if let stateText = stt_address_text_field.safeText() {
            mod.state = stateText
        }
        
        if let zipText = zip_code_text_field.safeText() {
            mod.zipCode = zipText
        }
        self.dismiss(animated: true) {
            self.onDismiss?(self.selected_properties, mod)
        }
    }
    
    func updateFilterDataSource() {
        self.selected_properties.removeAll()
        
        self.property_button.setTitle("Property (\(self.temp_selected_properties.count))", for: .normal)
        
        var count = 0
        if self.selected_prop_type.contains("ALL") {
            count = self.temp_selected_properties.count
        } else {
            for prop in self.temp_selected_properties {
                if selected_prop_type.contains(prop.prop_type) {
                    count += 1
                }
            }
        }
//        self.prop_type_button.setTitle("Property Type (\(count))", for: .normal)

        for prop in self.temp_selected_properties {
            var added = true
            if news_feed_filter {
                if let s_index = prop.address.indexOf(target: "\n") {
                    if let c_index = prop.address.indexOf(target: ",") {
                        let city = prop.address.subStringRange(from: s_index + 1, to: c_index).trimmingCharacters(in: .whitespaces)
                        if let st_index = prop.address.indexOf(target: "#") {
                            let state = prop.address.subStringRange(from: c_index + 1, to: st_index).trimmingCharacters(in: .whitespaces)
                            let zip = prop.address.subStringRange(from: st_index + 1, to: prop.address.count)
                            
                            if let cityText = ct_address_text_field.safeText() {
                                added = city.lowercased() == cityText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            
                            if let stateText = stt_address_text_field.safeText() {
                                if added {
                                    added = state.lowercased() == stateText.lowercased()
                                }
                            }
                            
                            if let zipText = zip_code_text_field.safeText() {
                                if added {
                                    added = zip.lowercased() == zipText.lowercased()
                                }
                            }
                        }
                    }
                }
            }
            
            if !selected_prop_type.contains("ALL") {
                if !selected_prop_type.contains(prop.prop_type) {
                    added = false
                }
            }
            
            if added {
                var bedroom_range = self.bedrooms_value.first!...self.bedrooms_value.last!

                if bedroom_range.lowerBound > 0 && bedroom_range.upperBound > 0 {
                    if prop.units.count > 0 {
                        if bedroom_range.upperBound == 5 {
                            bedroom_range = bedroom_range.lowerBound...10
                        }
                        added = bedroom_range.contains(prop.units.first!.bedrooms+1)
                    }
                }
                
                if added {
                    if self.bathrooms_value > -1 {
                        if prop.units.count > 0 {
                            var data = [Double]()
                            
                            for i in stride(from: 0.5, to: 5.5, by: 0.5) {
                                data.append(i)
                            }
                            
                            let bathroom = prop.units.first!.bathrooms
                            if bathroom < data.count {
                                let value = data[bathroom]
                                let bvalue = mapy(number: Double(self.bathrooms_value)) + 0.5

                                added = value >= bvalue
                            }
                        }
                    }
                    
                    if added {
                        if self.square_feet_value.first! != 0 {
                            if prop.units.count > 0 {
                                let lower = (prop.units.first!.square_feet) * 100
                                let upper = lower + 100
                                
                                var first = self.square_feet_value.first!
                                var second = self.square_feet_value.last!
                                
                                var data = [String]()
                                
                                for i in stride(from: 50, to: 3050, by: 50) {
                                    data.append("\(i)")
                                }
                                
                                data.insert("Any", at: 0)
                                data.append("3000+")
                                
                                if first == 61 {
                                    first = 5000
                                } else {
                                    first = Int(data[first]) ?? 0
                                }
                                
                                if second == 61 {
                                    second = 5000
                                } else {
                                    second = Int(data[second]) ?? 0
                                }

                                added = false
                                if lower >= first {
                                    if upper <= second {
                                        added = true
                                    }
                                }
                            }
                        }
                        
                        if added {
                            self.selected_properties.append(prop)
                        }
                    }
                }
            }
        }
        
        self.apply_button.setTitle("Apply (\(selected_properties.count) results)", for: .normal)
        self.apply_button.isEnabled = self.selected_properties.count != 0
        if self.apply_button.isEnabled {
            self.apply_button.backgroundColor = .primary
        } else {
            self.apply_button.backgroundColor = UIColor.primary.withAlphaComponent(0.7)
        }
    }
    
    @objc func didChangedAddressTextFields(_ sender: UITextField) {
        updateFilterDataSource()
    }
}

extension FilterVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width - 40
        return CGSize(width: size/6, height: size/6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                self.bedrooms_value = 0...0
            }
//            else if indexPath.item == 5 {
//                self.bedrooms_value = 5...5
//            }
            else {
                if bedrooms_value.lowerBound == 0 || bedrooms_value.upperBound == 0 {
                    self.bedrooms_value = indexPath.item...indexPath.item
                }
//                else if bedrooms_value.lowerBound == 5 || bedrooms_value.upperBound == 5 {
//                    self.bedrooms_value = indexPath.item...indexPath.item
//                }
                else {
                    if indexPath.item > self.bedrooms_value.upperBound {
                        self.bedrooms_value = self.bedrooms_value.lowerBound...indexPath.item
                    } else {
                        if indexPath.item > self.bedrooms_value.lowerBound {
                            self.bedrooms_value = indexPath.item...self.bedrooms_value.upperBound
                        } else {
                            self.bedrooms_value = indexPath.item...self.bedrooms_value.lowerBound
                        }
                    }
                }
                
//                if bedrooms_value.count > 1 {
//                    let last = bedrooms_value.last!
//                    bedrooms_value.removeAll()
//                    if indexPath.item >= last {
//                        bedrooms_value = [indexPath.item - 1, indexPath.item]
//                    } else {
//                        bedrooms_value = [indexPath.item, indexPath.item + 1]
//                    }
//                } else {
//                    bedrooms_value = [indexPath.item, indexPath.item]
//                }
                
            }
        } else {
            self.bathrooms_value = indexPath.item
        }
        
        filters_collection.reloadData()
        self.updateFilterDataSource()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionCell.identifier, for: indexPath) as? FilterCollectionCell {
            
            let index = indexPath
            if index.section == 0 {
                if index.item == 0 {
                    cell.textLabel.text = "Any"
                } else {
                    cell.textLabel.text = index.item == 5 ? "5+" : "\(index.item)"
                }
                
                let range = self.bedrooms_value.first!...self.bedrooms_value.last!
                cell.textLabel.textColor = range.contains(index.item) ? UIColor.white : UIColor.darkGray
                cell.contentView.backgroundColor = range.contains(index.item) ? UIColor.primary : UIColor.white
            } else {
//                if index.item == 0 {
//                    cell.textLabel.text = "Any"
//                } else {
//                    if index.item == 1 {
//                        cell.textLabel.text = "1+"
//                    } else {
//                        cell.textLabel.text = index.item == 2 ? "1.5+" : "\(index.item - 1)+"
//                    }
//                }
                cell.textLabel.text = "\(mapy(number: Double(indexPath.item)) + 0.5)+"
                
                cell.textLabel.textColor = self.bathrooms_value == index.item ? UIColor.white : UIColor.darkGray
                cell.contentView.backgroundColor = self.bathrooms_value == index.item ? UIColor.primary : UIColor.white
            }
            
            cell.contentView.subviews.forEach { (v) in
                if v.tag == 1212 {
                    v.removeFromSuperview()
                }
            }
            
            let border = Initializer<UIView>.initialize { (v) in
                v.backgroundColor = .lightGray; v.tag = 1212
            }
            
            let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: index)
            let width = size.width
            let height = size.height
            
            if indexPath.item == 0 {
                cell.contentView.addSubview(border.with(frame: CGRect(x: 0, y: 0, width: width, height: 1)))
                cell.contentView.addSubview(border.with(frame: CGRect(x: width - 1, y: 0, width: 1, height: height)))
                cell.contentView.addSubview(border.with(frame: CGRect(x: 0, y: height - 1, width: width, height: 1)))
                cell.contentView.addSubview(border.with(frame: CGRect(x: 0, y: 0, width: 1, height: height)))
            } else {
                cell.contentView.addSubview(border.with(frame: CGRect(x: 0, y: 0, width: width, height: 1)))
                cell.contentView.addSubview(border.with(frame: CGRect(x: width - 1, y: 0, width: 1, height: height)))
                cell.contentView.addSubview(border.with(frame: CGRect(x: 0, y: height - 1, width: width, height: 1)))
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! FilterCollectionHeader
        header.backgroundColor = UIColor.white
        if indexPath.section == 0 {
            header.titleLabel.text = "Bedrooms (tap 2 numbers to select a range)"
        } else {
            header.titleLabel.text = "Bathrooms"
        }
        return header
    }
    
    func mapy(number: Double) -> Double {
        let start1 = 0.0
        let stop1 = 6.0
        let start2 = 0.0
        let stop2 = 3.0
        return ((number - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
    }
}

class FilterCollectionCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
}

class FilterCollectionHeader: UICollectionReusableView {
    lazy var titleLabel: PaddingLabel = {
        let lbl = PaddingLabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        lbl.textColor = .darkText
        lbl.text = ""
        lbl.backgroundColor = .white
        lbl.topInset = 20; lbl.rightInset = 0; lbl.bottomInset = 0; lbl.leftInset = 0;
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        if let font = UIFont(name: "SFProDisplay-Medium", size: 16) {
            lbl.font = font
        }
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct FilterModel {
    var type: [String]
    var bedrooms = 0...0
    var bathrooms: Int
    var squareFeet: [Int]
    
    var city: String?
    var state: String?
    var zipCode: String?
    
    init() {
        self.type = ["ALL"]
        self.bedrooms = 0...0
        self.bathrooms = 0
        self.squareFeet = [0,0]
    }
}

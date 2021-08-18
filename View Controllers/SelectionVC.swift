//
//  SelectionVC.swift
//  RealEstate
//
//  Created by Muhammad Umair on 28/05/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class SelectionVC: UIViewController {

    @IBOutlet weak var names_tableview: UITableView!
    
    var items = [String]()
    var selected = [String]()

    var onDismiss: (([String]) -> Void)?

    /**
     Generic loading function
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        names_tableview.delegate = self
        names_tableview.dataSource = self
        names_tableview.allowsMultipleSelection = true

        navigationItem.title = "Properties"
        
        let sa = UIBarButtonItem(title: "Select All", style: .done, target: self, action: #selector(didPressedSelectAll))
        self.navigationItem.rightBarButtonItem = sa
        
        let ds = UIBarButtonItem(title: "Deselect All", style: .done, target: self, action: #selector(didPressedDeselectAll))
        self.navigationItem.leftBarButtonItem = ds
        
        for item in selected {
            if let i = items.firstIndex(of: item) {
                let index = IndexPath(row: i, section: 0)
                names_tableview.selectRow(at: index, animated: true, scrollPosition: .middle)
                names_tableview.delegate?.tableView?(names_tableview, didSelectRowAt: index)
            }
        }
    }
    
    /**
     Selects all properties on list.
     */
    @objc func didPressedSelectAll() {
        for i in 0..<items.count {
            let index = IndexPath(row: i, section: 0)
            names_tableview.selectRow(at: index, animated: true, scrollPosition: .middle)
            names_tableview.delegate?.tableView?(names_tableview, didSelectRowAt: index)
        }
    }
    
    /**
     Deselects all properties on list.
     */
    @objc func didPressedDeselectAll() {
        for i in 0..<items.count {
            let index = IndexPath(row: i, section: 0)
            names_tableview.deselectRow(at: index, animated: true)
            names_tableview.delegate?.tableView?(names_tableview, didDeselectRowAt: index)
        }
    }
    
    @IBAction func didPressedDoneButton(_ sender: UIButton) {
        var list = [String]()
        if let rows = self.names_tableview.indexPathsForSelectedRows {
            for row in rows {
                list.append(items[row.row])
            }
        }
        
        self.dismiss(animated: true) {
            self.onDismiss?(list)
        }
    }
}

/**
 Multiple helper functions for selection.
 */
extension SelectionVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier) {
            cell.textLabel?.text = items[indexPath.row].replacingOccurrences(of: "#", with: " ")
            cell.textLabel?.textColor = .darkText
            cell.textLabel?.numberOfLines = 0
            
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
}

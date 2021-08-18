//
//  NewAddPropTypeVC.swift
//  RealEstate
//
//  Created by Pritam Singh on 11/04/21.
//  Copyright © 2021 Code Gradients. All rights reserved.
//

import UIKit
import DropDown

/// Select Property type  mode .
public enum PropertyType {

    /// "A property I own"
    case IOwn

    /// "A property I am researching".
    case Researching

}
var propertyType : PropertyType = .IOwn

class NewAddPropTypeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func didPressedNextButton(_ sender: UIButton) {
       
        if let p = parent as? NewAddPropVC {
            p.moveToPage(1)
        }
    }
    @IBAction func didPressedProTypeButton(_ sender: UIButton) {
        let drop = DropDown(anchorView: sender)
        drop.dataSource = ["A property I own", "A property I am researching"]
        drop.selectionAction = { (index: Int, item: String) in
            sender.setTitle(item, for: .normal)

            switch index {
            case 1:
                propertyType = .Researching
            default:
                propertyType = .IOwn
            }
            sender.tag = index
        }
        drop.show()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

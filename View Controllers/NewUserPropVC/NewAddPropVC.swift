//
//  NewAddPropVC.swift
//  RealEstate
//
//  Created by CodeGradients on 23/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


class NewAddPropVC: UIViewController {
    @IBOutlet weak var page_control: UIPageControl!
    @IBOutlet weak var segment_scroll: UIScrollView!
    @IBOutlet weak var skip_button: UIButton!
    private var controllers =  [UIViewController]()
    var delegate: PropertyAddedDelegate!
    
    /**
     Standard setup, assign delegate, hide the skip buttom
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segment_scroll.delegate = self
        
        skip_button.isHidden = true
    }
    
    /**
     Setup status bar
     */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /**
     Show the appropriate view on instantiation
     */
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.presentingViewController as? MainVC {
            self.view.viewWithTag(212)?.isHidden = true
            self.view.viewWithTag(213)?.isHidden = true
        } else {
            if let v = self.view.viewWithTag(214) as? GVisibilityView {
                v.g_state = true
            }
        }
    }
    
    /**
     Setup subviews
     */
    override func viewDidAppear(_ animated: Bool) {
        if let _ = self.presentingViewController as? MainVC {
            setupSubviewControllers()
        }
    }
    
    /**
     Establish that the user is not new, then dismiss the VC
     - Parameter sender: back button
     */
    @IBAction func didPressedBackButton(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "is_new_user")
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     If the user presses continue, hide the continye button and show a new view ans setup subviews
     - Parameter sender: continue button, hidden when tapped
     */
    @IBAction func didPressedContinueButton(_ sender: UIButton) {
        sender.isHidden = true
        self.view.viewWithTag(212)?.isHidden = true
                
        setupSubviewControllers()
    }
    
    /**
     Setup address, purchase, rent income, and expense VC to be presented later
     */
    func setupSubviewControllers() {
         controllers = [AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropTypeVC.storyboard_id),AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropAddressVC.storyboard_id),
                           AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropPurchaseVC.storyboard_id),
                           AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropRentIncomeVC.storyboard_id),
                           AppStoryboard.AddProp.shared.instantiateViewController(withIdentifier: NewAddPropExpenseVC.storyboard_id)]
        
        let vc = controllers[0]
        self.addChild(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.segment_scroll.frame.height)
        self.segment_scroll.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            for (index, viewController) in self.controllers.enumerated() {
                if(index != 0) {
                    viewController.view.frame = CGRect(
                        x: UIScreen.main.bounds.width * CGFloat(index),
                        y: 0,
                        width: UIScreen.main.bounds.width,
                        height: self.segment_scroll.frame.height + 0
                    )
                    self.addChild(viewController)
                    self.segment_scroll.addSubview(viewController.view)
                    viewController.didMove(toParent: self)
                }
            }
            
            self.segment_scroll.contentSize = CGSize(width: (UIScreen.main.bounds.width) * CGFloat(self.children.count), height: self.segment_scroll.frame.height)
            self.page_control.numberOfPages = self.children.count
            self.page_control.currentPage = 0
            self.page_control.isHidden = false
        })
    }
  
    /**
     Move to a given page in the paged view using the content offset and the frame width to calculate the page
     - Parameter page: page # to move to
     */
    func moveToPage(_ page: CGFloat) {
        let x = self.segment_scroll.frame.width * page
        self.segment_scroll.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
        let page = Int(self.segment_scroll.contentOffset.x) / Int(self.segment_scroll.frame.width)
        page_control.currentPage = page + 1
        guard controllers.count>page+1 else { return}
        if let purchaseVC = controllers[page+1] as? NewAddPropPurchaseVC{
            purchaseVC.updateData()
        }else if let addProRentIncomVC = controllers[page+1] as? NewAddPropRentIncomeVC{
            addProRentIncomVC.updateData()
        }else if let addProExpenseVC = controllers[page+1] as? NewAddPropExpenseVC{
            addProExpenseVC.updateData()
        }
    }
}

extension NewAddPropVC : UIScrollViewDelegate {
    /**
     Lock in the page when scrolling is ending
     If the page is the last one, check if the user is new and hide the skip button accordingly
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        page_control.currentPage = page
        
        if page == self.children.count - 1 {
            let bool = UserDefaults.standard.bool(forKey: "is_new_user")
            if bool {
                skip_button.isHidden = false
            } else {
                skip_button.isHidden = true
            }
        } else {
            skip_button.isHidden = true
        }
        
        IQKeyboardManager.shared.resignFirstResponder()
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
           print("left")
        } else {
           print("right")
            if let purchaseVC = controllers[page] as? NewAddPropPurchaseVC{
                purchaseVC.updateData()
            }else if let addProRentIncomVC = controllers[page] as? NewAddPropRentIncomeVC{
                addProRentIncomVC.updateData()
            }else   if let expenseVC = controllers[page] as? NewAddPropExpenseVC{
                expenseVC.updateData()
            }
        }
    }
}

/**
 All classes conforming to this protocol must specify behavior for when a property is added
 */
protocol PropertyAddedDelegate {
    func didAddedNewProperty(key: String)
}


//
//  IntroVC.swift
//  RealEstate
//
//  Created by Umair on 16/06/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {

    @IBOutlet weak var intro_collection: UICollectionView!
    @IBOutlet weak var page_control: UIPageControl!
    @IBOutlet weak var next_button: UIButton!
    
    let titles = ["Add a Rental Property", "Input Income and Expenses", "Track Monthly Rent", "Calculate Cash Flow", "Analyze All Properties"]
    let sub_titles = ["Easily add your portfolio of properties and the financials that matters",
                      "Track inputs that affect your financials, for example, rent, property tax, and insurance",
                      "Track rent due and paid for your portfolio with a few clicks",
                      "Calculate your portofolio's profit, loss, and return on investment",
                      "Analyze the income and expenses that impact your financial returns"]
    
    let images = [#imageLiteral(resourceName: "Group 26"), #imageLiteral(resourceName: "Wallet-pana (1)"), #imageLiteral(resourceName: "Finance-pana"), #imageLiteral(resourceName: "Calculator-pana"), #imageLiteral(resourceName: "Analysis-pana")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intro_collection.delegate = self
        intro_collection.dataSource = self
        
        next_button.addTarget(self, action: #selector(didPressedDoneButton(_:)), for: .touchUpInside)
    }
    
    /// stores boolean initial_new to true after skip button is pressed. DIsmiss view Controller we just presented
    /// - Parameter sender: Skip Button
    @IBAction func didPressedSkipButton(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "initial_new")
        self.dismiss(animated: true, completion: nil)
    }
    
    /// When Done button is pressed show the appropiate view
    /// - Parameter sender: Done button UIButton object
    @objc func didPressedDoneButton(_ sender: UIButton) {
        let indexes = intro_collection.indexPathsForVisibleItems
        if let index = indexes.first {
            if index.item == 4 {
                UserDefaults.standard.setValue(true, forKey: "initial_new")
                self.dismiss(animated: true, completion: nil)
            } else {
                let page = index.item + 1
                intro_collection.scrollToItem(at: IndexPath(item: page, section: 0), at: .right, animated: true)
                page_control.currentPage = page
                if page == 4 {
                    self.next_button.setTitle("Continue", for: .normal)
                } else {
                    self.next_button.setTitle("Next", for: .normal)
                }
            }
        }
    }
}

extension IntroVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// <#Description#>
    /// - Parameters:
    ///   - collectionView: CollectionView object in IntroVC
    ///   - section: Number of items in section
    /// - Returns: 5, integer
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - collectionView: CollectionView object in IntroVC
    ///   - collectionViewLayout: <#collectionViewLayout description#>
    ///   - indexPath: sizeForItemAt
    /// - Returns: UiCollectionViewcell width and heigh
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: collectionView.frame.height)
    }
    
    /// At end of scrollview set nextButton to Continue
    /// - Parameter scrollView: UIScrollView object on Full Screen Image VC
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        page_control.currentPage = page
        if page == 4 {
            self.next_button.setTitle("Continue", for: .normal)
        } else {
            self.next_button.setTitle("Next", for: .normal)
        }
    }
    
    /// Gives a resuable table-view cell object after locating it by indexPath and set up cell
    /// - Parameters:
    ///   - collectionView: Collection view object in IntroVC
    ///   - indexPath: indexPath object
    /// - Returns: Cell object in UITableView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroCell.identifier, for: indexPath) as? IntroCell {
            cell.viewLbl.text = titles[indexPath.item]
            cell.viewSubLbl.text = sub_titles[indexPath.item]
            cell.viewImage.image = images[indexPath.item]
            
            return cell
        }
        return UICollectionViewCell()
    }
}

class IntroCell: UICollectionViewCell {
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewLbl: UILabel!
    @IBOutlet weak var viewSubLbl: UILabel!
}

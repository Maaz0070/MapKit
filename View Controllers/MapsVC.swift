//
//  MapsVC.swift
//  RealEstate
//
//  Created by Maaz Adil on 8/3/21.
//  Copyright © 2021 Code Gradients. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    
    func addCloseButton() {
        //let img = UIImage(systemName: "xmark.circle")?.withTintColor(.blue)
        let closeBtn = UIButton(type: .close)
        //let topConstraint = closeBtn.centerYAnchor.constraint(equalTo: mapView.topAnchor + clos)
        closeBtn.isEnabled = true
        closeBtn.tintColor = .blue
        closeBtn.frame = CGRect(x: 30, y: 40, width: 35, height: 35)
        closeBtn.addTarget(self, action: #selector(self.closeView), for: .touchUpInside)
        closeBtn.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        closeBtn.translatesAutoresizingMaskIntoConstraints = true
        self.mapView.addSubview(closeBtn)
    }
    
    @objc func closeView() {
        //print("***CALLED***")
        self.dismiss(animated: true, completion: nil) //this deallocates the VC so we need to set the delegate for the mapView to nil to avoid crashes on re-appearing
        //mapView.isHidden = true
    }
    
    deinit {
        self.mapView.delegate = nil
    }
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    var properties = [String]()
    var mainVCRef = UIViewController()
    
    var i = 0
    
    
    //let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
    let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    //let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.760122, -122.468158)
    //let locacion:CLLocation = CLLocation(latitude: 37.760122, longitude: -122.468158)
    
    func setMainVCRef(_ vc: UIViewController) {
        self.mainVCRef = vc
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        
        authorizeAndShowLocation()
        zoomToUserLocation()
        addCustomPin()
        addCloseButton()
        
        
        //Set the firebase reference
        /*
         ref = Database.database().reference()
         ref?.child("realestate-6126a").observeSingleEvent(of: .value, with: {snapshot in
         guard let value = snapshot.value as? [String: Any] else {
         return
         }
         print("Value: \(value)")
         })
         addCustomPin(propertyList: value(forKey: "address") as! String) as! String
         */
        
        // Retreive the posts and listen for changes
        /*
         databaseHandle =  ref?.child("realestate-6126a").observe(.childAdded, with: { (snapshot) in
         //Code to execute when a child is added under "house-flipping-dashboard-default-rtdb"
         //Take the value from the snapshot and added it to the postData array
         let post = snapshot.value as? String
         if let actualPost = post {
         self.properties.append(actualPost)
         self.map.reloadInputViews()
         }

         })
         */
        //
        
        // let pinned = addCustomPin()
        //mapView(map, pinned)
        
    }
    
    
    func authorizeAndShowLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            break
        case .denied:
            mapView.showsUserLocation = false
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            mapView.showsUserLocation = false
            break
        case .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            break
        @unknown default:
            print("**Unknown default hit!**")
            break
        }
    }
    
    func zoomToUserLocation() {
        if let location = locationManager.location?.coordinate {
            //35 mile radius
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 56327.04, longitudinalMeters: 56327.04)
            mapView.setRegion(region, animated: true)
        }
    }
    
    var indexOfLoop:PropertyModel = MainVC.all_properties_list[0]
    var lat:CLLocationDegrees = 0.0
    var lon:CLLocationDegrees = 0.0
    var j:Int = 0
    
    private func addCustomPin() {
        var requests = 0
        for prop in MainVC.all_properties_list {
            let pin = MKPointAnnotation()

            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(prop.address) { [self]
                placemarks, error in
                requests += 1
                //print("Requests: \(requests)")
                
                let placemark = placemarks?.first
                let latRand = Double.random(in: -0.0010010...0.0010000)
                let lonRand = Double.random(in: -0.0010000...0.0010000)
                var lat:Double = 0
                var lon:Double = 0
                
                if let propLat = placemark?.location?.coordinate.latitude {
                    lat = propLat + latRand
                }
                
                if let propLon = placemark?.location?.coordinate.longitude {
                    lon = propLon + lonRand
                }
                

                let propCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
                pin.coordinate = propCoordinate
                pin.title = "\(placemark?.locality ?? ""), \(placemark?.administrativeArea ?? "") \(placemark?.postalCode ?? "")"
                
                self.mapView.addOverlay(MKCircle(center: pin.coordinate, radius: 1250))
                
            }

            mapView.addAnnotation(pin)
            
            setIndex(index: prop)
            j += 1
            //  return pin
            
        }
    }
    /*
    func showPropertyDetails(_ model: PropertyModel, _ read: Bool = false) {
        //bottom_views.forEach({ $0.activated = false })
        let mvc = MainVC()
    //    let napvc = NewAddPropVC()
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyVC") as! PropertyVC
       // mvc.segment_scroll.subviews.forEach({ $0.removeFromSuperview() })
       // if let vc = se.children[0] as? PropertyVC {
        
            pvc.initPropertyData(model, read)
           // pvc.view.frame = CGRect(x: 0, y: 0, width: mvc.segment_scroll.frame.width, height: mvc.segment_scroll.frame.height)
           // mvc.segment_scroll.addSubview(pvc.view)
            pvc.didMove(toParent: mvc)
    //    }
        self.present(pvc, animated: false)
    }
    */
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = #colorLiteral(red: 0.07058823529, green: 0.6901960784, blue: 0.9098039216, alpha: 1)
            circleRenderer.alpha = 0.25
            return circleRenderer
        }
        else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            label1.text = " Cap Rate: \(numberFormatter.string(from: NSNumber(value:MainVC.all_properties_list[i].capRate())) ?? "")%\n CashFlow: $\(numberFormatter.string(from: NSNumber(value:MainVC.all_properties_list[i].calcAnnualRent() - MainVC.all_properties_list[i].calcAnnualExpenses())) ?? "")\n Income: $\(numberFormatter.string(from: NSNumber(value:MainVC.all_properties_list[i].calcAnnualRent())) ?? "")\n Expenses: $\(numberFormatter.string(from: NSNumber(value:MainVC.all_properties_list[i].calcAnnualExpenses())) ?? "") \n*All locations are approximate"
            
            i += 1
            label1.numberOfLines = 0
            annotationView!.detailCalloutAccessoryView = label1;
            
            let width = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
            label1.addConstraint(width)
            let height = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 150)
            label1.addConstraint(height)
        } else {
            annotationView!.annotation = annotation
        }
        
        
        
        if annotationView == nil {
            //Create the view
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.calloutOffset = CGPoint(x: 0, y: 0)
            
            let btn = UIButton(type: .detailDisclosure)
            btn.addAction {
                self.present(MainVC(), animated: true)
            }
            annotationView?.rightCalloutAccessoryView = btn
        }
        else {
            annotationView?.annotation = annotation
        }
        let btn = UIButton(type: .detailDisclosure)
        btn.addAction { [self] in
            
          
            let newsView = AppStoryboard.Main.shared.instantiateViewController(withIdentifier: NewsFeedVC.storyboard_id) as! NewsFeedVC
            newsView.modalPresentationStyle = .automatic
            present(newsView, true)
            
         //TODO: Using a reference to the newsVC passed in (function is implemented), pass it a filter (implemented below?) and then dismiss the MapView. Make sure the MapView is not presented in such a way that the NewsFeedVC is taken out of memory
            
            
            
         //   let v = UIStoryboard(name: "Utils", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
         //   mvc.viewDidLoad()
           // self.showPropertyDetails(indexOfLoop, true)
            /*
            newsView.modalPresentationStyle = .automatic
            newsView.refreshRecentList()
            
            var list = [PropertyModel]()
            v.to_be_filtered_properties = list
            v.news_feed_filter = true
            
            var items = [PropertyModel]()
            var mod = FilterModel()
            mod.city = self.getCityFromAdressString(self.indexOfLoop.address)
            //v.ct_address_text_field.safeText() = mod.city
            
           // v.updateFilterDataSource()
           // newsView.dataSource.removeAll()
            
            newsView.selected_filter_model = mod
            
            for prop in items {
                if getCityFromAdressString(prop.address) == mod.city {
                    newsView.dataSource.append(prop)
                    
                }
                
            }
            
           // newsView.recent_collection.reloadData()
        
            self.present(newsView, animated: true)
                
           */
            
            /*
            let v = FilterVC()
            let n = NewsFeedVC()
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
            
            let newsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsFeedVC") as! NewsFeedVC
            newsView.modalPresentationStyle = .automatic

            v.to_be_filtered_properties = list
            v.news_feed_filter = true
            
            var mod = FilterModel()
            mod.city = self.getCityFromAdressString(self.indexOfLoop.address)
            
            v.onDismiss = { (items, filter) in
                n.dataSource.removeAll()
                
                n.selected_filter_model = filter
                
                for prop in items {
                    n.dataSource.append(prop)
                }
                
                n.recent_collection.reloadData()
 */
          //  }
 
            
           
        //    self.present(newsView, animated: false)
 
        //}
        /*
         btn.addAction {
         self.present(NewsFeedVC(), animated: true)
         }
         */
        }//btn.addAction close
        
           
        annotationView?.rightCalloutAccessoryView = btn
        
        annotationView?.image = UIImage(named: "Icon")
        //self.performSegue(withIdentifier: "NewsFeedVC", sender: nil)
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        //let span1:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func stripHouseNumberFromAddressString(_ address: String) -> String {
        var splitStr:[String] = address.components(separatedBy: " ")
        
        if let firstElem = splitStr.first {
            if (firstElem.isNumber) {
                splitStr.removeFirst()
            }
        }
        
        return splitStr.joined(separator: " ")
    }
    
    func setIndex(index: PropertyModel)
    {
        indexOfLoop = index
    }
    
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}







/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */




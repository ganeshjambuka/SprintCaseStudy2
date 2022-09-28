//
//  MapViewController.swift
//  CaseStudy2
//
//  Created by adminn on 26/09/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variable
    // Instance of CLLocationManager
    var currLocManager: CLLocationManager!
     
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calling custom image button
        orderButtonImageConfig()
        // Calling Get User Location Function
        getUserLocation()
    }
    // MARK: Selector Method
    @objc func clickOnOrder(_ sender: UIButton) {
        let localVc = storyboard?.instantiateViewController(withIdentifier: "LocalNotificationViewController") as! LocalNotificationViewController
        self.navigationController?.pushViewController(localVc, animated: true)
    }
    // MARK: Functions
    func orderButtonImageConfig () {
        // Setting UIButton type
        let orderNowButton = UIButton(type: .custom)
        
        // Setting image size
        let imageSize: CGSize = CGSize(width: 254, height: 50)
        
        // Setting image
        let orderNowImage = UIImage(named: "ordernow.jpg")
        
        // Setting frame and position of button
        orderNowButton.frame = CGRect(x: 80, y: 800, width: 254, height: 60)
        
        // Setting image to button background
        orderNowButton.setImage(orderNowImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        // Configuring the edges for button so that image will be set within that edges
        orderNowButton.configuration?.contentInsets = NSDirectionalEdgeInsets (top: (orderNowButton.frame.size.height - imageSize.height)/2, leading: (orderNowButton.frame.size.width - imageSize.width)/2, bottom: (orderNowButton.frame.size.height - imageSize.height)/2, trailing: (orderNowButton.frame.size.width - imageSize.width)/2)
        
        // Adding button in the view
        self.view.addSubview(orderNowButton)
        
        // Adding target when clicked selector method will be called
        orderNowButton.addTarget(self, action: #selector(clickOnOrder(_:)), for: .touchUpInside)
        
    }
    
    func getUserLocation() {
        // Instance of CLLocatoinManager
        currLocManager = CLLocationManager()
        
        // Calling delegate
        currLocManager.delegate = self
        
        // Setting accuracy
        currLocManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Taking permission from user
        currLocManager.requestAlwaysAuthorization()
        
        // Checking if permission granted
        if CLLocationManager.locationServicesEnabled() {
            currLocManager.startUpdatingLocation()
        }
    }
    // Delegate Function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Coordinates accessed from Locations array which stores the coordinates
        let userLocation: CLLocation = locations[0] as CLLocation
        
        // Providing the coordinates from the userLocation to locate
        let view = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        // To get broader view region of that location
        let region = MKCoordinateRegion(center: view, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        // Calling setRegion method in mapview kit and also passing region view
        
        mapView.setRegion(region, animated: true)
        // Instance of MKPointAnnotation
        let pinpoint = MKPointAnnotation()
        
        // Passing Coordinates to newly created instance
        pinpoint.coordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        // Title for Annotation
        getTitleValue { (annotationTitle) in
            pinpoint.title = annotationTitle
        }
        // Adding it to mapview
        mapView.addAnnotation(pinpoint)
        func getTitleValue(handler: @escaping (String)-> Void) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: userLocation.coordinate.latitude , longitude: userLocation.coordinate.longitude)
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                (placemarkArr, error) -> Void in
                var placemarks: CLPlacemark?
                placemarks = placemarkArr?[0]
                let annotationTitle = "\(placemarks?.subLocality ?? "")"
                handler(annotationTitle)
            })
        }
    }
}

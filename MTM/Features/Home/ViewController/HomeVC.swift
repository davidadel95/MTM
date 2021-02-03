//
//  HomeVC.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import Firebase
import GoogleMaps

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var mapView: GMSMapView!
    // MARK: - Variables
    var locationManager = CLLocationManager()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let db = Firestore.firestore()
//        // Add a new document with a generated ID
//        var ref: DocumentReference? = nil
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
        
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16.0)
//        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)

//        mapView.camera = camera
//
//        // Creates a marker in the center of the map.
        
        setupMapView()
    }


    // MARK: - Actions
    
    @IBAction func menuTapped(_ sender: Any) {
        print("menu")
        sideMenuController?.revealMenu()
    }
    // MARK: - Methods
    
    func setupMapView(){
        self.mapView.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

    }

}

extension HomeVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)

        self.mapView?.animate(to: camera)
        
        print((location?.coordinate.latitude)!)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        marker.title = "You are here"
//        marker.snippet = "Australia"
        marker.map = mapView
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        
    }
}

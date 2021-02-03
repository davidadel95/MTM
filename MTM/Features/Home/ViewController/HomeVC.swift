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
//        GMSServices.provideAPIKey("AIzaSyB6RYZkcGKumvHuKMuUBTFXlpKEWorfo_c")
        
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16.0)
//        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
//        self.view.addSubview(mapView)
//
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView

    }


    // MARK: - Actions
    
    // MARK: - Methods

}

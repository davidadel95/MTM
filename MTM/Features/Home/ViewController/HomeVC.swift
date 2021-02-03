//
//  HomeVC.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import Firebase
import GoogleMaps
import FirebaseFirestoreSwift

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var resultsContainerView: UIView!
    
    @IBOutlet var sourceTxtFld: UITextField!
    @IBOutlet var destinationTxtFld: UITextField!
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
//    var homeViewModel = HomeViewModel()
    var sourcesGlobal: [SourceModel]?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        homeViewModel.fetchData()
//        addDestination(destination: SourceModel(name: "city stars", latitude: 12.2, longitude: 11.2))
        setupViews()
//        setupMapView()
//        fetch()
//        fetchData()
        fetchData()
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
    
    func setupViews(){
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        resultsTableView.registerCellNib(cellClass: ResultsTVC.self)
        
        sourceTxtFld.delegate = self
    }
    
    func fetchData() {
        let db = Firestore.firestore()
        var books: [SourceModel]?
        
        db.collection("Source").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            books = documents.compactMap { queryDocumentSnapshot -> SourceModel? in
                return try? queryDocumentSnapshot.data(as: SourceModel.self)
            }
            self.sourcesGlobal = books
            self.resultsTableView.reloadData()
        }
    }
    
    func addDestination(destination: SourceModel){
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        // Add a new document with a generated ID
        ref = db.collection(Constants.SOURCE).addDocument(data: [
            "name": destination.name,
            "latitude": destination.latitude,
            "longitude": destination.longitude
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
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
        marker.map = mapView
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
}

extension HomeVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourcesGlobal?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTVC") as! ResultsTVC
        cell.resultLbl.text = self.sourcesGlobal?[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
}
extension HomeVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension HomeVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resultsContainerView.isHidden = false
    }
}

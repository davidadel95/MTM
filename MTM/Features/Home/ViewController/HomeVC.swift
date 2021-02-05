//
//  HomeVC.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import Firebase
import GoogleMaps
import Toast_Swift
import CoreLocation
import GooglePlaces
import SVProgressHUD
import FirebaseFirestoreSwift

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var resultsContainerView: UIView!
    
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var sourceTxtFld: UITextField!
    @IBOutlet var destinationTxtFld: UITextField!
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
    var sourcesGlobal: [LocationModel]?
    var fetcher: GMSAutocompleteFetcher?

    var places = [DestinationModel]()
    var selectedResultType: ResultType = .firestore
    var drivers: [LocationModel]?
    var currentSourceLocation: LocationModel?
    var distances = [DistanceModel]()
    
    var isBackBtn: Bool = false
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMapView()
        setupMapsFetcher()
        fetchDriversLocations()
    }

    // MARK: - Actions
    
    @IBAction func menuTapped(_ sender: Any) {
        
        if isBackBtn == true{
            menuBtn.setImage(UIImage(named: "back"), for: .normal)
            resultsContainerView.isHidden = true
            view.endEditing(true)
            isBackBtn = false
            reloadImgBtn()
        }else{
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
            sideMenuController?.revealMenu()
        }
    }
    
    @IBAction func requestRdTapped(_ sender: Any) {
        guard let drivers = self.drivers else{
            return
        }
        
        self.distances.removeAll()
        for driver in drivers{
            let distance = calculateDistance(source: currentSourceLocation!, destination: driver)
            self.distances.append(DistanceModel(source: currentSourceLocation!, destination: driver, distance: distance))
        }
        
        self.distances.sort{$0.distance < $1.distance}
        var outputString = ""
        for distance in distances{
            outputString.append(String(format: "\n- \(distance.destination.name) is %.01fkm away", distance.distance))
        }
        
        let alert = UIAlertController(title: "Closest Driver", message: outputString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        destinationTxtFld.delegate = self
        
        SVProgressHUD.setBackgroundColor(.black)
        SVProgressHUD.setForegroundColor(.white)
    }
    
    func setupMapsFetcher(){
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.countries = ["EG"]
        
        // Create a new session token.
        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(filter: filter)
        fetcher?.delegate = self
        fetcher?.provide(token)
        
        destinationTxtFld?.addTarget(self, action: #selector(textFieldDidChange(textField:)),
                                 for: .editingChanged)
    }
    
    func reloadImgBtn(){
        if isBackBtn == true{
            menuBtn.setImage(UIImage(named: "back"), for: .normal)
        }else{
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        fetcher?.sourceTextHasChanged(textField.text!)  
    }

    
    func fetchSourceLocations() {
        let db = Firestore.firestore()
        var sources: [LocationModel]?
        
        db.collection(Constants.SOURCE).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            sources = documents.compactMap { queryDocumentSnapshot -> LocationModel? in
                return try? queryDocumentSnapshot.data(as: LocationModel.self)
            }
            self.sourcesGlobal = sources
            self.resultsTableView.reloadData()
        }
    }
    
    func fetchDriversLocations() {
        let db = Firestore.firestore()
        var drivers: [LocationModel]?
        
        db.collection(Constants.DRIVERS).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            drivers = documents.compactMap { queryDocumentSnapshot -> LocationModel? in
                return try? queryDocumentSnapshot.data(as: LocationModel.self)
            }
            self.drivers = drivers
        }
    }
    
    func addDestination(destination: LocationModel){
        SVProgressHUD.show()
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection(Constants.DESTINATION).addDocument(data: [
            "name": destination.name,
            "latitude": destination.latitude,
            "longitude": destination.longitude
        ]) { err in
            if let err = err {
                SVProgressHUD.dismiss()
                self.view.makeToast("Error adding location: \(err)", duration: 3.0, position: .top)
                print("Error adding document: \(err)")
            } else {
                SVProgressHUD.dismiss()
                self.view.makeToast("Location added to collection", duration: 2.0, position: .top)
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func getPlaceDataByPlaceID(pPlaceID: String){
        let placesClient = GMSPlacesClient.shared()
        placesClient.lookUpPlaceID(pPlaceID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }

            if let place = place {
                let dest = LocationModel(name: place.name ?? "", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                
                self.addDestination(destination: dest)
            } else {
                print("No place details for \(pPlaceID)")
            }
        })
    }
    
    func calculateDistance(source: LocationModel, destination: LocationModel) -> Double{
        //source location
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)

        //destination location
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

        //Measuring source location to destination location (in km)
        let distance = sourceLocation.distance(from: destinationLocation) / 1000
        
        return distance
    }
}

extension HomeVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)

        self.mapView?.animate(to: camera)
        
        
        currentSourceLocation = LocationModel(name: "Current Location",
                                            latitude: Double((location?.coordinate.latitude)!),
                                            longitude: Double((location?.coordinate.longitude)!))

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        marker.title = "You are here"
        marker.map = mapView
        
        self.locationManager.stopUpdatingLocation()
    }
}

extension HomeVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedResultType == .firestore{
            return self.sourcesGlobal?.count ?? 0
        }else{
            return self.places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTVC") as! ResultsTVC
        if selectedResultType == .firestore{
            cell.resultLbl.text = self.sourcesGlobal?[indexPath.row].name
        }else{
            cell.resultLbl.text = self.places[indexPath.row].name
        }
        cell.selectionStyle = .none
        return cell
    }
}
extension HomeVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedResultType == .firestore{
            sourceTxtFld.text = self.sourcesGlobal?[indexPath.row].name
            currentSourceLocation = self.sourcesGlobal?[indexPath.row]
        }else{
            destinationTxtFld.text = self.places[indexPath.row].name
            getPlaceDataByPlaceID(pPlaceID: self.places[indexPath.row].placeID)
        }
    }
}

extension HomeVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isBackBtn = true
        reloadImgBtn()
        
        if textField == sourceTxtFld{
            self.fetchSourceLocations()
            selectedResultType = .firestore
            resultsTableView.reloadData()
            resultsContainerView.isHidden = false
        }else{
            selectedResultType = .maps
            resultsTableView.reloadData()
            resultsContainerView.isHidden = false
        }
    }
}

extension HomeVC: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        let resultsStr = NSMutableString()
        self.places.removeAll()
        for prediction in predictions {
            resultsStr.appendFormat("\n Primary text: %@\n", prediction.attributedPrimaryText)
            resultsStr.appendFormat("Place ID: %@\n", prediction.placeID)
            self.places.append(DestinationModel(placeID: prediction.placeID, name: prediction.attributedPrimaryText.string))
            resultsTableView.reloadData()
        }
        print("Results : \(self.places)")
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("error \(error.localizedDescription)")
    }
}

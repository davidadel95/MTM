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
import GooglePlaces
import SVProgressHUD
import FirebaseFirestoreSwift

enum ResultType{
    case firestore
    case maps
}

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
    var fetcher: GMSAutocompleteFetcher?

    var places = [DestinationModel]()
    var selectedResultType: ResultType = .firestore
    var sourceLocation: SourceModel?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        homeViewModel.fetchData()
//        addDestination(destination: SourceModel(name: "city stars", latitude: 12.2, longitude: 11.2))
        setupViews()
        setupMapView()
        setupMapsFetcher()
    }

    // MARK: - Actions
    
    @IBAction func menuTapped(_ sender: Any) {
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
    
    @objc func textFieldDidChange(textField: UITextField) {
        fetcher?.sourceTextHasChanged(textField.text!)  
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
        //  pPlaceID = "ChIJXbmAjccVrjsRlf31U1ZGpDM"
        let placesClient = GMSPlacesClient.shared()
        placesClient.lookUpPlaceID(pPlaceID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }

            if let place = place {
                let dest = SourceModel(name: place.name ?? "", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                
                self.addDestination(destination: dest)
            } else {
                print("No place details for \(pPlaceID)")
            }
        })
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
            sourceLocation = self.sourcesGlobal?[indexPath.row]
        }else{
            destinationTxtFld.text = self.places[indexPath.row].name
            getPlaceDataByPlaceID(pPlaceID: self.places[indexPath.row].placeID)
        }
    }
}

extension HomeVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sourceTxtFld{
            self.fetchData()
            selectedResultType = .firestore
            resultsTableView.reloadData()
            resultsContainerView.isHidden = false
        }else{
            selectedResultType = .maps
            resultsTableView.reloadData()
            resultsContainerView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resultsContainerView.isHidden = true
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

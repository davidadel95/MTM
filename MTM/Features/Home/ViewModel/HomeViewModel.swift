//
//  HomeViewModel.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import Foundation
import Firebase

class HomeViewModel{
    
    var source: SourceModel?
    let db = Firestore.firestore()
    private var ref: DocumentReference? = nil
    
    func fetchData(){
        db.collection(Constants.SOURCE).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func addDestination(destination: SourceModel){
        // Add a new document with a generated ID
        ref = db.collection(Constants.DESTINATION).addDocument(data: [
            "name": destination.name,
            "latitude": destination.latitude,
            "longitude": destination.longitude
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }
    }
}

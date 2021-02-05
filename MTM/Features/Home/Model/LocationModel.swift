//
//  SourceModel.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import Foundation

struct LocationModel: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    
    var dictionary: [String: Any] {
        return [
          "name": name,
          "latitude": latitude,
          "longitude": longitude
        ]
      }
}

extension LocationModel{
    init?(dictionary: [String : Any]) {
      guard let name = dictionary["name"] as? String,
          let latitude = dictionary["latitude"] as? Double,
          let longitude = dictionary["longitude"] as? Double else { return nil }

      self.init(name: name,
                latitude: latitude,
                longitude: longitude)
    }
}

struct DestinationModel {
    let placeID: String
    let name: String
}

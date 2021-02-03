//
//  SourceModel.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import Foundation

struct SourceModel: Decodable {
    let name: String
    let latitude: Float
    let longitude: Float
    
    var dictionary: [String: Any] {
        return [
          "name": name,
          "latitude": latitude,
          "longitude": longitude
        ]
      }
}

extension SourceModel{
    init?(dictionary: [String : Any]) {
      guard let name = dictionary["name"] as? String,
          let latitude = dictionary["latitude"] as? Float,
          let longitude = dictionary["longitude"] as? Float else { return nil }

      self.init(name: name,
                latitude: latitude,
                longitude: longitude)
    }
}

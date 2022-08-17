//
//  LocationResponseModel.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation

public struct LocationResponse: Decodable {
        
    var name: String?
    var state: String?
    var country: String?
    var lat: Double?
    var lon: Double?
    
    internal init(cityName: String? = nil, state: String? = nil, country: String? = nil, lat: Double? = nil, lon: Double? = nil) {
        self.name = cityName
        self.state = state
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}

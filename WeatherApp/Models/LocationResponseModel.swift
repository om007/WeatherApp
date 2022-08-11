//
//  LocationResponseModel.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/11/22.
//

import Foundation

class LocationResponseModel: Decodable {
        
    var cityName: String?
    var country: String?
    
    internal init(cityName: String? = nil, country: String? = nil) {
        self.cityName = cityName
        self.country = country
    }

}

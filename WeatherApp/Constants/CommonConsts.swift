//
//  CommonConsts.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/11/22.
//

import Foundation

struct CommonConsts {
    
    static let APIKey_OpenWeather = ""
    static let HTTPGeocodeEndPoint = "http://api.openweathermap.org/geo/1.0/direct" //E.g: http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid={API key}
    static let HTTPWeatherEndpoint = "https://api.openweathermap.org/data/3.0/onecall" //E.g: https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&exclude=hourly,daily&appid={API key}
    
}

//
//  CommonConsts.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation

struct CommonConsts {
    
    static let APIKey_OpenWeather = "6e813ac88c303431179f8fc2dd9fe151"
    
    static let APIEndPoint_LocationSearch = "api.openweathermap.org" //E.g: http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid={API key}
    static let APIEndPoint_WeatherDetail = "api.openweathermap.org" //E.g: https://api.openweathermap.org/data/2.5/weather?lat=33.44&lon=-94.04&exclude=hourly,daily&appid={API key}
    
    static let openWeatherIconUrl = "http://openweathermap.org/img/w/" //E.g: http://openweathermap.org/img/w/${icon}.png
    
}

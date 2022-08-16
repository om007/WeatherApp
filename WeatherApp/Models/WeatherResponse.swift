//
//  WeatherResponseModel.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation

struct WeatherResponse: Decodable {
    var name: String?
    var lat: Double?
    var lon: Double?
    var timezone: Double?
    var weather: Weather?
    
    enum OuterKeys: String, CodingKey {
        case name, timezone, coordinates = "coord", weather = "weather", main = "main"
    }
    
    enum CoordKeys: String, CodingKey {
        case lon, lat
    }
    
    enum WeatherKeys: String, CodingKey {
        case main, description, icon
    }
    
    enum MainKeys: String, CodingKey {
        case temp, temp_min, temp_max, humidity
    }
    
    public init(from decoder: Decoder) throws {
        let outerValues = try decoder.container(keyedBy: OuterKeys.self)
        let coordValues = try outerValues.nestedContainer(keyedBy: CoordKeys.self, forKey: .coordinates)
        //var weatherValues = try outerValues.nestedUnkeyedContainer(forKey: .weather)
        let mainValues = try outerValues.nestedContainer(keyedBy: MainKeys.self, forKey: .main)

        // Decode lat, lon, timezone, when it comes as a String
        name = try outerValues.decode(String.self, forKey: .name)
        timezone = try outerValues.decode(Double.self, forKey: .timezone)
        
        lat = try coordValues.decode(Double.self, forKey: .lat)
        lon = try coordValues.decode(Double.self, forKey: .lon)
        
        // Decode Weather model
        let firstWeather = try outerValues.decode([Weather].self, forKey: .weather).first
        let temp = try mainValues.decode(Double.self, forKey: .temp)
        let temp_min = try mainValues.decode(Double.self, forKey: .temp_min)
        let temp_max = try mainValues.decode(Double.self, forKey: .temp_max)
        let humidity = try mainValues.decode(Double.self, forKey: .humidity)
            
        weather = Weather(main: firstWeather?.main, description: firstWeather?.description, icon: firstWeather?.icon, temp: temp, temp_max: temp_max, temp_min: temp_min, humidity: humidity)
    }
}

struct Weather: Decodable {
    var main: String?
    var description: String?
    var icon: String?
    var temp: Double?
    var temp_max: Double?
    var temp_min: Double?
    var humidity: Double?
}

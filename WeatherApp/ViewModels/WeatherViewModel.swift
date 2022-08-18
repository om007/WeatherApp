//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation
import Combine

class WeatherViewModel {
    
    @Published var locationResults = [LocationResponse]()
    @Published var weatherDetail: WeatherResponse?
    
    let limit = 5

    /// This method triggers location search to OpenWeather API by name. Also, notifies the observers attached with the location results.
    func searchLocations(_ name: String) {
        
        var searchRequest = URLComponents()
        searchRequest.scheme = "http"
        searchRequest.host = CommonConsts.APIEndPoint_LocationSearch
        searchRequest.path = "/geo/1.0/direct"
        let queryItems: [String : String] = ["q": name,
                                             "limit" : "\(limit)",
                                             "units" : "metric",
                                             "appid" : CommonConsts.APIKey_OpenWeather]
        searchRequest.queryItems  = WeatherViewModel.getQueryItems(from: queryItems)
        
        let httpRequest = HttpRequest(withUrl: searchRequest.url!, forHttpMethod: .get)
        HttpUtility.shared.request(httpRequest: httpRequest, resultType: [LocationResponse].self) { [weak self] result in
            switch result {
            case .success(let locations):
                //Populating locations as a suggestions in list
                let validLocations = locations?.filter { $0.lat != nil && $0.lon != nil }
                //completion(.success(validLocations))
                self?.locationResults = validLocations ?? []
                
            case .failure(let error):
                //Failed to retrive locations from search request
                //completion(.failure(error))
                self?.locationResults = []
                print(error.reason ?? "Error!")
            }
        }
    }
    
    /// This method requests OpenWeather API for the weather details from latitude and longitude. Also, notifies the observers attached with the weather details.
    func getWeatherInfo(lat: Double, lon: Double) {
        
        var weatherRequest = URLComponents()
        weatherRequest.scheme = "https"
        weatherRequest.host = CommonConsts.APIEndPoint_WeatherDetail
        weatherRequest.path = "/data/2.5/weather"
        let queryItems: [String : String] = ["lat" : "\(lat)",
                                             "lon" : "\(lon)",
                                             "units" : "metric",
                                             "exclude" : "minutely,hourly,daily",
                                             "appid" : CommonConsts.APIKey_OpenWeather]
        
        weatherRequest.queryItems = WeatherViewModel.getQueryItems(from: queryItems)

        let httpRequest = HttpRequest(withUrl: weatherRequest.url!, forHttpMethod: .get)
        HttpUtility.shared.request(httpRequest: httpRequest, resultType: WeatherResponse.self) { [weak self] result in
            switch result {
            case .success(let weatherReponse):
                //Showing weather detail
                self?.weatherDetail = weatherReponse
                
            case .failure(let error):
                //Failed to retrive weather details for selected location
                self?.weatherDetail = nil
                print(error.reason ?? "Error!")
            }
        }
    }
    
    /// A static method that creates an array of 'UIQueryItem' objects from dictionary of type [String : String] to be used with 'URLComponents' class's 'queryItems' property
    ///
    /// - Returns: An array of UIQueryItem objects to be used with 'URLComponents' class
    static func getQueryItems(from: [String: String]) -> [URLQueryItem] {
        return  from.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
}


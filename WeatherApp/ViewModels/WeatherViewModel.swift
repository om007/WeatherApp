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

    func searchLocations(_ name: String) {
        
        var searchRequest = URLComponents()
        searchRequest.scheme = "http"
        searchRequest.host = CommonConsts.APIEndPoint_LocationSearch
        searchRequest.path = "/geo/1.0/direct"
        searchRequest.queryItems = [URLQueryItem(name: "q", value: name),
                                    URLQueryItem(name: "limit", value: "5"),
                                    URLQueryItem(name: "units", value: "metric"),
                                    URLQueryItem(name: "appid", value: CommonConsts.APIKey_OpenWeather)]
        
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
                print(error.reason ?? "Error!")
            }
        }
    }
    
    func getWeatherInfo(lat: Double, lon: Double) {
        
        var weatherRequest = URLComponents()
        weatherRequest.scheme = "https"
        weatherRequest.host = CommonConsts.APIEndPoint_WeatherDetail
        weatherRequest.path = "/data/2.5/weather"
        weatherRequest.queryItems = [URLQueryItem(name: "lat", value: "\(lat)"),
                                     URLQueryItem(name: "lon", value: "\(lon)"),
                                     URLQueryItem(name: "units", value: "metric"),
                                     URLQueryItem(name: "exclude", value: "minutely,hourly,daily"),
                                     URLQueryItem(name: "appid", value: CommonConsts.APIKey_OpenWeather)]

        let httpRequest = HttpRequest(withUrl: weatherRequest.url!, forHttpMethod: .get)
        HttpUtility.shared.request(httpRequest: httpRequest, resultType: WeatherResponse.self) { [weak self] result in
            switch result {
            case .success(let weatherReponse):
                //Showing weather detail
                self?.weatherDetail = weatherReponse
                
            case .failure(let error):
                //Failed to retrive weather details for selected location
                print(error.reason ?? "Error!")
            }
        }
    }
    
}


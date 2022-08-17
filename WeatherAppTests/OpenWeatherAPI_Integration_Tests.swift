//
//  OpenWeatherAPI_Integration_Tests.swift
//  OpenWeatherAPI_Integration_Tests
//
//  Created by Om Prakash Shah on 8/15/22.
//

import XCTest
@testable import WeatherApp

class OpenWeatherAPI_Integration_Tests: XCTestCase {

    private var httpUtility = HttpUtility.shared

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getApiData_With_Valid_Request_Returns_Success() {
        // ARRANGE
        let name = "London"
        let limit = 5
        var searchRequest = URLComponents()
        searchRequest.scheme = "http"
        searchRequest.host = CommonConsts.APIEndPoint_LocationSearch
        searchRequest.path = "/geo/1.0/direct"
        let queryItems: [String : String] = ["q": name,
                                             "limit" : "5",
                                             "units" : "metric",
                                             "appid" : CommonConsts.APIKey_OpenWeather]
        searchRequest.queryItems  = WeatherViewModel.getQueryItems(from: queryItems)
        
        let expectation = XCTestExpectation(description: "Location received from OpenWeather API")
        let httpRequest = HttpRequest(withUrl: searchRequest.url!, forHttpMethod: .get)

        //ACT
        httpUtility.request(httpRequest: httpRequest, resultType: [LocationResponse].self) { (response) in
            switch response {
            case .success(let locations):
                // ASSERT
                XCTAssertNotNil(locations)
                XCTAssertLessThanOrEqual(locations?.count ?? 0, limit)
                
                //Checking each location result name against the input name by the user to be a substring
                for location in locations ?? [] {
                    let resultValid = location.name?.contains(name) ?? false
                    XCTAssert(resultValid)
                }
                
            case .failure(let error):
                // ASSERT
                XCTAssertNil(error)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func test_getWeatherDetail_From_Lat_Lon_Returns_Success() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // ARRANGE
        let lat = 33.44
        let lon = -94.04
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

        let expectation = XCTestExpectation(description: "Weather detail from OpenWeather API")
        let httpRequest = HttpRequest(withUrl: weatherRequest.url!, forHttpMethod: .get)
        
        //ACT
        httpUtility.request(httpRequest: httpRequest, resultType: WeatherResponse.self) { (response) in
            switch response {
            case .success(let weatherResponse):
                // ASSERT
                XCTAssertNotNil(weatherResponse)
                XCTAssertEqual(weatherResponse?.lat, lat)
                XCTAssertEqual(weatherResponse?.lon, lon)
                
            case .failure(let error):
                // ASSERT
                XCTAssertNil(error)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
            
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

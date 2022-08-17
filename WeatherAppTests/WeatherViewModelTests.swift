//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Om Prakash Shah on 8/17/22.
//

import XCTest
import Combine
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {

    private var httpUtility = HttpUtility.shared
    private var weatherViewModel: WeatherViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        weatherViewModel = WeatherViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        weatherViewModel = nil
    }

    func test_searchLocations_With_ValidName_Resturns_Success() throws {
        XCTAssert(weatherViewModel!.locationResults.isEmpty)
        
        //ARRANGE
        let name = "Kathmandu"
        let expectation = XCTestExpectation(description: "Wait for valid location autocomplete suggestions")
        //Just binding here
        weatherViewModel.$locationResults
            .dropFirst()
            .sink { [unowned self] validLocations in
                // ASSERT
                XCTAssertFalse(validLocations.isEmpty)
                XCTAssertLessThanOrEqual(validLocations.count, weatherViewModel.limit)
                
                for location in validLocations {
                    let resultValid = location.name?.contains(name) ?? false
                    XCTAssert(resultValid)
                }
                
                expectation.fulfill()
            }.store(in: &cancellables)
        
        //ACT
        weatherViewModel.searchLocations(name)
        wait(for: [expectation], timeout: 10.0)
    }
        
    func test_searchLocations_With_InvalidName_Resturns_Failure() throws {
        XCTAssert(weatherViewModel!.locationResults.isEmpty)
        
        //ARRANGE
        let name = "$%^Kathmandu5436"
        let expectation = expectation(description: "Wait for no location autocomplete suggestions")
        //Just binding here
        weatherViewModel.$locationResults
            .dropFirst()
            .sink { noLocations in
                // ASSERT
                XCTAssertNotNil(noLocations)
                XCTAssertTrue(noLocations.isEmpty)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        //ACT
        weatherViewModel.searchLocations(name)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_get_WeatherInfo_With_FromValid_Lat_Lon_Returns_Success() throws {
        XCTAssertNil(weatherViewModel.weatherDetail)
        
        //ARRANGE
        let lat = 33.44
        let lon = -94.04
        let expectation = XCTestExpectation(description: "Wait for weather detail")
        //Just binding here
        weatherViewModel.$weatherDetail
            .dropFirst()
            .sink { weatherInfo in
                // ASSERT
                XCTAssertNotNil(weatherInfo)
                XCTAssertEqual(weatherInfo?.lat, lat)
                XCTAssertEqual(weatherInfo?.lon, lon)
                
                expectation.fulfill()
            }.store(in: &cancellables)
        
        //ACT
        weatherViewModel.getWeatherInfo(lat: lat, lon: lon)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_get_WeatherInfo_With_FromInvalid_Lat_Lon_Returns_Failure() throws {
        XCTAssertNil(weatherViewModel.weatherDetail)
        
        //ARRANGE
        let lat = 33567567.44
        let lon = -945656756.04
        let expectation = XCTestExpectation(description: "Wait for no weather detail")
        //Just binding here
        weatherViewModel.$weatherDetail
            .dropFirst()
            .sink { weatherInfo in
                // ASSERT
                XCTAssertNil(weatherInfo)
                XCTAssertNotEqual(weatherInfo?.lat, lat)
                XCTAssertNotEqual(weatherInfo?.lon, lon)
                
                expectation.fulfill()
            }.store(in: &cancellables)
        
        //ACT
        weatherViewModel.getWeatherInfo(lat: lat, lon: lon)
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

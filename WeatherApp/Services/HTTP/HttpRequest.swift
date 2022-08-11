//
//  HttpRequest.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/11/22.
//

import Foundation

public enum HUHttpMethods: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Request {
    var url: URL { get set }
    var method: HUHttpMethods { get set }
}

public struct HttpRequest: Request {
    var url: URL
    var method: HUHttpMethods
    var requestBody: Data? = nil

    public init(withUrl url: URL, forHttpMethod method: HUHttpMethods, requestBody: Data? = nil) {
        self.url = url
        self.method = method
        self.requestBody = requestBody != nil ? requestBody: nil
    }
}


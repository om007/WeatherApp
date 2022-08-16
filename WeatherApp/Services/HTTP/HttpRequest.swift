//
//  HttpRequest.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation

public enum HTTPMethods: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Request {
    var url: URL { get set }
    var method: HTTPMethods { get set }
}

public struct HttpRequest: Request {
    var url: URL
    var method: HTTPMethods
    var requestBody: Data? = nil

    public init(withUrl url: URL, forHttpMethod method: HTTPMethods, requestBody: Data? = nil) {
        self.url = url
        self.method = method
        self.requestBody = requestBody != nil ? requestBody: nil
    }
}


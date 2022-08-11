//
//  HttpNetworkError.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/11/22.
//

import Foundation

public struct HttpNetworkError: Error {
    
    let reason: String?
    let httpStatusCode: Int?
    let requestUrl: URL?
    let requestBody: String?
    let serverResponse: String?

    init(withServerResponse response: Data? = nil, forRequestUrl url: URL, withHttpBody body: Data? = nil, errorMessage message: String, forStatusCode statusCode: Int) {
        self.serverResponse = response != nil ? String(data: response!, encoding: .utf8): nil
        self.requestUrl = url
        self.requestBody = body != nil ? String(data: body!, encoding: .utf8): nil
        self.httpStatusCode = statusCode
        self.reason = message
    }
}

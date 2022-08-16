//
//  HttpUtility.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import Foundation

public class HttpUtility {
    
    public static let shared = HttpUtility()
    public var authenticationToken: String? = nil
    public var customJsonDecoder: JSONDecoder? = nil

    private init() {}
    
    public func request<T:Decodable>(httpRequest: HttpRequest, resultType: T.Type, completionHandler: @escaping(Result<T?, HttpNetworkError>) -> Void) {
        switch httpRequest.method {
        case .get:
            getData(requestUrl: httpRequest.url, resultType: resultType) { completionHandler($0) }
            break

        case .post:
            postData(request: httpRequest, resultType: resultType) { completionHandler($0) }
            break

        case .put:
            putData(requestUrl: httpRequest.url, resultType: resultType) { completionHandler($0) }
            break

        case .delete:
            deleteData(requestUrl: httpRequest.url, resultType: resultType) { completionHandler($0) }
            break
        }
    }

    // MARK: - Private functions
    private func createJsonDecoder() -> JSONDecoder {
        let decoder = customJsonDecoder != nil ? customJsonDecoder!: JSONDecoder()
        if(customJsonDecoder == nil) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
    private func createUrlRequest(requestUrl: URL) -> URLRequest {
        var urlRequest = URLRequest(url: requestUrl)
        if(authenticationToken != nil) {
            urlRequest.setValue(authenticationToken!, forHTTPHeaderField: "authorization")
        }
        
        return urlRequest
    }

    private func decodeJsonResponse<T: Decodable>(data: Data, responseType: T.Type) -> T? {
        let decoder = createJsonDecoder()
        do {
            return try decoder.decode(responseType, from: data)
        }catch let error {
            debugPrint("error while decoding JSON response =>\(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - GET Api
    private func getData<T:Decodable>(requestUrl: URL, resultType: T.Type, completionHandler:@escaping(Result<T?, HttpNetworkError>) -> Void) {
        var urlRequest = self.createUrlRequest(requestUrl: requestUrl)
        urlRequest.httpMethod = HTTPMethods.get.rawValue

        performOperation(requestUrl: urlRequest, responseType: T.self) { (result) in
            completionHandler(result)
        }
    }

    // MARK: - POST Api
    private func postData<T:Decodable>(request: HttpRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, HttpNetworkError>) -> Void) {
        var urlRequest = self.createUrlRequest(requestUrl: request.url)
        urlRequest.httpMethod = HTTPMethods.post.rawValue
        urlRequest.httpBody = request.requestBody
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")

        performOperation(requestUrl: urlRequest, responseType: T.self) { (result) in
            completionHandler(result)
        }
    }
    
    // MARK: - PUT Api
    private func putData<T:Decodable>(requestUrl: URL, resultType: T.Type, completionHandler:@escaping(Result<T?, HttpNetworkError>) -> Void) {
        var urlRequest = self.createUrlRequest(requestUrl: requestUrl)
        urlRequest.httpMethod = HTTPMethods.put.rawValue

        performOperation(requestUrl: urlRequest, responseType: T.self) { (result) in
            completionHandler(result)
        }
    }

    // MARK: - DELETE Api
    private func deleteData<T:Decodable>(requestUrl: URL, resultType: T.Type, completionHandler:@escaping(Result<T?, HttpNetworkError>) -> Void) {
        var urlRequest = self.createUrlRequest(requestUrl: requestUrl)
        urlRequest.httpMethod = HTTPMethods.delete.rawValue

        performOperation(requestUrl: urlRequest, responseType: T.self) { (result) in
            completionHandler(result)
        }
    }

    // MARK: - Perform data task
    private func performOperation<T: Decodable>(requestUrl: URLRequest, responseType: T.Type, completionHandler:@escaping(Result<T?, HttpNetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: requestUrl) { (data, httpUrlResponse, error) in
            let statusCode = (httpUrlResponse as? HTTPURLResponse)?.statusCode
            if(error == nil && data != nil && data?.count != 0) {
                let response = self.decodeJsonResponse(data: data!, responseType: responseType)
                if (response != nil) {
                    completionHandler(.success(response))
                } else {
                    completionHandler(.failure(HttpNetworkError(withServerResponse: data, forRequestUrl: requestUrl.url!, withHttpBody: requestUrl.httpBody, errorMessage: error.debugDescription, forStatusCode: statusCode!)))
                }
            } else {
                let networkError = HttpNetworkError(withServerResponse: data, forRequestUrl: requestUrl.url!, withHttpBody: requestUrl.httpBody, errorMessage: error.debugDescription, forStatusCode: statusCode!)
                completionHandler(.failure(networkError))
            }
        }.resume()
    }
}

//
//  ApiManager.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 29.11.21.
//

import Foundation

final class ApiManager {

    // MARK: - Executing Request
    /// This function is called everytime an API Request is executed
    /// - Parameter request: URLRequest which will be executed
    private static func executeRequest(request: URLRequest) {
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = session.dataTask(with: request) {
                (data, response, error) in
                if let unwrappedData = data {
                    if let _ = try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableLeaves) as? [String:Any] {
                        // Handle The Response If You Need It
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        200...299 ~= httpResponse.statusCode ? print("Success") : print("Failure")
                    }
                }
                
            }
            task.resume()
        }
    }

    // MARK: - Creating And Preparing Request For Execution
    /// This function prepares and creates the needed URL Request that needs to be executed
    /// - Parameters:
    ///   - url: URL of the request
    ///   - httpBody: Paramaters of the request that previously needed to be converted to Data
    ///   - httpMethod: HTTPMethod of the request
    /// - Returns: URLRequest
    private static func prepareRequest(forUrl url: URL, httpBody: Data?, httpMethod: RequestMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        if httpMethod != .get && httpMethod != .delete {
            request.httpBody = httpBody
        }

        for (header, value) in NetworkConstant.Network.header {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return request
    }

    // MARK: - Tracking Notification
    static func trackNotificationAnalytics(requestDict: [String:Any]) {
        let httpBody = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        guard let url = URL(string: Router.TrackNotification.path) else { return }
        let trackNotificationURLRequest = prepareRequest(forUrl: url, httpBody: httpBody, httpMethod: Router.TrackNotification.method)
        executeRequest(request: trackNotificationURLRequest)
    }

    // MARK: - Tracking Session
    static func trackSession(requestDict: [String:Any]) {
        let httpBody = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        guard let url = URL(string: Router.TrackSession.path) else { return }
        let trackSessionURLRequest = prepareRequest(forUrl: url, httpBody: httpBody, httpMethod: Router.TrackSession.method)
        executeRequest(request: trackSessionURLRequest)
    }

    // MARK: - Tracking Event
    static func trackEvent(requestDict: [String:Any]) {
        let httpBody = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        guard let url = URL(string: Router.TrackEvent.path) else { return }
        let trackEventURLRequest = prepareRequest(forUrl: url, httpBody: httpBody, httpMethod: Router.TrackEvent.method)
        executeRequest(request: trackEventURLRequest)
    }

    // MARK: - Tracking Engagament
    static func trackEngagement(requestDict: [String:Any]) {
        let httpBody = try? JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
        guard let url = URL(string: Router.TrackEngagement.path) else { return }
        let trackEventURLRequest = prepareRequest(forUrl: url, httpBody: httpBody, httpMethod: Router.TrackEngagement.method)
        executeRequest(request: trackEventURLRequest)
    }
}

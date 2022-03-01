//
//  Router.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 21.12.21.
//

import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum Router {
    case TrackNotification
    case TrackSession
    case TrackEvent
    case TrackEngagement

    private var baseURL: String {
        return NetworkConstant.Network.baseUrl
    }

    var path: String {
        switch self {
        case .TrackNotification:
            return baseURL + NetworkConstant.Network.Endpoints.trackNotification
        case .TrackSession:
            return baseURL + NetworkConstant.Network.Endpoints.trackSessions
        case .TrackEvent:
            return baseURL + NetworkConstant.Network.Endpoints.trackEvents
        case .TrackEngagement:
            return baseURL + NetworkConstant.Network.Endpoints.trackEngagements
        }
    }

    var method: RequestMethod {
        switch self {
        case .TrackNotification, .TrackSession, .TrackEvent, .TrackEngagement:
            return .post
        }
    }
}


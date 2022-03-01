//
//  NetworkConstants.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 29.11.21.
//

import Foundation

struct NetworkConstant {
    
    struct Network {
        static let baseUrl = "https://gopush.simplyphp.dev/api/sdk"
        
        static let header = ["Content-Type" : "application/json", "api-token": GoPushManager.token ?? ""]
        
        struct Endpoints {
            static let trackNotification = "/devices"
            static let trackSessions = "/sessions"
            static let trackEvents = "/events"
            static let trackEngagements = "/engagements"
        }
    }
}

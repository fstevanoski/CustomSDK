//
//  UserDefaultsManager.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 24.2.22.
//

import Foundation


class UserDefaultsManager {
    
    static private let defaults = UserDefaults.standard
    
    //MARK: - Set/Get SocketData Array
    static func setSocketData(socketDataArray: [SocketData]) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(socketDataArray)
        defaults.set(data, forKey: "SocketData")
    }
    
    static func getSocketData() -> [SocketData]? {
        guard let socketData = defaults.data(forKey: "SocketData") else { return nil }
        do {
            let decoder = JSONDecoder()
            let socketDataArray = try decoder.decode([SocketData].self, from: socketData)
            return socketDataArray
        } catch {
            print("Unable to decode Array of SocketData (\(error)")
        }
        return nil
    }

    static func getDeviceID() -> String {
        guard let deviceID = defaults.value(forKey: "UUID") as? String else {
            let deviceID = UUID().uuidString
            defaults.setValue(deviceID, forKey: "UUID")
            return deviceID
        }
        return deviceID
    }

    static func saveLatestTimeStampForPresentedInAppMessage() {
        defaults.setValue(Date(), forKey: "lastInAppTimeStamp")
    }

    static func getLatestTimeStampForPresentedInAppMessage() -> Date? {
        return defaults.value(forKey: "lastInAppTimeStamp") as? Date
    }
}

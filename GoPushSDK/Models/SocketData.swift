//
//  SocketData.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 31.1.22.
//

import Foundation

enum Layout: String {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
    case full = "full"
    case carousel = "carousel"
}

enum TriggerType: String {
    case onAppOpen = "onAppOpen"
    case sessionDuration = "sessionDuration"
    case durationSinceLastInApp = "durationSinceLastInApp"
}

enum ScheduleDateCheck {
    case endDateInPast
    case endDateInPresentOrFuture
    case startDateInPast
    case startDateInPresent
    case startDateInFuture
    case startDateInPresentOrFuture
    case startDateInPresentOrPast
}

enum LogicOperatorType: String {
    case equals = "is"
    case notEquals = "not"
    case greater = "greater"
    case less = "less"
}

enum FrequencyType: String {
    case once = "once"
    case reccuring = "recurring"
}

struct SocketData: Codable {
    var id: Int?
    var position: String?
    var frequency: String?
    var closeButton: CloseButton?
    var blocks: [BlockElement]?
    var triggers: [[Trigger]]?
    var createdAt: String?
    var updatedAt: String?
    var schedule: Schedule?
    var dismiss: Int?

    var layoutType: Layout? {
        return Layout(rawValue: position ?? "")
    }
    
    var reccurenceType: FrequencyType {
        return FrequencyType(rawValue: frequency ?? "once") ?? .once
    }
}

struct Trigger: Codable {
    var type: String?
    var key: String?
    var logicOperator: String?
    var value: String?

    var triggerType: TriggerType? {
        return TriggerType(rawValue: type ?? "")
    }
    
    var logicOperatorType: LogicOperatorType? {
        return LogicOperatorType(rawValue: logicOperator ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case key = "key"
        case logicOperator = "operator"
        case value = "value"
    }
}

struct CloseButton: Codable {
    var show: Bool
    var icon: String?
    var height: Int?
    var width: Int?
}

struct Schedule: Codable {
    var start: String?
    var end: String?
    
    func checkForEndDate(scheduleDateCheck: ScheduleDateCheck) -> Bool {
        guard let endDate = DateFormatterManager.getDateFromStringWith(string: end, dateFormat: "yyyy-MM-dd hh:mm:ss"), let currentDate = DateFormatterManager.getDateFromStringWith(string: DateFormatterManager.getDateStringWithFormat(dateFormat: "yyyy-MM-dd hh:mm:ss", date: Date()), dateFormat: "yyyy-MM-dd hh:mm:ss") else { return false}
        let components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate, to: endDate)
        
        guard let year = components.year, let month = components.month, let days = components.day else { return true }
        
        if scheduleDateCheck == .endDateInPast {
            return year <= 0 && month <= 0 && days < 0
        } else {
            return year >= 0 && month >= 0 && days >= 0
        }
    }
    
    func checkForStarDate(scheduleDateCheck: ScheduleDateCheck) -> Bool {
        guard let startDate = DateFormatterManager.getDateFromStringWith(string: start, dateFormat: "yyyy-MM-dd hh:mm:ss"), let currentDate = DateFormatterManager.getDateFromStringWith(string: DateFormatterManager.getDateStringWithFormat(dateFormat: "yyyy-MM-dd hh:mm:ss", date: Date()), dateFormat: "yyyy-MM-dd hh:mm:ss") else { return false}
        let components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate, to: startDate)

        guard let year = components.year, let month = components.month, let days = components.day else { return true }
        
        if scheduleDateCheck == .startDateInPast {
            return year <= 0 && month <= 0 && days < 0
        } else if scheduleDateCheck == .startDateInPresentOrFuture {
            return year <= 0 && month <= 0 && days <= 0
        } else if scheduleDateCheck == .startDateInPresent {
            return year == 0 && month == 0 && days == 0
        } else if scheduleDateCheck == .startDateInFuture {
            return year >= 0 && month >= 0 && days > 0
        } else {
            return year >= 0 && month >= 0 && days >= 0
        }
    }
}

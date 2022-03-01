//
//  GoPushManager.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 23.11.21.
//

import Foundation
import UIKit

public protocol GoPushManagerDelegate {
    func showLocationPrompt()
}

public class GoPushManager: InAppManagerDelegate {
    func blockTappedWithLocationPrompt() {
        GoPushManager.delegate?.showLocationPrompt()
    }
    
    
    static let socketManager = SocketManager()
    static var accountNumber: String?
    static var token: String?
    static var deviceCountry: String?
    static var userTags: String?
    static var userPhone: String?
    static var userEmail: String?
    static var layout: Layout?
    static var socketData: SocketData?

    static var deviceID: String = UserDefaultsManager.getDeviceID()

    static let holderView = UIView()
    
    static public var delegate: GoPushManagerDelegate?

    static func getSocketType(type: MessageLayoutType) -> SocketData? {

        var jsonName = ""
        switch type {
        case .top:
            jsonName = "topLayout"
        case .center:
            jsonName = "centerLayout"
        case .bottom:
            jsonName = "bottomLayout"
        case .full:
            jsonName = "fullLayout"
        case .carousel:
            jsonName = "carouselLayout"
        }
        
        guard let bundlePath = Bundle(for: GoPushManager.self).path(forResource: jsonName, ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath), options: .mappedIfSafe) else { return nil}
        
        return try? JSONDecoder().decode(SocketData.self, from: jsonData)
    }
    
    @discardableResult public init(accountNumber: String?, token: String?, deviceCountry: String?, userTags: String?, userPhone: String?, userEmail: String?, webSocketToken: String?) {
        GoPushManager.accountNumber = accountNumber
        GoPushManager.token = token
        GoPushManager.deviceCountry = deviceCountry
        GoPushManager.userTags = userTags
        GoPushManager.userPhone = userPhone
        GoPushManager.userEmail = userEmail
        
        
        GoPushManager.socketManager.setToken(token: webSocketToken ?? "")
        
        
        InAppManager.delegate = self
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
                                               object: nil,
                                               queue: .main,
                                               using: didRotate)

        print(UserDefaultsManager.getDeviceID())
    }
    
    var didRotate: (Notification) -> Void = { notification in
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
//            print("landscape")
            break
        case .portrait, .portraitUpsideDown:
//            print("Portrait")
            break
        default:
            break
//            print("other (such as face up & down)")
        }
        guard let window = keyWindow else { print("window is nil"); return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                holderView.frame = window.frame
                holderView.layoutIfNeeded()
            }
        }
    }
    
    public static func setUserTags(userTags: String?) {
        GoPushManager.userTags = userTags
    }
    
    public static func setUserPhone(userPhone: String?) {
        GoPushManager.userPhone = userPhone
    }
    
    public static func setUserEmail(userEmail: String?) {
        GoPushManager.userEmail = userEmail
    }
    
    public static func setToken(token: String?) {
        GoPushManager.token = token
    }
    
    public static func setAccountNumber(accountNumber: String?) {
        GoPushManager.accountNumber = accountNumber
    }
    
    public static func setDeviceCountry(deviceCountry: String?) {
        GoPushManager.deviceCountry = deviceCountry
    }
    
    public static func sendNotificationAnalytic(for notificationState: NotificationInteractionState) {
        ApiManager.trackNotificationAnalytics(requestDict: getRequestDictForNotification(withState: .openedInForeground))
    }
    
    public static func sendSessionAnalytic(for sessionState: SessionState, duration: Int?, dateTime: Date) {
        ApiManager.trackSession(requestDict: getRequestDictForSession(with: sessionState, duration: duration, dateTime: dateTime))
    }

    public static func sendEventAnalytic(action: String, type: String, data: [String:Any]?) {
        ApiManager.trackEvent(requestDict: getRequestDictForEvents(action: action, type: type, data: data))
    }

    public static func sendEngagementAnalytic(action: String, messageID: String, type: String, dateTime: Date) {
        ApiManager.trackEngagement(requestDict: getRequestDictForEngagements(action: action, messageID: messageID, type: type, dateTime: dateTime))
    }

    static func formatDateToString(format: String, dateTime: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: dateTime)
    }
    
    static var keyWindow: UIWindow? {
           // Get connected scenes
           return UIApplication.shared.connectedScenes
               // Keep only active scenes, onscreen and visible to the user
//               .filter { $0.activationState == .foregroundActive }
               // Keep only the first `UIWindowScene`
               .first(where: { $0 is UIWindowScene })
               // Get its associated windows
               .flatMap({ $0 as? UIWindowScene })?.windows
               // Finally, keep only the key window
//               .first(where: \.isKeyWindow)
               .last
       }

    static func presentInAppMessage(socketData: SocketData?) {
        guard let socketData = socketData else { print ("SocketData is nil"); return }
        
        DispatchQueue.main.async {
            guard let inAppMessageView = InAppManager.createInAppMessageView(socketData: socketData) else { print ("inAppMessageView is nil"); return }



            guard let window = keyWindow else { print("window is nil"); return }

            GoPushManager.holderView.removeFromSuperview()

            holderView.frame = window.frame
            holderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            

            holderView.addSubview(inAppMessageView)

            self.makeConstraintsFor(view: inAppMessageView,
                                    layoutType: socketData.layoutType)

            window.addSubview(holderView)

            inAppMessageView.layoutSubviews()

            if let closeButton = inAppMessageView.subviews.first(where: {$0 is UIButton}) as? UIButton {
                closeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            }
            
            GoPushManager.socketManager.sendDataForPresentedInAppMessage(inAppMessageID: socketData.id)
            UserDefaultsManager.saveLatestTimeStampForPresentedInAppMessage()
            handleDismissingHolderView(dismissTime: socketData.dismiss ?? 5)
        }
    }
    
    private static func makeConstraintsFor(view: UIView, layoutType: Layout?) {
        view.translatesAutoresizingMaskIntoConstraints = false
                        
        view.leadingAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        view.trailingAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        switch layoutType {
        case .top:
            view.topAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        case .bottom:
            view.bottomAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        case .center:
            view.centerYAnchor.constraint(equalTo: holderView.centerYAnchor).isActive = true
            let viewHeight: CGFloat
            if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                // Portrait
                // -40 is the offset from left and right
                viewHeight = UIScreen.main.bounds.width - 40
            } else {
                // Landscape
                viewHeight = UIScreen.main.bounds.height - 40
            }
            // This can be optimised
            view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        case .full, .carousel, .none:
            view.bottomAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: holderView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        }

    }


    @objc static func buttonTapped(_ sender: UIButton) {
        GoPushManager.holderView.removeFromSuperview()
    }

    public static func calculateTimeFromLastInAppMessage() -> Int? {
        guard let dateFromLastInAppMessage = UserDefaultsManager.getLatestTimeStampForPresentedInAppMessage() else { return nil }

        return Calendar.current.dateComponents([.second], from: dateFromLastInAppMessage, to: Date()).second
    }

    private static func handleDismissingHolderView(dismissTime: Int) {
        var timeInSecondsToDismiss = dismissTime
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeInSecondsToDismiss == 0 {
                GoPushManager.holderView.removeFromSuperview()
                timer.invalidate()
                return
            }
            timeInSecondsToDismiss -= 1
        }
    }
}

// MARK: - Extension For Creating Dictionaries For Requests
extension GoPushManager {

    // MARK: - Creating Dictionary For Tracking Notification Request
    static func getRequestDictForNotification(withState notificationInteractionState: NotificationInteractionState) -> [String:Any] {
        var dictionary = [String:Any]()
        var dataDictionary = [String:Any]()

        dataDictionary["deviceOs"] = "iOS"
        dataDictionary["deviceTimezone"] = TimeZone.current.identifier
        dataDictionary["deviceModel"] = UIDevice().type.rawValue

        dataDictionary["deviceLanguage"] = Locale.components(fromIdentifier: Locale.preferredLanguages.first ?? "")["kCFLocaleLanguageCodeKey"] ?? ""

        dataDictionary["deviceAppVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

        dataDictionary["deviceCountry"] = deviceCountry ?? ""
        dictionary["accountNumber"] = accountNumber ?? ""

        dataDictionary["userPhone"] = userPhone ?? ""
        dataDictionary["userEmail"] = userEmail ?? ""
        dataDictionary["userTags"] = userTags ?? ""

        dictionary["action"] = notificationInteractionState.rawValue
        dictionary["deviceId"] = deviceID

        dictionary["data"] = dataDictionary

        return dictionary
    }

    // MARK: - Creating Dictionary For Tracking Sessions Request
    static func getRequestDictForSession(with sessionState: SessionState, duration: Int?, dateTime: Date) -> [String:Any] {
        var dictionary = [String:Any]()
        var dataDictionary = [String:Any]()

        dictionary["action"] = sessionState.rawValue
        dictionary["deviceId"] = deviceID

        dictionary["accountNumber"] = accountNumber ?? ""

        dataDictionary["duration"] = duration ?? ""

        dataDictionary["datetime"] = formatDateToString(format: "yyyy-MM-dd hh:mm:ss", dateTime: dateTime)
        dataDictionary["type"] = sessionState.rawValue


        dataDictionary["timezone"] = TimeZone.current.identifier

        dictionary["data"] = dataDictionary

        return dictionary
    }

    // MARK: - Creating Dictionary For Tracking Events Request
    static func getRequestDictForEvents(action: String, type: String, data: [String:Any]?) -> [String:Any] {
        var dictionary = [String:Any]()
        let dataDictionary = data ?? [:]

        dictionary["accountNumber"] = accountNumber ?? ""
        dictionary["deviceId"] = deviceID
        dictionary["action"] = action
        dictionary["type"] = type
        dictionary["data"] = dataDictionary

        return dictionary
    }

    // MARK: - Creating Dictionary For Tracking Engagement Request
    static func getRequestDictForEngagements(action: String, messageID: String, type: String, dateTime: Date) -> [String:Any] {
        var dictionary = [String:Any]()
        var dataDictionary = [String:Any]()

        dictionary["accountNumber"] = accountNumber ?? ""
        dictionary["deviceId"] = deviceID
        dictionary["action"] = action



        dataDictionary["datetime"] = formatDateToString(format: "yyyy-MM-dd hh:mm:ss", dateTime: dateTime)
        dataDictionary["messageId"] = messageID
        dataDictionary["type"] = type
        dataDictionary["timezone"] = TimeZone.current.identifier

        dictionary["data"] = dataDictionary

        return dictionary
    }
}

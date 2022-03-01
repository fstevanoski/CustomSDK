//
//  SocketManager.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 16.2.22.
//

import Foundation
import PusherSwift

//Used to authorize user when user try to subscribe to channels
class AuthRequestBuilder: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channelName: String) -> URLRequest? {
        let pathString = "https://gopush.simplyphp.dev/websockets-monitor/auth"
        var request = URLRequest(url: URL(string: pathString)!)
        request.httpMethod = "POST"
        request.addValue("staging", forHTTPHeaderField: "X-App-ID")
        
        return request
    }
}

class SocketManager: NSObject {
    
    private var token: String!
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession!
    private var socketDataArray = [SocketData]()
    private var currentSessionDuration = 0
    private var initalSDKStart = true
    
    override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        setupPusherConnection()
        getSocketData()
        startTimerForSession()
    }
    
    let options = PusherClientOptions(
        authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder()),
        host: .host("socket-gopush.simplyphp.dev")
    )
    
    private lazy var client: Pusher = {
        return Pusher(key: "staging", options: options)
    }()
    
    func setToken(token: String) {
        self.token = token
    }
    
    func setupPusherConnection() {
        
        client.connection.pongResponseTimeoutInterval = 10
        client.delegate = self
        client.connect()
        
        let channel = client.subscribeToPresenceChannel(channelName: "AppMessageEvent")
        let _ = channel.bind(eventName: "App\\Events\\AppMessageEvent", eventCallback: { [self] (event: PusherEvent) -> Void in
            
            
            
            if let eventDataMessage = event.data, var dictionaries = self.convertToDictionary(message: eventDataMessage) {
                dictionaries = dictionaries.sorted(by: { firstDict, secondDict in
                    if let schedule1 = firstDict["schedule"] as? [String:Any], let start1 = schedule1["start"] as? String, let schedule2 = secondDict["schedule"] as? [String:Any], let start2 = schedule2["start"] as? String {
                        return start1 > start2
                    }
                    return false
                })
                let jsonDecoder = JSONDecoder()
                var socketDataArray = [SocketData]()
                for dictionary in dictionaries {
                    if let data = createDataFromJSON(dict: dictionary) {
                        do {
                            let socketData = try jsonDecoder.decode(SocketData.self, from: data)
                            if !(socketData.schedule?.checkForEndDate(scheduleDateCheck: .endDateInPast) ?? true) {
                                socketDataArray.append(socketData)
                            }
                            
                        } catch {
                            print(error)
                        }
                        
                        
                    }
                }
                socketDataArray = socketDataArray.sorted(by: {$0.schedule?.start ?? "" > $1.schedule?.start ?? ""})
                UserDefaultsManager.setSocketData(socketDataArray: socketDataArray)
                getSocketData()
            }
        })
    }
    
    private func convertToDictionary(message: String) -> [Dictionary<String,Any>]? {
        if let data = message.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Dictionary<String,Any>]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func createDataFromJSON(dict: [String:Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    func checkArrayForBool(arrayOfBools: [Bool]) -> Bool {
        for bool in arrayOfBools {
            if !bool {
                return false
            }
        }
        return true
    }
    
    func checkForScheduledSocketData(socketDataArray: [SocketData]) {

        var outerTriggersBool = [Bool]()
        var innerTriggersBool = [Bool]()
        
        for socketData in socketDataArray {
            if let outerTriggers = socketData.triggers {
                for innerTriggers in outerTriggers {
                    for innerTrigger in innerTriggers {
                        innerTriggersBool.append(checkTrigger(trigger: innerTrigger))
                    }
//                    print("Inner triggers: \(innerTriggersBool)")
//                    print("Result of inner triggers \(checkArrayForBool(arrayOfBools: innerTriggersBool))")
                    outerTriggersBool.append(checkArrayForBool(arrayOfBools: innerTriggersBool))
                    innerTriggersBool.removeAll()
                }
//                print("Outer triggers: \(outerTriggersBool)")
                if outerTriggersBool.contains(true) {
                    handleSocketDataAfterItsPresentation(socketData: socketData)
                    GoPushManager.presentInAppMessage(socketData: socketData)
                }
                innerTriggersBool.removeAll()
                
            }
            outerTriggersBool.removeAll()
        }
        initalSDKStart = false
    }
    
    func handleSocketDataAfterItsPresentation(socketData: SocketData) {
        socketDataArray = socketDataArray.filter({$0.id != socketData.id})
        
        if socketData.reccurenceType == .once {
            guard var locallySavedSocketDataArray = UserDefaultsManager.getSocketData() else { return }
            locallySavedSocketDataArray = locallySavedSocketDataArray.filter({$0.id != socketData.id})
            UserDefaultsManager.setSocketData(socketDataArray: socketDataArray)
        }
    }
    
    func startTimerForSession() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            currentSessionDuration += 1
//            print("Session duration: \(currentSessionDuration) Duration since last in app: \(GoPushManager.calculateTimeFromLastInAppMessage())")
            checkForScheduledSocketData(socketDataArray: socketDataArray)
        }
    }
    
    func checkTriggerForDurationSinceLastInApp(trigger: Trigger) -> Bool {
        guard let triggerValue = trigger.value, let triggerValue = Int(triggerValue), let triggerType = trigger.triggerType, let triggerLogicOperatorType = trigger.logicOperatorType else { return false }
        
        let valueToCompare = triggerType == .sessionDuration ? currentSessionDuration : (GoPushManager.calculateTimeFromLastInAppMessage() ?? 0)
                                                                                              
        switch triggerLogicOperatorType {
        case .equals:
            return valueToCompare == triggerValue
        case .notEquals:
            return valueToCompare != triggerValue
        case .greater:
            return valueToCompare > triggerValue
        case .less:
            return valueToCompare < triggerValue
        }
    }
    
    func checkTrigger(trigger: Trigger) -> Bool {
        guard let triggerType = trigger.triggerType else { return false }
        
        switch triggerType {
        case .onAppOpen:
            return initalSDKStart
        case .sessionDuration, .durationSinceLastInApp:
            return checkTriggerForDurationSinceLastInApp(trigger: trigger)
        }
    }
    
    private func getSocketData() {
        guard var socketDataArray = UserDefaultsManager.getSocketData() else { return }
        socketDataArray = socketDataArray.compactMap({ socketData in
            if socketData.reccurenceType == .reccuring && socketData.schedule?.checkForStarDate(scheduleDateCheck: .startDateInPresentOrPast) ?? false && socketData.schedule?.checkForEndDate(scheduleDateCheck: .endDateInPresentOrFuture) ?? false  {
                return socketData
            }
            
            if socketData.reccurenceType == .once {
                if socketData.schedule?.checkForStarDate(scheduleDateCheck: .startDateInPresent) ?? false {
                    return socketData
                }
                return nil
            }
            return nil
        })
        
        self.socketDataArray = socketDataArray
    }
}

// MARK: - Handling The Socket Connection For Sending Data Through The Socket
// This extension is meant for creating, sending and closing the socket connection meant for sending the data through websocket every time an InAppMessage is presented on screen
extension SocketManager {
    func sendDataForPresentedInAppMessage(inAppMessageID: Int?) {
        guard let inAppMessageID = inAppMessageID else { print("InAppMessageID Is Nil"); return }
        
        guard let url = URL(string: "wss://socket-gopush.simplyphp.dev/api/sdk/devices/connect") else { return  }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(token, forHTTPHeaderField: "token")
        
        webSocket = session.webSocketTask(with: urlRequest)
        
        webSocket?.resume()
        
        guard let data = getDataForSuccesfullPresentedInAppMessage(inAppMessageID: String(inAppMessageID)) else { print("Data is nil"); self.closeSocketConnectionForSendingData(); return }
        
        webSocket?.send(.data(data), completionHandler: { error in
            if let error = error {
                print(error)
            } else {
                print("Successful Sending Data")
            }
            self.closeSocketConnectionForSendingData()
            return
        })
    }
    
    func closeSocketConnectionForSendingData() {
        webSocket?.cancel(with: .goingAway, reason: "Data sent".data(using: .utf8))
    }
    
    func getDataForSuccesfullPresentedInAppMessage(inAppMessageID: String) -> Data? {
        var dict = [String:Any]()
        dict["deviceId"] = UserDefaultsManager.getDeviceID()
        dict["inAppMessagesId"] = inAppMessageID
        dict["openAt"] = GoPushManager.formatDateToString(format: "yyyy-MM-dd hh:mm:ss", dateTime: Date())
        
        return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}

// MARK: - Pusher Delegate Methods
extension SocketManager: PusherDelegate {
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        switch new {
        case .disconnected:
            print("Pusher is disconnected")
            break
        case .connected:
            print("Pusher is connected")
        case .connecting:
            print("Pusher is connecting")
        case .disconnecting:
            print("Pusher is disconnecting")
        case .reconnecting:
            print("Pusher is reconnecting")
        default:
            break
        }
    }
    
    func subscribedToChannel(name: String) {
        print(name)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("Failed \(name)")
    }
    
    func receivedError(error: PusherError) {
        print(error.message)
        print(error.code ?? 0)
    }
    
    func debugLog(message: String) {
//        print(message)
    }
}

// MARK: - URLSessionWebSocket Delegate Methods
extension SocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to socket for sending")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Closed connection to socket for sending data")
    }
}

//
//  PushNotificationType.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 23.11.21.
//

import Foundation

public enum NotificationInteractionState: String {
    case openedInForeground = "Opened_In_Foreground_State"
    case openedInInactiveState = "Opened_In_Background/Inactive_State"
    case openedRichNotification = "Opened_Rich_Notification"
    case interactedWithActionOnRichNotification = "Interacted_With_Action"
}

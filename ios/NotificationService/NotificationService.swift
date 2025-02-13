//
//  NotificationService.swift
//  NotificationService
//
//  Created by Sasho Hadzhiev on 2/13/25.
//

import UserNotifications
import CTNotificationService
import CleverTapSDK


class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//         self.contentHandler = contentHandler
        print("in notification service")
        // bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // if let bestAttemptContent = bestAttemptContent {
        //     // Modify the notification content here...
        //     bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
        //     contentHandler(bestAttemptContent)
        // }

        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: request.content.userInfo)
        super.didReceive(request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

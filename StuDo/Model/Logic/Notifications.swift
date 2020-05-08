//
//  Notifications.swift
//  StuDo
//
//  Created by Andrew on 9/15/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject {
    
    private static let center = UNUserNotificationCenter.current()
    
    static func checkIfCanSetNotifications(for date: Date) -> Bool {
        let lastReminderDate = Calendar.current.date(byAdding: .minute, value: -15, to: date)!
        let currentDate: Date = Date()
        return lastReminderDate > currentDate
    }
    
    
    static func notificationAlert(for ad: Ad, in controller: UIViewController) -> UIAlertController {
        
        func publishAction(for option: NotificationOption) {
            RootViewController.startLoadingIndicator()
            publishNotification(for: ad, option: option, completion: { success in
                DispatchQueue.main.async {
                    RootViewController.stopLoadingIndicator(with: success ? .success : .fail, completion: nil)
                }
            })
        }
        
        
        var authGranted = true
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if !success || error != nil {
                authGranted = false
            }
            
            dispatchGroup.leave()

        }
        
        dispatchGroup.wait()
        
        
        
        if authGranted {
            
            
            let alert = UIAlertController(title: Localizer.string(for: .notificationReminderAlertTitle), message: nil, preferredStyle: .actionSheet)
            
            if Calendar.current.date(byAdding: .minute, value: -15, to: ad.beginTime)! > Date() {
                alert.addAction(UIAlertAction(title: Localizer.string(for: .notificationRemindBefore15m), style: .default, handler: { _ in
                    publishAction(for: .before15m)
                }))
            }
            
            if Calendar.current.date(byAdding: .minute, value: -60, to: ad.beginTime)! > Date() {
                alert.addAction(UIAlertAction(title: Localizer.string(for: .notificationRemindBefore1h), style: .default, handler: { _ in
                    publishAction(for: .before1h)
                }))
            }
            
            alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
            
            return alert
            
            
        } else {
            
            
            let alert = UIAlertController(title: Localizer.string(for: .notificationsDisabledAlertTitle), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localizer.string(for: .okay), style: .default, handler: nil))
            
            let settingsAction = UIAlertAction(title: Localizer.string(for: .notificationsDisabledSettings), style: .default, handler: { _ in
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            })
            alert.addAction(settingsAction)
            alert.preferredAction = settingsAction
            
            return alert
            
            
        }
        
        
        
    }
    
    
    
    private static func publishNotification(for ad: Ad, option: NotificationOption, completion: @escaping (Bool) -> ()) {
        let notificationId = "ad-reminder:\(ad.id!)"
        
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        let content = UNMutableNotificationContent()
        content.title = ad.name
        var diffValue: Int = 0
        switch option {
        case .before15m:
            content.body = Localizer.string(for: .notificationEventReminderMessageBefore15m)
            diffValue = -15
        case .before1h:
            content.body = Localizer.string(for: .notificationEventReminderMessageBefore1h)
            diffValue = -60
        }
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: diffValue, to: ad.beginTime)!
        let triggerDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
        center.add(request) { (error) in
            completion(error == nil)
        }
        
    }
    
    private enum NotificationOption {
        case before15m
        case before1h
    }
    
}

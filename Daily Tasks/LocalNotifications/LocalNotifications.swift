//
//  LocalNotifications.swift
//  TaskManagerApp
//
//  Created by iosdev on 25.01.2024.
//

import Foundation
import UserNotifications

class LocalNotifications {
    
    func scheduleNotification(forTask task: Task, date: Date, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Manager"
        content.body = task.title
        content.sound = UNNotificationSound.default
        
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "taskNotification_\(task.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully")
                }
            }
        }
    }
    
    func cancelNotification(forTask task: Task) {
        let identifier = "taskNotification_\(task.id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

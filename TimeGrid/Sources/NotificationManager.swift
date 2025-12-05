//
//  NotificationManager.swift
//  时光格 V3.0 - 通知管理
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - 请求权限
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("通知权限请求错误: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - 每日提醒
    
    func scheduleDailyReminder(at time: Date) {
        // 先取消现有通知
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "今天的时光格还没记录"
        content.body = "花一分钟，封存这一天的心情吧 ✨"
        content.sound = .default
        content.badge = 1
        
        // 从时间中提取小时和分钟
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "TimeGrid_DailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 取消通知
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - 清除角标
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("清除角标失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 检查权限状态
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
}

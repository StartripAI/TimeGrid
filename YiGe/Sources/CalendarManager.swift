//
//  CalendarManager.swift
//  时光格 V3.3 - 系统日历集成
//
//  使用 EventKit 获取系统日历事件
//

import Foundation
import EventKit
import SwiftUI

// MARK: - 系统日历事件模型

struct SystemCalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let daysUntil: Int
}

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    
    @Published var authorizationStatus: EKAuthorizationStatus
    
    init() {
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - 请求日历权限
    
    func requestAccess() {
        guard authorizationStatus == .notDetermined else { return }
        
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.updateStatus()
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.updateStatus()
                }
            }
        }
    }
    
    private func updateStatus() {
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - 获取事件
    
    /// 获取指定月份有事件的日期集合（用于日历小点）
    func fetchEventPresence(for month: Date) -> Set<Date> {
        // 检查权限
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = authorizationStatus == .fullAccess
        } else {
            hasAccess = authorizationStatus == .authorized
        }
        
        guard hasAccess else { return [] }
        
        let calendar = Calendar.current
        
        // 计算月份的开始和结束日期
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth) else {
            return []
        }
        
        // 创建查询谓词
        let predicate = eventStore.predicateForEvents(withStart: startOfMonth, end: endOfMonth, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // 提取有事件的日期
        var daysWithEvents = Set<Date>()
        for event in events {
            let startDay = calendar.startOfDay(for: event.startDate)
            daysWithEvents.insert(startDay)
        }
        
        return daysWithEvents
    }
    
    /// 获取指定日期的事件列表
    func fetchEvents(for date: Date) -> [EKEvent] {
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = authorizationStatus == .fullAccess
        } else {
            hasAccess = authorizationStatus == .authorized
        }
        
        guard hasAccess else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    /// 获取接下来一段时间内的事件摘要（用于首页列表）
    func upcomingEvents(limit: Int = 3) -> [SystemCalendarEvent] {
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = authorizationStatus == .fullAccess
        } else {
            hasAccess = authorizationStatus == .authorized
        }
        guard hasAccess else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        // 查询未来 60 天的事件
        guard let endDate = calendar.date(byAdding: .day, value: 60, to: now) else {
            return []
        }
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
            .filter { !$0.isAllDay } // 简化：忽略全天事件
            .sorted { $0.startDate < $1.startDate }
        
        let mapped: [SystemCalendarEvent] = events.map { event in
            let startOfToday = calendar.startOfDay(for: now)
            let startDay = calendar.startOfDay(for: event.startDate)
            let days = calendar.dateComponents([.day], from: startOfToday, to: startDay).day ?? 0
            return SystemCalendarEvent(
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                daysUntil: max(days, 0)
            )
        }
        
        if limit > 0 {
            return Array(mapped.prefix(limit))
        } else {
            return mapped
        }
    }
    
    /// 将一条纪念日同步到系统日历
    func addEventToSystemCalendar(title: String, date: Date, notes: String? = nil) {
        let hasAccess: Bool
        if #available(iOS 17.0, *) {
            hasAccess = authorizationStatus == .fullAccess
        } else {
            hasAccess = authorizationStatus == .authorized
        }
        guard hasAccess else { return }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        // 纪念日设置为 1 小时事件，避免成为全天事件
        event.endDate = date.addingTimeInterval(60 * 60)
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            print("Failed to save event to system calendar: \(error)")
        }
    }
}


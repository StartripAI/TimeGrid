//
//  KeepsakeDateFormatter.swift
//  时光格 V4.0 - 统一日期格式化工具
//
//  统一日期格式化：所有信物使用统一的日期格式
//  减少重复代码，统一视觉风格
//

import SwiftUI

// MARK: - 日期格式化工具
struct KeepsakeDateFormatter {
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    static func formattedDateWithWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date)
    }
    
    static func formattedElegantTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
    
    static func weekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ViewModifier 便捷使用
struct KeepsakeDateModifier: ViewModifier {
    let date: Date
    let format: DateFormat
    
    enum DateFormat {
        case dateOnly
        case dateWithWeekday
        case elegantTimestamp
        case weekday
        case short
    }
    
    func body(content: Content) -> some View {
        Text(formattedText)
            .font(.system(size: 14, weight: .medium))
    }
    
    private var formattedText: String {
        switch format {
        case .dateOnly:
            return KeepsakeDateFormatter.formattedDate(date)
        case .dateWithWeekday:
            return KeepsakeDateFormatter.formattedDateWithWeekday(date)
        case .elegantTimestamp:
            return KeepsakeDateFormatter.formattedElegantTimestamp(date)
        case .weekday:
            return KeepsakeDateFormatter.weekday(date)
        case .short:
            return KeepsakeDateFormatter.shortDate(date)
        }
    }
}

extension View {
    func keepsakeDate(_ date: Date, format: KeepsakeDateModifier.DateFormat = .dateOnly) -> some View {
        self.modifier(KeepsakeDateModifier(date: date, format: format))
    }
}


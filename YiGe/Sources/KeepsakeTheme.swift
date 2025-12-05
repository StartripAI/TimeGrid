//
//  KeepsakeTheme.swift
//  时光格 V4.0 - 统一信物主题系统
//
//  统一颜色系统：所有信物使用统一的主题配置
//  改一个地方全改，新增信物也只需要填一行
//

import SwiftUI

// MARK: - 信物主题协议
protocol KeepsakeTheme {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var shadowColor: Color { get }
}

// MARK: - 全局主题表（12种信物）
struct KeepsakeThemeRegistry {
    static func theme(for style: RitualStyle) -> KeepsakeTheme {
        switch style {
        // 影像类
        case .polaroid:
            return PolaroidTheme()
        case .developedPhoto:
            return DevelopedPhotoTheme()
        
        // 票据类
        
        // 书信类
        case .envelope:
            return EnvelopeTheme()
        case .postcard:
            return PostcardTheme()
        case .journalPage:
            return JournalPageTheme()
        
        // 收藏类
        case .vinylRecord:
            return VinylRecordTheme()
        case .bookmark:
            return BookmarkTheme()
        case .pressedFlower:
            return PressedFlowerTheme()
        
        // 兼容旧版本
        case .monoTicket:
            return MovieTicketTheme() // 复用电影票主题
        case .galaInvite:
            return ConcertTicketTheme() // 复用演出票主题
        }
    }
}

// MARK: - 影像类主题

struct PolaroidTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#F5F5F5") }
    var secondaryColor: Color { Color(hex: "#FFFFFF") }
    var accentColor: Color { Color(hex: "#1C1C1C") }
    var backgroundColor: Color { Color(hex: "#FFFFFF") }
    var textColor: Color { Color(hex: "#2C2C2C") }
    var shadowColor: Color { Color.black.opacity(0.15) }
}

struct FilmNegativeTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#2C1810") }
    var secondaryColor: Color { Color(hex: "#1C1C1C") }
    var accentColor: Color { Color(hex: "#C41E3A") }
    var backgroundColor: Color { Color(hex: "#1C1C1C") }
    var textColor: Color { Color(hex: "#FFFFFF") }
    var shadowColor: Color { Color.black.opacity(0.5) }
}

struct DevelopedPhotoTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#FFF8E7") }
    var secondaryColor: Color { Color(hex: "#F5E6D3") }
    var accentColor: Color { Color(hex: "#8B4513") }
    var backgroundColor: Color { Color(hex: "#FFF8E7") }
    var textColor: Color { Color(hex: "#4A4A4A") }
    var shadowColor: Color { Color.black.opacity(0.2) }
}

// MARK: - 票据类主题

struct MovieTicketTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#C41E3A") }
    var secondaryColor: Color { Color(hex: "#8B0000") }
    var accentColor: Color { Color(hex: "#FFD700") }
    var backgroundColor: Color { Color(hex: "#FFFFFF") }
    var textColor: Color { Color(hex: "#1C1C1C") }
    var shadowColor: Color { Color(hex: "#C41E3A").opacity(0.3) }
}

struct TrainTicketTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#1E5631") }
    var secondaryColor: Color { Color(hex: "#2D5016") }
    var accentColor: Color { Color(hex: "#C41E3A") }
    var backgroundColor: Color { Color(hex: "#F5F5F5") }
    var textColor: Color { Color(hex: "#1C1C1C") }
    var shadowColor: Color { Color(hex: "#1E5631").opacity(0.2) }
}

struct ConcertTicketTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#1C1C1C") }
    var secondaryColor: Color { Color(hex: "#2C2C2C") }
    var accentColor: Color { Color(hex: "#FFD700") }
    var backgroundColor: Color { Color(hex: "#1C1C1C") }
    var textColor: Color { Color(hex: "#FFFFFF") }
    var shadowColor: Color { Color(hex: "#FFD700").opacity(0.4) }
}

// MARK: - 书信类主题

struct EnvelopeTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#8B4513") }
    var secondaryColor: Color { Color(hex: "#D2B48C") }
    var accentColor: Color { Color(hex: "#8B0000") }
    var backgroundColor: Color { Color(hex: "#FDF8F3") }
    var textColor: Color { Color(hex: "#2C2C2C") }
    var shadowColor: Color { Color(hex: "#8B4513").opacity(0.3) }
}

struct PostcardTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#87CEEB") }
    var secondaryColor: Color { Color(hex: "#B0E0E6") }
    var accentColor: Color { Color(hex: "#FF6B6B") }
    var backgroundColor: Color { Color(hex: "#FFFFFF") }
    var textColor: Color { Color(hex: "#2C2C2C") }
    var shadowColor: Color { Color(hex: "#87CEEB").opacity(0.2) }
}

struct JournalPageTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#FFF8DC") }
    var secondaryColor: Color { Color(hex: "#F5E6D3") }
    var accentColor: Color { Color(hex: "#C41E3A") }
    var backgroundColor: Color { Color(hex: "#FFF8DC") }
    var textColor: Color { Color(hex: "#4A4A4A") }
    var shadowColor: Color { Color.black.opacity(0.1) }
}

// MARK: - 收藏类主题

struct VinylRecordTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#1C1C1C") }
    var secondaryColor: Color { Color(hex: "#2C2C2C") }
    var accentColor: Color { Color(hex: "#C41E3A") }
    var backgroundColor: Color { Color(hex: "#1C1C1C") }
    var textColor: Color { Color(hex: "#FFFFFF") }
    var shadowColor: Color { Color.black.opacity(0.6) }
}

struct BookmarkTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#722F37") }
    var secondaryColor: Color { Color(hex: "#8B0000") }
    var accentColor: Color { Color(hex: "#FFD700") }
    var backgroundColor: Color { Color(hex: "#FFFFFF") }
    var textColor: Color { Color(hex: "#2C2C2C") }
    var shadowColor: Color { Color(hex: "#722F37").opacity(0.3) }
}

struct PressedFlowerTheme: KeepsakeTheme {
    var primaryColor: Color { Color(hex: "#228B22") }
    var secondaryColor: Color { Color(hex: "#90EE90") }
    var accentColor: Color { Color(hex: "#DEB887") }
    var backgroundColor: Color { Color(hex: "#FFF8DC") }
    var textColor: Color { Color(hex: "#2C2C2C") }
    var shadowColor: Color { Color(hex: "#228B22").opacity(0.2) }
}

// MARK: - 便捷扩展
extension RitualStyle {
    var theme: KeepsakeTheme {
        KeepsakeThemeRegistry.theme(for: self)
    }
}


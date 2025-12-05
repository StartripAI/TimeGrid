//
//  Models+V2.swift
//  时光格 V2.0 - 扩展数据模型
//
//  新增：时光胶囊、AI分析结果、云同步状态
//

import Foundation

// MARK: - ============================================
// MARK: - 时光胶囊模型
// MARK: - ============================================

/// 时光胶囊 - 可选的延迟开启功能
struct TimeCapsule: Codable, Identifiable, Equatable {
    let id: UUID
    let recordId: UUID                    // 关联的记录ID
    let createdAt: Date                   // 封入时间
    let scheduledOpenAt: Date             // 计划开启时间
    var isOpened: Bool                    // 是否已开启
    var openedAt: Date?                   // 实际开启时间
    var recipientUserId: String?          // 收件人（未来社交功能）
    var message: String?                  // 附加留言
    
    init(
        id: UUID = UUID(),
        recordId: UUID,
        scheduledOpenAt: Date,
        message: String? = nil,
        recipientUserId: String? = nil
    ) {
        self.id = id
        self.recordId = recordId
        self.createdAt = Date()
        self.scheduledOpenAt = scheduledOpenAt
        self.isOpened = false
        self.message = message
        self.recipientUserId = recipientUserId
    }
    
    /// 是否可以开启
    var canOpen: Bool {
        !isOpened && Date() >= scheduledOpenAt
    }
    
    /// 距离开启还有多久
    var timeUntilOpen: TimeInterval {
        max(0, scheduledOpenAt.timeIntervalSince(Date()))
    }
    
    /// 格式化的剩余时间
    var formattedTimeRemaining: String {
        let interval = timeUntilOpen
        if interval <= 0 { return "可以开启了" }
        
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)天\(hours)小时后"
        } else if hours > 0 {
            return "\(hours)小时后"
        } else {
            let minutes = Int(interval / 60)
            return "\(minutes)分钟后"
        }
    }
}

/// 时光胶囊预设时间选项
enum CapsuleTimePreset: CaseIterable {
    case tomorrow
    case nextWeek
    case nextMonth
    case threeMonths
    case halfYear
    case nextYear
    case custom
    
    var label: String {
        switch self {
        case .tomorrow: return "明天"
        case .nextWeek: return "一周后"
        case .nextMonth: return "一个月后"
        case .threeMonths: return "三个月后"
        case .halfYear: return "半年后"
        case .nextYear: return "一年后"
        case .custom: return "自定义"
        }
    }
    
    var icon: String {
        switch self {
        case .tomorrow: return "sunrise"
        case .nextWeek: return "calendar.badge.clock"
        case .nextMonth: return "calendar"
        case .threeMonths: return "leaf"
        case .halfYear: return "sun.max"
        case .nextYear: return "sparkles"
        case .custom: return "calendar.badge.plus"
        }
    }
    
    func targetDate(from baseDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch self {
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: baseDate)!
        case .nextWeek:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate)!
        case .nextMonth:
            return calendar.date(byAdding: .month, value: 1, to: baseDate)!
        case .threeMonths:
            return calendar.date(byAdding: .month, value: 3, to: baseDate)!
        case .halfYear:
            return calendar.date(byAdding: .month, value: 6, to: baseDate)!
        case .nextYear:
            return calendar.date(byAdding: .year, value: 1, to: baseDate)!
        case .custom:
            return baseDate // 需要用户选择
        }
    }
}

// MARK: - ============================================
// MARK: - AI 分析结果模型
// MARK: - ============================================

/// AI 情绪分析结果
struct EmotionAnalysis: Codable, Equatable {
    let recordId: UUID
    let analyzedAt: Date
    let dominantEmotion: EmotionType
    let emotionScores: [EmotionType: Double]
    let keywords: [String]
    let summary: String?
    let suggestions: [String]?
    
    enum EmotionType: String, Codable, CaseIterable {
        case joy = "喜悦"
        case calm = "平静"
        case sadness = "忧伤"
        case anxiety = "焦虑"
        case anger = "愤怒"
        case gratitude = "感恩"
        case hope = "希望"
        case nostalgia = "怀念"
        
        var emoji: String {
            switch self {
            case .joy: return "😊"
            case .calm: return "😌"
            case .sadness: return "😢"
            case .anxiety: return "😰"
            case .anger: return "😤"
            case .gratitude: return "🙏"
            case .hope: return "✨"
            case .nostalgia: return "🥹"
            }
        }
        
        var color: String {
            switch self {
            case .joy: return "#FFD700"
            case .calm: return "#87CEEB"
            case .sadness: return "#6495ED"
            case .anxiety: return "#DDA0DD"
            case .anger: return "#FF6B6B"
            case .gratitude: return "#98FB98"
            case .hope: return "#F5A623"
            case .nostalgia: return "#DEB887"
            }
        }
    }
}

/// AI 周报/月报
struct EmotionReport: Codable, Identifiable {
    let id: UUID
    let userId: String
    let periodType: PeriodType
    let startDate: Date
    let endDate: Date
    let generatedAt: Date
    let recordCount: Int
    let emotionDistribution: [EmotionAnalysis.EmotionType: Int]
    let topKeywords: [String]
    let aiSummary: String
    let highlights: [String]
    let suggestions: [String]
    
    enum PeriodType: String, Codable {
        case weekly = "周报"
        case monthly = "月报"
        case yearly = "年度总结"
    }
}

/// AI 续写建议
struct WritingSuggestion: Codable, Identifiable {
    let id: UUID
    let prompt: String           // 用户输入
    let suggestion: String       // AI 续写
    let style: SuggestionStyle
    let generatedAt: Date
    
    enum SuggestionStyle: String, Codable {
        case expand = "展开描述"
        case emotional = "情感深化"
        case poetic = "诗意润色"
        case concise = "简洁总结"
    }
}

// MARK: - ============================================
// MARK: - 扩展 DayRecord
// MARK: - ============================================

extension DayRecord {
    /// V2: 是否在时光胶囊中（需要从 DataManager 查询）
    var isInCapsule: Bool {
        // 将在 DataManager 扩展中实现
        return false
    }
}

// MARK: - ============================================
// MARK: - 云同步状态
// MARK: - ============================================

/// 同步状态
enum SyncStatus: String, Codable {
    case synced = "已同步"
    case pending = "待同步"
    case syncing = "同步中"
    case failed = "同步失败"
    case conflict = "冲突"
}

/// 可同步的数据项
protocol Syncable {
    var syncId: String { get }
    var syncStatus: SyncStatus { get set }
    var lastModified: Date { get }
    var localVersion: Int { get }
    var serverVersion: Int? { get set }
}

/// 同步元数据
struct SyncMetadata: Codable {
    var lastSyncAt: Date?
    var pendingChanges: Int
    var syncErrors: [SyncError]
    
    struct SyncError: Codable, Identifiable {
        let id: UUID
        let itemId: String
        let errorType: String
        let message: String
        let occurredAt: Date
    }
}


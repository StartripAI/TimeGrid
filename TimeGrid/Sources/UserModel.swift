//
//  UserModel.swift
//  时光格 V2.0 - 用户模型
//

import Foundation

// MARK: - ============================================
// MARK: - 用户模型
// MARK: - ============================================

struct User: Codable, Identifiable, Equatable {
    let id: String                        // 唯一标识（服务端生成）
    var nickname: String?
    var avatarURL: String?
    var phone: String?
    var email: String?
    var wechatOpenId: String?
    var appleUserId: String?
    let createdAt: Date
    var lastLoginAt: Date
    var isPro: Bool
    var proExpiresAt: Date?
    var settings: UserSettings
    var statistics: UserStatistics
    
    init(
        id: String,
        nickname: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.nickname = nickname
        self.createdAt = createdAt
        self.lastLoginAt = createdAt
        self.isPro = false
        self.settings = UserSettings()
        self.statistics = UserStatistics()
    }
    
    /// 是否已完善资料
    var isProfileComplete: Bool {
        nickname != nil && (phone != nil || wechatOpenId != nil || appleUserId != nil)
    }
    
    /// 显示名称
    var displayName: String {
        nickname ?? "时光旅人"
    }
}

/// 用户设置
struct UserSettings: Codable, Equatable {
    var notificationEnabled: Bool = true
    var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!
    var dailyQuoteEnabled: Bool = true
    var preferredRitualStyle: RitualStyle = .envelope
    var todayHubStyle: TodayHubStyle = .waxEnvelope
    var aiAssistEnabled: Bool = true
    var cloudSyncEnabled: Bool = false
    var language: String = "zh-CN"
}

/// 用户统计
struct UserStatistics: Codable, Equatable {
    var totalRecords: Int = 0
    var totalCapsules: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastRecordDate: Date?
    
    var joinedDays: Int {
        // 计算注册天数（需要从 User 的 createdAt 计算）
        return 0
    }
}

// MARK: - ============================================
// MARK: - 认证状态
// MARK: - ============================================

enum AuthState: Equatable {
    case unknown              // 初始状态
    case guest                // 游客模式（本地数据）
    case authenticated(User)  // 已登录
    case migrating            // 数据迁移中
    
    var isLoggedIn: Bool {
        if case .authenticated = self { return true }
        return false
    }
    
    var user: User? {
        if case .authenticated(let user) = self { return user }
        return nil
    }
}

/// 登录方式
enum AuthProvider: String, CaseIterable {
    case wechat = "微信"
    case apple = "Apple"
    case phone = "手机号"
    
    var icon: String {
        switch self {
        case .wechat: return "message.fill"
        case .apple: return "apple.logo"
        case .phone: return "phone.fill"
        }
    }
    
    var backgroundColor: String {
        switch self {
        case .wechat: return "#07C160"
        case .apple: return "#000000"
        case .phone: return "#F5A623"
        }
    }
}

// MARK: - ============================================
// MARK: - 注册触发条件
// MARK: - ============================================

/// 触发注册的条件
enum RegistrationTrigger {
    case recordCount(Int)     // 达到N条记录
    case capsuleCreate        // 创建时光胶囊
    case cloudSync            // 开启云同步
    case aiFeature            // 使用AI功能
    case proUpgrade           // 升级Pro
    case socialFeature        // 社交功能
    
    var message: String {
        switch self {
        case .recordCount(let count):
            return "你已经记录了\(count)条时光，注册后数据永不丢失"
        case .capsuleCreate:
            return "注册后才能创建时光胶囊，让未来的自己收到惊喜"
        case .cloudSync:
            return "注册后开启云同步，多设备无缝切换"
        case .aiFeature:
            return "注册后解锁AI智能助手，让记录更轻松"
        case .proUpgrade:
            return "注册后才能升级Pro，解锁全部功能"
        case .socialFeature:
            return "注册后加入时光社区，分享生活点滴"
        }
    }
}

/// 本地游客数据（用于迁移）
struct GuestData: Codable {
    let deviceId: String
    let records: [DayRecord]
    let capsules: [TimeCapsule]
    let anniversaries: [Anniversary]
    let settings: AppSettings
    let createdAt: Date
    let lastModified: Date
    
    var recordCount: Int { records.count }
}


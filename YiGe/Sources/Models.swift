//
//  Models.swift
//  一格 V3.0 - 数据模型
//

import Foundation
import SwiftUI

// MARK: - 核心记录模型
// MARK: - 蜡封印章设计枚举
enum WaxSealDesign: String, Codable, CaseIterable {
    case initialY = "Y"
    case initialG = "G"
    case heart = "♥"
    case star = "★"
    case crown = "♔"
    case anchor = "⚓"
    
    var text: String? {
        switch self {
        case .initialY: return "Y"
        case .initialG: return "G"
        default: return nil
        }
    }
    
    var systemImageName: String? {
        switch self {
        case .heart: return "heart.fill"
        case .star: return "star.fill"
        case .crown: return "crown.fill"
        case .anchor: return "anchor.fill"
        default: return nil
        }
    }
}

// MARK: - 记录摘要 (V4.2)
struct RecordSummary: Equatable {
    let emoji: String
    let sticker: String?
}

// MARK: - 美学细节模型 (V4.2)
struct AestheticDetails: Codable, Equatable {
    var letterBackgroundColorHex: String? // 信纸背景色 (信封风格)
    var sealRotationDegrees: Double?       // 印章旋转角度
    var waxSealDesign: WaxSealDesign?      // 蜡封印章设计
    var qrCodeContent: String?             // QR码内容
    var paperTexture: String?              // 纸张纹理
    var customStickers: [String]?          // 自定义贴纸
    
    // V7.5 新增字段用于高定系列
    var flightNumber: String? // The Voyager
    var seatNumber: String? // The Voyager
    var trackName: String? // The Collector (Vinyl)
    var magazineIssue: String? // The Vogue

    static func generate(for style: RitualStyle, customColorHex: String? = nil) -> AestheticDetails {
        var details = AestheticDetails()
        
        // 通用随机元素（所有信物都有）
        let allStickers = ["✨", "💫", "🌟", "🎨", "📸", "❤️", "🌸", "🍃", "📷", "🎬", "✉️", "📮", "🎯", "💎", "🔥", "⭐", "🌙", "☀️", "🌈", "🎪", "🎭", "🎪", "🎨", "🖼️", "📝", "✍️", "🎵", "🎶", "🎤", "🎧", "🎸", "🎹", "🎺", "🎻", "🥁", "🎲"]
        let stickerCount = Int.random(in: 2...5) // 随机2-5个贴纸
        details.customStickers = Array(allStickers.shuffled().prefix(stickerCount))
        
        // 70%概率添加二维码
        if Double.random(in: 0...1) < 0.7 {
            details.qrCodeContent = "YIGE-\(UUID().uuidString.prefix(12).uppercased())-\(Date().timeIntervalSince1970)"
        }

        switch style {
        // 影像类
        case .polaroid:
            details.paperTexture = "polaroid"
            // 添加更多贴纸
            details.customStickers = (details.customStickers ?? []) + ["📷", "✨", "📸"]
            // 添加时间戳
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "POLAROID-\(Date().formatted(date: .numeric, time: .omitted))"
            }
        case .developedPhoto:
            details.paperTexture = "vintage"
            details.customStickers = (details.customStickers ?? []) + ["🖼️", "📷", "✨"]
            details.sealRotationDegrees = Double.random(in: -8...8)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "PHOTO-\(Date().formatted(date: .numeric, time: .omitted))"
            }
        case .filmNegative:
            details.paperTexture = "film"
            details.customStickers = (details.customStickers ?? []) + ["🎞️", "📷", "✨"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "FILM-\(UUID().uuidString.prefix(8))"
            }
        
        // 票据类
        case .receipt:
            details.qrCodeContent = "RECEIPT-\(UUID().uuidString.prefix(12))-\(Date().timeIntervalSince1970)"
            details.paperTexture = "receipt"
            details.customStickers = (details.customStickers ?? []) + ["🧾", "💰", "💳"]
            details.sealRotationDegrees = Double.random(in: -3...3)
        case .thermal:
            details.qrCodeContent = "THERMAL-\(UUID().uuidString.prefix(12))-\(Date().timeIntervalSince1970)"
            details.paperTexture = "thermal"
            details.customStickers = (details.customStickers ?? []) + ["🧾", "🖨️"]
            details.sealRotationDegrees = Double.random(in: -2...2)
        
        // 书信类
        case .envelope:
            details.letterBackgroundColorHex = customColorHex ?? ["#FDF8F3", "#F9F7F1", "#E3F2FD", "#E8F5E9", "#FCE4EC"].randomElement()!
            details.sealRotationDegrees = Double.random(in: -20...20)
            details.waxSealDesign = [.initialY, .heart, .star, .crown, .anchor].randomElement()!
            details.qrCodeContent = "ENVELOPE-\(UUID().uuidString.prefix(8))-\(Date().timeIntervalSince1970)"
            details.customStickers = (details.customStickers ?? []) + ["✉️", "💌", "📮"]
        case .postcard:
            details.letterBackgroundColorHex = customColorHex ?? ["#FFF9E6", "#E8F4F8", "#F5E6E8"].randomElement()!
            details.customStickers = (details.customStickers ?? []) + ["📮", "✉️", "🌍"]
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "POSTCARD-\(UUID().uuidString.prefix(8))"
            }
        case .journalPage:
            details.letterBackgroundColorHex = customColorHex ?? "#FDF8F3"
            details.paperTexture = "lined"
            details.customStickers = (details.customStickers ?? []) + ["📝", "✍️", "📖"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.6 {
                details.qrCodeContent = "JOURNAL-\(Date().formatted(date: .numeric, time: .omitted))"
            }
        
        // 收藏类
        case .vinylRecord:
            details.paperTexture = "vinyl"
            details.customStickers = (details.customStickers ?? []) + ["💿", "🎵", "🎶"]
            details.trackName = "Track \(Int.random(in: 1...12)): Memory Lane"
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "VINYL-\(UUID().uuidString.prefix(8))"
            }
        case .bookmark:
            details.letterBackgroundColorHex = "#8B0000"
            details.paperTexture = "elegant"
            details.customStickers = (details.customStickers ?? []) + ["📑", "📖", "✨"]
            details.sealRotationDegrees = Double.random(in: -8...8)
            if Double.random(in: 0...1) < 0.6 {
                details.qrCodeContent = "BOOKMARK-\(UUID().uuidString.prefix(8))"
            }
        case .pressedFlower:
            details.paperTexture = "specimen"
            details.customStickers = (details.customStickers ?? []) + ["🌸", "🍃", "🌿", "🌺"]
            details.sealRotationDegrees = Double.random(in: -15...15)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "FLOWER-\(Date().formatted(date: .numeric, time: .omitted))"
            }
        
        // 兼容旧版本
        case .monoTicket:
            details.qrCodeContent = "TICKET-\(UUID().uuidString.prefix(8))-\(Date().timeIntervalSince1970)"
            details.customStickers = (details.customStickers ?? []) + ["🧾", "🎫"]
            details.sealRotationDegrees = Double.random(in: -5...5)
        case .galaInvite:
            details.paperTexture = "elegant"
            details.sealRotationDegrees = Double.random(in: -15...15)
            details.waxSealDesign = .star
            details.customStickers = (details.customStickers ?? []) + ["🎬", "✨", "🎭"]
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "GALA-\(UUID().uuidString.prefix(8))"
            }
        case .waxStamp:
            details.waxSealDesign = .crown
            details.sealRotationDegrees = Double.random(in: -20...20)
            details.customStickers = (details.customStickers ?? []) + ["👑", "✨", "💎"]
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "STAMP-\(UUID().uuidString.prefix(8))"
            }
        case .typewriter:
            details.paperTexture = "typewriter"
            details.customStickers = (details.customStickers ?? []) + ["⌨️", "📝", "✍️"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "TYPEWRITER-\(Date().formatted(date: .numeric, time: .omitted))"
            }
        case .safari:
            details.paperTexture = "map"
            details.customStickers = (details.customStickers ?? []) + ["🦁", "🌍", "🗺️", "🧭"]
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "SAFARI-\(UUID().uuidString.prefix(8))"
            }
        case .aurora:
            details.paperTexture = "holographic"
            details.customStickers = (details.customStickers ?? []) + ["🌌", "✨", "💫", "🌟"]
            details.sealRotationDegrees = Double.random(in: -15...15)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "AURORA-\(UUID().uuidString.prefix(8))"
            }
        case .astrolabe:
            details.paperTexture = "star_chart"
            details.customStickers = (details.customStickers ?? []) + ["🔭", "⭐", "🌙", "✨"]
            details.sealRotationDegrees = Double.random(in: -20...20)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "ASTROLABE-\(UUID().uuidString.prefix(8))"
            }
        case .omikuji:
            details.paperTexture = "wood"
            details.customStickers = (details.customStickers ?? []) + ["⛩️", "🎋", "🎐", "✨"]
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "OMIKUJI-\(UUID().uuidString.prefix(8))"
            }
        case .hourglass:
            details.paperTexture = "sand"
            details.customStickers = (details.customStickers ?? []) + ["⏳", "⏰", "✨"]
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "HOURGLASS-\(UUID().uuidString.prefix(8))"
            }
        
        // ✈️ 航空系列
        case .boardingPass:
            details.paperTexture = "boarding"
            details.customStickers = (details.customStickers ?? []) + ["✈️", "🎫", "🌍"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "BOARDING-\(UUID().uuidString.prefix(8))"
            }
        case .aircraftType:
            details.paperTexture = "certificate"
            details.customStickers = (details.customStickers ?? []) + ["✈️", "📋", "🏆"]
            details.sealRotationDegrees = Double.random(in: -3...3)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "AIRCRAFT-\(UUID().uuidString.prefix(8))"
            }
        case .flightLog:
            details.paperTexture = "logbook"
            details.customStickers = (details.customStickers ?? []) + ["📒", "✈️", "📝"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "FLIGHTLOG-\(UUID().uuidString.prefix(8))"
            }
        case .luggageTag:
            details.paperTexture = "tag"
            details.customStickers = (details.customStickers ?? []) + ["🏷️", "✈️", "🧳"]
            details.sealRotationDegrees = Double.random(in: -8...8)
            if Double.random(in: 0...1) < 0.6 {
                details.qrCodeContent = "LUGGAGE-\(UUID().uuidString.prefix(8))"
            }
        
        // 🎫 票据系列
        case .concertTicket:
            details.paperTexture = "ticket"
            details.customStickers = (details.customStickers ?? []) + ["🎸", "🎵", "🎤"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "CONCERT-\(UUID().uuidString.prefix(8))"
            }
        case .vault:
            details.paperTexture = "kraft"
            details.customStickers = ["TOP SECRET", "🔒", "💎", "✨"]
            details.sealRotationDegrees = Double.random(in: -10...10)
            if Double.random(in: 0...1) < 0.9 {
                details.qrCodeContent = "VAULT-\(UUID().uuidString.prefix(12))"
            }
        case .simple: // Vogue Cover
            details.paperTexture = "glossy"
            details.magazineIssue = "SEPTEMBER ISSUE"
            details.customStickers = (details.customStickers ?? []) + ["📰", "✨", "💎"]
            details.sealRotationDegrees = Double.random(in: -5...5)
            if Double.random(in: 0...1) < 0.7 {
                details.qrCodeContent = "VOGUE-\(UUID().uuidString.prefix(8))"
            }
        case .waxEnvelope:
            details.letterBackgroundColorHex = customColorHex ?? "#F3E5AB"
            details.paperTexture = "parchment"
            details.waxSealDesign = .crown
            details.sealRotationDegrees = Double.random(in: -20...20)
            details.customStickers = (details.customStickers ?? []) + ["📜", "👑", "✨"]
            if Double.random(in: 0...1) < 0.8 {
                details.qrCodeContent = "ROYAL-\(UUID().uuidString.prefix(8))"
            }
        }

        return details
    }
}

// MARK: - 核心记录模型
struct DayRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var content: String
    var mood: Mood
    var photos: [Data]
    var weather: Weather?
    var isSealed: Bool
    var sealedAt: Date?
    var hasBeenOpened: Bool
    var openedAt: Date?
    var artifactStyle: RitualStyle  // V3.0: 记录创建时使用的信物风格
    var aestheticDetails: AestheticDetails? // V4.2: 美学细节
    var sticker: String? // V4.2: 自定义贴纸
    var renderedArtifactID: String? // V4.0: 保存的信物图片ID（用于自定义信物）
    
    // MARK: - 新增元数据字段
    var timestamp: Date? // 精确时间戳（创建时的时间，精确到秒）
    var location: LocationData? // 位置信息
    var weatherData: WeatherData? // 详细天气数据
    var tags: [String] // 标签数组
    var eventType: EventType? // 事件类型
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        content: String = "",
        mood: Mood = .neutral,
        photos: [Data] = [],
        weather: Weather? = nil,
        isSealed: Bool = false,
        sealedAt: Date? = nil,
        hasBeenOpened: Bool = false,
        openedAt: Date? = nil,
        artifactStyle: RitualStyle = .envelope,
        aestheticDetails: AestheticDetails? = nil,
        sticker: String? = nil,
        renderedArtifactID: String? = nil,
        timestamp: Date? = nil,
        location: LocationData? = nil,
        weatherData: WeatherData? = nil,
        tags: [String] = [],
        eventType: EventType? = nil
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.content = content
        self.mood = mood
        self.photos = photos
        self.weather = weather
        self.isSealed = isSealed
        self.sealedAt = sealedAt
        self.hasBeenOpened = hasBeenOpened
        self.openedAt = openedAt
        self.artifactStyle = artifactStyle
        self.aestheticDetails = aestheticDetails
        self.sticker = sticker
        self.renderedArtifactID = renderedArtifactID
        // 新增元数据
        self.timestamp = timestamp ?? Date() // 默认使用当前时间
        self.location = location
        self.weatherData = weatherData
        self.tags = tags
        self.eventType = eventType
    }
    
    var formattedDate: String {
        DayRecordFormatters.full.string(from: date)
    }
    
    var shortDate: String {
        DayRecordFormatters.short.string(from: date)
    }
    
    var formattedElegantTimestamp: String {
        DayRecordFormatters.elegant.string(from: date)
    }
    
    // MARK: - 元数据格式化辅助方法
    
    /// 格式化位置信息（用于显示）
    var formattedLocation: String? {
        guard let location = location else { return nil }
        return location.address ?? location.placeName
    }
    
    /// 格式化详细天气信息（用于显示）
    var formattedWeatherInfo: String? {
        guard let weatherData = weatherData else { return nil }
        var parts: [String] = []
        
        if let temp = weatherData.temperature {
            parts.append("\(Int(temp))°C")
        }
        if let aqi = weatherData.airQuality {
            parts.append("AQI: \(aqi)")
        }
        if let humidity = weatherData.humidity {
            parts.append("湿度: \(Int(humidity))%")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
    
    /// 格式化日出日落信息
    var formattedSunriseSunset: String? {
        guard let weatherData = weatherData,
              let sunrise = weatherData.sunrise,
              let sunset = weatherData.sunset else { return nil }
        return "日出 \(sunrise) · 日落 \(sunset)"
    }
    
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var daysAgo: Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date, to: todayStart)
        return components.day ?? 0
    }
    
    var canBeOpened: Bool {
        guard isSealed, !hasBeenOpened, let sealedAt = sealedAt else { return false }
        return Date().timeIntervalSince(sealedAt) >= 24 * 3600
    }
    
    static func == (lhs: DayRecord, rhs: DayRecord) -> Bool {
        lhs.id == rhs.id
    }
}

private enum DayRecordFormatters {
    static let full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()
    
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()
    
    static let elegant: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
}

// MARK: - 心情枚举
enum Mood: String, Codable, CaseIterable {
    case joyful, peaceful, neutral, tired, sad
    
    var emoji: String {
        switch self {
        case .joyful: return "☀️"
        case .peaceful: return "🌤"
        case .neutral: return "☁️"
        case .tired: return "🌧"
        case .sad: return "🌫"
        }
    }
    
    var label: String {
        switch self {
        case .joyful: return "开心"
        case .peaceful: return "平静"
        case .neutral: return "一般"
        case .tired: return "疲惫"
        case .sad: return "低落"
        }
    }
    
    var color: Color {
        switch self {
        case .joyful: return .yellow
        case .peaceful: return .green
        case .neutral: return .gray
        case .tired: return .purple
        case .sad: return .blue
        }
    }
    
    var score: Int {
        switch self {
        case .joyful: return 5
        case .peaceful: return 4
        case .neutral: return 3
        case .tired: return 2
        case .sad: return 1
        }
    }
    
    // 用于心情趋势图的高度计算 (0.0 - 1.0)
    var intensity: Double {
        switch self {
        case .joyful: return 1.0
        case .peaceful: return 0.75
        case .neutral: return 0.5
        case .tired: return 0.3
        case .sad: return 0.2
        }
    }
    
    // 匹配HTML中的趋势图颜色
    var trendColor: Color {
        switch self {
        case .joyful: return Color(hex: "FFD54F")
        case .peaceful: return Color(hex: "81C784")
        case .neutral: return Color(hex: "B0BEC5")
        case .tired: return Color(hex: "B39DDB")
        case .sad: return Color(hex: "90A4AE")
        }
    }
}

// MARK: - 天气枚举
enum Weather: String, Codable, CaseIterable {
    case sunny, cloudy, rainy, snowy, windy
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .windy: return "wind"
        }
    }
    
    var label: String {
        switch self {
        case .sunny: return "晴"
        case .cloudy: return "阴"
        case .rainy: return "雨"
        case .snowy: return "雪"
        case .windy: return "风"
        }
    }
    
    // 🔥 新增：天气表情包
    var emoji: String? {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        case .windy: return "💨"
        }
    }
}

// MARK: - 详细天气数据（扩展元数据）
struct WeatherData: Codable, Equatable {
    var condition: Weather // 基础天气条件
    var temperature: Double? // 温度（摄氏度）
    var airQuality: Int? // 空气质量指数（AQI）
    var humidity: Double? // 湿度（0-100）
    var windSpeed: Double? // 风速（km/h）
    
    // 日出/日落时间
    var sunrise: String? // "06:45"
    var sunset: String? // "18:30"
    var daylightHours: String? // "10h 45m"
    
    init(condition: Weather, temperature: Double? = nil, airQuality: Int? = nil, humidity: Double? = nil, windSpeed: Double? = nil, sunrise: String? = nil, sunset: String? = nil, daylightHours: String? = nil) {
        self.condition = condition
        self.temperature = temperature
        self.airQuality = airQuality
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.sunrise = sunrise
        self.sunset = sunset
        self.daylightHours = daylightHours
    }
}

// MARK: - 位置数据
struct LocationData: Codable, Equatable {
    var address: String? // 地址文本（如"北京市朝阳区"）
    var latitude: Double? // 纬度
    var longitude: Double? // 经度
    var placeName: String? // 地点名称（如"三里屯"）
    
    init(address: String? = nil, latitude: Double? = nil, longitude: Double? = nil, placeName: String? = nil) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
    }
    
    var coordinate: (lat: Double, lon: Double)? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return (lat, lon)
    }
}

// MARK: - 事件类型
enum EventType: String, Codable, CaseIterable {
    case daily = "日常"
    case event = "事件"
    case inspiration = "灵感"
    case travel = "旅行"
    case work = "工作"
    case custom = "自定义"
    
    var icon: String {
        switch self {
        case .daily: return "house.fill"
        case .event: return "calendar"
        case .inspiration: return "lightbulb.fill"
        case .travel: return "airplane"
        case .work: return "briefcase.fill"
        case .custom: return "tag.fill"
        }
    }
}

// MARK: - 纪念日/节日模型
struct Anniversary: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var date: Date
    var isYearly: Bool // 是否每年重复
    var isBuiltIn: Bool // 是否内置节日
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        date: Date,
        isYearly: Bool = true,
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.date = date
        self.isYearly = isYearly
        self.isBuiltIn = isBuiltIn
    }
    
    // 计算距离下一次的天数
    func daysUntilNext(from today: Date = Date()) -> Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        
        if isYearly {
            // 获取今年的日期
            var components = calendar.dateComponents([.month, .day], from: date)
            components.year = calendar.component(.year, from: today)
            
            guard let thisYearDate = calendar.date(from: components) else { return 999 }
            let thisYearStart = calendar.startOfDay(for: thisYearDate)
            
            if thisYearStart >= todayStart {
                return calendar.dateComponents([.day], from: todayStart, to: thisYearStart).day ?? 0
            } else {
                // 今年已过，算明年
                components.year = calendar.component(.year, from: today) + 1
                guard let nextYearDate = calendar.date(from: components) else { return 999 }
                return calendar.dateComponents([.day], from: todayStart, to: nextYearDate).day ?? 0
            }
        } else {
            let targetStart = calendar.startOfDay(for: date)
            if targetStart < todayStart { return -1 } // 已过期
            return calendar.dateComponents([.day], from: todayStart, to: targetStart).day ?? 0
        }
    }
    
    // 获取下一次发生的日期
    func nextOccurrence(from today: Date = Date()) -> Date {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        
        if isYearly {
            var components = calendar.dateComponents([.month, .day], from: date)
            components.year = calendar.component(.year, from: today)
            
            guard let thisYearDate = calendar.date(from: components) else { return date }
            let thisYearStart = calendar.startOfDay(for: thisYearDate)
            
            if thisYearStart >= todayStart {
                return thisYearStart
            } else {
                components.year = calendar.component(.year, from: today) + 1
                return calendar.date(from: components) ?? date
            }
        } else {
            return date
        }
    }
}

// MARK: - 内置中国节日
struct ChineseHolidays {
    static func getBuiltInHolidays(for year: Int) -> [Anniversary] {
        let calendar = Calendar.current
        
        func makeDate(month: Int, day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        }
        
        return [
            Anniversary(name: "元旦", emoji: "🎆", date: makeDate(month: 1, day: 1), isBuiltIn: true),
            Anniversary(name: "情人节", emoji: "💕", date: makeDate(month: 2, day: 14), isBuiltIn: true),
            Anniversary(name: "妇女节", emoji: "👩", date: makeDate(month: 3, day: 8), isBuiltIn: true),
            Anniversary(name: "清明节", emoji: "🌿", date: makeDate(month: 4, day: 5), isBuiltIn: true),
            Anniversary(name: "劳动节", emoji: "💪", date: makeDate(month: 5, day: 1), isBuiltIn: true),
            Anniversary(name: "儿童节", emoji: "👶", date: makeDate(month: 6, day: 1), isBuiltIn: true),
            Anniversary(name: "建党节", emoji: "🎗️", date: makeDate(month: 7, day: 1), isBuiltIn: true),
            Anniversary(name: "建军节", emoji: "⭐️", date: makeDate(month: 8, day: 1), isBuiltIn: true),
            Anniversary(name: "教师节", emoji: "📚", date: makeDate(month: 9, day: 10), isBuiltIn: true),
            Anniversary(name: "国庆节", emoji: "🇨🇳", date: makeDate(month: 10, day: 1), isBuiltIn: true),
            Anniversary(name: "万圣节", emoji: "🎃", date: makeDate(month: 10, day: 31), isBuiltIn: true),
            Anniversary(name: "光棍节", emoji: "🛒", date: makeDate(month: 11, day: 11), isBuiltIn: true),
            Anniversary(name: "感恩节", emoji: "🦃", date: makeDate(month: 11, day: 28), isBuiltIn: true),
            Anniversary(name: "圣诞节", emoji: "🎄", date: makeDate(month: 12, day: 25), isBuiltIn: true),
            // 农历节日（这里用固定日期近似，实际应该用农历计算）
            Anniversary(name: "春节", emoji: "🧧", date: makeDate(month: 1, day: 29), isBuiltIn: true),
            Anniversary(name: "元宵节", emoji: "🏮", date: makeDate(month: 2, day: 12), isBuiltIn: true),
            Anniversary(name: "端午节", emoji: "🐲", date: makeDate(month: 5, day: 31), isBuiltIn: true),
            Anniversary(name: "七夕", emoji: "💑", date: makeDate(month: 8, day: 10), isBuiltIn: true),
            Anniversary(name: "中秋节", emoji: "🥮", date: makeDate(month: 9, day: 17), isBuiltIn: true),
            Anniversary(name: "重阳节", emoji: "🍂", date: makeDate(month: 10, day: 11), isBuiltIn: true),
        ]
    }
}

// MARK: - 格子状态
enum GridState {
    case empty, sealed, opened, today, future
    
    var backgroundColor: Color {
        switch self {
        case .empty: return Color("GridEmpty")
        case .sealed: return Color("GridSealed")
        case .opened: return Color("GridOpened")
        case .today: return Color("GridToday")
        case .future: return Color("GridFuture")
        }
    }
}

// MARK: - 设置模型
struct AppSettings: Codable, Equatable {
    var notificationEnabled: Bool
    var notificationTime: Date
    var dailyQuoteEnabled: Bool
    var quoteCategory: QuoteCategory
    // V4.0: 清晰区分入口风格和信物风格
    var preferredArtifactStyle: RitualStyle  // V4.0: 首选信物风格(输出)
    var todayHubStyle: TodayHubStyle          // V4.0: 今日首页仪式风格(入口)
    
    // V4.0: 向后兼容 - 保留旧字段用于迁移
    private var preferredRitualStyle: RitualStyle?  // 旧字段，用于迁移
    
    static func defaultSettings() -> AppSettings {
        let defaultTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
        return AppSettings(
            notificationEnabled: true,
            notificationTime: defaultTime,
            dailyQuoteEnabled: true,
            quoteCategory: .mixed,
            preferredArtifactStyle: .thermal,  // V4.0: 默认信物风格（改为thermal）
            todayHubStyle: .simple  // V4.0: 默认入口风格
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case notificationEnabled
        case notificationTime
        case dailyQuoteEnabled
        case quoteCategory
        case preferredRitualStyle  // 旧key，用于迁移
        case preferredArtifactStyle  // 新key
        case todayHubStyle
    }
    
    init(
        notificationEnabled: Bool,
        notificationTime: Date,
        dailyQuoteEnabled: Bool,
        quoteCategory: QuoteCategory,
        preferredArtifactStyle: RitualStyle,
        todayHubStyle: TodayHubStyle
    ) {
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.dailyQuoteEnabled = dailyQuoteEnabled
        self.quoteCategory = quoteCategory
        self.preferredArtifactStyle = preferredArtifactStyle
        self.todayHubStyle = todayHubStyle
        self.preferredRitualStyle = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationEnabled) ?? true
        notificationTime = try container.decodeIfPresent(Date.self, forKey: .notificationTime) ?? Date()
        dailyQuoteEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyQuoteEnabled) ?? true
        quoteCategory = try container.decodeIfPresent(QuoteCategory.self, forKey: .quoteCategory) ?? .mixed
        
        // V4.0: 迁移逻辑 - 优先使用新key，如果没有则从旧key迁移
        if let newStyle = try? container.decodeIfPresent(RitualStyle.self, forKey: .preferredArtifactStyle) {
            preferredArtifactStyle = newStyle
        } else if let oldStyle = try? container.decodeIfPresent(RitualStyle.self, forKey: .preferredRitualStyle) {
            preferredArtifactStyle = oldStyle
        } else {
            preferredArtifactStyle = .envelope  // 默认值
        }
        
        // V4.0: 迁移 todayHubStyle
        if let hubStyle = try? container.decodeIfPresent(TodayHubStyle.self, forKey: .todayHubStyle) {
            todayHubStyle = hubStyle
        } else {
            todayHubStyle = .simple  // 默认值
        }
        
        preferredRitualStyle = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(notificationEnabled, forKey: .notificationEnabled)
        try container.encode(notificationTime, forKey: .notificationTime)
        try container.encode(dailyQuoteEnabled, forKey: .dailyQuoteEnabled)
        try container.encode(quoteCategory, forKey: .quoteCategory)
        try container.encode(preferredArtifactStyle, forKey: .preferredArtifactStyle)
        try container.encode(todayHubStyle, forKey: .todayHubStyle)
    }
}

enum QuoteCategory: String, Codable, CaseIterable {
    case mixed = "混合"
    case philosophy = "哲学名言"
    case poetry = "古诗词"
    case motivation = "励志语录"
    case time = "时间智慧"
    case life = "生活哲理"
    
    var label: String { rawValue }
}

// MARK: - 信物分类枚举
enum ArtifactCategory: String, CaseIterable, Identifiable {
    case photography = "影像类"      // 📷
    case tickets = "票据类"         // 🎫
    case letters = "书信类"         // ✉️
    case collection = "收藏类"       // ⭐
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .photography: return "📷"
        case .tickets: return "🎫"
        case .letters: return "✉️"
        case .collection: return "⭐"
        }
    }
    
    var description: String {
        switch self {
        case .photography: return "即时生活"
        case .tickets: return "旅途风景"
        case .letters: return "远方问候"
        case .collection: return "自然之美"
        }
    }
}

// MARK: - 时光信物风格 (V4.0 - 12种完整信物系统)
enum RitualStyle: String, Codable, CaseIterable, Equatable {
    // 影像类
    case polaroid = "拍立得照片"           // 📷 拍立得
    case developedPhoto = "冲洗照片"       // 🖼️ 胶卷/暗房
    case filmNegative = "胶片底片"         // 🎞️ 胶片底片
    
    // 票据类
    case receipt = "收据"                  // 🧾 收据
    case thermal = "热敏小票"              // 🧾 热敏纸
    
    // 书信类
    case envelope = "火漆信封"             // ✉️ 信封
    case postcard = "手写明信片"          // 📮 明信片
    case journalPage = "日记内页"         // 📖 日记本
    
    // 收藏类
    case vinylRecord = "唱片封套"         // 💿 黑胶唱片
    case bookmark = "书签"                // 📑 阅读
    case pressedFlower = "干花标本"       // 🌸 自然
    
    // V7.5 新增高定风格 (The Rarities)
    case waxStamp = "皇家御玺"            // 👑
    case typewriter = "作家手稿"          // ⌨️
    case safari = "探险日志"              // 🦁
    case aurora = "极光幻境"              // 🌌
    case astrolabe = "星象仪"             // 🔭
    case omikuji = "神社绘马"             // ⛩️
    case hourglass = "流沙时光"           // ⏳
    case vault = "绝密档案"               // 🔒
    case simple = "极致黑白"              // ⚫️
    case waxEnvelope = "皇家诏书"         // 📜 (原 envelope 升级或并存，这里作为独立风格)
    
    // ✈️ 航空系列 (Aviation Collection)
    case boardingPass = "登机牌"          // ✈️ Pan Am黄金年代
    case aircraftType = "机型证"          // 📋 FAA/CAAC执照
    case flightLog = "航空日志"          // 📒 飞行员日志本
    case luggageTag = "行李牌"           // 🏷 复古行李标签
    
    // 🎫 票据系列 (Ticket Collection)
    case concertTicket = "演出门票"       // 🎸 Live House演出票
    
    // 兼容旧版本
    case monoTicket = "时光小票"          // 保留用于迁移
    case galaInvite = "流光邀约"          // 保留用于迁移
    
    var label: String { rawValue }
    
    // V4.0: 分类属性
    var category: ArtifactCategory {
        switch self {
        // 影像类
        case .polaroid, .developedPhoto, .filmNegative:
            return .photography
        // 票据类
        case .receipt, .thermal:
            return .tickets
        // 书信类
        case .envelope, .postcard, .journalPage:
            return .letters
        // 收藏类
        case .vinylRecord, .bookmark, .pressedFlower:
            return .collection
        // 新增高定
        case .waxStamp, .typewriter, .safari, .aurora, .astrolabe, .omikuji, .hourglass, .vault, .simple, .waxEnvelope:
            return .collection // 暂时归类为收藏
        // ✈️ 航空系列
        case .boardingPass, .aircraftType, .flightLog, .luggageTag:
            return .tickets // 归类为票据类
        // 🎫 票据系列
        case .concertTicket:
            return .tickets
        // 兼容旧版本（默认归类）
        case .monoTicket, .galaInvite:
            return .tickets
        }
    }
    
    var icon: String {
        switch self {
        // 影像类
        case .polaroid: return "camera.fill"
        case .developedPhoto: return "photo.stack.fill"
        case .filmNegative: return "film.fill"
        // 票据类
        case .receipt: return "doc.text.fill"
        case .thermal: return "printer.fill"
        // 书信类
        case .envelope: return "envelope.fill"
        case .postcard: return "envelope.open.fill"
        case .journalPage: return "book.fill"
        // 收藏类
        case .vinylRecord: return "opticaldisc.fill"
        case .bookmark: return "bookmark.fill"
        case .pressedFlower: return "leaf.fill"
        // 新增高定
        case .waxStamp: return "crown.fill"
        case .typewriter: return "keyboard.fill"
        case .safari: return "safari.fill"
        case .aurora: return "sparkles"
        case .astrolabe: return "star.circle.fill"
        case .omikuji: return "scroll.fill"
        case .hourglass: return "hourglass"
        case .vault: return "lock.fill"
        case .simple: return "circle.fill"
        case .waxEnvelope: return "doc.text.fill"
        // 兼容
        case .monoTicket: return "ticket.fill"
        case .galaInvite: return "scroll.fill"
        // ✈️ 航空系列
        case .boardingPass: return "airplane"
        case .aircraftType: return "doc.text.fill"
        case .flightLog: return "book.fill"
        case .luggageTag: return "tag.fill"
        // 🎫 票据系列
        case .concertTicket: return "music.note"
        }
    }
    
    var emoji: String {
        switch self {
        // 影像类
        case .polaroid: return "📷"
        case .developedPhoto: return "🖼️"
        case .filmNegative: return "🎞️"
        // 票据类
        case .receipt: return "🧾"
        case .thermal: return "🧾"
        // 书信类
        case .envelope: return "✉️"
        case .postcard: return "📮"
        case .journalPage: return "📖"
        // 收藏类
        case .vinylRecord: return "💿"
        case .bookmark: return "📑"
        case .pressedFlower: return "🌸"
        // 新增高定
        case .waxStamp: return "👑"
        case .typewriter: return "⌨️"
        case .safari: return "🦁"
        case .aurora: return "🌌"
        case .astrolabe: return "🔭"
        case .omikuji: return "⛩️"
        case .hourglass: return "⏳"
        case .vault: return "🔒"
        case .simple: return "⚫️"
        case .waxEnvelope: return "📜"
        // 兼容
        case .monoTicket: return "🧾"
        case .galaInvite: return "🎬"
        // ✈️ 航空系列
        case .boardingPass: return "✈️"
        case .aircraftType: return "📋"
        case .flightLog: return "📒"
        case .luggageTag: return "🏷️"
        // 🎫 票据系列
        case .concertTicket: return "🎸"
        }
    }
    
    var description: String {
        switch self {
        // 影像类
        case .polaroid: return "白边即时照片，手写字"
        case .developedPhoto: return "复古色调，堆叠效果"
        case .filmNegative: return "柯达胶片底片，负片效果"
        // 票据类
        case .receipt: return "白色收据，黑色文字"
        case .thermal: return "热敏纸质感，细长条"
        // 书信类
        case .envelope: return "牛皮纸+红色火漆"
        case .postcard: return "左图右文，邮票"
        case .journalPage: return "横线纸，装订孔"
        // 收藏类
        case .vinylRecord: return "黑金配色，唱片露出"
        case .bookmark: return "深红金边，引言"
        case .pressedFlower: return "标本纸，胶带固定"
        // 新增高定
        case .waxStamp: return "皇家御玺，至高无上"
        case .typewriter: return "海明威手稿，文学质感"
        case .safari: return "探险日志，野性呼唤"
        case .aurora: return "极光幻境，流体渐变"
        case .astrolabe: return "占星术士，旋转星盘"
        case .omikuji: return "神社绘马，祈福心愿"
        case .hourglass: return "流沙时光，岁月无声"
        case .vault: return "绝密档案，封存记忆"
        case .simple: return "极致黑白，黑色电影"
        case .waxEnvelope: return "皇家诏书，庄重威严"
        // 兼容
        case .monoTicket: return "复古热敏打印风格，时间凭证"
        case .galaInvite: return "电影节邀请函风格，优雅精致"
        // ✈️ 航空系列
        case .boardingPass: return "Pan Am黄金年代，经典登机牌"
        case .aircraftType: return "FAA/CAAC执照，机型认证"
        case .flightLog: return "飞行员日志本，飞行记录"
        case .luggageTag: return "复古行李标签，旅行记忆"
        // 🎫 票据系列
        case .concertTicket: return "Live House演出票，音乐现场"
        }
    }
    
    var onboardingTitle: String {
        return rawValue
    }
    
    var onboardingDescription: String {
        switch self {
        case .polaroid: return "每一张拍立得，都是瞬间的定格。用即时成像的方式，记录生活的美好。"
        case .developedPhoto: return "每一张照片，都是时光的见证。用复古的色调，定格美好的瞬间。"
        case .filmNegative: return "每一帧底片，都是光影的负像。用胶片的质感，记录时光的痕迹。"
        case .receipt: return "每一张收据，都是消费的凭证。用简洁的格式，记录生活的点滴。"
        case .thermal: return "每一张小票，都是瞬间的印记。用热敏纸的质感，珍藏珍贵的回忆。"
        case .envelope: return "每一封信，都是时光的见证。用温暖的笔触，记录生活的点滴。"
        case .postcard: return "每一张明信片，都是远方的问候。用图文并茂，传递思念的情意。"
        case .journalPage: return "每一页日记，都是内心的独白。用横线的纸张，记录生活的轨迹。"
        case .vinylRecord: return "每一张唱片，都是音乐的载体。用黑金的配色，珍藏经典的旋律。"
        case .bookmark: return "每一枚书签，都是阅读的标记。用深红的金边，记录阅读的时光。"
        case .pressedFlower: return "每一朵干花，都是自然的馈赠。用标本的纸张，珍藏美好的回忆。"
        case .waxStamp: return "至高无上的皇家御玺，为您盖下永恒的印记。"
        case .typewriter: return "用老式打字机敲击出的每一个字母，都充满文学的温度。"
        case .safari: return "翻开探险家的日志，记录那些狂野而自由的瞬间。"
        case .aurora: return "将极光的绚烂封存在水晶球中，留住稍纵即逝的美好。"
        case .astrolabe: return "转动古老的星盘，在浩瀚星空中寻找命运的指引。"
        case .omikuji: return "在神社的绘马上写下心愿，祈求未来的好运与平安。"
        case .hourglass: return "看着沙漏中的流沙缓缓落下，感受时间无声的流逝。"
        case .vault: return "将最珍贵的秘密锁进绝密档案，只有您自己能开启。"
        case .simple: return "剥离一切繁杂的色彩，用极致的黑白光影诉说故事。"
        case .waxEnvelope: return "庄重而威严的皇家诏书，记录下每一个重要的时刻。"
        case .monoTicket: return "每一张小票，都是时间的凭证。用复古的质感，珍藏珍贵的瞬间。"
        case .galaInvite: return "每一份邀约，都是生活的仪式。用优雅的设计，定格美好的回忆。"
        // ✈️ 航空系列
        case .boardingPass: return "每一张登机牌，都是旅程的开始。用Pan Am黄金年代的设计，记录每一次飞翔。"
        case .aircraftType: return "每一张机型证，都是专业的证明。用FAA/CAAC执照的风格，见证飞行梦想。"
        case .flightLog: return "每一页飞行日志，都是天空的见证。用飞行员日志本的格式，记录每一次翱翔。"
        case .luggageTag: return "每一张行李牌，都是旅行的标记。用复古行李标签的设计，珍藏旅途回忆。"
        // 🎫 票据系列
        case .concertTicket: return "每一张演出票，都是音乐的见证。用Live House的设计，记录每一次现场。"
        }
    }
    
    var onboardingSubtitle: String {
        return description
    }
    
    // MARK: - 十二大基础主题（主要主题）
    /// 返回基础的12个主要主题，不包括高定风格和兼容旧版本的样式
    static var mainTwelveThemes: [RitualStyle] {
        [
            // 影像类
            .polaroid,
            .developedPhoto,
            // 票据类
            .receipt,
            .thermal,
            // 书信类
            .envelope,
            .postcard,
            .journalPage,
            // 收藏类
            .vinylRecord,
            .bookmark,
            .pressedFlower
        ]
    }
    
    // MARK: - 图片和文字位置配置
    /// 每个信物支持的最大图片数量
    var maxPhotos: Int {
        switch self {
        // 长条形信物可以放多张
        case .receipt, .thermal:
            return 6
        // 大部分信物可以放3张
        case .polaroid, .developedPhoto:
            return 3
        // 信封、明信片等可以放2张
        case .envelope, .postcard, .journalPage:
            return 2
        // 收藏类通常只放1张
        case .vinylRecord, .bookmark, .pressedFlower:
            return 1
        // 高定风格默认3张
        default:
            return 3
        }
    }
    
    /// 文字位置（相对于信物）
    var textPosition: TextPosition {
        switch self {
        case .polaroid:
            return .bottom // 拍立得：底部白边
        case .receipt, .thermal:
            return .middle // 收据：中间商品列表区域
        case .envelope, .postcard, .journalPage:
            return .center // 书信类：中心
        case .vinylRecord:
            return .bottom // 唱片：底部
        case .bookmark:
            return .center // 书签：中心
        case .pressedFlower:
            return .bottom // 干花：底部
        default:
            return .center
        }
    }
    
    /// 图片位置（相对于信物）
    var photoPosition: PhotoPosition {
        switch self {
        case .polaroid:
            return .top // 拍立得：顶部照片区域
        case .receipt, .thermal:
            return .middle // 收据：中间区域，多张水平排列
        case .envelope:
            return .center // 信封：中心
        case .postcard:
            return .left // 明信片：左侧
        case .journalPage:
            return .top // 日记：顶部
        case .vinylRecord:
            return .center // 唱片：中心封面
        case .bookmark:
            return .center // 书签：中心
        case .pressedFlower:
            return .center // 干花：中心
        default:
            return .center
        }
    }
}

// MARK: - 文字位置枚举
enum TextPosition {
    case top
    case middle
    case bottom
    case center
}

// MARK: - 图片位置枚举
enum PhotoPosition {
    case top
    case middle
    case bottom
    case left
    case right
    case center
}

// MARK: - V4.0 首页入口风格
enum TodayHubStyle: String, Codable, CaseIterable, Identifiable {
    case simple = "极简模式"
    case leicaCamera = "徕卡相机"
    case jewelryBox = "时光珠宝盒"
    case polaroidCamera = "拍立得"
    case waxEnvelope = "火漆信封"
    case waxStamp = "黄铜印章"
    case vault = "记忆金库"
    case typewriter = "老式打字机"
    case safari = "日落狩猎"
    case aurora = "极光水晶球"
    case astrolabe = "星象仪"
    case omikuji = "日式签筒"
    case hourglass = "时光沙漏"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .simple: return "纯粹的记录按钮，无干扰"
        case .leicaCamera: return "经典旁轴相机取景器"
        case .jewelryBox: return "精致的木质首饰盒"
        case .polaroidCamera: return "复古即时成像相机"
        case .waxEnvelope: return "待拆封的火漆信件"
        case .waxStamp: return "厚重的黄铜印章"
        case .vault: return "坚固的银行保险库"
        case .typewriter: return "机械打字机键盘"
        case .safari: return "非洲草原的金色日落"
        case .aurora: return "封存着极光的玻璃球"
        case .astrolabe: return "观测星辰的古老仪器"
        case .omikuji: return "浅草寺风格的求签筒"
        case .hourglass: return "静静流淌的细沙"
        }
    }
    
    // 注意：preferredBackground 和 textColor 已在 ForgeViewV3.swift 中定义
    // Models.swift 中的旧定义已移除，避免类型冲突
    // preferredBackground 在 V3 中返回 some View（支持渐变），而不是 Color
    
    var hint: String {
        switch self {
        case .simple: return "记录今天"
        case .leicaCamera: return "定格瞬间"
        case .jewelryBox: return "珍藏记忆"
        case .polaroidCamera: return "显影时光"
        case .waxEnvelope: return "封存信件"
        case .waxStamp: return "加盖印记"
        case .vault: return "存入金库"
        case .typewriter: return "敲击键盘"
        case .safari: return "追逐落日"
        case .aurora: return "凝视极光"
        case .astrolabe: return "观测星象"
        case .omikuji: return "抽取运势"
        case .hourglass: return "翻转时光"
        }
    }
    
    var subhint: String {
        return "点击进入"
    }
}


// MARK: - 统计数据模型
struct MoodStatistics {
    var moodCounts: [Mood: Int]
    var recentMoods: [(date: Date, mood: Mood)]
    var averageScore: Double
    
    static func empty() -> MoodStatistics {
        MoodStatistics(moodCounts: [:], recentMoods: [], averageScore: 0)
    }
}

// MARK: - Color 扩展 (支持 Hex 初始化)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - RitualStyle 扩展（用于信物选择器）
// MARK: - ═══════════════════════════════════════════════════════════
extension RitualStyle {
    /// 所有可选择的信物样式（排除兼容性样式）
    static var allSelectableStyles: [RitualStyle] {
        [
            // 小票系列
            .thermal, .receipt,
            // 皇家系列
            .envelope, .vault, .waxEnvelope,
            // 收藏家系列
            .vinylRecord, .polaroid, .postcard, .bookmark,
            // 航空系列
            .boardingPass, .aircraftType, .flightLog, .luggageTag,
            // 票据系列
            .monoTicket, .galaInvite, .concertTicket,
            // 自然书写系列
            .pressedFlower, .journalPage, .typewriter,
            // 影像系列
            .developedPhoto, .filmNegative,
            // 探索者系列
            .safari, .aurora, .astrolabe, .omikuji, .hourglass,
        ]
    }
    
    /// 系列名称
    var seriesName: String {
        switch self {
        case .thermal, .receipt:
            return "小票系列"
        case .envelope, .waxEnvelope, .vault, .waxStamp:
            return "皇家系列"
        case .vinylRecord, .polaroid, .postcard, .bookmark:
            return "收藏家系列"
        case .boardingPass, .aircraftType, .flightLog, .luggageTag:
            return "航空系列"
        case .monoTicket, .galaInvite, .concertTicket:
            return "票据系列"
        case .pressedFlower, .journalPage, .typewriter:
            return "自然书写系列"
        case .developedPhoto, .filmNegative:
            return "影像系列"
        case .safari, .aurora, .astrolabe, .omikuji, .hourglass:
            return "探索者系列"
        default:
            return "其他"
        }
    }
    
    /// 系列图标（emoji风格）
    var seriesIcon: String {
        switch seriesName {
        case "小票系列": return "🧾"
        case "皇家系列": return "👑"
        case "收藏家系列": return "💎"
        case "航空系列": return "✈️"
        case "票据系列": return "🎫"
        case "自然书写系列": return "🌿"
        case "影像系列": return "🎬"
        case "探索者系列": return "🌍"
        default: return "📄"
        }
    }
    
    /// 短名称（用于快速按钮）
    var shortName: String {
        switch self {
        case .thermal: return "小票"
        case .receipt: return "收据"
        case .polaroid: return "拍立得"
        case .envelope: return "诏书"
        case .waxEnvelope: return "信封"
        case .vault: return "档案"
        case .vinylRecord: return "唱片"
        case .postcard: return "明信片"
        case .bookmark: return "书签"
        case .monoTicket: return "电影票"
        case .galaInvite: return "邀请函"
        case .boardingPass: return "登机牌"
        case .aircraftType: return "机型证"
        case .flightLog: return "航空日志"
        case .luggageTag: return "行李牌"
        case .concertTicket: return "演出票"
        case .pressedFlower: return "标本"
        case .journalPage: return "日记"
        case .typewriter: return "手稿"
        case .developedPhoto: return "胶片"
        case .filmNegative: return "底片"
        case .safari: return "探险"
        case .aurora: return "极光"
        case .astrolabe: return "星盘"
        case .omikuji: return "御籤"
        case .hourglass: return "沙漏"
        default: return displayName
        }
    }
    
    /// 完整显示名称
    var displayName: String {
        switch self {
        case .thermal: return "热敏小票"
        case .receipt: return "购物收据"
        case .polaroid: return "拍立得"
        case .envelope: return "皇家诏书"
        case .waxEnvelope: return "火漆信封"
        case .vault: return "机密档案"
        case .vinylRecord: return "黑胶唱片"
        case .postcard: return "复古明信片"
        case .bookmark: return "皮质书签"
        case .monoTicket: return "复古电影票"
        case .galaInvite: return "流光邀约"
        case .boardingPass: return "登机牌"
        case .aircraftType: return "机型签注"
        case .flightLog: return "航空日志"
        case .luggageTag: return "行李牌"
        case .concertTicket: return "演出门票"
        case .pressedFlower: return "干花标本"
        case .journalPage: return "日记内页"
        case .typewriter: return "打字机手稿"
        case .developedPhoto: return "冲洗照片"
        case .filmNegative: return "胶片底片"
        case .safari: return "探险日志"
        case .aurora: return "极光幻境"
        case .astrolabe: return "星象仪"
        case .omikuji: return "御神籤"
        case .hourglass: return "时光沙漏"
        default: return rawValue
        }
    }
    
    /// 图标名称（用于 SF Symbols）
    var iconName: String {
        return icon
    }
    
    /// 强调色
    var accentColor: Color {
        switch self {
        case .thermal, .receipt: return Color(hex: "1E90FF")
        case .polaroid: return Color(hex: "C41E3A")
        case .envelope, .waxEnvelope: return Color(hex: "D4AF37")
        case .vault: return Color(hex: "1E3A5F")
        case .vinylRecord: return Color(hex: "1E3A5F")
        case .postcard: return Color(hex: "E8B4B8")
        case .bookmark: return Color(hex: "8B4513")
        case .monoTicket: return Color(hex: "8B0000")
        case .galaInvite: return Color(hex: "D4AF37")
        case .boardingPass: return Color(hex: "D4AF37")
        case .aircraftType: return Color(hex: "1E3A5F")
        case .flightLog: return Color(hex: "1E3A5F")
        case .luggageTag: return Color(hex: "8B7355")
        case .concertTicket: return Color(hex: "FF006E")
        case .pressedFlower: return Color(hex: "228B22")
        case .journalPage: return Color(hex: "8B4513")
        case .typewriter: return Color(hex: "C9A55C")
        case .developedPhoto: return Color(hex: "8B0000")
        case .filmNegative: return Color(hex: "FF8C00")
        case .safari: return Color(hex: "FF6B35")
        case .aurora: return Color(hex: "00CED1")
        case .astrolabe: return Color(hex: "9370DB")
        case .omikuji: return Color(hex: "C41E3A")
        case .hourglass: return Color(hex: "F5A623")
        default: return Color(hex: "D4AF37")
        }
    }
    
    /// 预览背景色
    var previewBackground: Color {
        switch self {
        case .thermal, .receipt:
            return Color(hex: "F5F5F0")
        case .envelope, .vault:
            return Color(hex: "1E3A5F").opacity(0.1)
        case .vinylRecord:
            return Color(hex: "1A1A1A").opacity(0.1)
        case .polaroid:
            return Color(hex: "F8F4F0")
        case .postcard:
            return Color(hex: "E8B4B8").opacity(0.2)
        case .bookmark:
            return Color(hex: "8B4513").opacity(0.1)
        case .boardingPass, .aircraftType, .flightLog:
            return Color(hex: "1E3A5F").opacity(0.1)
        case .luggageTag:
            return Color(hex: "F5E6D3")
        case .monoTicket:
            return Color(hex: "FFF8E7")
        case .galaInvite:
            return Color(hex: "1A1A1A").opacity(0.1)
        case .concertTicket:
            return Color(hex: "FF006E").opacity(0.1)
        case .pressedFlower:
            return Color(hex: "228B22").opacity(0.1)
        case .journalPage:
            return Color(hex: "FFFEF5")
        case .typewriter:
            return Color(hex: "F5E6D3")
        case .developedPhoto:
            return Color(hex: "1A0505").opacity(0.1)
        case .filmNegative:
            return Color(hex: "FF8C00").opacity(0.1)
        case .safari:
            return Color(hex: "FF6B35").opacity(0.1)
        case .aurora:
            return Color(hex: "00CED1").opacity(0.1)
        case .astrolabe:
            return Color(hex: "9370DB").opacity(0.1)
        case .omikuji:
            return Color(hex: "8B0000").opacity(0.1)
        case .hourglass:
            return Color(hex: "D4AF37").opacity(0.1)
        default:
            return Color(hex: "F5F5F0")
        }
    }
}

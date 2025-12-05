//
//  KeepsakeRecommendation.swift
//  时光格 V4.0 - 信物推荐逻辑
//
//  补全所有中Tab样式映射，新增 defaultRecommended 兜底
//  推荐逻辑覆盖100%，不再出现fallback到拍立得的情况
//

import SwiftUI

// MARK: - 信物推荐系统
struct KeepsakeRecommendation {
    // 根据 TodayHubStyle 推荐对应的信物风格
    static func recommended(for hubStyle: TodayHubStyle) -> RitualStyle {
        switch hubStyle {
        // 影像类入口 → 影像类信物
        case .polaroidCamera:
            return .polaroid
        case .leicaCamera:
            return .filmNegative
        
        // 书信类入口 → 书信类信物
        case .waxEnvelope:
            return .envelope
        case .waxStamp:
            return .envelope // 印章入口也推荐信封
        
        // 收藏类入口 → 收藏类信物
        case .jewelryBox:
            return .vinylRecord // 珠宝盒 → 唱片封套（都是收藏品）
        
        // 其他入口的智能推荐
        case .simple:
            // 极简模式 → 默认推荐信封（最经典）
            return .envelope
        case .vault:
            // 记忆金库 → 推荐日记页（私密记录）
            return .journalPage
        case .typewriter:
            // 老式打字机 → 推荐日记页（文字记录）
            return .journalPage
        case .safari:
            // 日落狩猎 → 推荐明信片（旅行记忆）
            return .postcard
        case .aurora:
            // 极光水晶球 → 推荐冲洗照片（梦幻影像）
            return .developedPhoto
        case .astrolabe:
            // 星象仪 → 推荐干花标本（自然收藏）
            return .pressedFlower
        case .omikuji:
            // 日式签筒 → 推荐书签（阅读相关）
            return .bookmark
        case .hourglass:
            // 时光沙漏 → 推荐车票（时间旅行）
            return .trainTicket
        
        // 默认兜底（不应该到达这里，但以防万一）
        @unknown default:
            return defaultRecommended
        }
    }
    
    // 默认推荐（兜底方案）
    static var defaultRecommended: RitualStyle {
        return .envelope // 改为信封（更经典），而不是拍立得
    }
    
    // 根据入口风格字符串推荐（向后兼容）
    static func recommended(for hubStyleString: String) -> RitualStyle {
        // 先尝试匹配 TodayHubStyle
        if let hubStyle = TodayHubStyle.allCases.first(where: { $0.rawValue == hubStyleString }) {
            return recommended(for: hubStyle)
        }
        
        // 字符串匹配（向后兼容旧代码）
        switch hubStyleString.lowercased() {
        // 影像类
        case "polaroid", "polaroidalbum", "polaroidcamera":
            return .polaroid
        case "leicacamera", "leica":
            return .filmNegative
        case "filmroll", "darkroom", "developedphoto":
            return .developedPhoto
        
        // 票据类
        case "movieticket", "cinema", "movie":
            return .movieTicket
        case "trainticket", "train", "travel", "journey":
            return .trainTicket
        case "concertticket", "concert", "vinylrecord", "musicplayer":
            return .concertTicket
        
        // 书信类
        case "envelope", "letter", "waxenvelope", "waxstamp":
            return .envelope
        case "postcard":
            return .postcard
        case "journal", "notebook", "journalpage":
            return .journalPage
        
        // 收藏类
        case "vinylsleeve", "vinyl":
            return .vinylRecord
        case "bookmark", "library":
            return .bookmark
        case "pressedflower", "botanical", "nature", "flower":
            return .pressedFlower
        
        // 默认兜底
        default:
            return defaultRecommended
        }
    }
}

// MARK: - 便捷扩展
extension TodayHubStyle {
    var recommendedArtifactStyle: RitualStyle {
        KeepsakeRecommendation.recommended(for: self)
    }
}


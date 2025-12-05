import SwiftUI

// MARK: - 奢华材质定义 (Legacy Support)
// 保留此枚举以防有旧代码引用，但核心逻辑已迁移至 LuxuryTheme
enum LuxuryMaterial {
    case leather(Color)
    case velvet(Color)
    case wood(Color)
    case matteMetal(Color)
    
    var gradient: LinearGradient {
        switch self {
        case .leather(let color):
            return LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
        }
    }
}

// MARK: - V9.0 十一大工坊主题系统 (The Undecad Workshop Themes)
enum LuxuryTheme: String, CaseIterable, Identifiable {
    // 第一组：原五大主题（优化）
    case equestrian = "The Equestrian"   // 皮具风 - Hermès × LV
    case chronograph = "The Chronograph" // 机械风 - Patek × Richard Mille
    case gemstone = "The Gemstone"       // 珠宝风 - Cartier × Graff
    case formula = "The Formula"         // 赛道风 - Formula 1
    case celestial = "The Celestial"     // 星际风 - Star Trek × NASA
    
    // 第二组：新增六大主题
    case botanical = "The Botanical"     // 草本风 - Diptyque × Aesop
    case porcelain = "The Porcelain"      // 青瓷风 - 故宫 × 景德镇
    case hauteCouture = "Haute Couture"      // 高定工坊 - Chanel/Dior (Tweed & Elegance)
    case shanshui = "The Shanshui"           // 水墨丹青 - Chinese Ink Painting
    case minimalist = "The Minimalist"      // 极简主义 - 待定义
    case artisan = "The Artisan"             // 手工艺坊 - 待定义
    
    var id: String { rawValue }
    
    // MARK: - 颜色系统
    
    /// 主强调色
    var accentColor: Color {
        switch self {
        case .equestrian:  return Color(hex: "D4AF37")  // 爱马仕金
        case .chronograph: return Color(hex: "C0C0C0")  // 银色
        case .gemstone:    return Color(hex: "E5E4E2")  // 铂金白
        case .formula:     return Color(hex: "E10600")  // 法拉利红
        case .celestial:   return Color(hex: "8B5CF6")  // 星云紫
        case .botanical:   return Color(hex: "4CAF50")  // 自然绿
        case .porcelain:   return Color(hex: "1E407C")  // 青花蓝
        case .hauteCouture: return Color(hex: "1C1C1E") // 经典黑
        case .shanshui:     return Color(hex: "3C3C3C") // 浓墨色
        case .minimalist:   return Color(hex: "808080")  // 中性灰
        case .artisan:      return Color(hex: "8B4513")  // 手工棕
        }
    }
    
    /// 次强调色（用于渐变）
    var secondaryAccent: Color {
        switch self {
        case .equestrian:  return Color(hex: "8B4513")  // 马鞍棕
        case .chronograph: return Color(hex: "1a2a4a")  // 深海蓝
        case .gemstone:    return Color(hex: "4B2D5E")  // 皇室紫
        case .formula:     return Color(hex: "1A1A1A")  // 碳纤维黑
        case .celestial:   return Color(hex: "3B82F6")  // 星轨蓝
        case .botanical:   return Color(hex: "1A3324")  // 森林深绿
        case .porcelain:   return Color(hex: "F8F8F8")  // 素白釉
        case .hauteCouture: return Color(hex: "C6AC8F") // 米色
        case .shanshui:     return Color(hex: "8B7355") // 赭石色
        case .minimalist:   return Color(hex: "E5E5E5") // 浅灰
        case .artisan:      return Color(hex: "D2691E") // 手工橙
        }
    }
    
    /// 背景基础色
    var backgroundColor: Color {
        switch self {
        case .equestrian:  return Color(hex: "1A0F0A")
        case .chronograph: return Color(hex: "0B1221")
        case .gemstone:    return Color(hex: "0A0512")
        case .formula:     return Color(hex: "0A0A0A")
        case .celestial:   return Color(hex: "030014")
        case .botanical:   return Color(hex: "0A1A0F")
        case .porcelain:   return Color(hex: "F0F0F0") // 素白釉
        case .hauteCouture: return Color(hex: "F8F4F1") // 奶油色
        case .shanshui:     return Color(hex: "F8F6F0") // 宣纸色
        case .minimalist:   return Color(hex: "FFFFFF") // 纯白
        case .artisan:      return Color(hex: "2F1B14") // 手工深棕
        }
    }
    
    /// 文字颜色（瓷器主题特殊处理）
    var textColor: Color {
        switch self {
        case .porcelain, .hauteCouture, .shanshui, .minimalist: return Color(hex: "1E407C")
        default: return .white
        }
    }
    
    /// 次要文字颜色
    var secondaryTextColor: Color {
        switch self {
        case .porcelain, .hauteCouture, .shanshui, .minimalist: return Color(hex: "5577AA")
        default: return Color.white.opacity(0.6)
        }
    }
    
    // MARK: - 元数据
    
    /// SF Symbol 图标
    var iconName: String {
        switch self {
        case .equestrian:  return "bag.fill"
        case .chronograph: return "gearshape.2.fill"
        case .gemstone:    return "diamond.fill"
        case .formula:     return "car.fill"
        case .celestial:   return "sparkles"
        case .botanical:   return "leaf.fill"
        case .porcelain:   return "cup.and.saucer.fill"
        case .hauteCouture: return "scissors"
        case .shanshui:     return "mountain.2.fill"
        case .minimalist:   return "circle.grid.2x2.fill"
        case .artisan:      return "hammer.fill"
        }
    }
    
    /// 中文名称
    var chineseName: String {
        switch self {
        case .equestrian:  return "皮具"
        case .chronograph: return "机械"
        case .gemstone:    return "珠宝"
        case .formula:     return "赛道"
        case .celestial:   return "星际"
        case .botanical:   return "草本"
        case .porcelain:   return "青瓷"
        case .hauteCouture: return "高定"
        case .shanshui:     return "水墨"
        case .minimalist:   return "极简"
        case .artisan:      return "手工艺"
        }
    }
    
    /// 工坊全称
    var workshopName: String {
        switch self {
        case .equestrian:  return "皮具工坊"
        case .chronograph: return "机械工坊"
        case .gemstone:    return "珠宝工坊"
        case .formula:     return "赛道工坊"
        case .celestial:   return "星际工坊"
        case .botanical:   return "草本工坊"
        case .porcelain:   return "青瓷工坊"
        case .hauteCouture: return "高定工坊"
        case .shanshui:     return "水墨工坊"
        case .minimalist:   return "极简工坊"
        case .artisan:      return "手工艺坊"
        }
    }
    
    /// 品牌灵感来源
    var inspiration: String {
        switch self {
        case .equestrian:  return "Hermès × Louis Vuitton"
        case .chronograph: return "Patek Philippe × Richard Mille"
        case .gemstone:    return "Cartier × Graff × 大英博物馆"
        case .formula:     return "Formula 1 × Ferrari × McLaren"
        case .celestial:   return "Star Trek × NASA × Rolex Meteorite"
        case .botanical:   return "Diptyque × Aesop × Le Labo"
        case .porcelain:   return "景德镇 × 故宫 × 大都会博物馆"
        case .hauteCouture: return "Chanel × Dior"
        case .shanshui:     return "宋代山水 × 文人写意"
        case .minimalist:   return "Muji × Apple"
        case .artisan:      return "传统手工艺 × 现代设计"
        }
    }
    
    /// 主题描述
    var description: String {
        switch self {
        case .equestrian:  return "深棕皮革 · 金色缝线 · 经典马具"
        case .chronograph: return "深海蓝 · 日内瓦波纹 · 精密机芯"
        case .gemstone:    return "皇室紫 · 丝绒质感 · 钻石火彩"
        case .formula:     return "碳纤维 · 法拉利红 · 赛道激情"
        case .celestial:   return "深空紫 · 星云光晕 · 无垠宇宙"
        case .botanical:   return "森林绿 · 叶脉纹理 · 自然芬芳"
        case .porcelain:   return "素白釉 · 青花纹 · 东方美学"
        case .hauteCouture: return "粗花呢 · 经典优雅 · 永恒时尚"
        case .shanshui:     return "墨分五色 · 留白美学 · 意境优先"
        case .minimalist:   return "极简线条 · 留白空间 · 纯粹美学"
        case .artisan:      return "手工质感 · 传统工艺 · 匠心独运"
        }
    }
    
    // MARK: - 渐变定义
    
    /// 主背景渐变
    var backgroundGradient: LinearGradient {
        switch self {
        case .equestrian:
            return LinearGradient(
                colors: [
                    Color(hex: "1A0F0A"),
                    Color(hex: "2D1810"),
                    Color(hex: "3D2218"),
                    Color(hex: "2D1810"),
                    Color(hex: "1A0F0A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .chronograph:
            return LinearGradient(
                colors: [
                    Color(hex: "0B1221"),
                    Color(hex: "1a2a4a"),
                    Color(hex: "0B1221")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .gemstone:
            return LinearGradient(
                colors: [
                    Color(hex: "0A0512"),
                    Color(hex: "1A0F24"),
                    Color(hex: "2D1B3D"),
                    Color(hex: "1A0F24"),
                    Color(hex: "0A0512")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .formula:
            return LinearGradient(
                colors: [
                    Color(hex: "0A0A0A"),
                    Color(hex: "1A1A1A"),
                    Color(hex: "0A0A0A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .celestial:
            return LinearGradient(
                colors: [
                    Color(hex: "030014"),
                    Color(hex: "0A0520"),
                    Color(hex: "030014")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .botanical:
            return LinearGradient(
                colors: [
                    Color(hex: "0A1A0F"),
                    Color(hex: "122318"),
                    Color(hex: "1A3324"),
                    Color(hex: "122318"),
                    Color(hex: "0A1A0F")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .porcelain:
            return LinearGradient(
                colors: [
                    Color(hex: "F8F8F8"),
                    Color(hex: "E8E8E8"),
                    Color(hex: "F8F8F8")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .hauteCouture:
            return LinearGradient(
                colors: [
                    Color(hex: "F8F4F1"),
                    Color(hex: "E8E4DA"),
                    Color(hex: "F8F4F1")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .shanshui:
            return LinearGradient(
                colors: [
                    Color(hex: "F8F6F0"),
                    Color(hex: "F0EDE5"),
                    Color(hex: "E8E4DA")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .minimalist:
            return LinearGradient(
                colors: [
                    Color(hex: "FFFFFF"),
                    Color(hex: "F5F5F5"),
                    Color(hex: "FFFFFF")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .artisan:
            return LinearGradient(
                colors: [
                    Color(hex: "2F1B14"),
                    Color(hex: "3D2819"),
                    Color(hex: "2F1B14")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// 强调光晕渐变
    var glowGradient: RadialGradient {
        RadialGradient(
            colors: [
                accentColor.opacity(0.3),
                accentColor.opacity(0.1),
                .clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 300
        )
    }
    
    // MARK: - 兼容旧代码属性
    var backgroundMaterial: LuxuryMaterial {
        return .leather(.black) // 占位符
    }
    
    // MARK: - 主题辉光色 (Glow Color) - 兼容旧代码
    var glowColor: Color {
        switch self {
        case .equestrian:   return Color(hex: "9E6C4D")
        case .chronograph:  return Color(hex: "1D3557")
        case .gemstone:     return Color.white
        case .formula:      return Color(hex: "FF5733")
        case .celestial:    return Color(hex: "A020F0") // Nebula Purple
        case .botanical:    return Color(hex: "4CAF50")
        case .porcelain:    return Color(hex: "1E407C") // 青花蓝
        case .hauteCouture: return Color(hex: "C6AC8F")
        case .shanshui:     return Color(hex: "8B7355")
        case .minimalist:   return Color(hex: "808080")
        case .artisan:      return Color(hex: "D2691E")
        }
    }
}

// MARK: - 主题引擎
class ThemeEngine: ObservableObject {
    static let shared = ThemeEngine()
    
    @Published var currentTheme: LuxuryTheme = .equestrian
    @Published var currentHubStyle: TodayHubStyle = .waxEnvelope
    
    private init() {
        // 从 UserDefaults 加载上次选择的主题
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedLuxuryTheme"),
           let theme = LuxuryTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    /// 切换主题
    func switchTheme(to theme: LuxuryTheme) {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.currentTheme = theme
        }
        
        // 保存到 UserDefaults
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedLuxuryTheme")
        
        // 触发触觉反馈
        SensoryManager.shared.playUIFeedback(.success)
    }
    
    /// 获取下一个主题（循环切换）
    func nextTheme() {
        let allThemes = LuxuryTheme.allCases
        guard let currentIndex = allThemes.firstIndex(of: currentTheme) else { return }
        let nextIndex = (currentIndex + 1) % allThemes.count
        switchTheme(to: allThemes[nextIndex])
    }
}


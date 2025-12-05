//
//  ArtifactPickerV2.swift
//  时光格 - 世界级信物选择器
//
//  特性：
//  1. 每次打开随机选择一个信物作为默认
//  2. "今日推荐" 随机展示3个信物
//  3. 分组浏览（按系列分组）
//  4. 最近使用记忆
//  5. 精美的预览卡片
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎰 信物选择管理器
// MARK: - ═══════════════════════════════════════════════════════════
class ArtifactPickerManager: ObservableObject {
    static let shared = ArtifactPickerManager()
    
    /// 最近使用的信物（最多5个）
    @Published var recentlyUsed: [RitualStyle] = []
    
    /// 今日推荐（每天随机3个）
    @Published var todayRecommendations: [RitualStyle] = []
    
    /// 上次推荐日期
    private var lastRecommendationDate: Date?
    
    private init() {
        loadRecentlyUsed()
        refreshTodayRecommendations()
    }
    
    /// 随机选择一个信物
    func getRandomStyle() -> RitualStyle {
        let allStyles = RitualStyle.allSelectableStyles
        return allStyles.randomElement() ?? .thermal
    }
    
    /// 记录使用
    func recordUsage(_ style: RitualStyle) {
        // 移除已存在的
        recentlyUsed.removeAll { $0 == style }
        // 添加到最前面
        recentlyUsed.insert(style, at: 0)
        // 保留最多5个
        if recentlyUsed.count > 5 {
            recentlyUsed = Array(recentlyUsed.prefix(5))
        }
        saveRecentlyUsed()
    }
    
    /// 刷新今日推荐
    func refreshTodayRecommendations() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // 如果是同一天，不刷新
        if let lastDate = lastRecommendationDate,
           Calendar.current.isDate(lastDate, inSameDayAs: today) {
            return
        }
        
        // 随机选择3个不同系列的信物
        var recommendations: [RitualStyle] = []
        var usedSeries: Set<String> = []
        let allStyles = RitualStyle.allSelectableStyles.shuffled()
        
        for style in allStyles {
            if !usedSeries.contains(style.seriesName) {
                recommendations.append(style)
                usedSeries.insert(style.seriesName)
                if recommendations.count >= 3 {
                    break
                }
            }
        }
        
        todayRecommendations = recommendations
        lastRecommendationDate = today
    }
    
    // MARK: - 持久化
    
    private func saveRecentlyUsed() {
        let rawValues = recentlyUsed.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: "recentlyUsedArtifacts")
    }
    
    private func loadRecentlyUsed() {
        if let rawValues = UserDefaults.standard.array(forKey: "recentlyUsedArtifacts") as? [String] {
            recentlyUsed = rawValues.compactMap { RitualStyle(rawValue: $0) }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 信物选择器主视图
// MARK: - ═══════════════════════════════════════════════════════════
struct ArtifactPickerView: View {
    @Binding var selectedStyle: RitualStyle
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = ArtifactPickerManager.shared
    
    @State private var searchText = ""
    @State private var selectedSeries: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ═══ 今日推荐 ═══
                    todayRecommendationSection
                    
                    // ═══ 最近使用 ═══
                    if !manager.recentlyUsed.isEmpty {
                        recentlyUsedSection
                    }
                    
                    // ═══ 全部信物（分组） ═══
                    allArtifactsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(hex: "F5F5F0"))
            .navigationTitle("选择信物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 随机按钮
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedStyle = manager.getRandomStyle()
                        }
                        hapticFeedback(.light)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "dice.fill")
                            Text("随机")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                    }
                }
            }
        }
    }
    
    // MARK: - 今日推荐
    
    private var todayRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(hex: "D4AF37"))
                Text("今日推荐")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Button {
                    withAnimation {
                        manager.todayRecommendations = RitualStyle.allSelectableStyles.shuffled().prefix(3).map { $0 }
                    }
                    hapticFeedback(.light)
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(manager.todayRecommendations, id: \.self) { style in
                        RecommendationCard(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectStyle(style)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - 最近使用
    
    private var recentlyUsedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(Color(hex: "8B8B8B"))
                Text("最近使用")
                    .font(.system(size: 16, weight: .bold))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(manager.recentlyUsed, id: \.self) { style in
                        RecentStyleChip(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectStyle(style)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - 全部信物
    
    private var allArtifactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(Color(hex: "8B8B8B"))
                Text("全部信物")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Text("\(RitualStyle.allSelectableStyles.count) 种")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // 系列筛选器
            SeriesFilterBar(selectedSeries: $selectedSeries)
            
            // 信物网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(filteredStyles, id: \.self) { style in
                    ArtifactGridCard(
                        style: style,
                        isSelected: selectedStyle == style
                    ) {
                        selectStyle(style)
                    }
                }
            }
        }
    }
    
    // MARK: - 筛选后的信物
    
    private var filteredStyles: [RitualStyle] {
        let styles = RitualStyle.allSelectableStyles
        
        if let series = selectedSeries {
            return styles.filter { $0.seriesName == series }
        }
        
        return styles
    }
    
    // MARK: - 选择信物
    
    private func selectStyle(_ style: RitualStyle) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedStyle = style
        }
        manager.recordUsage(style)
        hapticFeedback(.medium)
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📦 子组件
// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 推荐卡片
struct RecommendationCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // 预览区
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.previewBackground)
                        .frame(width: 100, height: 120)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(style.accentColor)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style.accentColor, lineWidth: 3)
                            .frame(width: 100, height: 120)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(style.accentColor)
                            .background(Circle().fill(.white).padding(4))
                            .offset(x: 35, y: -45)
                    }
                }
                
                // 名称
                VStack(spacing: 2) {
                    Text(style.shortName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(style.seriesName)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
        }
    }
}

// MARK: - 最近使用标签
struct RecentStyleChip: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: style.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : style.accentColor)
                
                Text(style.shortName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? style.accentColor : Color.white)
            )
            .overlay(
                Capsule()
                    .stroke(style.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - 系列筛选栏
struct SeriesFilterBar: View {
    @Binding var selectedSeries: String?
    
    private let series = [
        ("全部", nil as String?),
        ("小票", "小票系列"),
        ("皇家", "皇家系列"),
        ("收藏", "收藏家系列"),
        ("航空", "航空系列"),
        ("票据", "票据系列"),
        ("书写", "自然书写系列"),
        ("影像", "影像系列"),
        ("探索", "探索者系列"),
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(series, id: \.0) { item in
                    FilterChip(
                        title: item.0,
                        isSelected: selectedSeries == item.1
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedSeries = item.1
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "1E3A5F") : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "1E3A5F").opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - 信物网格卡片
struct ArtifactGridCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 图标区
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.previewBackground)
                        .frame(height: 90)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(style.accentColor)
                    
                    // 系列标签
                    Text(style.seriesIcon)
                        .font(.system(size: 10))
                        .padding(4)
                        .background(Circle().fill(.white.opacity(0.9)))
                        .offset(x: 55, y: -35)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style.accentColor, lineWidth: 2.5)
                            .frame(height: 90)
                    }
                }
                
                // 名称
                Text(style.shortName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? style.accentColor : .primary)
                    .lineLimit(1)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: isSelected ? style.accentColor.opacity(0.3) : .black.opacity(0.05), radius: isSelected ? 8 : 4, y: 2)
            )
        }
    }
}


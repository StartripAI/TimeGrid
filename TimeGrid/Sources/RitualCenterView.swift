//
//  RitualCenterView.swift
//  时光格 - 全新中Tab（仪式入口中心）
//
//  设计理念：
//  - 这是App的核心入口，必须有极致仪式感
//  - 整合：仪式入口 + 工坊主题切换
//  - 用户体验：点击入口 → 创建信物
//
//  替换原来的 TodayView 作为中Tab
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 仪式中心主视图（中Tab）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualCenterView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    
    // 状态
    @State private var showingNewRecord = false
    @State private var showingStylePicker = false
    @State private var showingTodayRecord: DayRecord?
    @State private var currentStyle: RitualHubStyleV2 = .auroraGlobe
    
    // 今日记录
    private var todayRecord: DayRecord? {
        dataManager.todayRecord()
    }
    
    var body: some View {
        ZStack {
            // 背景（根据入口风格变化）
            currentStyle.backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentStyle)
            
            VStack(spacing: 0) {
                // ═══════════════════════════════════════
                // 顶部栏：日期 + 工坊入口
                // ═══════════════════════════════════════
                topBar
                
                Spacer()
                
                // ═══════════════════════════════════════
                // 核心：仪式入口组件
                // ═══════════════════════════════════════
                ritualHubSection
                
                Spacer()
                
                // ═══════════════════════════════════════
                // 底部：今日状态 + 快捷操作
                // ═══════════════════════════════════════
                bottomSection
            }
        }
        .fullScreenCover(isPresented: $showingNewRecord) {
            NewRecordView(recordDate: Date())
        }
        .sheet(isPresented: $showingStylePicker) {
            RitualStylePickerSheet(selectedStyle: $currentStyle)
                .presentationDetents([.medium])
        }
        .sheet(item: $showingTodayRecord) { record in
            RecordDetailView(record: record)
        }
        .onAppear {
            // 从设置加载当前风格
            loadCurrentStyle()
        }
    }
    
    // MARK: - 顶部栏
    
    private var topBar: some View {
        HStack {
            // 日期
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(currentStyle.textColor)
                
                Text(formattedWeekday)
                    .font(.system(size: 14))
                    .foregroundColor(currentStyle.textColor.opacity(0.6))
            }
            
            Spacer()
            
            // 工坊入口按钮
            Button {
                showingStylePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 14))
                    Text("工坊")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(currentStyle.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(currentStyle.accentColor.opacity(0.15))
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - 仪式入口区域
    
    private var ritualHubSection: some View {
        VStack(spacing: 20) {
            // 当前入口名称
            Text(currentStyle.rawValue)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(currentStyle.textColor.opacity(0.7))
                .tracking(4)
            
            // 仪式入口组件
            RitualHubContainerV2(style: currentStyle) {
                handleRitualTrigger()
            }
            .frame(height: 380)
        }
    }
    
    // MARK: - 底部区域
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // 今日状态卡片
            if let record = todayRecord {
                todayRecordCard(record)
            } else {
                todayEmptyCard
            }
            
            // 今日一言（可选）
            if dataManager.settings.dailyQuoteEnabled {
                quoteCard
                    .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - 今日记录卡片（已有记录）
    
    private func todayRecordCard(_ record: DayRecord) -> some View {
        Button {
            showingTodayRecord = record
        } label: {
            HStack(spacing: 16) {
                // 心情emoji
                Text(record.mood.emoji)
                    .font(.system(size: 36))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日已记录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(currentStyle.textColor)
                    
                    Text(record.content.prefix(20) + (record.content.count > 20 ? "..." : ""))
                        .font(.system(size: 12))
                        .foregroundColor(currentStyle.textColor.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(currentStyle.textColor.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(currentStyle.cardBackground)
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 今日空状态卡片
    
    private var todayEmptyCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(currentStyle.accentColor)
            
            Text("今天还没有记录，开始你的仪式吧")
                .font(.system(size: 14))
                .foregroundColor(currentStyle.textColor.opacity(0.7))
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(currentStyle.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(currentStyle.accentColor.opacity(0.3), lineWidth: 1)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                )
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - 今日一言
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("「\(quotesManager.todayQuote.text)」")
                .font(.system(size: 13, design: .serif))
                .foregroundColor(currentStyle.textColor.opacity(0.8))
                .lineSpacing(4)
                .italic()
            
            Text("— \(quotesManager.todayQuote.source)")
                .font(.system(size: 11, design: .serif))
                .foregroundColor(currentStyle.textColor.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(currentStyle.cardBackground.opacity(0.5))
        )
    }
    
    // MARK: - 辅助方法
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: Date())
    }
    
    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private func loadCurrentStyle() {
        // 从 dataManager 加载保存的风格
        // 这里假设你会在 Settings 中添加一个 ritualHubStyle 字段
        // currentStyle = dataManager.settings.ritualHubStyleV2 ?? .auroraGlobe
    }
    
    private func handleRitualTrigger() {
        // 保存当前风格到设置
        // dataManager.settings.ritualHubStyleV2 = currentStyle
        // dataManager.updateSettings()
        
        // 打开新记录页面
        showingNewRecord = true
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 工坊主题选择器（底部Sheet）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualStylePickerSheet: View {
    @Binding var selectedStyle: RitualHubStyleV2
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题说明
                    VStack(spacing: 8) {
                        Text("选择你的仪式入口")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("每种入口都有独特的交互体验")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // 风格网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(RitualHubStyleV2.allCases) { style in
                            StyleCard(
                                style: style,
                                isSelected: selectedStyle == style
                            ) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.spring(response: 0.3)) {
                                    selectedStyle = style
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("仪式工坊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

// MARK: - 风格卡片

struct StyleCard: View {
    let style: RitualHubStyleV2
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // 预览图标
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(style.backgroundColor)
                        .frame(height: 100)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(style.accentColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                
                VStack(spacing: 4) {
                    Text(style.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextPrimary"))
                    
                    Text(style.shortDescription)
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 RitualHubStyleV2 扩展（颜色和UI属性）
// MARK: - ═══════════════════════════════════════════════════════════

extension RitualHubStyleV2 {
    
    var backgroundColor: Color {
        switch self {
        case .auroraGlobe:
            return Color(hex: "0B1026")
        case .leicaCamera:
            return Color(hex: "1C1C1E")
        case .polaroidCamera:
            return Color(hex: "F0F0F0")
        case .waxEnvelope:
            return Color(hex: "FDF8F3")
        case .astrolabe:
            return Color(hex: "0B1026")
        case .omikuji:
            return Color(hex: "FDF8F3")
        }
    }
    
    var textColor: Color {
        switch self {
        case .auroraGlobe, .leicaCamera, .astrolabe:
            return .white
        case .polaroidCamera, .waxEnvelope, .omikuji:
            return Color(hex: "1A1A1A")
        }
    }
    
    var accentColor: Color {
        switch self {
        case .auroraGlobe:
            return Color(hex: "00CED1")
        case .leicaCamera:
            return Color(hex: "C9A55C")
        case .polaroidCamera:
            return Color(hex: "C41E3A")
        case .waxEnvelope:
            return Color(hex: "8B4513")
        case .astrolabe:
            return Color(hex: "9370DB")
        case .omikuji:
            return Color(hex: "8B4513")
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .auroraGlobe, .leicaCamera, .astrolabe:
            return Color.white.opacity(0.1)
        case .polaroidCamera, .waxEnvelope, .omikuji:
            return Color.white.opacity(0.8)
        }
    }
    
    var iconName: String {
        switch self {
        case .auroraGlobe:
            return "snowflake"
        case .leicaCamera:
            return "camera.fill"
        case .polaroidCamera:
            return "camera.viewfinder"
        case .waxEnvelope:
            return "envelope.fill"
        case .astrolabe:
            return "sparkles"
        case .omikuji:
            return "leaf.fill"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .auroraGlobe:
            return "摇晃封存极光"
        case .leicaCamera:
            return "按下快门定格"
        case .polaroidCamera:
            return "即拍即得"
        case .waxEnvelope:
            return "火漆郑重封印"
        case .astrolabe:
            return "转动预见命运"
        case .omikuji:
            return "摇签探索运势"
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 预览
// MARK: - ═══════════════════════════════════════════════════════════

#Preview("仪式中心 - 极光") {
    RitualCenterView()
        .environmentObject(DataManager())
        .environmentObject(QuotesManager())
}

#Preview("工坊选择器") {
    RitualStylePickerSheet(selectedStyle: .constant(.auroraGlobe))
}


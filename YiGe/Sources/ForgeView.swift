//
//  ForgeView.swift
//  时光格 - 铸造页面（中Tab专用）
//
//  这是一个纯仪式感页面：
//  - 6种极致动效的仪式入口
//  - 工坊主题切换
//  - 有趣的铸造统计
//  - 不存放信物（信物在日历/倒数日/今日里查看）
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔥 铸造页面主视图
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // 状态
    @State private var showingNewRecord = false
    @State private var showingStylePicker = false
    @State private var currentStyle: ForgeHubStyle = .auroraGlobe
    
    // 统计数据
    private var totalForgeCount: Int {
        dataManager.records.count
    }
    
    private var streakDays: Int {
        calculateStreak()
    }
    
    private var todayForged: Bool {
        dataManager.todayRecord() != nil
    }
    
    private var thisMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return dataManager.records.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    var body: some View {
        ZStack {
            // 背景（根据入口风格变化）
            currentStyle.backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentStyle)
            
            // 背景装饰粒子
            if currentStyle.hasParticles {
                ParticleBackground(style: currentStyle)
            }
            
            VStack(spacing: 0) {
                // ═══════════════════════════════════════
                // 顶部栏
                // ═══════════════════════════════════════
                topBar
                    .padding(.top, 10)
                
                Spacer()
                
                // ═══════════════════════════════════════
                // 核心：仪式入口
                // ═══════════════════════════════════════
                VStack(spacing: 16) {
                    // 入口名称
                    Text(currentStyle.rawValue)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(currentStyle.textColor.opacity(0.6))
                        .tracking(6)
                    
                    // 仪式入口组件
                    ForgeHubContainer(style: currentStyle) {
                        triggerForge()
                    }
                    .frame(height: 340)
                }
                
                Spacer()
                
                // ═══════════════════════════════════════
                // 底部：铸造统计
                // ═══════════════════════════════════════
                forgeStatsSection
                    .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showingNewRecord) {
            NewRecordView(recordDate: Date())
        }
        .sheet(isPresented: $showingStylePicker) {
            ForgeStylePickerSheet(selectedStyle: $currentStyle)
                .presentationDetents([.medium])
        }
        .onAppear {
            loadSavedStyle()
        }
    }
    
    // MARK: - 顶部栏
    
    private var topBar: some View {
        HStack {
            // 左侧：铸造统计徽章
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(currentStyle.accentColor)
                
                Text("\(totalForgeCount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(currentStyle.textColor)
                
                Text("信物")
                    .font(.system(size: 12))
                    .foregroundColor(currentStyle.textColor.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(currentStyle.cardBackground)
            )
            
            Spacer()
            
            // 右侧：工坊入口
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingStylePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 13))
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
        .padding(.horizontal, 20)
    }
    
    // MARK: - 铸造统计区域
    
    private var forgeStatsSection: some View {
        HStack(spacing: 20) {
            // 连续天数
            ForgeStatCard(
                icon: "🔥",
                value: "\(streakDays)",
                label: "连续铸造",
                accentColor: currentStyle.accentColor,
                cardBackground: currentStyle.cardBackground,
                textColor: currentStyle.textColor
            )
            
            // 今日状态
            ForgeStatCard(
                icon: todayForged ? "✅" : "⭕",
                value: todayForged ? "已铸" : "待铸",
                label: "今日",
                accentColor: currentStyle.accentColor,
                cardBackground: currentStyle.cardBackground,
                textColor: currentStyle.textColor
            )
            
            // 本月铸造
            ForgeStatCard(
                icon: "📅",
                value: "\(thisMonthCount)",
                label: "本月",
                accentColor: currentStyle.accentColor,
                cardBackground: currentStyle.cardBackground,
                textColor: currentStyle.textColor
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 计算方法
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        // 如果今天没有记录，从昨天开始算
        if dataManager.record(for: checkDate) == nil {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        while let _ = dataManager.record(for: checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    private func loadSavedStyle() {
        // 从设置加载保存的风格
        // currentStyle = dataManager.settings.forgeHubStyle ?? .auroraGlobe
    }
    
    private func triggerForge() {
        // 保存当前风格
        // dataManager.settings.forgeHubStyle = currentStyle
        // dataManager.updateSettings()
        
        // 打开新记录页面
        showingNewRecord = true
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📊 统计卡片组件
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeStatCard: View {
    let icon: String
    let value: String
    let label: String
    let accentColor: Color
    let cardBackground: Color
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(textColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 工坊风格选择器
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeStylePickerSheet: View {
    @Binding var selectedStyle: ForgeHubStyle
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 说明
                    Text("选择你喜欢的仪式入口")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                    
                    // 风格网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(ForgeHubStyle.allCases) { style in
                            ForgeStyleCard(
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

struct ForgeStyleCard: View {
    let style: ForgeHubStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // 预览
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(style.backgroundColor)
                        .frame(height: 90)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(style.accentColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                
                VStack(spacing: 2) {
                    Text(style.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextPrimary"))
                    
                    Text(style.shortDescription)
                        .font(.system(size: 10))
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌌 背景粒子效果
// MARK: - ═══════════════════════════════════════════════════════════

struct ParticleBackground: View {
    let style: ForgeHubStyle
    
    var body: some View {
        Canvas { context, size in
            for _ in 0..<80 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let starSize = Double.random(in: 0.5...2)
                let opacity = Double.random(in: 0.2...0.6)
                
                let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 铸造入口风格枚举
// MARK: - ═══════════════════════════════════════════════════════════

enum ForgeHubStyle: String, CaseIterable, Identifiable {
    case auroraGlobe = "极光水晶球"
    case leicaCamera = "徕卡相机"
    case polaroidCamera = "拍立得"
    case waxEnvelope = "火漆信封"
    case astrolabe = "星象仪"
    case omikuji = "日式签筒"
    
    var id: String { rawValue }
    
    var shortDescription: String {
        switch self {
        case .auroraGlobe: return "摇晃封存极光"
        case .leicaCamera: return "按下快门定格"
        case .polaroidCamera: return "即拍即得"
        case .waxEnvelope: return "火漆郑重封印"
        case .astrolabe: return "转动预见命运"
        case .omikuji: return "摇签探索运势"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .auroraGlobe, .astrolabe:
            return Color(hex: "0B1026")
        case .leicaCamera:
            return Color(hex: "1C1C1E")
        case .polaroidCamera:
            return Color(hex: "F0F0F0")
        case .waxEnvelope, .omikuji:
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
        case .auroraGlobe: return Color(hex: "00CED1")
        case .leicaCamera: return Color(hex: "C9A55C")
        case .polaroidCamera: return Color(hex: "C41E3A")
        case .waxEnvelope, .omikuji: return Color(hex: "8B4513")
        case .astrolabe: return Color(hex: "9370DB")
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
        case .auroraGlobe: return "snowflake"
        case .leicaCamera: return "camera.fill"
        case .polaroidCamera: return "camera.viewfinder"
        case .waxEnvelope: return "envelope.fill"
        case .astrolabe: return "sparkles"
        case .omikuji: return "leaf.fill"
        }
    }
    
    var hasParticles: Bool {
        switch self {
        case .auroraGlobe, .astrolabe: return true
        default: return false
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 入口容器（路由到具体组件）
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeHubContainer: View {
    let style: ForgeHubStyle
    let onTrigger: () -> Void
    
    var body: some View {
        // 使用 ForgeHubWidgetsV2 中的组件（与 ForgeViewV2 一致）
        switch style {
        case .auroraGlobe:
            AuroraGlobeWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        case .leicaCamera:
            LeicaCameraWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        case .polaroidCamera:
            PolaroidCameraWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        case .waxEnvelope:
            WaxEnvelopeWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        case .astrolabe:
            AstrolabeWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        case .omikuji:
            OmikujiWidgetV2(onTrigger: onTrigger) // 来自 ForgeHubWidgetsV2.swift
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 预览
// MARK: - ═══════════════════════════════════════════════════════════

#Preview("铸造页面") {
    ForgeView()
        .environmentObject(DataManager())
}


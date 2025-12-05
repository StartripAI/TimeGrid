//
//  ForgeViewV2.swift
//  时光格 - 铸造页面（中Tab）完整版
//
//  功能：
//  - 13种完整的交互风格（与"我的"Tab一致）
//  - 5种工坊主题背景（皮具、机械、珠宝、赛道、星际）
//  - 极致精美的动效和音效
//  - 触发时的"迸发"效果
//  - 铸造统计（连续天数、总数等）
//

import SwiftUI
import AVFoundation

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔥 铸造页面主视图 V2
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeViewV2: View {
    @EnvironmentObject var dataManager: DataManager
    
    // 状态
    @State private var showingNewRecord = false
    @State private var showingStylePicker = false
    @State private var showingBurstEffect = false
    @State private var burstParticles: [BurstParticle] = []
    
    // 当前选择的交互风格（从设置读取）
    private var currentStyle: TodayHubStyle {
        dataManager.settings.todayHubStyle
    }
    
    // 统计数据
    private var totalForgeCount: Int { dataManager.records.count }
    private var todayForged: Bool { dataManager.todayRecord() != nil }
    
    var body: some View {
        ZStack {
            // ═══════════════════════════════════════
            // 背景（根据交互风格变化）
            // ═══════════════════════════════════════
            // 注意：preferredBackground 在 ForgeViewV3.swift 中定义
            Color("BackgroundCream")
                .ignoresSafeArea()
            
            // 背景粒子（深色主题）
            if currentStyle.isDarkTheme {
                StarsBackgroundView()
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
                    ForgeHubRouter(style: currentStyle) {
                        triggerForgeWithBurst()
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
            
            // ═══════════════════════════════════════
            // 迸发效果层
            // ═══════════════════════════════════════
            if showingBurstEffect {
                BurstEffectView(particles: burstParticles, style: currentStyle)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .fullScreenCover(isPresented: $showingNewRecord) {
            // 传入初始化的信物风格为 thermal
            NewRecordView(recordDate: Date())
        }
        .sheet(isPresented: $showingStylePicker) {
            InteractionStylePickerSheet()
                .presentationDetents([.large]) // 大窗口
                .presentationDragIndicator(.visible)
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
                    .fill(cardBackgroundForStyle(currentStyle))
            )
            
            Spacer()
            
            // 右侧：互动风格入口
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingStylePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 13))
                    Text("互动风格")
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
            ForgeStatCardV2(
                icon: "🔥",
                value: "\(calculateStreak())",
                label: "连续铸造",
                style: currentStyle
            )
            
            ForgeStatCardV2(
                icon: todayForged ? "✅" : "⭕",
                value: todayForged ? "已铸" : "待铸",
                label: "今日",
                style: currentStyle
            )
            
            ForgeStatCardV2(
                icon: "📅",
                value: "\(thisMonthCount)",
                label: "本月",
                style: currentStyle
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 计算方法
    
    private var thisMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return dataManager.records.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        if dataManager.record(for: checkDate) == nil {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        while let _ = dataManager.record(for: checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    // MARK: - 迸发效果触发
    
    private func triggerForgeWithBurst() {
        // 1. 播放迸发音效
        ForgeSoundManager.shared.playBurstSound()
        
        // 2. 生成迸发粒子
        generateBurstParticles()
        
        // 3. 显示迸发效果
        withAnimation(.easeOut(duration: 0.1)) {
            showingBurstEffect = true
        }
        
        // 4. 强烈的触感反馈
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
        
        // 连续触感，模拟"迸发"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        // 5. 延迟后打开新记录页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showingBurstEffect = false
            showingNewRecord = true
        }
    }
    
    private func generateBurstParticles() {
        burstParticles = (0..<40).map { _ in
            BurstParticle(
                id: UUID(),
                angle: Double.random(in: 0...360),
                distance: CGFloat.random(in: 100...300),
                size: CGFloat.random(in: 4...12),
                duration: Double.random(in: 0.4...0.8),
                delay: Double.random(in: 0...0.1)
            )
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 💥 迸发效果视图
// MARK: - ═══════════════════════════════════════════════════════════

struct BurstParticle: Identifiable {
    let id: UUID
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
}

struct BurstEffectView: View {
    let particles: [BurstParticle]
    let style: TodayHubStyle
    
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                // 中心闪光
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                style.accentColor,
                                style.accentColor.opacity(0.5),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: isAnimating ? 200 : 0
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(center)
                    .opacity(isAnimating ? 0 : 0.8)
                
                // 粒子
                ForEach(particles) { particle in
                    Circle()
                        .fill(style.accentColor)
                        .frame(width: particle.size, height: particle.size)
                        .position(center)
                        .offset(
                            x: isAnimating ? cos(particle.angle * .pi / 180) * particle.distance : 0,
                            y: isAnimating ? sin(particle.angle * .pi / 180) * particle.distance : 0
                        )
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            .easeOut(duration: particle.duration).delay(particle.delay),
                            value: isAnimating
                        )
                }
                
                // 光环
                Circle()
                    .stroke(style.accentColor, lineWidth: isAnimating ? 2 : 8)
                    .frame(width: isAnimating ? 300 : 20, height: isAnimating ? 300 : 20)
                    .position(center)
                    .opacity(isAnimating ? 0 : 0.6)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📊 统计卡片 V2
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeStatCardV2: View {
    let icon: String
    let value: String
    let label: String
    let style: TodayHubStyle
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(style.textColor)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(style.textColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundForStyle(style))
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 互动风格选择器（大窗口）
// MARK: - ═══════════════════════════════════════════════════════════

struct InteractionStylePickerSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 当前预览
                    VStack(spacing: 12) {
                        Text("当前效果预览")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(backgroundColorForStyle(dataManager.settings.todayHubStyle))
                                .frame(height: 200)
                            
                            ForgeHubRouter(
                                style: dataManager.settings.todayHubStyle,
                                onTrigger: {}
                            )
                            .scaleEffect(0.6)
                            .allowsHitTesting(false)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 风格网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(TodayHubStyle.allCases) { style in
                            InteractionStyleCard(
                                style: style,
                                isSelected: dataManager.settings.todayHubStyle == style
                            ) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.spring(response: 0.3)) {
                                    dataManager.settings.todayHubStyle = style
                                }
                                dataManager.updateSettings()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("互动风格")
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

struct InteractionStyleCard: View {
    let style: TodayHubStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // 预览图标
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(backgroundColorForStyle(style))
                        .frame(height: 70)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(style.iconColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                
                Text(style.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextPrimary"))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌟 星星背景
// MARK: - ═══════════════════════════════════════════════════════════

// StarsBackgroundView 已在 ForgeViewV3.swift 中定义，这里移除以避免重复声明

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔊 音效管理器
// MARK: - ═══════════════════════════════════════════════════════════

class ForgeSoundManager {
    static let shared = ForgeSoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    func playBurstSound() {
        // 尝试播放迸发音效
        if let url = Bundle.main.url(forResource: "forge_burst", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                // 如果没有音效文件，用系统音效代替
                AudioServicesPlaySystemSound(1520) // Pop sound
            }
        } else {
            // 备用：系统音效
            AudioServicesPlaySystemSound(1520)
        }
    }
    
    func playStyleSound(_ style: TodayHubStyle) {
        switch style {
        case .leicaCamera, .polaroidCamera:
            AudioServicesPlaySystemSound(1108) // Camera shutter
        case .typewriter:
            AudioServicesPlaySystemSound(1104) // Keyboard click
        case .waxEnvelope, .waxStamp:
            AudioServicesPlaySystemSound(1519) // Heavy impact
        case .aurora, .astrolabe:
            AudioServicesPlaySystemSound(1057) // Mystic
        case .omikuji:
            AudioServicesPlaySystemSound(1103) // Shake
        default:
            AudioServicesPlaySystemSound(1520) // Default pop
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 入口路由器（13种完整风格）
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeHubRouter: View {
    let style: TodayHubStyle
    let onTrigger: () -> Void
    
    var body: some View {
        switch style {
        case .simple:
            SimpleHubWidgetV2(onTrigger: onTrigger)
        case .leicaCamera:
            LeicaCameraWidgetV2(onTrigger: onTrigger)
        case .jewelryBox:
            JewelryBoxWidgetV2(onTrigger: onTrigger)
        case .polaroidCamera:
            PolaroidCameraWidgetV2(onTrigger: onTrigger)
        case .waxEnvelope:
            WaxEnvelopeWidgetV2(onTrigger: onTrigger)
        case .waxStamp:
            WaxStampWidgetV2(onTrigger: onTrigger)
        case .vault:
            VaultWidgetV2(onTrigger: onTrigger)
        case .typewriter:
            TypewriterWidgetV2(onTrigger: onTrigger)
        case .safari:
            SafariWidgetV2(onTrigger: onTrigger)
        case .aurora:
            AuroraGlobeWidgetV2(onTrigger: onTrigger)
        case .astrolabe:
            AstrolabeWidgetV2(onTrigger: onTrigger)
        case .omikuji:
            OmikujiWidgetV2(onTrigger: onTrigger)
        case .hourglass:
            HourglassWidgetV2(onTrigger: onTrigger)
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - TodayHubStyle 辅助函数
// MARK: - ═══════════════════════════════════════════════════════════
// 注意：TodayHubStyle 的扩展已在 ForgeViewV3.swift 中定义
// 辅助函数 backgroundColorForStyle 和 cardBackgroundForStyle 已在 Helpers.swift 中定义

// MARK: - Color Hex 扩展
// 注意：Color(hex:) 已在 Models.swift 中定义，这里不再重复定义

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 预览
// MARK: - ═══════════════════════════════════════════════════════════

#Preview("铸造页面 V2") {
    ForgeViewV2()
        .environmentObject(DataManager())
}

#Preview("互动风格选择器") {
    InteractionStylePickerSheet()
        .environmentObject(DataManager())
}


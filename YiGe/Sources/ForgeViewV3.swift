//
//  ForgeViewV3.swift
//  时光格 - 铸造页面 V3（世界级设计）
//
//  设计理念：
//  - 每个组件都是艺术品
//  - 底部统计使用精美的实体化设计
//  - 迸发效果震撼人心
//

import SwiftUI
import AudioToolbox

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔥 铸造页面主视图 V3
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeViewV3: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var showingNewRecord = false
    @State private var showingStylePicker = false
    @State private var showingBurstEffect = false
    @State private var burstParticles: [BurstParticleV3] = []
    @State private var burstRings: [BurstRing] = []
    
    private var currentStyle: TodayHubStyle {
        dataManager.settings.todayHubStyle
    }
    
    private var totalForgeCount: Int { dataManager.records.count }
    private var todayForged: Bool { dataManager.todayRecord() != nil }
    
    var body: some View {
        ZStack {
            // 背景
            currentStyle.preferredBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentStyle)
            
            // 背景粒子
            if currentStyle.isDarkTheme {
                AmbientParticlesView(style: currentStyle)
            }
            
            VStack(spacing: 0) {
                // 顶部栏
                topBar
                    .padding(.top, 10)
                
                Spacer()
                
                // 仪式入口
                VStack(spacing: 12) {
                    Text(currentStyle.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(currentStyle.textColor.opacity(0.5))
                        .tracking(8)
                    
                    ForgeHubRouterV3(style: currentStyle) {
                        triggerForgeWithBurst()
                    }
                    .frame(height: 360)
                }
                
                Spacer()
                
                // 底部：精美统计组件
                ForgeStatsRowV3(
                    streak: calculateStreak(),
                    todayForged: todayForged,
                    monthCount: thisMonthCount,
                    totalCount: totalForgeCount,
                    style: currentStyle
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 25)
            }
            
            // 迸发效果层
            if showingBurstEffect {
                BurstEffectViewV3(
                    particles: burstParticles,
                    rings: burstRings,
                    style: currentStyle
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        .fullScreenCover(isPresented: $showingNewRecord) {
            // 每次打开随机选择一个信物
            NewRecordView(recordDate: Date(), initialStyle: ArtifactPickerManager.shared.getRandomStyle())
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingStylePicker) {
            InteractionStylePickerSheetV3()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - 顶部栏
    
    private var topBar: some View {
        HStack {
            // 左侧：铸造徽章
            ForgeCountBadge(count: totalForgeCount, style: currentStyle)
            
            Spacer()
            
            // 右侧：互动风格按钮
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingStylePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 14, weight: .medium))
                    Text("互动风格")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(currentStyle.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(currentStyle.textColor.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(currentStyle.textColor.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 计算
    
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
    
    // MARK: - 迸发效果
    
    private func triggerForgeWithBurst() {
        // 音效
        AudioServicesPlaySystemSound(1520)
        
        // 生成粒子和光环
        generateBurstElements()
        
        // 显示效果
        withAnimation(.easeOut(duration: 0.1)) {
            showingBurstEffect = true
        }
        
        // 触感序列
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
        
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                UIImpactFeedbackGenerator(style: i < 3 ? .medium : .light)
                    .impactOccurred(intensity: 1.0 - Double(i) * 0.15)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            showingBurstEffect = false
            showingNewRecord = true
        }
    }
    
    private func generateBurstElements() {
        // 粒子
        burstParticles = (0..<60).map { _ in
            BurstParticleV3(
                id: UUID(),
                angle: Double.random(in: 0...360),
                distance: CGFloat.random(in: 80...350),
                size: CGFloat.random(in: 3...10),
                duration: Double.random(in: 0.4...0.9),
                delay: Double.random(in: 0...0.15),
                shape: Int.random(in: 0...2) // 0=圆形, 1=星形, 2=菱形
            )
        }
        
        // 光环
        burstRings = (0..<4).map { i in
            BurstRing(
                id: UUID(),
                delay: Double(i) * 0.08,
                maxRadius: CGFloat(150 + i * 80)
            )
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🏅 铸造计数徽章
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeCountBadge: View {
    let count: Int
    let style: TodayHubStyle
    
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: 8) {
            // 火焰图标
            ZStack {
                // 外焰
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "FF6B35"))
                    .blur(radius: 3)
                
                // 内焰
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "FFD93D"))
            }
            
            // 计数
            Text("\(count)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(style.textColor)
            
            Text("信物")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(style.textColor.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // 底色
                Capsule()
                    .fill(style.isDarkTheme ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
                
                // 流光效果
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.clear, style.accentColor.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset)
                    .mask(Capsule())
            }
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [style.accentColor.opacity(0.4), style.accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 100
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📊 精美统计组件行
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeStatsRowV3: View {
    let streak: Int
    let todayForged: Bool
    let monthCount: Int
    let totalCount: Int
    let style: TodayHubStyle
    
    var body: some View {
        HStack(spacing: 12) {
            // 连续铸造 - 火焰计数器
            StreakFlameCard(streak: streak, style: style)
            
            // 今日状态 - 印章卡片
            TodayStampCard(isForged: todayForged, style: style)
            
            // 本月 - 日历卡片
            MonthCalendarCard(count: monthCount, style: style)
        }
    }
}

// MARK: - 🔥 连续铸造 - 火焰计数器

struct StreakFlameCard: View {
    let streak: Int
    let style: TodayHubStyle
    
    @State private var flameScale: CGFloat = 1
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            // 火焰容器
            ZStack {
                // 火焰粒子
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "FFD93D"), Color(hex: "FF6B35").opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 16, height: 16)
                        .offset(
                            x: CGFloat.random(in: -15...15),
                            y: -particleOffset + CGFloat(i * 5)
                        )
                        .opacity(Double(5 - i) / 5)
                }
                
                // 主火焰
                ZStack {
                    // 外焰（橙红）
                    FlameShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF6B35"), Color(hex: "FF4500")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 36, height: 44)
                    
                    // 内焰（黄色）
                    FlameShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 24, height: 30)
                        .offset(y: 5)
                    
                    // 核心（白黄）
                    FlameShape()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FFD93D")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 12, height: 16)
                        .offset(y: 10)
                }
                .scaleEffect(flameScale)
                .shadow(color: Color(hex: "FF6B35").opacity(0.5), radius: 10)
            }
            .frame(height: 50)
            
            // 数字
            Text("\(streak)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(style.textColor)
            
            Text("连续天")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(style.textColor.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.cardBackgroundV3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style.cardBorderV3, lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                flameScale = 1.1
            }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                particleOffset = 30
            }
        }
    }
}

// 火焰形状
struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.6),
            control1: CGPoint(x: w * 0.8, y: h * 0.1),
            control2: CGPoint(x: w, y: h * 0.3)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.85),
            control2: CGPoint(x: w * 0.7, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.6),
            control1: CGPoint(x: w * 0.3, y: h),
            control2: CGPoint(x: 0, y: h * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.3),
            control2: CGPoint(x: w * 0.2, y: h * 0.1)
        )
        
        return path
    }
}

// MARK: - ✅ 今日状态 - 印章卡片

struct TodayStampCard: View {
    let isForged: Bool
    let style: TodayHubStyle
    
    @State private var stampRotation: Double = -8
    @State private var stampScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 8) {
            // 印章
            ZStack {
                // 印泥痕迹（已完成时显示）
                if isForged {
                    Circle()
                        .fill(Color(hex: "C41E3A").opacity(0.15))
                        .frame(width: 55, height: 55)
                        .blur(radius: 5)
                }
                
                // 印章主体
                ZStack {
                    Circle()
                        .fill(
                            isForged ?
                            LinearGradient(
                                colors: [Color(hex: "C41E3A"), Color(hex: "8B0000")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    // 印章内容
                    if isForged {
                        VStack(spacing: 2) {
                            Text("已")
                                .font(.system(size: 12, weight: .bold))
                            Text("铸")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                    } else {
                        Text("待铸")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // 边框
                    Circle()
                        .stroke(
                            isForged ? Color(hex: "FFD700").opacity(0.6) : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 48, height: 48)
                }
                .rotationEffect(.degrees(stampRotation))
                .scaleEffect(stampScale)
                .shadow(
                    color: isForged ? Color(hex: "C41E3A").opacity(0.4) : Color.clear,
                    radius: 8
                )
            }
            .frame(height: 50)
            
            // 文字
            Text(isForged ? "完成" : "待完成")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isForged ? Color(hex: "4CAF50") : style.textColor.opacity(0.5))
            
            Text("今日")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(style.textColor.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.cardBackgroundV3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style.cardBorderV3, lineWidth: 1)
                )
        )
        .onAppear {
            if isForged {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    stampRotation = -5
                    stampScale = 1.05
                }
            }
        }
    }
}

// MARK: - 📅 本月 - 日历卡片

struct MonthCalendarCard: View {
    let count: Int
    let style: TodayHubStyle
    
    var body: some View {
        VStack(spacing: 8) {
            // 迷你日历
            ZStack {
                // 日历背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 48)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                VStack(spacing: 0) {
                    // 顶部红条
                    Rectangle()
                        .fill(Color(hex: "C41E3A"))
                        .frame(height: 12)
                    
                    Spacer()
                    
                    // 数字
                    Text("\(count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    
                    Spacer()
                }
                .frame(width: 44, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 日历孔
                HStack(spacing: 20) {
                    Circle()
                        .fill(style.isDarkTheme ? Color(hex: "1C1C1E") : Color(hex: "F5F0E8"))
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(style.isDarkTheme ? Color(hex: "1C1C1E") : Color(hex: "F5F0E8"))
                        .frame(width: 6, height: 6)
                }
                .offset(y: -21)
            }
            .frame(height: 50)
            
            // 文字
            Text("\(count)篇")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(style.textColor)
            
            Text(currentMonthName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(style.textColor.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.cardBackgroundV3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style.cardBorderV3, lineWidth: 1)
                )
        )
    }
    
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月"
        return formatter.string(from: Date())
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 💥 迸发效果 V3
// MARK: - ═══════════════════════════════════════════════════════════

struct BurstParticleV3: Identifiable {
    let id: UUID
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
    let shape: Int
}

struct BurstRing: Identifiable {
    let id: UUID
    let delay: Double
    let maxRadius: CGFloat
}

struct BurstEffectViewV3: View {
    let particles: [BurstParticleV3]
    let rings: [BurstRing]
    let style: TodayHubStyle
    
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                // 中心闪光
                RadialGradient(
                    colors: [
                        style.accentColor,
                        style.accentColor.opacity(0.6),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: isAnimating ? 250 : 0
                )
                .frame(width: 500, height: 500)
                .position(center)
                .opacity(isAnimating ? 0 : 0.9)
                
                // 光环
                ForEach(rings) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [style.accentColor, style.accentColor.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: isAnimating ? 2 : 6
                        )
                        .frame(
                            width: isAnimating ? ring.maxRadius * 2 : 30,
                            height: isAnimating ? ring.maxRadius * 2 : 30
                        )
                        .position(center)
                        .opacity(isAnimating ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 0.6).delay(ring.delay),
                            value: isAnimating
                        )
                }
                
                // 粒子
                ForEach(particles) { particle in
                    ParticleShapeView(shape: particle.shape, color: style.accentColor)
                        .frame(width: particle.size, height: particle.size)
                        .position(center)
                        .offset(
                            x: isAnimating ? cos(particle.angle * .pi / 180) * particle.distance : 0,
                            y: isAnimating ? sin(particle.angle * .pi / 180) * particle.distance : 0
                        )
                        .opacity(isAnimating ? 0 : 1)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            .easeOut(duration: particle.duration).delay(particle.delay),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            withAnimation { isAnimating = true }
        }
    }
}

struct ParticleShapeView: View {
    let shape: Int
    let color: Color
    
    var body: some View {
        switch shape {
        case 0:
            Circle().fill(color)
        case 1:
            StarShape(points: 4).fill(color)
        default:
            Diamond().fill(color)
        }
    }
}

struct StarShape: Shape {
    let points: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌟 环境粒子背景
// MARK: - ═══════════════════════════════════════════════════════════

struct AmbientParticlesView: View {
    let style: TodayHubStyle
    
    @State private var particles: [AmbientParticle] = []
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x * size.width,
                    y: particle.y * size.height,
                    width: particle.size,
                    height: particle.size
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(style.accentColor.opacity(particle.opacity))
                )
            }
        }
        .onAppear {
            particles = (0..<80).map { _ in
                AmbientParticle(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 1...3),
                    opacity: Double.random(in: 0.1...0.5)
                )
            }
        }
    }
}

struct AmbientParticle {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - TodayHubStyle 扩展 V3
// MARK: - ═══════════════════════════════════════════════════════════

extension TodayHubStyle {
    // 是否为深色主题
    var isDarkTheme: Bool {
        switch self {
        case .leicaCamera, .vault, .typewriter, .aurora, .astrolabe, .hourglass, .waxStamp, .safari, .jewelryBox:
            return true
        default:
            return false
        }
    }
    
    // 主题强调色
    var accentColor: Color {
        switch self {
        case .simple: return Color("PrimaryWarm")
        case .leicaCamera: return Color(hex: "D4AF37")
        case .jewelryBox: return Color(hex: "C9A55C")
        case .polaroidCamera: return Color(hex: "C41E3A")
        case .waxEnvelope: return Color(hex: "8B4513")
        case .waxStamp: return Color(hex: "D4AF37")
        case .vault: return Color(hex: "C9A55C")
        case .typewriter: return Color(hex: "C9A55C")
        case .safari: return Color(hex: "FF6B35")
        case .aurora: return Color(hex: "00CED1")
        case .astrolabe: return Color(hex: "9370DB")
        case .omikuji: return Color(hex: "C41E3A")
        case .hourglass: return Color(hex: "F5A623")
        }
    }
    
    // 文字颜色
    var textColor: Color {
        isDarkTheme ? .white : Color("TextPrimary")
    }
    
    // 卡片背景
    var cardBackgroundV3: Color {
        if isDarkTheme {
            return Color.white.opacity(0.06)
        } else {
            return Color.white.opacity(0.85)
        }
    }
    
    // 卡片边框
    var cardBorderV3: Color {
        if isDarkTheme {
            return Color.white.opacity(0.1)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    // 图标名称
    var iconName: String {
        switch self {
        case .simple: return "plus.circle.fill"
        case .leicaCamera: return "camera.fill"
        case .jewelryBox: return "gift.fill"
        case .polaroidCamera: return "camera.viewfinder"
        case .waxEnvelope: return "envelope.fill"
        case .waxStamp: return "seal.fill"
        case .vault: return "lock.fill"
        case .typewriter: return "keyboard"
        case .safari: return "sun.horizon.fill"
        case .aurora: return "sparkles"
        case .astrolabe: return "star.circle.fill"
        case .omikuji: return "scroll.fill"
        case .hourglass: return "hourglass"
        }
    }
    
    // 图标颜色
    var iconColor: Color {
        switch self {
        case .simple: return Color("PrimaryWarm")
        case .leicaCamera: return Color(hex: "C41E3A")
        case .jewelryBox: return Color(hex: "D4AF37")
        case .polaroidCamera: return Color(hex: "FF6B6B")
        case .waxEnvelope: return Color(hex: "C41E3A")
        case .waxStamp: return Color(hex: "D4AF37")
        case .vault: return Color(hex: "C9A55C")
        case .typewriter: return Color.white.opacity(0.7)
        case .safari: return Color(hex: "FFD700")
        case .aurora: return Color(hex: "00CED1")
        case .astrolabe: return Color(hex: "9370DB")
        case .omikuji: return Color(hex: "C41E3A")
        case .hourglass: return Color(hex: "F5A623")
        }
    }
    
    // 首选背景
    var preferredBackground: some View {
        Group {
            switch self {
            case .simple:
                Color("BackgroundCream")
            case .leicaCamera:
                LinearGradient(
                    colors: [Color(hex: "1C1C1E"), Color(hex: "0A0A0A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .jewelryBox:
                LinearGradient(
                    colors: [Color(hex: "2C1810"), Color(hex: "1A0F0A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .polaroidCamera:
                Color("BackgroundCream")
            case .waxEnvelope:
                LinearGradient(
                    colors: [Color(hex: "F5E6D3"), Color(hex: "E8D5C4")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .waxStamp:
                LinearGradient(
                    colors: [Color(hex: "2C2C2E"), Color(hex: "1A1A1A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .vault:
                LinearGradient(
                    colors: [Color(hex: "1C1C1E"), Color(hex: "0A0A0A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .typewriter:
                LinearGradient(
                    colors: [Color(hex: "2A2A2A"), Color(hex: "1A1A1A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .safari:
                LinearGradient(
                    colors: [Color(hex: "FFB347"), Color(hex: "FF6B35"), Color(hex: "8B4513")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .aurora:
                LinearGradient(
                    colors: [Color(hex: "0F0F2A"), Color(hex: "1A1A3F"), Color(hex: "0A0A20")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .astrolabe:
                LinearGradient(
                    colors: [Color(hex: "1A1A2E"), Color(hex: "0F0F1A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .omikuji:
                LinearGradient(
                    colors: [Color(hex: "F8F0E8"), Color(hex: "F0E4D8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .hourglass:
                LinearGradient(
                    colors: [Color(hex: "2A2A2A"), Color(hex: "1A1A1A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

// MARK: - Color Hex 扩展
// 注意：Color(hex:) 已在 Models.swift 中定义，这里不再重复定义

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎨 互动风格选择器 V3
// MARK: - ═══════════════════════════════════════════════════════════

struct InteractionStylePickerSheetV3: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 预览区
                    VStack(spacing: 12) {
                        Text("当前效果")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(backgroundColorForStyle(dataManager.settings.todayHubStyle))
                            
                            ForgeHubRouterV3(
                                style: dataManager.settings.todayHubStyle,
                                onTrigger: {}
                            )
                            .scaleEffect(0.55)
                            .allowsHitTesting(false)
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
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
                            InteractionStyleCardV3(
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
                    Button("完成") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

struct InteractionStyleCardV3: View {
    let style: TodayHubStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColorForStyle(style))
                        .frame(height: 75)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 26))
                        .foregroundColor(style.iconColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color("PrimaryWarm") : Color.clear,
                            lineWidth: 3
                        )
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
// MARK: - 🌟 星星背景视图
// MARK: - ═══════════════════════════════════════════════════════════

struct StarsBackgroundView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<100 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let starSize = Double.random(in: 0.5...2)
                let opacity = Double.random(in: 0.2...0.7)
                
                let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
    }
}

// MARK: - 路由器（实现在 ForgeHubWidgetsV3.swift）
// ForgeHubRouterV3 已在 ForgeHubWidgetsV3.swift 中实现


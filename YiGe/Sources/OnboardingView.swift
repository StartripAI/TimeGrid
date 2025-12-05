//
//  OnboardingView.swift
//  时光格 V4.0 - 全新艺术级引导页
//
//  设计理念：
//  - 用视觉打动用户，让人一眼爱上
//  - 每一页都是一幅精心设计的艺术品
//  - 抓住核心卖点：仪式感、20+种信物、每日记录
//

import SwiftUI

// MARK: - 主引导视图

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    
    // 4页引导
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            // 动态背景
            pageBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // 主内容
                TabView(selection: $currentPage) {
                    // 第1页：欢迎页
                    WelcomePageV4()
                        .tag(0)
                    
                    // 第2页：皇家诏书 (信封)
                    StyleIntroPageV4(
                        style: .envelope,
                        title: "皇家诏书",
                        subtitle: "火漆封印 · 仪式感满满",
                        description: "每一封信，都值得被庄重对待\n用火漆印章封存你的珍贵时刻",
                        icon: "envelope.fill",
                        primaryColor: Color(hex: "8B4513"),
                        secondaryColor: Color(hex: "C41E3A"),
                        bgColors: [Color(hex: "FDF8F3"), Color(hex: "E8DCC8"), Color(hex: "D4C4B0")]
                    )
                    .tag(1)
                    
                    // 第3页：时光小票
                    StyleIntroPageV4(
                        style: .monoTicket,
                        title: "时光小票",
                        subtitle: "便利店美学 · 日常即永恒",
                        description: "把生活装进一张小票\n每个瞬间都是限量发售",
                        icon: "doc.text.fill",
                        primaryColor: Color(hex: "1A1A1A"),
                        secondaryColor: Color(hex: "C41E3A"),
                        bgColors: [Color.white, Color(hex: "F5F5F5"), Color(hex: "EBEBEB")]
                        )
                    .tag(2)
                    
                    // 第4页：工坊主题
                    WorkshopThemePageV4()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 底部控制栏
                BottomControlBarV4(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    isLastPage: currentPage == totalPages - 1,
                    accentColor: pageAccentColor,
                    textColor: pageTextColor,
                    onSkip: onComplete,
                    onNext: {
                        if currentPage < totalPages - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }
                )
            }
        }
    }
    
    // 页面背景
    private var pageBackground: some View {
        Group {
            switch currentPage {
            case 0:
                LinearGradient(colors: [Color(hex: "FDF8F3"), Color(hex: "F5EDE0")], startPoint: .top, endPoint: .bottom)
            case 1:
                LinearGradient(colors: [Color(hex: "FDF8F3"), Color(hex: "E8DCC8")], startPoint: .topLeading, endPoint: .bottomTrailing)
            case 2:
                LinearGradient(colors: [Color.white, Color(hex: "F5F5F5")], startPoint: .top, endPoint: .bottom)
            case 3:
                LinearGradient(colors: [Color(hex: "2C1810"), Color(hex: "1A0F0A"), Color(hex: "0D0705")], startPoint: .top, endPoint: .bottom)
            default:
                Color(hex: "FDF8F3")
            }
        }
    }
    
    // 页面强调色
    private var pageAccentColor: Color {
        switch currentPage {
        case 0: return Color(hex: "C41E3A")
        case 1: return Color(hex: "8B4513")
        case 2: return Color(hex: "C41E3A")
        case 3: return Color(hex: "FF8C00")
        default: return Color(hex: "C41E3A")
        }
    }
    
    // 页面文字色
    private var pageTextColor: Color {
        currentPage == 3 ? .white : Color(hex: "1A1A1A")
    }
}

// MARK: - 第4页：工坊主题

struct WorkshopThemePageV4: View {
    @State private var appear = false
    @State private var cardFloat: CGFloat = 0
    @State private var glowPulse = false
    @State private var sparkPhase: [Bool] = Array(repeating: false, count: 7)
    @State private var hammerRotation: Double = 0
    
    // 7种主题色
    private let themeColors: [Color] = [
        Color(hex: "8B4513"), // 棕
        Color(hex: "C41E3A"), // 红
        Color(hex: "1A1A1A"), // 黑
        Color(hex: "FFD700"), // 金
        Color(hex: "4A90A4"), // 蓝
        Color(hex: "9B59B6"), // 紫
        Color(hex: "27AE60")  // 绿
    ]
    
    var body: some View {
        ZStack {
            // 火花粒子
            ForEach(0..<7, id: \.self) { i in
                SparkParticleV4(delay: Double(i) * 0.4)
            }
            
            // 锤子
            Text("🔨")
                .font(.system(size: 24))
                .rotationEffect(.degrees(hammerRotation), anchor: .bottomTrailing)
                .position(x: UIScreen.main.bounds.width * 0.75, y: 120)
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    // 火焰光效
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "FF8C00").opacity(0.4), Color(hex: "FF6B00").opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: glowPulse ? 190 : 150
                            )
                        )
                        .frame(width: 380, height: 380)
                        .blur(radius: 50)
                        .hueRotation(.degrees(glowPulse ? 10 : -10))
                    
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF8C00").opacity(0.2))
                                .frame(width: 70, height: 70)
                                .shadow(color: Color(hex: "FF6B00").opacity(glowPulse ? 0.6 : 0.2), radius: glowPulse ? 20 : 8)
                            Text("⚒️")
                                .font(.system(size: 32))
                        }
                        
                        Text("工坊主题")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                        
                        // 7种主题色
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 20))], spacing: 6) {
                            ForEach(0..<7, id: \.self) { i in
                                Circle()
                                    .fill(themeColors[i])
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                    .scaleEffect(sparkPhase[i] ? 1.15 : 1.0)
                                    .animation(.easeInOut(duration: 0.8).repeatForever().delay(Double(i) * 0.15), value: sparkPhase[i])
                            }
                        }
                        .frame(width: 100)
                    }
                    .frame(width: 180, height: 240)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color(hex: "3D2817"), Color(hex: "2C1810")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "FF8C00").opacity(0.3), lineWidth: 1)
                    )
                    .offset(y: cardFloat)
                    .shadow(color: Color(hex: "FF6B00").opacity(glowPulse ? 0.4 : 0.2), radius: glowPulse ? 35 : 25, y: 15)
                }
                .frame(height: 360)
                
                Spacer().frame(height: 30)
                
                VStack(spacing: 18) {
                    Text("工坊主题")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .tracking(3)
                    
                    Text("7种精选配色 · 铸造专属风格")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "FF8C00"))
                        .tracking(2)
                    
                    Text("在工坊中挑选你的专属主题\n每种配色都是精心锻造的艺术")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 25)
            
            Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                cardFloat = -15
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            // 锤子动画
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                hammerRotation = -30
            }
            // 色块动画
            for i in 0..<7 {
                sparkPhase[i] = true
            }
        }
    }
}

// MARK: - 火花粒子

struct SparkParticleV4: View {
    let delay: Double
    
    @State private var y: CGFloat = 300
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(Color(hex: "FF6B00"))
            .frame(width: 4, height: 4)
            .shadow(color: Color(hex: "FF6B00"), radius: 4)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(x: CGFloat.random(in: -100...100), y: y)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false).delay(delay)) {
                    y = -100
                    opacity = 0
                    scale = 0.3
                }
        }
    }
}

// MARK: - 第1页：欢迎页

struct WelcomePageV4: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var lineHeight: CGFloat = 0
    @State private var showSlogan = false
    @State private var floatY: CGFloat = 0
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // 浮动装饰圈
            FloatingCirclesV4()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 刊号
                Text("ISSUE NO. 001 · EST. 2025")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(4)
                    .foregroundColor(Color.black.opacity(0.25))
                    .opacity(logoOpacity)
                    .padding(.bottom, 40)
                
                // 主视觉
                VStack(spacing: 16) {
                    // 顶部装饰线
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 1.5, height: lineHeight)
                    
                    // Logo
                    VStack(spacing: 10) {
                        // 英文
                        HStack(spacing: 0) {
                            Text("Time")
                                .font(.custom("Didot", size: 64))
                                .fontWeight(.light)
                            Text("Grid")
                                .font(.custom("Didot", size: 64))
                            .fontWeight(.bold)
                        }
                            .foregroundColor(.black)
                        
                        // 中文
                        Text("时  光  格")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .tracking(16)
                            .foregroundColor(Color.black.opacity(0.75))
                        
                        // 装饰
                        HStack(spacing: 10) {
                            Rectangle().fill(Color.black.opacity(0.2)).frame(width: 25, height: 0.5)
                            Image(systemName: "sparkle")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "C41E3A"))
                                .rotationEffect(.degrees(sparkleRotation))
                            Rectangle().fill(Color.black.opacity(0.2)).frame(width: 25, height: 0.5)
                    }
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // 底部装饰线
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 1.5, height: lineHeight)
            }
            
            Spacer()
            
                // Slogan 区域
                VStack(spacing: 20) {
                    // 核心卖点
                    HStack(spacing: 20) {
                        FeatureTagV4(icon: "square.grid.3x3.fill", text: "每日一格")
                        FeatureTagV4(icon: "theatermasks.fill", text: "20+信物")
                        FeatureTagV4(icon: "seal.fill", text: "仪式封存")
                    }
                    
                    // Slogan
                    VStack(spacing: 8) {
                        Text("CAPTURE · SEAL · TREASURE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(5)
                            .foregroundColor(Color.black.opacity(0.35))
                
                        Text("每一格，都是时光的仪式")
                            .font(.system(size: 15, weight: .regular, design: .serif))
                            .foregroundColor(Color.black.opacity(0.55))
                            .tracking(3)
            }
                    
                    // 向下提示
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(Color.black.opacity(0.25))
                        .offset(y: floatY)
                }
                .opacity(showSlogan ? 1 : 0)
                .offset(y: showSlogan ? 0 : 20)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            // Logo动画
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // 线条动画
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                lineHeight = 45
            }
            
            // Slogan动画
            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                showSlogan = true
            }
            
            // 浮动动画
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                floatY = 8
            }
            
            // 星星旋转
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
    }
}

// MARK: - 特性标签

struct FeatureTagV4: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(Color(hex: "8B4513"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "8B4513").opacity(0.1))
        )
    }
}

// MARK: - 浮动装饰圈

struct FloatingCirclesV4: View {
    @State private var f1 = false
    @State private var f2 = false
    @State private var f3 = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "C41E3A").opacity(0.04))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: -100, y: f1 ? -180 : -200)
            
            Circle()
                .fill(Color(hex: "8B4513").opacity(0.04))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 120, y: f2 ? 220 : 240)
            
            Circle()
                .fill(Color(hex: "FFD700").opacity(0.03))
                .frame(width: 160, height: 160)
                .blur(radius: 50)
                .offset(x: f3 ? 40 : 20, y: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { f1 = true }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true).delay(0.5)) { f2 = true }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(1)) { f3 = true }
        }
    }
}

// MARK: - 风格介绍页

struct StyleIntroPageV4: View {
    let style: RitualStyle
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let primaryColor: Color
    let secondaryColor: Color
    let bgColors: [Color]
    
    @State private var appear = false
    @State private var cardFloat: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var cardSwing: Double = 0
    @State private var glowPulse = false
    @State private var sealGlow = false
    @State private var scanLineY: CGFloat = 0.2
    @State private var barcodeGlow = false
    
    var body: some View {
        ZStack {
            // 第2页：飘落信封粒子
            if style == .envelope {
                ForEach(0..<5, id: \.self) { i in
                    FallingParticleV4(
                        emoji: "✉️",
                        delay: Double(i) * 0.8,
                        duration: Double.random(in: 7...11)
                    )
                }
            }
            
            // 第3页：扫描线和飘落小票
            if style == .monoTicket {
                // 扫描线
                GeometryReader { geo in
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, Color(hex: "C41E3A").opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 2)
                        .position(x: geo.size.width / 2, y: geo.size.height * scanLineY)
                }
                
                // 飘落小票粒子
                ForEach(0..<5, id: \.self) { i in
                    FallingReceiptV4(delay: Double(i) * 1.2, duration: Double.random(in: 8...12))
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // 3D 信物展示区
            ZStack {
                    // 光效
                Circle()
                    .fill(
                        RadialGradient(
                                colors: [primaryColor.opacity(style == .envelope ? 0.35 : 0.25), primaryColor.opacity(0.05), Color.clear],
                            center: .center,
                                startRadius: 20,
                                endRadius: glowPulse ? 180 : 150
                        )
                    )
                        .frame(width: 360, height: 360)
                        .blur(radius: style == .envelope ? 50 : 25)
                    
                    // 信物卡片
                    ArtifactCardV4(
                        icon: icon,
                        styleName: style.label,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        bgColors: bgColors,
                        isDark: false,
                        sealGlow: sealGlow,
                        barcodeGlow: barcodeGlow
                    )
                    .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(.degrees(style == .monoTicket ? cardSwing : 0))
                    .offset(y: cardFloat)
                    .shadow(color: primaryColor.opacity(0.3), radius: 25, x: 0, y: 15)
                }
                .frame(height: 360)
                
                Spacer().frame(height: 30)
                
                // 文案区域
                VStack(spacing: 18) {
                    // 主标题
                    Text(title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .tracking(3)
                    
                    // 副标题
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(primaryColor)
                        .tracking(2)
                    
                    // 描述
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "666666"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 45)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 25)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                cardFloat = style == .envelope ? -15 : -12
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: style == .envelope ? 6 : 7).repeatForever(autoreverses: true)) {
                cardRotation = style == .envelope ? 8 : 6
            }
            // 第3页：卡片摇摆
            if style == .monoTicket {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    cardSwing = 3
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                    scanLineY = 0.7
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    barcodeGlow = true
                }
            }
            // 第2页：火漆印章呼吸光效
            if style == .envelope {
                sealGlow = true
            }
        }
    }
}

// MARK: - 信物卡片

struct ArtifactCardV4: View {
    let icon: String
    let styleName: String
    let primaryColor: Color
    let secondaryColor: Color
    let bgColors: [Color]
    let isDark: Bool
    var sealGlow: Bool = false
    var barcodeGlow: Bool = false
    
    var body: some View {
        ZStack {
            // 卡片背景
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(colors: bgColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 230, height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(primaryColor.opacity(0.25), lineWidth: 1)
                )
            
            // 卡片内容
            VStack(spacing: 18) {
                // 图标
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.12))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(primaryColor)
            }
            
                // 名称
                Text(styleName)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(isDark ? .white : Color(hex: "1A1A1A"))
                
                // 装饰元素
                cardDecoration
            }
        }
    }
    
    @ViewBuilder
    private var cardDecoration: some View {
        if styleName.contains("诏书") || styleName.contains("信封") {
            // 火漆印章 - 呼吸光效
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "8B0000"))
                        .frame(width: 14, height: 14)
                        .shadow(color: Color(hex: "8B0000").opacity(sealGlow ? 0.6 : 0.2), radius: sealGlow ? 8 : 2)
                        .animation(.easeInOut(duration: 1.5).repeatForever().delay(Double(i) * 0.3), value: sealGlow)
            }
        }
        } else if styleName.contains("小票") || styleName.contains("收据") {
            // 条形码 - 闪烁效果
            HStack(spacing: 1) {
                ForEach(0..<22, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: CGFloat.random(in: 1...3), height: 22)
                }
            }
            .brightness(barcodeGlow ? 0.1 : 0)
        } else if styleName.contains("邀约") || styleName.contains("流光") {
            // 星星
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: i == 2 ? 14 : 10))
                        .foregroundColor(Color(hex: "FFD700"))
                }
            }
        }
    }
}

// MARK: - 飘落粒子效果

struct FallingParticleV4: View {
    let emoji: String
    let delay: Double
    let duration: Double
    
    @State private var y: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 16))
            .opacity(opacity * 0.15)
            .rotationEffect(.degrees(rotation))
            .offset(x: CGFloat.random(in: -150...150), y: y)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                    y = 700
                    rotation = 360
                }
                withAnimation(.easeIn(duration: 1).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

struct FallingReceiptV4: View {
    let delay: Double
    let duration: Double
    
    @State private var y: CGFloat = -60
    @State private var rotation: Double = 5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.black.opacity(0.05))
            .frame(width: 15, height: 25)
            .rotationEffect(.degrees(rotation))
            .offset(x: CGFloat.random(in: -150...150), y: y)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                    y = 700
                    rotation = -10
                }
            }
        }
    }
    
// MARK: - 底部控制栏

struct BottomControlBarV4: View {
    let currentPage: Int
    let totalPages: Int
    let isLastPage: Bool
    let accentColor: Color
    let textColor: Color
    let onSkip: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            // 跳过
            Button(action: onSkip) {
                Text("跳过")
                    .font(.system(size: 14))
                    .foregroundColor(textColor.opacity(0.5))
            }
            .frame(width: 55)
            
            Spacer()
            
            // 分页指示器
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? accentColor : textColor.opacity(0.2))
                        .frame(width: i == currentPage ? 26 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            
            Spacer()
            
            // 下一步/开始
            Button(action: onNext) {
                HStack(spacing: 5) {
                    Text(isLastPage ? "开始使用" : "下一步")
                        .font(.system(size: 14, weight: .semibold))
                    
                    if !isLastPage {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .foregroundColor(isLastPage ? (currentPage == 3 ? .black : .white) : accentColor)
                .padding(.horizontal, isLastPage ? 20 : 0)
                .padding(.vertical, isLastPage ? 10 : 0)
                .background(
                    Group {
                        if isLastPage {
                            Capsule()
                                .fill(accentColor)
                        }
                    }
                )
            }
            .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 45)
        }
    }


// MARK: - 预览动画视图（简化版）

struct PreviewAnimationView: View {
    let style: RitualStyle
    let onDismiss: () -> Void
    
    @State private var showComplete = false
    
    var body: some View {
        ZStack {
            // V3.5.1 修改：使用米黄色背景替代黑色
            Color("BackgroundCream").ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 关闭按钮
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("TextSecondary").opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // V3.5.1 优化：直接显示动画，无需二次点击
                SimplifiedSealAnimation(style: style, onComplete: {
                    showComplete = true
                })
                
                Spacer()
                
                // 完成后显示关闭提示
                if showComplete {
                    Button(action: onDismiss) {
                        Text("了解了")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color("PrimaryWarm"))
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - 简化的封存动画

struct SimplifiedSealAnimation: View {
    let style: RitualStyle
    let onComplete: () -> Void
    
    @State private var showStamp = false
    @State private var stampScale: CGFloat = 2.0
    @State private var stampRotation: Double = -30
    
    var body: some View {
        VStack(spacing: 40) {
            // 风格图标
            ZStack {
                Circle()
                    .fill(Color("SealColor").opacity(0.15))
                    .frame(width: 180, height: 180)
                    .scaleEffect(showStamp ? 1.3 : 0.8)
                    .opacity(showStamp ? 0.5 : 0)
                
                ZStack {
                    Circle()
                        .fill(Color("SealColor"))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color("SealColor").opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
                .scaleEffect(showStamp ? 1.0 : stampScale)
                .rotationEffect(.degrees(showStamp ? 0 : stampRotation))
                .opacity(showStamp ? 1 : 0)
            }
            
            // 文字
            VStack(spacing: 8) {
                Text("封存成功")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(style.onboardingDescription)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .opacity(showStamp ? 1 : 0)
        }
        .onAppear {
            // 简化的动画序列
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showStamp = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}


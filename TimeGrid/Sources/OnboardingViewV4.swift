//
//  OnboardingViewV4.swift
//  时光格 V4.0 - 全新艺术级引导页
//
//  设计理念：
//  - 用视觉打动用户，让人一眼爱上
//  - 每一页都是一幅精心设计的艺术品
//  - 抓住核心卖点：仪式感、20+种信物、每日记录
//

import SwiftUI

// MARK: - 主引导视图

struct OnboardingViewV4: View {
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
                    
                    // 第4页：流光邀约
                    StyleIntroPageV4(
                        style: .galaInvite,
                        title: "流光邀约",
                        subtitle: "红毯之夜 · 璀璨登场",
                        description: "你的人生是一场盛大首映\n每一天都值得一张入场券",
                        icon: "ticket.fill",
                        primaryColor: Color(hex: "FFD700"),
                        secondaryColor: Color(hex: "FFD700"),
                        bgColors: [Color(hex: "1A1A1A"), Color(hex: "2C2C2C"), Color(hex: "0D0D0D")]
                    )
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
                LinearGradient(colors: [Color(hex: "1A1A1A"), Color(hex: "0D0D0D")], startPoint: .top, endPoint: .bottom)
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
        case 3: return Color(hex: "FFD700")
        default: return Color(hex: "C41E3A")
        }
    }
    
    // 页面文字色
    private var pageTextColor: Color {
        currentPage == 3 ? .white : Color(hex: "1A1A1A")
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
    @State private var glowPulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 3D 信物展示区
            ZStack {
                // 光效
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [primaryColor.opacity(0.25), primaryColor.opacity(0.05), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: glowPulse ? 180 : 150
                        )
                    )
                    .frame(width: 360, height: 360)
                    .blur(radius: 25)
                
                // 信物卡片
                ArtifactCardV4(
                    icon: icon,
                    styleName: style.displayName,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    bgColors: bgColors,
                    isDark: style == .galaInvite
                )
                .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
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
                    .foregroundColor(style == .galaInvite ? .white : Color(hex: "1A1A1A"))
                    .tracking(3)
                
                // 副标题
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(primaryColor)
                    .tracking(2)
                
                // 描述
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(style == .galaInvite ? .white.opacity(0.7) : Color(hex: "666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 45)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 25)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                cardFloat = -12
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                cardRotation = 6
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
            // 火漆印章
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "8B0000"))
                        .frame(width: 14, height: 14)
                }
            }
        } else if styleName.contains("小票") || styleName.contains("收据") {
            // 条形码
            HStack(spacing: 1) {
                ForEach(0..<22, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: CGFloat.random(in: 1...3), height: 22)
                }
            }
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


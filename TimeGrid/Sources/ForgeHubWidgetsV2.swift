//
//  ForgeHubWidgetsV2.swift
//  时光格 - 13种完整交互风格组件
//
//  每个组件都有：
//  - 精美的视觉设计
//  - 丰富的动效
//  - 点击/交互动画
//  - 音效反馈
//

import SwiftUI
import AudioToolbox

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 1️⃣ 极简模式
// MARK: - ═══════════════════════════════════════════════════════════

struct SimpleHubWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                // 脉冲光环
                Circle()
                    .stroke(Color("PrimaryWarm").opacity(0.3), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)
                
                // 点击波纹
                Circle()
                    .stroke(Color("PrimaryWarm"), lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
                
                // 主按钮
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("PrimaryWarm"), Color("PrimaryWarm").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color("PrimaryWarm").opacity(0.4), radius: isPressed ? 5 : 15, y: isPressed ? 2 : 8)
                    .scaleEffect(isPressed ? 0.92 : 1)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(spacing: 6) {
                Text("记录今天")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("点击开始")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .frame(height: 280)
        .contentShape(Rectangle())
        .onTapGesture { triggerAction() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
    }
    
    private func triggerAction() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.easeIn(duration: 0.1)) { isPressed = true }
        withAnimation(.spring(response: 0.3).delay(0.1)) { isPressed = false }
        
        // 波纹效果
        ringScale = 0.8
        ringOpacity = 1
        withAnimation(.easeOut(duration: 0.5)) {
            ringScale = 1.8
            ringOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 2️⃣ 徕卡相机
// MARK: - ═══════════════════════════════════════════════════════════

struct LeicaCameraWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var flashOpacity: Double = 0
    @State private var lensRotation: Double = 0
    @State private var focusRingRotation: Double = 0
    @State private var shutterOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 闪光效果
            Color.white.opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 相机主体
                ZStack {
                    // 机身
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2C2C2E"), Color(hex: "1A1A1A"), Color(hex: "2C2C2E")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 260, height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "3A3A3C"), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    
                    HStack(spacing: 25) {
                        // 取景器
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                                .frame(width: 50, height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                            
                            Text("Leica")
                                .font(.system(size: 8, weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // 镜头组
                        ZStack {
                            // 外圈 - 对焦环
                            Circle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 110, height: 110)
                                .rotationEffect(.degrees(focusRingRotation))
                            
                            // 中圈 - 光圈环
                            Circle()
                                .fill(Color.black)
                                .frame(width: 85, height: 85)
                            
                            // 镜片
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: "1A3050"),
                                            Color(hex: "0A1525"),
                                            Color(hex: "000510")
                                        ],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 35
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(lensRotation))
                        }
                        
                        // 右侧装饰
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: "C41E3A"))
                                .frame(width: 12, height: 12)
                            
                            Text("M11")
                                .font(.system(size: 7, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    // 快门按钮（顶部）
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 28, height: 28)
                                    .offset(y: isPressed ? 3 : 0)
                            }
                            .padding(.trailing, 20)
                        }
                        .offset(y: -70)
                        Spacer()
                    }
                }
                
                // 提示文字
                VStack(spacing: 4) {
                    Text("定格瞬间")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("按下快门")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .frame(height: 300)
        .contentShape(Rectangle())
        .onTapGesture { triggerShutter() }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                focusRingRotation = 360
            }
        }
    }
    
    private func triggerShutter() {
        AudioServicesPlaySystemSound(1108)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        withAnimation(.easeIn(duration: 0.05)) {
            isPressed = true
            shutterOffset = 3
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            lensRotation += 15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.08)) { flashOpacity = 0.9 }
            withAnimation(.easeIn(duration: 0.3).delay(0.08)) { flashOpacity = 0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = false
                shutterOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 3️⃣ 时光珠宝盒
// MARK: - ═══════════════════════════════════════════════════════════

struct JewelryBoxWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isOpen = false
    @State private var lidRotation: Double = 0
    @State private var glowPulse = false
    @State private var sparkles: [SparkleParticle] = []
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 光晕
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "C9A55C").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 120)
                    .blur(radius: 20)
                    .scaleEffect(glowPulse ? 1.1 : 1)
                    .offset(y: 40)
                
                VStack(spacing: 0) {
                    // 盒盖
                    ZStack {
                        // 盖子主体
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "3D2914"), Color(hex: "2C1810"), Color(hex: "1A0F0A")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 180, height: 50)
                        
                        // 金属镶边
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "8B7355"), Color(hex: "D4AF37")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 180, height: 50)
                        
                        // 中央宝石
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "E8D5C4"), Color(hex: "C9A55C")],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "D4AF37"), lineWidth: 1.5)
                            )
                            .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 5)
                    }
                    .rotation3DEffect(
                        .degrees(isOpen ? -70 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.5
                    )
                    .zIndex(isOpen ? 0 : 1)
                    
                    // 盒身
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "2C1810"), Color(hex: "1A0F0A")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 180, height: 80)
                        
                        // 内衬（丝绒）
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "1A0520"))
                            .frame(width: 160, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "3D1A40").opacity(0.5), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                        
                        // 珠宝光芒（打开时显示）
                        if isOpen {
                            ForEach(sparkles) { sparkle in
                                Circle()
                                    .fill(Color(hex: "D4AF37"))
                                    .frame(width: sparkle.size, height: sparkle.size)
                                    .offset(x: sparkle.x, y: sparkle.y)
                                    .opacity(sparkle.opacity)
                            }
                        }
                        
                        // 金属镶边
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "8B7355"), lineWidth: 1.5)
                            .frame(width: 180, height: 80)
                    }
                }
                .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
            }
            
            VStack(spacing: 4) {
                Text("珍藏记忆")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Text("点击开启")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 280)
        .contentShape(Rectangle())
        .onTapGesture { triggerOpen() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            generateSparkles()
        }
    }
    
    private func generateSparkles() {
        sparkles = (0..<8).map { _ in
            SparkleParticle(
                id: UUID(),
                x: CGFloat.random(in: -60...60),
                y: CGFloat.random(in: -20...20),
                size: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.5...1)
            )
        }
    }
    
    private func triggerOpen() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isOpen = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onTrigger()
        }
    }
}

struct SparkleParticle: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 4️⃣ 拍立得
// MARK: - ═══════════════════════════════════════════════════════════

struct PolaroidCameraWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var flashOpacity: Double = 0
    @State private var photoOffset: CGFloat = 0
    @State private var photoOpacity: Double = 0
    @State private var rainbowHue: Double = 0
    
    var body: some View {
        ZStack {
            Color.white.opacity(flashOpacity)
            
            VStack(spacing: 15) {
                ZStack {
                    // 相机主体
                    VStack(spacing: 0) {
                        ZStack {
                            // 机身
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .frame(width: 200, height: 145)
                                .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
                            
                            // 彩虹条纹
                            HStack(spacing: 0) {
                                ForEach(0..<6, id: \.self) { i in
                                    Rectangle()
                                        .fill(rainbowColor(i))
                                        .frame(width: 8)
                                }
                            }
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .offset(x: -62)
                            
                            // 闪光灯
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "E8E8E8"))
                                    .frame(width: 45, height: 25)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 35, height: 15)
                                    .opacity(flashOpacity > 0 ? 1 : 0.3)
                            }
                            .offset(x: 50, y: -40)
                            
                            // 镜头
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color(hex: "2A4A6A"), Color(hex: "1A2A3A")],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                // 彩虹反光
                                Circle()
                                    .fill(
                                        AngularGradient(
                                            colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                            center: .center
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .opacity(0.15)
                                    .rotationEffect(.degrees(rainbowHue))
                            }
                            .offset(x: 20)
                        }
                        
                        // 出片口
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 160, height: 12)
                            
                            // 照片
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 85, height: 100)
                                .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                                .overlay(
                                    VStack {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(hex: "E8D5C4"))
                                            .frame(width: 70, height: 70)
                                            .padding(.top, 8)
                                        Spacer()
                                    }
                                )
                                .offset(y: photoOffset)
                                .opacity(photoOpacity)
                        }
                    }
                    
                    // 快门按钮
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "C41E3A"), Color(hex: "8B0000")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "E8E8E8"), lineWidth: 3)
                        )
                        .scaleEffect(isPressed ? 0.88 : 1)
                        .shadow(color: Color(hex: "C41E3A").opacity(0.4), radius: isPressed ? 2 : 6)
                        .offset(y: -105)
                }
                
                VStack(spacing: 4) {
                    Text("显影时光")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("按下快门")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .frame(height: 300)
        .contentShape(Rectangle())
        .onTapGesture { triggerCapture() }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                rainbowHue = 360
            }
        }
    }
    
    private func rainbowColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "C41E3A"), Color(hex: "FF8C00"), Color(hex: "FFD700"),
            Color(hex: "228B22"), Color(hex: "1E90FF"), Color(hex: "9370DB")
        ]
        return colors[index % colors.count]
    }
    
    private func triggerCapture() {
        AudioServicesPlaySystemSound(1108)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.easeIn(duration: 0.05)) { isPressed = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.1)) { flashOpacity = 0.95 }
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) { flashOpacity = 0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) { isPressed = false }
        }
        
        // 照片弹出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                photoOffset = -85
                photoOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 5️⃣ 火漆信封
// MARK: - ═══════════════════════════════════════════════════════════

struct WaxEnvelopeWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var sealScale: CGFloat = 1
    @State private var sealPressed = false
    @State private var waxDripScale: CGFloat = 0
    @State private var envelopeOpen = false
    @State private var letterOffset: CGFloat = 0
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 背景光晕
                Circle()
                    .fill(Color(hex: "8B4513").opacity(glowIntensity * 0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                
                // 信封组
                ZStack {
                    // 信封底部
                    ForgeEnvelopeShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F5E6D3"), Color(hex: "E8D5C4"), Color(hex: "DCC8B5")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 220, height: 150)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    
                    // 信封盖
                    ForgeEnvelopeFlapShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "E8D5C4"), Color(hex: "DCC8B5")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 220, height: 90)
                        .rotation3DEffect(
                            .degrees(envelopeOpen ? -160 : 0),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .bottom,
                            perspective: 0.3
                        )
                        .offset(y: -30)
                    
                    // 内信纸（打开时显示）
                    if envelopeOpen {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 150, height: 100)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            .offset(y: letterOffset - 30)
                    }
                    
                    // 火漆印章
                    ZStack {
                        // 蜡滴扩散
                        Circle()
                            .fill(Color(hex: "8B0000").opacity(0.3))
                            .frame(width: 60 * waxDripScale, height: 60 * waxDripScale)
                            .blur(radius: 5)
                        
                        // 火漆主体
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "C41E3A"), Color(hex: "8B0000"), Color(hex: "5C0000")],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "FFD700").opacity(0.7))
                            )
                            .scaleEffect(sealScale)
                            .shadow(color: Color(hex: "5C0000").opacity(0.5), radius: sealPressed ? 2 : 6, y: sealPressed ? 1 : 4)
                    }
                    .offset(y: 50)
                }
            }
            
            VStack(spacing: 4) {
                Text("封存信件")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("按压印章")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .frame(height: 300)
        .contentShape(Rectangle())
        .onTapGesture { triggerSeal() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
    }
    
    private func triggerSeal() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        sealPressed = true
        withAnimation(.easeIn(duration: 0.1)) { sealScale = 0.85 }
        
        withAnimation(.easeOut(duration: 0.3).delay(0.1)) { waxDripScale = 1.5 }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5).delay(0.15)) {
            sealScale = 1.08
            sealPressed = false
        }
        withAnimation(.spring(response: 0.25).delay(0.35)) { sealScale = 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                envelopeOpen = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                letterOffset = -40
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            onTrigger()
        }
    }
}

// 信封形状（重命名以避免与 KeepsakeSystem.swift 中的定义冲突）
struct ForgeEnvelopeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct ForgeEnvelopeFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 6️⃣-1️⃣3️⃣ 其他组件（简化实现，保持功能完整）
// MARK: - ═══════════════════════════════════════════════════════════

struct WaxStampWidgetV2: View {
    let onTrigger: () -> Void
    @State private var stampPressed = false
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "C41E3A"))
                    .frame(width: 80, height: 80)
                    .scaleEffect(stampPressed ? 0.9 : 1)
                Image(systemName: "seal.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            Text("加盖印记")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .onTapGesture {
            stampPressed = true
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                stampPressed = false
                onTrigger()
            }
        }
    }
}

struct VaultWidgetV2: View {
    let onTrigger: () -> Void
    @State private var dialRotation: Double = 0
    @State private var doorOpen = false
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "2C2C2E"))
                    .frame(width: 180, height: 180)
                Circle()
                    .stroke(Color(hex: "C9A55C"), lineWidth: 3)
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(dialRotation))
            }
            Text("存入金库")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.5)) { dialRotation = 360 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                doorOpen = true
                onTrigger()
            }
        }
    }
}

struct TypewriterWidgetV2: View {
    let onTrigger: () -> Void
    @State private var typedText = ""
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "2C2C2E"))
                .frame(width: 260, height: 160)
                .overlay(
                    Text(typedText.isEmpty ? "MEMORY" : typedText)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                )
            Text("敲击键盘")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .onTapGesture {
            typedText = "MEMORY"
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onTrigger()
            }
        }
    }
}

struct SafariWidgetV2: View {
    let onTrigger: () -> Void
    @State private var sunOffset: CGFloat = 0
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FF8C00"), Color(hex: "8B4513")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 260, height: 180)
                Circle()
                    .fill(Color(hex: "FFD700"))
                    .frame(width: 70, height: 70)
                    .offset(y: sunOffset)
            }
            Text("追逐落日")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 1)) { sunOffset = 60 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onTrigger()
            }
        }
    }
}

struct AuroraGlobeWidgetV2: View {
    let onTrigger: () -> Void
    @State private var isShaking = false
    @State private var showSnow = false
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1A1A2E"), Color(hex: "0B1026")],
                            center: .center,
                            startRadius: 10,
                            endRadius: 85
                        )
                    )
                    .frame(width: 170, height: 170)
                Circle()
                    .stroke(Color(hex: "00CED1"), lineWidth: 2.5)
                    .frame(width: 170, height: 170)
            }
            .rotationEffect(.degrees(isShaking ? 5 : -5))
            Text("摇晃水晶球")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "00CED1"))
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.spring(response: 0.12, dampingFraction: 0.3).repeatCount(10, autoreverses: true)) {
                isShaking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isShaking = false
                onTrigger()
            }
        }
    }
}

struct AstrolabeWidgetV2: View {
    let onTrigger: () -> Void
    @State private var outerRotation: Double = 0
    @State private var pointerRotation: Double = 0
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "C9A55C"), lineWidth: 8)
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(outerRotation))
                Capsule()
                    .fill(Color(hex: "C9A55C"))
                    .frame(width: 6, height: 70)
                    .offset(y: -35)
                    .rotationEffect(.degrees(pointerRotation))
            }
            Text("观测星象")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 1.5)) { pointerRotation += 720 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onTrigger()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                outerRotation = 360
            }
        }
    }
}

struct OmikujiWidgetV2: View {
    let onTrigger: () -> Void
    @State private var isShaking = false
    @State private var stickOffset: CGFloat = 0
    var body: some View {
        VStack(spacing: 20) {
            Text("⛩️")
                .font(.system(size: 40))
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "8B5A2B"))
                    .frame(width: 100, height: 170)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "F5DEB3"))
                    .frame(width: 6, height: 110)
                    .offset(y: stickOffset)
            }
            .rotationEffect(.degrees(isShaking ? 5 : -5))
            Text("抽取运势")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.3).repeatCount(10, autoreverses: true)) {
                isShaking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    stickOffset = -150
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                onTrigger()
            }
        }
    }
}

struct HourglassWidgetV2: View {
    let onTrigger: () -> Void
    @State private var rotation: Double = 0
    @State private var topSandHeight: CGFloat = 50
    @State private var bottomSandHeight: CGFloat = 0
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "C9A55C"))
                    .frame(width: 120, height: 200)
                HourglassTopSand(fillHeight: topSandHeight)
                    .fill(Color(hex: "F5A623"))
                    .frame(width: 80, height: 70)
                    .offset(y: -40)
                HourglassBottomSand(fillHeight: bottomSandHeight)
                    .fill(Color(hex: "F5A623"))
                    .frame(width: 80, height: 70)
                    .offset(y: 40)
            }
            .rotationEffect(.degrees(rotation))
            Text("翻转时光")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(height: 280)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                rotation += 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.linear(duration: 0.8)) {
                    topSandHeight = 0
                    bottomSandHeight = 50
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onTrigger()
            }
        }
    }
}

struct HourglassTopSand: Shape {
    var fillHeight: CGFloat
    var animatableData: CGFloat {
        get { fillHeight }
        set { fillHeight = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let ratio = fillHeight / 50
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * (1 - ratio)))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * (1 - ratio)))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct HourglassBottomSand: Shape {
    var fillHeight: CGFloat
    var animatableData: CGFloat {
        get { fillHeight }
        set { fillHeight = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let ratio = fillHeight / 50
        path.move(to: CGPoint(x: rect.width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: rect.width * (0.5 - 0.4 * ratio), y: rect.height * ratio))
        path.addLine(to: CGPoint(x: rect.width * (0.5 + 0.4 * ratio), y: rect.height * ratio))
        path.closeSubpath()
        return path
    }
}

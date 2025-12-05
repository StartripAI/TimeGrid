//
//  RitualHubWidgets.swift
//  时光格 V3.4 - 今日首页拟物化组件
//

import SwiftUI

struct RitualHubWidgetContainer: View {
    let style: TodayHubStyle
    let hasRecordToday: Bool
    let onTrigger: () -> Void
    let onShowRecord: () -> Void
    
    var body: some View {
        // V2.0: 始终根据风格显示对应widget，不因有记录而改变样式
        // V2.0: 始终允许创建新记录（无限次打卡），不限制
        switch style {
        case .leicaCamera:
            LeicaCameraWidget(onTrigger: onTrigger)  // 始终创建新记录
        case .jewelryBox:
            JewelryBoxWidget(onTrigger: onTrigger)
        case .polaroidCamera:
            PolaroidCameraWidget(onTrigger: onTrigger)
        case .waxEnvelope:
            WaxEnvelopeWidget(onTrigger: onTrigger)
        case .waxStamp:
            WaxStampWidget(onTrigger: onTrigger)
        case .vault:
            VaultWidget(onTrigger: onTrigger)
        case .typewriter:
            TypewriterWidget(onTrigger: onTrigger)
        case .safari:
            SafariSunsetWidget(onTrigger: onTrigger)
        case .aurora:
            AuroraGlobeWidget(onTrigger: onTrigger)
        case .astrolabe:
            AstrolabeWidget(onTrigger: onTrigger)
        case .omikuji:
            OmikujiWidget(onTrigger: onTrigger)
        case .hourglass:
            HourglassWidget(onTrigger: onTrigger)
        case .simple:
            ClassicHubButton(onTap: onTrigger)  // 始终创建新记录
        }
    }
}

// MARK: - 经典按钮（今日已记录状态或极简模式）

private struct ClassicHubButton: View {
    let onTap: () -> Void
    @State private var glow = false
    @State private var pressed = false
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("PrimaryWarm").opacity(0.4),
                                Color("PrimaryWarm").opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 70,
                            endRadius: 140
                        )
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(glow ? 1.12 : 1.0)
                    .opacity(glow ? 0.9 : 0.6)
                
                Button(action: onTap) {
                    VStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("记录今天")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(width: 170, height: 170)
                    .background(
                        LinearGradient(
                            colors: [Color("PrimaryWarm"), Color("SealColor")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color("PrimaryWarm").opacity(0.4), radius: 20, y: 12)
                }
                .scaleEffect(pressed ? 0.94 : 1.0)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                pressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                pressed = false
                            }
                        }
                )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glow = true
                }
            }
            
            Text("点击开始，封存此刻")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
        }
    }
}

// MARK: - Leica 相机

private struct LeicaCameraWidget: View {
    let onTrigger: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color(hex: "#2C2C2C"), Color(hex: "#0C0C0C")], startPoint: .top, endPoint: .bottom))
                    .frame(width: 220, height: 150)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 15)
                
                // 取景器
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 60, height: 34)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(colors: [Color(hex: "#2A4A6A"), Color(hex: "#0E2034")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 20)
                    )
                    .offset(x: -60, y: -40)
                
                // Logo
                Text("Leica")
                    .font(.custom("Times New Roman", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(Color("SealColor"))
                    .offset(x: 60, y: -42)
                
                // 快门
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [Color(hex: "#d7d7d7"), Color(hex: "#8b8b8b")], startPoint: .top, endPoint: .bottom))
                    .frame(width: 28, height: 16)
                    .offset(x: 50, y: isPressed ? -62 : -65)
                
                // 镜头
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#4A4A4A"), Color(hex: "#1A1A1A")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .fill(RadialGradient(colors: [Color(hex: "#0F2742"), .black], center: .center, startRadius: 10, endRadius: 45))
                            .frame(width: 65, height: 65)
                    )
                    .offset(y: 35)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    isPressed = true
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPressed = false
                    onTrigger()
                }
            }
            
            WidgetHint(title: "按下快门", subtitle: "记录今天的瞬间")
        }
    }
}

// MARK: - 珠宝盒 (V3.5 优化 - Harry Winston 风格)

private struct JewelryBoxWidget: View {
    let onTrigger: () -> Void
    @State private var isOpen = false
    @State private var lidRotation: Double = 0
    @State private var gemGlow: CGFloat = 0.5
    @State private var isPressed = false
    
    // 装饰粒子
    @State private var particles: [Particle] = []
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        ZStack {
            // 背景光晕装饰
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("PrimaryWarm").opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .scaleEffect(isOpen ? 1.5 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isOpen)
            
            // 漂浮粒子
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
            
            // 底部阴影
            Ellipse()
                .fill(.black.opacity(0.3))
                .frame(width: 200, height: 40)
                .blur(radius: 20)
                .offset(y: 100)
            
            // 盒子主体 (放大 1.4 倍)
            ZStack {
                // 底座
                BoxBaseView(isOpen: isOpen, gemGlow: gemGlow)
                    .offset(y: 30)
                
                // 盒盖
                BoxLidView()
                    .rotation3DEffect(
                        .degrees(lidRotation),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.5
                    )
                    .offset(y: isOpen ? -80 : -30)
            }
            .scaleEffect(isPressed ? 1.35 : 1.4) // 整体放大
        }
        .frame(height: 360) // 增加点击区域高度
        .onTapGesture {
            performOpenAnimation()
        }
        .onAppear {
            // 宝石呼吸光效
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                gemGlow = 0.9
            }
            // 生成背景粒子
            generateParticles()
        }
        
        WidgetHint(title: "打开珠宝盒", subtitle: "珍藏今日的宝石", isDarkBackground: true)
            .offset(y: 160) // 调整提示文字位置
    }
    
    private func generateParticles() {
        for _ in 0..<15 {
            let x = CGFloat.random(in: 50...300)
            let y = CGFloat.random(in: 50...300)
            particles.append(Particle(x: x, y: y, scale: CGFloat.random(in: 0.5...1.5), opacity: Double.random(in: 0.3...0.8)))
        }
        
        // 粒子动画
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            for i in 0..<particles.count {
                particles[i].y -= 50
                particles[i].opacity = 0
            }
        }
    }
    
    private func performOpenAnimation() {
        isPressed = true
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = false
        }
        
        // 更有趣的开启动画序列
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                lidRotation = -110
                isOpen = true
            }
            
            // 开启时光效爆发
            withAnimation(.easeOut(duration: 0.5)) {
                gemGlow = 1.5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onTrigger()
            // 重置状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    lidRotation = 0
                    isOpen = false
                    gemGlow = 0.5
                }
            }
        }
    }
}

// 盒盖
private struct BoxLidView: View {
    var body: some View {
        ZStack {
            // 盒盖主体
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#3a3a3a"), Color(hex: "#2a2a2a"), Color(hex: "#1a1a1a")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 55)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            
            // Logo
            VStack(spacing: 2) {
                Text("时光格")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "#C9A55C"))
                    .tracking(4)
                
                Rectangle()
                    .fill(Color(hex: "#C9A55C").opacity(0.5))
                    .frame(width: 60, height: 0.5)
            }
            
            // 金属扣
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C9A55C"), Color(hex: "#A08040"), Color(hex: "#8B7355")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 24, height: 14)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 2)
                    .offset(y: 7)
            }
            .frame(height: 55)
        }
    }
}

// 盒底
private struct BoxBaseView: View {
    let isOpen: Bool
    let gemGlow: CGFloat
    
    var body: some View {
        ZStack {
            // 盒底外壳
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(colors: [Color(hex: "#2a2a2a"), Color(hex: "#1a1a1a")], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 180, height: 85)
                .shadow(color: .black.opacity(0.5), radius: 15, y: 10)
            
            // 天鹅绒内衬
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(colors: [Color(hex: "#2a1a2a"), Color(hex: "#1a0a1a")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 164, height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [.white.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
            
            // 记忆宝石
            if isOpen {
                MemoryGemView(glowIntensity: gemGlow)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// 记忆宝石
private struct MemoryGemView: View {
    let glowIntensity: CGFloat
    
    var body: some View {
        ZStack {
            // 光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("PrimaryWarm").opacity(glowIntensity * 0.6), Color("PrimaryWarm").opacity(0)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
            
            // 宝石形状
            GemShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FFD700"), Color("PrimaryWarm"), Color("SealColor"), Color(hex: "#8B0000")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 42)
                .shadow(color: Color("PrimaryWarm").opacity(glowIntensity), radius: 15)
            
            // 高光
            GemShape()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .center)
                )
                .frame(width: 36, height: 42)
        }
    }
}

// 宝石形状
private struct GemShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 五边形宝石
        path.move(to: CGPoint(x: w * 0.5, y: 0))           // 顶点
        path.addLine(to: CGPoint(x: w, y: h * 0.35))       // 右上
        path.addLine(to: CGPoint(x: w * 0.82, y: h))       // 右下
        path.addLine(to: CGPoint(x: w * 0.18, y: h))       // 左下
        path.addLine(to: CGPoint(x: 0, y: h * 0.35))       // 左上
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 拍立得 (V3.5 优化 - Polaroid 风格)

private struct PolaroidCameraWidget: View {
    let onTrigger: () -> Void
    @State private var isPressed = false
    @State private var flashOpacity: CGFloat = 0
    @State private var photoOffset: CGFloat = 0
    @State private var showPhoto = false
    @State private var lensScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 闪光效果
            if flashOpacity > 0 {
                Color.white
                    .opacity(flashOpacity)
                    .ignoresSafeArea()
            }
            
            // 背景装饰
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 200
                    )
                )
            
            VStack(spacing: 0) {
                // 相机主体 (放大 1.3 倍)
                ZStack {
                    CameraBodyView(lensScale: lensScale)
                        .scaleEffect(isPressed ? 1.25 : 1.3)
                    
                    // 快门按钮
                    ShutterButtonView()
                        .offset(x: 55 * 1.3, y: -75 * 1.3)
                        .scaleEffect(isPressed ? 1.1 : 1.3)
                }
                .onTapGesture {
                    takePhoto()
                }
                
                // 吐出的照片
                if showPhoto {
                    PolaroidPhotoPreview()
                        .scaleEffect(1.2)
                        .offset(y: photoOffset)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(-1)
                }
            }
        }
        .frame(height: 350)
        
        WidgetHint(title: "拍一张", subtitle: "等待今天慢慢显影")
            .offset(y: 40)
    }
    
    private func takePhoto() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        
        // 按压效果
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            isPressed = true
            lensScale = 1.05
        }
        
        // 快门声 + 震动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                lensScale = 0.95
            }
        }
        
        // 闪光
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 0.8
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                flashOpacity = 0
            }
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = false
                lensScale = 1.0
            }
        }
        
        // 照片吐出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showPhoto = true
                photoOffset = 60 // 增加偏移量
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { // 延长时间
            onTrigger()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showPhoto = false
                    photoOffset = 0
                }
            }
        }
    }
}

// 相机主体
private struct CameraBodyView: View {
    let lensScale: CGFloat
    
    var body: some View {
        ZStack {
            // 底部阴影
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.3))
                .frame(width: 190, height: 160)
                .blur(radius: 20)
                .offset(y: 15)
            
            // 相机外壳
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#f8f8f8"), Color(hex: "#e8e8e8"), Color(hex: "#d8d8d8")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 165)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
            
            // 镜头
            CameraLensView()
                .scaleEffect(lensScale)
                .offset(y: -10)
            
            // 闪光灯
            FlashLightView()
                .offset(x: 60, y: -40)
            
            // 取景器
            ViewfinderView()
                .offset(x: -60, y: -45)
            
            // 彩虹条纹
            RainbowStripeView()
                .offset(x: -50, y: 50)
            
            // 出片口
            PhotoSlotView()
                .offset(y: 82)
            
            // 品牌标志
            Text("Polaroid")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#666666"))
                .tracking(1)
                .offset(x: 30, y: 55)
        }
    }
}

// 镜头
private struct CameraLensView: View {
    var body: some View {
        ZStack {
            // 镜头外环
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#4a4a4a"), Color(hex: "#2a2a2a"), Color(hex: "#1a1a1a")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#5a5a5a"), lineWidth: 3)
                )
            
            // 镜头内环
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#5a7090"), Color(hex: "#3a5070"), Color(hex: "#1a3050"), Color(hex: "#0a1a2a")],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 55, height: 55)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#3a3a3a"), lineWidth: 2)
                )
            
            // 高光
            Circle()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .center)
                )
                .frame(width: 20, height: 20)
                .offset(x: -12, y: -12)
        }
    }
}

// 闪光灯
private struct FlashLightView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(
                LinearGradient(colors: [Color(hex: "#fafafa"), Color(hex: "#e0e0e0")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: 28, height: 28)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(hex: "#c0c0c0"), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 22, height: 22)
            )
    }
}

// 取景器
private struct ViewfinderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(colors: [Color(hex: "#2a2a2a"), Color(hex: "#1a1a1a")], startPoint: .top, endPoint: .bottom)
            )
            .frame(width: 30, height: 20)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(colors: [Color(hex: "#4a6a8a"), Color(hex: "#2a4a6a")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 22, height: 12)
            )
    }
}

// 彩虹条纹
private struct RainbowStripeView: View {
    let colors: [Color] = [
        Color(hex: "#E53935"),
        Color(hex: "#FB8C00"),
        Color(hex: "#FDD835"),
        Color(hex: "#43A047"),
        Color(hex: "#1E88E5"),
        Color(hex: "#8E24AA")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(colors.indices, id: \.self) { index in
                Rectangle()
                    .fill(colors[index])
                    .frame(width: 10, height: 10)
            }
        }
        .cornerRadius(2)
    }
}

// 出片口
private struct PhotoSlotView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(hex: "#2a2a2a"))
            .frame(width: 110, height: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: "#4a4a4a"), lineWidth: 0.5)
            )
    }
}

// 快门按钮
private struct ShutterButtonView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(colors: [Color("SealColor"), Color(hex: "#b04040")], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 35, height: 18)
                .shadow(color: Color("SealColor").opacity(0.4), radius: 4, y: 2)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .center)
                )
                .frame(width: 30, height: 8)
                .offset(y: -3)
        }
    }
}

// 拍出的照片预览
private struct PolaroidPhotoPreview: View {
    var body: some View {
        VStack(spacing: 0) {
            // 照片区域
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#f0f0e8"))
                .frame(width: 90, height: 75)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color("PrimaryWarm").opacity(0.3), Color(hex: "#e8dcd0")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(8)
                )
            
            // 白边
            Rectangle()
                .fill(Color(hex: "#f8f8f5"))
                .frame(width: 90, height: 25)
        }
        .background(Color(hex: "#f8f8f5"))
        .cornerRadius(3)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - 蜡封信封 (V3.5 优化 - 参考 HTML)

private struct WaxEnvelopeWidget: View {
    let onTrigger: () -> Void
    @State private var sealScale: CGFloat = 1.0
    @State private var envelopeRotation: Double = 0
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 24) { // 增加间距
            ZStack {
                // 背景装饰
                Circle()
                    .fill(Color("PrimaryWarm").opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                
                // 信封主体 (放大 1.3 倍)
                Group {
                    WidgetEnvelopeBodyShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#D4A574"), Color(hex: "#C49A6C"), Color(hex: "#B8906A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 286, height: 195) // 220 * 1.3, 150 * 1.3
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 12)
                        // 牛皮纸纹理
                        .overlay(
                            WidgetEnvelopeBodyShape()
                                .fill(.white.opacity(0.03))
                                .frame(width: 286, height: 195)
                        )
                    
                    // 信封三角盖子
                    WidgetEnvelopeFlapShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#C8956A"), Color(hex: "#BA8760")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 286, height: 91) // 220 * 1.3, 70 * 1.3
                        .offset(y: -52) // -40 * 1.3
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 3)
                    
                    // 蜡封印章
                    WaxSealBadge(text: "封")
                        .scaleEffect(sealScale * 1.3)
                        .offset(y: -32) // -25 * 1.3
                    
                    // 收件人信息
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(.black.opacity(0.1))
                            .frame(width: 150, height: 2)
                        Rectangle()
                            .fill(.black.opacity(0.1))
                            .frame(width: 100, height: 2)
                    }
                    .offset(y: 40)
                }
                .rotation3DEffect(.degrees(envelopeRotation), axis: (x: 1, y: 0, z: 0))
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .onTapGesture {
                performOpenAnimation()
            }
            
            WidgetHint(title: "开启信笺", subtitle: "书写今日的篇章", isDarkBackground: false)
        }
    }
    
    private func performOpenAnimation() {
        isPressed = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.spring(response: 0.3)) {
            isPressed = false
            sealScale = 1.2
        }
        
        // 更有趣的抖动开启效果
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            envelopeRotation = 3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                sealScale = 0.0 // 印章消失
                envelopeRotation = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onTrigger()
            // 重置
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                sealScale = 1.0
            }
        }
    }
}

// 信封形状 (Widget 专用，避免与 RecordDetailView 冲突)
private struct WidgetEnvelopeBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: 6)
    }
}

private struct WidgetEnvelopeFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// 蜡封徽章
private struct WaxSealBadge: View {
    let text: String
    
    var body: some View {
        ZStack {
            // 不规则边缘的蜡
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#B22222"), Color(hex: "#8B0000"), Color(hex: "#5a0000")],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 35
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    WaxEdgeShape()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#B22222"), Color(hex: "#8B0000")],
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 68, height: 68)
                )
                .shadow(color: Color(hex: "#8B0000").opacity(0.5), radius: 8, y: 4)
            
            // 内凹效果
            Circle()
                .fill(
                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 48, height: 48)
            
            // 高光
            Circle()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .center)
                )
                .frame(width: 55, height: 55)
            
            // 文字
            Text(text)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        }
    }
}

// 蜡封不规则边缘
private struct WaxEdgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 16
        let innerRadius = rect.width * 0.42
        let outerRadius = rect.width * 0.5
        
        for i in 0..<points {
            let angle = (Double(i) / Double(points)) * 2 * .pi - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius + CGFloat.random(in: -3...3)
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - 火漆印章

private struct WaxStampWidget: View {
    let onTrigger: () -> Void
    @State private var offset: CGFloat = -25
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#8B7355"), Color(hex: "#5a4a3a")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 10)
                    .overlay(
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#6a5a4a"), Color(hex: "#433529")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 70, height: 70)
                            .overlay(Text("封").font(.system(size: 26, weight: .bold)).foregroundColor(Color(hex: "#C9A55C")))
                    )
                
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Color(hex: "#5a4030"), Color(hex: "#8B6914")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 60, height: 110)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [Color(hex: "#C9A55C"), Color(hex: "#8B7355")], startPoint: .top, endPoint: .bottom))
                        .frame(width: 70, height: 14)
                }
                .offset(y: offset)
            }
            .frame(height: 160)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.12)) { offset = 35 }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { offset = -25 }
                    onTrigger()
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    offset = -20
                }
            }
            
            WidgetHint(title: "按下印章", subtitle: "封存今天的记忆", isDarkBackground: true)
        }
    }
}

// MARK: - 瑞士保险箱

private struct VaultWidget: View {
    let onTrigger: () -> Void
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color(hex: "#4a5060"), Color(hex: "#262b38")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 210, height: 210)
                    .shadow(color: .black.opacity(0.4), radius: 22, y: 12)
                
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(RadialGradient(colors: [Color(hex: "#6a7080"), Color(hex: "#3a4050")], center: .center, startRadius: 0, endRadius: 6))
                        .frame(width: 12, height: 12)
                        .position(x: index % 2 == 0 ? 25 : 185, y: index < 2 ? 25 : 185)
                }
                
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: "#C9A55C"), Color(hex: "#8B7355")], center: .topLeading, startRadius: 0, endRadius: 50))
                    .frame(width: 110, height: 110)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#4a5060"), lineWidth: 4)
                            .frame(width: 90, height: 90)
                    )
                    .rotationEffect(.degrees(rotation))
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 1.4)) {
                    rotation += 540
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    onTrigger()
                }
            }
            
            WidgetHint(title: "转动转盘", subtitle: "锁住今天的秘密", isDarkBackground: true)
        }
    }
}

// MARK: - 辅助视图

private struct WidgetHint: View {
    let title: String
    let subtitle: String
    var isDarkBackground: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDarkBackground ? .white : Color("TextPrimary"))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(isDarkBackground ? Color.white.opacity(0.7) : Color("TextSecondary"))
        }
    }
}

private struct PolygonShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.4))
            path.addLine(to: CGPoint(x: rect.width * 0.82, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.4))
            path.closeSubpath()
        }
    }
}

// MARK: - V3.6 新增 Widget

// MARK: - 打字机

private struct TypewriterWidget: View {
    let onTrigger: () -> Void
    @State private var keyPressed: Int? = nil
    @State private var paperOffset: CGFloat = 0
    @State private var typedText = "今天是..."
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 打字机主体
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color(hex: "#3a3a3a"), Color(hex: "#2a2a2a")], startPoint: .top, endPoint: .bottom))
                    .frame(width: 200, height: 140)
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
                
                // 纸张
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 180, height: 80)
                    .offset(y: paperOffset)
                    .overlay(
                        Text(typedText)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .offset(y: paperOffset)
                    )
                
                // 键盘区域
                HStack(spacing: 4) {
                    ForEach(0..<8, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(keyPressed == index ? Color(hex: "#C9A55C") : Color(hex: "#1a1a1a"))
                            .frame(width: 20, height: 12)
                    }
                }
                .offset(y: 50)
            }
            .onTapGesture {
                performTypeAnimation()
            }
            
            WidgetHint(title: "敲击键盘", subtitle: "写下今天的故事", isDarkBackground: true)
        }
    }
    
    private func performTypeAnimation() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 按键动画
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    keyPressed = i
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    keyPressed = nil
                }
            }
        }
        
        // 纸张移动
        withAnimation(.easeInOut(duration: 0.8)) {
            paperOffset = -20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onTrigger()
            withAnimation {
                paperOffset = 0
            }
        }
    }
}

// MARK: - 非洲日落

private struct SafariSunsetWidget: View {
    let onTrigger: () -> Void
    @State private var sunScale: CGFloat = 1.0
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 天空渐变
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF6B35"),
                                Color(hex: "#F7931E"),
                                Color(hex: "#1a0f0a")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 220, height: 180)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                
                // 太阳
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#FF6B35"), Color(hex: "#F7931E")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .offset(y: -30)
                    .scaleEffect(sunScale)
                
                // 地平线
                Rectangle()
                    .fill(Color(hex: "#1a0f0a"))
                    .frame(width: 220, height: 60)
                    .offset(y: 60)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onTapGesture {
                performSunsetAnimation()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    sunScale = 1.1
                }
            }
            
            WidgetHint(title: "触碰落日", subtitle: "记录今天的旅程", isDarkBackground: true)
        }
    }
    
    private func performSunsetAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) {
                isPressed = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onTrigger()
        }
    }
}

// MARK: - 南极极光

private struct AuroraGlobeWidget: View {
    let onTrigger: () -> Void
    @State private var auroraOffset: CGFloat = 0
    @State private var globeRotation: Double = 0
    @State private var isShaking = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0a0a20"), Color(hex: "#1a1a3a")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                
                // 极光效果
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#00CED1").opacity(0.6),
                                Color(hex: "#9370DB").opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 100)
                    .offset(y: -50 + auroraOffset)
                
                // 水晶球
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color(hex: "#00CED1").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#00CED1").opacity(0.5), lineWidth: 2)
                    )
                    .rotationEffect(.degrees(globeRotation))
            }
            .rotationEffect(.degrees(isShaking ? -5 : 0))
            .onTapGesture {
                shakeGlobe()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    auroraOffset = 10
                }
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    globeRotation = 360
                }
            }
            
            WidgetHint(title: "摇晃水晶球", subtitle: "让雪花封存今天", isDarkBackground: true)
        }
    }
    
    private func shakeGlobe() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            isShaking = true
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                isShaking = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onTrigger()
        }
    }
}

// MARK: - 魔法星盘

private struct AstrolabeWidget: View {
    let onTrigger: () -> Void
    @State private var rotation: Double = 0
    @State private var gemPulse: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0a0a1a"), Color(hex: "#1a1a2a")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                
                // 星盘外圈
                Circle()
                    .stroke(Color(hex: "#9370DB").opacity(0.6), lineWidth: 2)
                    .frame(width: 160, height: 160)
                
                // 星盘内圈
                Circle()
                    .stroke(Color(hex: "#9370DB").opacity(0.4), lineWidth: 1)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(rotation))
                
                // 中心宝石
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#9370DB"), Color(hex: "#6A5ACD")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(gemPulse)
                    .shadow(color: Color(hex: "#9370DB").opacity(0.8), radius: 10)
            }
            .onTapGesture {
                spinAstrolabe()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    gemPulse = 1.15
                }
            }
            
            WidgetHint(title: "转动星盘", subtitle: "探索今日的星象", isDarkBackground: true)
        }
    }
    
    private func spinAstrolabe() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            rotation += 360
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onTrigger()
        }
    }
}

// MARK: - 日式签筒

private struct OmikujiWidget: View {
    let onTrigger: () -> Void
    @State private var boxRotation: Double = 0
    @State private var stickOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFF5F5"), Color(hex: "#FFE5E5")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 180, height: 200)
                    .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                
                // 签筒
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#8B4513"), Color(hex: "#654321")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 100, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#6B4423"), lineWidth: 2)
                    )
                
                // 签
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 80, height: 20)
                    .offset(y: stickOffset)
            }
            .rotationEffect(.degrees(boxRotation))
            .onTapGesture {
                drawFortune()
            }
            
            WidgetHint(title: "抽一支签", subtitle: "看看今天的运势", isDarkBackground: false)
        }
    }
    
    private func drawFortune() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            boxRotation = 15
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) {
                boxRotation = -15
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring()) {
                boxRotation = 0
                stickOffset = -60
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onTrigger()
            withAnimation {
                stickOffset = 0
            }
        }
    }
}

// MARK: - 沙漏时光

private struct HourglassWidget: View {
    let onTrigger: () -> Void
    @State private var rotation: Double = 0
    @State private var sandFlow: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1a0f08"), Color(hex: "#2a1f18")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 180, height: 200)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                
                // 沙漏框架
                VStack(spacing: 0) {
                    // 上部分
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#3a2a1a"))
                        .frame(width: 80, height: 60)
                    
                    // 中间连接
                    Rectangle()
                        .fill(Color(hex: "#3a2a1a"))
                        .frame(width: 20, height: 20)
                    
                    // 下部分
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#3a2a1a"))
                        .frame(width: 80, height: 60)
                }
                .rotationEffect(.degrees(rotation))
                
                // 沙子
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F5A623"), Color(hex: "#D4A574")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 40 * sandFlow)
                    .offset(y: rotation == 0 ? -30 : 30)
            }
            .onTapGesture {
                flipHourglass()
            }
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                    sandFlow = 0.7
                }
            }
            
            WidgetHint(title: "翻转沙漏", subtitle: "让时间开始流动", isDarkBackground: true)
        }
    }
    
    private func flipHourglass() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            rotation = rotation == 0 ? 180 : 0
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onTrigger()
        }
    }
}

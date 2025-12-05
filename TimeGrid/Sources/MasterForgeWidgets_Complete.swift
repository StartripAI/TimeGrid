//
//  MasterForgeWidgets_Complete.swift
//  时光格 - 世界级互动风格组件完整版
//
//  包含所有13个互动风格的完整实现：
//  Part 1: 极简模式、徕卡相机、时光珠宝盒、拍立得、火漆信封
//  Part 2: 黄铜印章、记忆金库、老式打字机、日落狩猎
//  Part 3: 极光水晶球、星象仪、日式签筒、时光沙漏
//
//  设计标准：
//  - 每个组件都是博物馆级别的艺术品
//  - 参考真实顶级工艺品的材质和光影
//  - 极致的动效细节
//  - 震撼的触发时刻
//

import SwiftUI
import AudioToolbox

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - Part 1: 极简模式、徕卡相机、时光珠宝盒、拍立得、火漆信封
// MARK: - ═══════════════════════════════════════════════════════════

// MARK: - 1️⃣ 极简模式 - 禅意墨圆（参考：日本枯山水）

struct MasterSimpleWidget: View {
    let onTrigger: () -> Void
    
    @State private var breatheScale: CGFloat = 1
    @State private var innerRotation: Double = 0
    @State private var ripples: [ZenRipple] = []
    @State private var isPressed = false
    @State private var inkDrops: [InkDrop] = []
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // ═══ 墨晕层 ═══
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("PrimaryWarm").opacity(0.12 - Double(i) * 0.025),
                                    Color("PrimaryWarm").opacity(0.03),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30 + CGFloat(i) * 25,
                                endRadius: 100 + CGFloat(i) * 35
                            )
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(breatheScale + CGFloat(i) * 0.03)
                }
                
                // ═══ 涟漪 ═══
                ForEach(ripples) { ripple in
                    Circle()
                        .stroke(
                            Color("PrimaryWarm").opacity(ripple.opacity),
                            lineWidth: ripple.lineWidth
                        )
                        .frame(width: ripple.size, height: ripple.size)
                }
                
                // ═══ 墨滴飞溅 ═══
                ForEach(inkDrops) { drop in
                    Circle()
                        .fill(Color("PrimaryWarm").opacity(drop.opacity))
                        .frame(width: drop.size, height: drop.size)
                        .offset(x: drop.x, y: drop.y)
                }
                
                // ═══ 主圆 ═══
                ZStack {
                    // 外环 - 流动渐变
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color("PrimaryWarm").opacity(0.9),
                                    Color("PrimaryWarm").opacity(0.4),
                                    Color("PrimaryWarm").opacity(0.7),
                                    Color("PrimaryWarm").opacity(0.3),
                                    Color("PrimaryWarm").opacity(0.9)
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 125, height: 125)
                        .rotationEffect(.degrees(innerRotation))
                    
                    // 内圆 - 主体
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("PrimaryWarm"),
                                    Color("PrimaryWarm").opacity(0.88)
                                ],
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 115, height: 115)
                    
                    // 高光层
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.45), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 115, height: 115)
                        .mask(
                            Ellipse()
                                .frame(width: 55, height: 35)
                                .offset(x: -25, y: -30)
                        )
                    
                    // 底部阴影
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.15)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 115, height: 115)
                        .mask(
                            Ellipse()
                                .frame(width: 80, height: 30)
                                .offset(y: 35)
                        )
                    
                    // 图标
                    Image(systemName: "plus")
                        .font(.system(size: 42, weight: .light))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .scaleEffect(isPressed ? 0.88 : breatheScale)
                .shadow(color: Color("PrimaryWarm").opacity(0.35), radius: isPressed ? 10 : 25, y: isPressed ? 5 : 12)
            }
            
            // ═══ 提示文字 ═══
            VStack(spacing: 8) {
                Text("记录这一刻")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(Color("TextPrimary"))
                    .tracking(2)
                
                Text("轻触，开始书写")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerAction() }
        .onAppear {
            // 呼吸动画
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                breatheScale = 1.06
            }
            // 外环旋转
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                innerRotation = 360
            }
        }
    }
    
    private func triggerAction() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 按下
        withAnimation(.easeIn(duration: 0.08)) { isPressed = true }
        
        // 生成涟漪
        addRipples()
        
        // 墨滴飞溅
        generateInkDrops()
        
        // 回弹
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6).delay(0.1)) {
            isPressed = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onTrigger()
        }
    }
    
    private func addRipples() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                let ripple = ZenRipple(id: UUID(), size: 115, opacity: 0.7, lineWidth: 2.5 - CGFloat(i) * 0.5)
                ripples.append(ripple)
                
                withAnimation(.easeOut(duration: 0.9)) {
                    if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                        ripples[index].size = 280
                        ripples[index].opacity = 0
                        ripples[index].lineWidth = 0.5
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    ripples.removeAll { $0.id == ripple.id }
                }
            }
        }
    }
    
    private func generateInkDrops() {
        for _ in 0..<8 {
            let angle = Double.random(in: 0...360)
            let distance = CGFloat.random(in: 60...120)
            let drop = InkDrop(
                id: UUID(),
                x: cos(angle * .pi / 180) * distance,
                y: sin(angle * .pi / 180) * distance,
                size: CGFloat.random(in: 4...10),
                opacity: 0.7
            )
            inkDrops.append(drop)
            
            withAnimation(.easeOut(duration: 0.6)) {
                if let index = inkDrops.firstIndex(where: { $0.id == drop.id }) {
                    inkDrops[index].opacity = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                inkDrops.removeAll { $0.id == drop.id }
            }
        }
    }
}

struct ZenRipple: Identifiable {
    let id: UUID
    var size: CGFloat
    var opacity: Double
    var lineWidth: CGFloat
}

struct InkDrop: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

// MARK: - 2️⃣ 徕卡相机 - Leica M11-P（参考：真实徕卡M11-P）

struct MasterLeicaWidget: View {
    let onTrigger: () -> Void
    
    @State private var shutterPressed = false
    @State private var flashOpacity: Double = 0
    @State private var focusRingRotation: Double = 0
    @State private var apertureScale: CGFloat = 1
    @State private var filmAdvanceAngle: Double = 0
    @State private var viewfinderBrightness: Double = 0.2
    @State private var lensReflectionAngle: Double = 0
    @State private var shutterCurtainOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 闪光效果
            Color.white.opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                // ═══ 相机主体 ═══
                ZStack {
                    // ═══ 机身底板 ═══
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "2D2D2D"),
                                    Color(hex: "1A1A1A"),
                                    Color(hex: "0D0D0D"),
                                    Color(hex: "1A1A1A")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 290, height: 175)
                        .overlay(
                            // 磨砂质感
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.1), Color.clear, Color.white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            // 边框高光
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "4A4A4A"), Color(hex: "2A2A2A")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.6), radius: 30, y: 15)
                    
                    HStack(spacing: 28) {
                        // ═══ 左侧区域 ═══
                        VStack(spacing: 14) {
                            // 取景器
                            ZStack {
                                // 取景器外框
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black)
                                    .frame(width: 58, height: 34)
                                
                                // 取景器玻璃
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "1A3555").opacity(viewfinderBrightness + 0.6),
                                                Color(hex: "0A1828")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 28)
                                    .overlay(
                                        // 取景框线
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                            .frame(width: 38, height: 20)
                                    )
                                    .overlay(
                                        // 测光点
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                    )
                                
                                // 金属镶边
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "E8D5B7"), Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 58, height: 34)
                            }
                            
                            // Leica 标识
                            HStack(spacing: 7) {
                                // 红点
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color(hex: "FF3B30"), Color(hex: "C41E3A")],
                                            center: .topLeading,
                                            startRadius: 0,
                                            endRadius: 6
                                        )
                                    )
                                    .frame(width: 9, height: 9)
                                    .shadow(color: Color(hex: "C41E3A").opacity(0.6), radius: 4)
                                
                                Text("Leica")
                                    .font(.system(size: 11, weight: .medium, design: .serif))
                                    .foregroundColor(.white.opacity(0.55))
                                    .italic()
                            }
                        }
                        
                        // ═══ 镜头组 ═══
                        ZStack {
                            // 镜头座
                            Circle()
                                .fill(Color(hex: "0A0A0A"))
                                .frame(width: 138, height: 138)
                            
                            // 对焦环
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "1C1C1C"))
                                    .frame(width: 128, height: 128)
                                
                                // 对焦环纹理（72条精密纹理）
                                ForEach(0..<72, id: \.self) { i in
                                    Rectangle()
                                        .fill(Color(hex: "2D2D2D"))
                                        .frame(width: 1.2, height: 7)
                                        .offset(y: -60)
                                        .rotationEffect(.degrees(Double(i) * 5))
                                }
                                
                                // 对焦刻度（米/英尺）
                                ForEach([0, 45, 90, 135, 180, 225, 270, 315], id: \.self) { angle in
                                    VStack(spacing: 2) {
                                        Rectangle()
                                            .fill(Color(hex: "C9A55C"))
                                            .frame(width: 1.5, height: angle % 90 == 0 ? 8 : 5)
                                        
                                        if angle % 90 == 0 {
                                            Text(["∞", "3m", "1m", "0.7"][angle / 90])
                                                .font(.system(size: 6, weight: .medium))
                                                .foregroundColor(Color(hex: "C9A55C").opacity(0.7))
                                        }
                                    }
                                    .offset(y: -52)
                                    .rotationEffect(.degrees(Double(angle)))
                                }
                            }
                            .rotationEffect(.degrees(focusRingRotation))
                            
                            // 光圈环
                            Circle()
                                .fill(Color(hex: "111111"))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "2A2A2A"), lineWidth: 2)
                                )
                            
                            // 镜片组
                            ZStack {
                                // 镜片基底
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(hex: "1E3A5F"),
                                                Color(hex: "0F2540"),
                                                Color(hex: "050D18")
                                            ],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 42
                                        )
                                    )
                                    .frame(width: 82, height: 82)
                                
                                // 光圈叶片（10片精密光圈）
                                ForEach(0..<10, id: \.self) { i in
                                    ApertureBladeV2()
                                        .fill(Color.black.opacity(0.75))
                                        .frame(width: 40 * apertureScale, height: 40 * apertureScale)
                                        .rotationEffect(.degrees(Double(i) * 36))
                                }
                                
                                // 快门帘幕
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 60, height: 60)
                                    .offset(y: shutterCurtainOffset - 60)
                                    .mask(Circle().frame(width: 60, height: 60))
                                
                                // 多层镀膜反射
                                Circle()
                                    .fill(
                                        AngularGradient(
                                            colors: [
                                                Color.purple.opacity(0.12),
                                                Color.blue.opacity(0.08),
                                                Color.cyan.opacity(0.1),
                                                Color.green.opacity(0.06),
                                                Color.yellow.opacity(0.05),
                                                Color.purple.opacity(0.12)
                                            ],
                                            center: .center,
                                            startAngle: .degrees(lensReflectionAngle),
                                            endAngle: .degrees(lensReflectionAngle + 360)
                                        )
                                    )
                                    .frame(width: 82, height: 82)
                                
                                // 主高光
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.45), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
                                    )
                                    .frame(width: 82, height: 82)
                                    .mask(
                                        Ellipse()
                                            .frame(width: 35, height: 22)
                                            .offset(x: -20, y: -22)
                                    )
                                
                                // 次高光
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 8, height: 8)
                                    .offset(x: 25, y: 25)
                            }
                            
                            // 镜头边框
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "4A4A4A"), Color(hex: "1A1A1A"), Color(hex: "3A3A3A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 82, height: 82)
                        }
                        
                        // ═══ 右侧区域 ═══
                        VStack(spacing: 12) {
                            // 型号
                            VStack(spacing: 2) {
                                Text("M11-P")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                Text("SUMMILUX")
                                    .font(.system(size: 6, weight: .regular))
                                    .foregroundColor(.white.opacity(0.25))
                            }
                            
                            // 过片拨杆
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "5A5A5A"), Color(hex: "3A3A3A"), Color(hex: "4A4A4A")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 28, height: 10)
                                
                                // 纹理
                                HStack(spacing: 3) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 1, height: 6)
                                    }
                                }
                            }
                            .rotationEffect(.degrees(filmAdvanceAngle))
                        }
                    }
                    
                    // ═══ 快门按钮 ═══
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                // 按钮底座
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "5A5A5A"), Color(hex: "3A3A3A")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 46, height: 46)
                                
                                // 按钮主体 - 黄铜
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "F0E4C8"),
                                                Color(hex: "D4AF37"),
                                                Color(hex: "C9A55C"),
                                                Color(hex: "8B7355")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        // 同心圆纹理
                                        ForEach(0..<3, id: \.self) { i in
                                            Circle()
                                                .stroke(Color(hex: "6B5A3A").opacity(0.3), lineWidth: 0.5)
                                                .frame(width: CGFloat(28 - i * 6), height: CGFloat(28 - i * 6))
                                        }
                                    )
                                    .overlay(
                                        // 中心凹陷
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [Color(hex: "1A1A1A"), Color(hex: "2A2A2A")],
                                                    center: .center,
                                                    startRadius: 0,
                                                    endRadius: 7
                                                )
                                            )
                                            .frame(width: 14, height: 14)
                                    )
                                    .offset(y: shutterPressed ? 4 : 0)
                                    .shadow(color: .black.opacity(0.5), radius: shutterPressed ? 1 : 5, y: shutterPressed ? 1 : 4)
                            }
                            .padding(.trailing, 28)
                        }
                        .offset(y: -78)
                        Spacer()
                    }
                    
                    // ═══ 热靴 ═══
                    VStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4A4A4A"), Color(hex: "2A2A2A")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 50, height: 8)
                            .overlay(
                                HStack(spacing: 8) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color(hex: "C9A55C"))
                                            .frame(width: 8, height: 3)
                                    }
                                }
                            )
                            .offset(y: -78)
                        Spacer()
                    }
                }
                
                // ═══ 提示 ═══
                VStack(spacing: 6) {
                    Text("定格瞬间")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("按下快门")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerShutter() }
        .onAppear {
            // 对焦环缓慢转动
            withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
                focusRingRotation = 360
            }
            // 镀膜反射转动
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                lensReflectionAngle = 360
            }
            // 取景器呼吸
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                viewfinderBrightness = 0.5
            }
        }
    }
    
    private func triggerShutter() {
        // 快门音效
        AudioServicesPlaySystemSound(1108)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        // 快门按下
        withAnimation(.easeIn(duration: 0.03)) {
            shutterPressed = true
        }
        
        // 快门帘幕运动
        withAnimation(.easeIn(duration: 0.05)) {
            shutterCurtainOffset = 60
        }
        
        // 光圈收缩
        withAnimation(.easeIn(duration: 0.06)) {
            apertureScale = 0.4
        }
        
        // 闪光
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.05)) { flashOpacity = 0.95 }
            withAnimation(.easeIn(duration: 0.4).delay(0.05)) { flashOpacity = 0 }
        }
        
        // 过片拨杆
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                filmAdvanceAngle = 30
            }
        }
        
        // 复位
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
                shutterPressed = false
                apertureScale = 1
                shutterCurtainOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring()) { filmAdvanceAngle = 0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            onTrigger()
        }
    }
}

struct ApertureBladeV2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.15))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 3️⃣ 时光珠宝盒 - Cartier风格（参考：卡地亚珠宝盒）

struct MasterJewelryBoxWidget: View {
    let onTrigger: () -> Void
    
    @State private var lidAngle: Double = 0
    @State private var isOpen = false
    @State private var innerGlow: Double = 0
    @State private var diamondSparkles: [DiamondSparkle] = []
    @State private var velvetShimmer: CGFloat = 0
    @State private var hingeMoved = false
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // ═══ 环境光 ═══
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "C9A55C").opacity(innerGlow * 0.4),
                                Color(hex: "D4AF37").opacity(innerGlow * 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 180
                        )
                    )
                    .frame(width: 350, height: 180)
                    .offset(y: 60)
                    .blur(radius: 35)
                
                VStack(spacing: 0) {
                    // ═══ 盒盖 ═══
                    ZStack {
                        // 主体
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "5A3D28"),
                                        Color(hex: "3D2714"),
                                        Color(hex: "2C1810"),
                                        Color(hex: "1A0F0A")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 210, height: 58)
                        
                        // 皮革纹理
                        Canvas { context, size in
                            for _ in 0..<500 {
                                let x = Double.random(in: 0...size.width)
                                let y = Double.random(in: 0...size.height)
                                let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(Double.random(in: 0.02...0.05))))
                            }
                        }
                        .frame(width: 210, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // 金属镶边 - 双层
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "F0E4C8"), Color(hex: "D4AF37"), Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 210, height: 58)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "5A4030").opacity(0.5), lineWidth: 1)
                            .frame(width: 204, height: 52)
                        
                        // 中央装饰 - 钻石扣
                        ZStack {
                            // 底座
                            Ellipse()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "E8D5B7"), Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 36, height: 18)
                            
                            // 钻石
                            DiamondGemView()
                                .frame(width: 22, height: 22)
                        }
                    }
                    .rotation3DEffect(
                        .degrees(lidAngle),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.35
                    )
                    .zIndex(isOpen ? 0 : 1)
                    
                    // ═══ 盒身 ═══
                    ZStack {
                        // 外壳
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "3D2714"), Color(hex: "2C1810"), Color(hex: "1A0F0A")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 210, height: 95)
                        
                        // 内衬 - 丝绒
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "3D1F4D"), Color(hex: "2D1538"), Color(hex: "1A0A24")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 190, height: 75)
                            .overlay(
                                // 丝绒波纹
                                VStack(spacing: 8) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.clear, Color(hex: "5A3060").opacity(0.3), Color.clear],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(height: 2)
                                            .offset(x: velvetShimmer)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                        
                        // 钻石火彩
                        if isOpen {
                            ForEach(diamondSparkles) { sparkle in
                                SparkleStarView(size: sparkle.size)
                                    .foregroundColor(.white)
                                    .offset(x: sparkle.x, y: sparkle.y)
                                    .opacity(sparkle.opacity)
                            }
                        }
                        
                        // 金属边框
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "8B7355"), lineWidth: 2)
                            .frame(width: 210, height: 95)
                        
                        // 铰链
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                HingeView(moved: hingeMoved)
                                HingeView(moved: hingeMoved)
                            }
                            .offset(x: 8)
                        }
                        .frame(width: 210)
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: 25, y: 12)
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("珍藏记忆")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("点击开启珠宝盒")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerOpen() }
        .onAppear {
            generateSparkles()
            
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                innerGlow = 0.35
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                velvetShimmer = 40
            }
        }
    }
    
    private func generateSparkles() {
        diamondSparkles = (0..<15).map { _ in
            DiamondSparkle(
                id: UUID(),
                x: CGFloat.random(in: -80...80),
                y: CGFloat.random(in: -30...30),
                size: CGFloat.random(in: 4...10),
                opacity: Double.random(in: 0.6...1)
            )
        }
    }
    
    private func triggerOpen() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 铰链声
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            hingeMoved = true
        }
        
        // 开盖
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            lidAngle = -80
            isOpen = true
        }
        
        // 内部光芒
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            innerGlow = 0.9
        }
        
        // 火彩闪烁
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateSparkles()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            onTrigger()
        }
    }
    
    private func animateSparkles() {
        for i in 0..<diamondSparkles.count {
            withAnimation(.easeInOut(duration: 0.3).delay(Double(i) * 0.03)) {
                diamondSparkles[i].opacity = Double.random(in: 0.3...1)
            }
        }
    }
}

struct DiamondSparkle: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    var opacity: Double
}

struct DiamondGemView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 钻石切面
            ForEach(0..<8, id: \.self) { i in
                Triangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.6),
                                Color(hex: "E8E8FF").opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 10, height: 11)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            
            // 中心高光
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .blur(radius: 1)
            
            // 彩虹反射
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.red.opacity(0.1), .yellow.opacity(0.1), .green.opacity(0.1), .blue.opacity(0.1), .purple.opacity(0.1), .red.opacity(0.1)],
                        center: .center
                    )
                )
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SparkleStarView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // 水平线
            Rectangle()
                .fill(Color.white)
                .frame(width: size, height: 1)
            
            // 垂直线
            Rectangle()
                .fill(Color.white)
                .frame(width: 1, height: size)
            
            // 对角线
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(width: size * 0.7, height: 0.5)
                .rotationEffect(.degrees(45))
            
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(width: size * 0.7, height: 0.5)
                .rotationEffect(.degrees(-45))
            
            // 中心光点
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
        }
    }
}

struct HingeView: View {
    let moved: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 10, height: 14)
            
            Circle()
                .fill(Color(hex: "D4AF37"))
                .frame(width: 4, height: 4)
                .offset(y: moved ? -2 : 2)
        }
    }
}

// MARK: - 4️⃣ 拍立得 - Polaroid SX-70（参考：经典SX-70折叠机）

struct MasterPolaroidWidget: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var flashOpacity: Double = 0
    @State private var photoOffset: CGFloat = 0
    @State private var photoOpacity: Double = 0
    @State private var photoRotation: Double = 0
    @State private var rainbowHue: Double = 0
    @State private var lensGlow: Double = 0.3
    @State private var motorSound = false
    
    var body: some View {
        ZStack {
            // 闪光
            Color.white.opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                ZStack {
                    // ═══ 相机主体 ═══
                    VStack(spacing: 0) {
                        ZStack {
                            // 机身 - 白色塑料
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FFFFFF"),
                                            Color(hex: "F5F5F5"),
                                            Color(hex: "EBEBEB")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 230, height: 168)
                                .overlay(
                                    // 塑料质感
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.5), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .center
                                            )
                                        )
                                )
                                .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
                            
                            // 彩虹条纹
                            HStack(spacing: 0) {
                                ForEach(Array(["C41E3A", "FF8C00", "FFD700", "228B22", "1E90FF", "9370DB"].enumerated()), id: \.offset) { index, hex in
                                    Rectangle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 9)
                                }
                            }
                            .frame(height: 115)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: -82)
                            
                            // 闪光灯
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "E8E8E8"))
                                    .frame(width: 52, height: 30)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "FFE4B5"),
                                                Color(hex: "FFD700"),
                                                Color(hex: "FFA500")
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 42, height: 18)
                                    .opacity(flashOpacity > 0 ? 1 : 0.4)
                                    .overlay(
                                        // 闪光灯纹理
                                        HStack(spacing: 2) {
                                            ForEach(0..<8, id: \.self) { _ in
                                                Rectangle()
                                                    .fill(Color.white.opacity(0.3))
                                                    .frame(width: 1, height: 14)
                                            }
                                        }
                                    )
                            }
                            .offset(x: 58, y: -48)
                            
                            // 镜头
                            ZStack {
                                // 镜头座
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 88, height: 88)
                                
                                // 镜头环
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "3A3A3A"), Color(hex: "1A1A1A")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 78, height: 78)
                                
                                // 镜片
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(hex: "2A4A6A"),
                                                Color(hex: "1A3050"),
                                                Color(hex: "0A1828")
                                            ],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 30
                                        )
                                    )
                                    .frame(width: 58, height: 58)
                                
                                // 彩虹反射
                                Circle()
                                    .fill(
                                        AngularGradient(
                                            colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.red]
                                                .map { $0.opacity(0.12) },
                                            center: .center,
                                            startAngle: .degrees(rainbowHue),
                                            endAngle: .degrees(rainbowHue + 360)
                                        )
                                    )
                                    .frame(width: 58, height: 58)
                                
                                // 高光
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.5), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
                                    )
                                    .frame(width: 58, height: 58)
                                    .mask(
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .offset(x: -15, y: -15)
                                    )
                                
                                // 镜头光晕
                                Circle()
                                    .stroke(Color(hex: "4A90D9").opacity(lensGlow), lineWidth: 2)
                                    .frame(width: 65, height: 65)
                                    .blur(radius: 2)
                            }
                            .offset(x: 25)
                            
                            // 取景器
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                                .frame(width: 20, height: 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: "1A3050").opacity(0.5))
                                        .frame(width: 14, height: 10)
                                )
                                .offset(x: 58, y: -20)
                        }
                        
                        // ═══ 出片口 ═══
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 175, height: 14)
                            
                            // 橡胶滚轮痕迹
                            HStack(spacing: 0) {
                                ForEach(0..<30, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color(hex: "2A2A2A"))
                                        .frame(width: 2, height: 8)
                                    Rectangle()
                                        .fill(Color(hex: "1A1A1A"))
                                        .frame(width: 3, height: 8)
                                }
                            }
                            .frame(width: 165)
                            .mask(Rectangle().frame(width: 165, height: 8))
                        }
                        .offset(y: -5)
                        
                        // ═══ 照片 ═══
                        PolaroidPhotoView(
                            offset: photoOffset,
                            opacity: photoOpacity,
                            rotation: photoRotation
                        )
                        .offset(y: -10)
                    }
                    
                    // ═══ 快门按钮 ═══
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "E63946"),
                                    Color(hex: "C41E3A"),
                                    Color(hex: "8B0000")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .overlay(
                            // 高光
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .mask(
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .offset(x: -10, y: -10)
                                )
                        )
                        .scaleEffect(isPressed ? 0.88 : 1)
                        .shadow(color: Color(hex: "C41E3A").opacity(0.4), radius: isPressed ? 3 : 8)
                        .offset(y: -125)
                }
                
                // ═══ 提示 ═══
                VStack(spacing: 6) {
                    Text("显影时光")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("按下快门，等待显影")
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerCapture() }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rainbowHue = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                lensGlow = 0.6
            }
        }
    }
    
    private func triggerCapture() {
        // 快门音
        AudioServicesPlaySystemSound(1108)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 按下
        withAnimation(.easeIn(duration: 0.05)) { isPressed = true }
        
        // 闪光
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.08)) { flashOpacity = 0.95 }
            withAnimation(.easeIn(duration: 0.35).delay(0.08)) { flashOpacity = 0 }
        }
        
        // 回弹
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring()) { isPressed = false }
        }
        
        // 照片弹出（模拟马达声）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            // 马达振动
            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
                }
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                photoOffset = -100
                photoOpacity = 1
                photoRotation = Double.random(in: -8...8)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            onTrigger()
        }
    }
}

struct PolaroidPhotoView: View {
    let offset: CGFloat
    let opacity: Double
    let rotation: Double
    
    var body: some View {
        ZStack {
            // 照片白边
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white)
                .frame(width: 98, height: 118)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            
            // 照片区域
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E8DDD0"), Color(hex: "D5C8B8")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 82, height: 82)
                    .overlay(
                        // 未显影的效果
                        ZStack {
                            Color(hex: "C8B8A0").opacity(0.5)
                            
                            // 显影中的痕迹
                            ForEach(0..<3, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: "A08060").opacity(0.2))
                                    .frame(width: 70, height: 10)
                                    .offset(y: CGFloat(i - 1) * 25)
                            }
                        }
                    )
                    .padding(.top, 10)
                
                Spacer()
            }
            .frame(width: 98, height: 118)
        }
        .offset(y: offset)
        .opacity(opacity)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - 5️⃣ 火漆信封 - 维多利亚风格

struct MasterWaxEnvelopeWidget: View {
    let onTrigger: () -> Void
    
    @State private var sealScale: CGFloat = 1
    @State private var sealPressed = false
    @State private var waxDripScale: CGFloat = 0
    @State private var envelopeFlapAngle: Double = 0
    @State private var letterOffset: CGFloat = 0
    @State private var letterOpacity: Double = 0
    @State private var waxGlow: Double = 0.3
    @State private var sealRotation: Double = -8
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                // 光晕
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "8B4513").opacity(waxGlow * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 160)
                    .offset(y: 40)
                    .blur(radius: 30)
                
                // ═══ 信封组合 ═══
                ZStack {
                    // 信封底部
                    EnvelopeBodyShapeV2()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "F8F0E3"),
                                    Color(hex: "F0E4D3"),
                                    Color(hex: "E8D8C5")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 255, height: 170)
                        .overlay(
                            // 纸张纹理
                            Canvas { context, size in
                                for _ in 0..<400 {
                                    let x = Double.random(in: 0...size.width)
                                    let y = Double.random(in: 0...size.height)
                                    let rect = CGRect(x: x, y: y, width: 1.5, height: 1.5)
                                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.02)))
                                }
                            }
                            .clipShape(EnvelopeBodyShapeV2())
                        )
                        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
                    
                    // 信封内衬（露出的信纸）
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white)
                        .frame(width: 180, height: 120)
                        .overlay(
                            // 信纸线条
                            VStack(spacing: 12) {
                                ForEach(0..<6, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color(hex: "E0E0E0"))
                                        .frame(height: 1)
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                        )
                        .offset(y: letterOffset - 20)
                        .opacity(letterOpacity)
                    
                    // 信封盖
                    EnvelopeFlapShapeV2()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F0E4D3"), Color(hex: "E5D5C0")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 255, height: 100)
                        .overlay(
                            // 纹理
                            Canvas { context, size in
                                for _ in 0..<200 {
                                    let x = Double.random(in: 0...size.width)
                                    let y = Double.random(in: 0...size.height)
                                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.015)))
                                }
                            }
                            .clipShape(EnvelopeFlapShapeV2())
                        )
                        .rotation3DEffect(
                            .degrees(envelopeFlapAngle),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .bottom,
                            perspective: 0.25
                        )
                        .offset(y: -35)
                    
                    // ═══ 火漆印章 ═══
                    ZStack {
                        // 蜡滴扩散
                        Circle()
                            .fill(Color(hex: "8B0000").opacity(0.25))
                            .frame(width: 65 * waxDripScale, height: 65 * waxDripScale)
                            .blur(radius: 6)
                        
                        // 火漆主体
                        ZStack {
                            // 蜡的边缘不规则
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: "DC3545"),
                                            Color(hex: "C41E3A"),
                                            Color(hex: "8B0000"),
                                            Color(hex: "5C0000")
                                        ],
                                        center: .init(x: 0.35, y: 0.35),
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 58, height: 58)
                            
                            // 蜡的光泽
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.35), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 58, height: 58)
                                .mask(
                                    Ellipse()
                                        .frame(width: 25, height: 15)
                                        .offset(x: -12, y: -15)
                                )
                            
                            // 皇冠印记
                            Image(systemName: "crown.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "FFD700").opacity(0.75))
                                .shadow(color: Color(hex: "5C0000"), radius: 1, x: 0.5, y: 0.5)
                            
                            // 边框装饰
                            Circle()
                                .stroke(Color(hex: "5C0000").opacity(0.3), lineWidth: 2)
                                .frame(width: 50, height: 50)
                        }
                        .scaleEffect(sealScale)
                        .rotationEffect(.degrees(sealRotation))
                        .shadow(
                            color: Color(hex: "5C0000").opacity(sealPressed ? 0.3 : 0.6),
                            radius: sealPressed ? 3 : 8,
                            y: sealPressed ? 2 : 5
                        )
                    }
                    .offset(y: 55)
                }
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("封存信件")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("按压火漆印章")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerSeal() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                waxGlow = 0.6
            }
        }
    }
    
    private func triggerSeal() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        // 按压印章
        sealPressed = true
        withAnimation(.easeIn(duration: 0.1)) {
            sealScale = 0.82
            sealRotation = -5
        }
        
        // 蜡滴扩散
        withAnimation(.easeOut(duration: 0.35).delay(0.08)) {
            waxDripScale = 1.6
        }
        
        // 印章回弹
        withAnimation(.spring(response: 0.35, dampingFraction: 0.45).delay(0.15)) {
            sealScale = 1.1
            sealPressed = false
        }
        withAnimation(.spring(response: 0.25).delay(0.4)) {
            sealScale = 1
            sealRotation = -8
        }
        
        // 信封打开
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                envelopeFlapAngle = -165
            }
        }
        
        // 信纸升起
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                letterOffset = -50
                letterOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onTrigger()
        }
    }
}

struct EnvelopeBodyShapeV2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 8
        
        path.move(to: CGPoint(x: cornerRadius, y: rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.height * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.25 + cornerRadius),
            control: CGPoint(x: rect.width, y: rect.height * 0.25)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - cornerRadius),
            control: CGPoint(x: 0, y: rect.height)
        )
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.25 + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: rect.height * 0.25),
            control: CGPoint(x: 0, y: rect.height * 0.25)
        )
        path.closeSubpath()
        
        return path
    }
}

struct EnvelopeFlapShapeV2: Shape {
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
// MARK: - Part 2: 黄铜印章、记忆金库、老式打字机、日落狩猎
// MARK: - ═══════════════════════════════════════════════════════════

// MARK: - 6️⃣ 黄铜印章 - 维多利亚时代（参考：古董黄铜印章）

struct MasterWaxStampWidget: View {
    let onTrigger: () -> Void
    
    @State private var stampOffset: CGFloat = 0
    @State private var stampPressed = false
    @State private var waxPoolSize: CGFloat = 0
    @State private var imprintOpacity: Double = 0
    @State private var steamParticles: [SteamParticle] = []
    @State private var brassGlow: Double = 0.3
    @State private var handleRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                // 环境光
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "C9A55C").opacity(brassGlow * 0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 150)
                    .offset(y: 80)
                    .blur(radius: 30)
                
                // ═══ 蜡池（桌面） ═══
                ZStack {
                    // 桌面
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "5D4037"), Color(hex: "3E2723")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 140, height: 45)
                    
                    // 蜡池
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "C41E3A"),
                                    Color(hex: "8B0000"),
                                    Color(hex: "5C0000")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 55
                            )
                        )
                        .frame(width: 90 + waxPoolSize, height: 28 + waxPoolSize * 0.3)
                        .shadow(color: Color(hex: "5C0000").opacity(0.5), radius: 6)
                    
                    // 印记（盖章后显示）
                    ZStack {
                        Circle()
                            .fill(Color(hex: "6B0000"))
                            .frame(width: 65, height: 65)
                        
                        // 皇冠印记
                        Image(systemName: "crown.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "4A0000"))
                        
                        // 边框
                        Circle()
                            .stroke(Color(hex: "4A0000"), lineWidth: 2)
                            .frame(width: 55, height: 55)
                    }
                    .opacity(imprintOpacity)
                    .offset(y: -5)
                }
                .offset(y: 90)
                
                // ═══ 蒸汽粒子 ═══
                ForEach(steamParticles) { particle in
                    Circle()
                        .fill(Color.white.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .blur(radius: 2)
                }
                
                // ═══ 印章 ═══
                VStack(spacing: 0) {
                    // 手柄顶部
                    ZStack {
                        // 手柄装饰球
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "F0E4C8"),
                                        Color(hex: "D4AF37"),
                                        Color(hex: "8B7355")
                                    ],
                                    center: .init(x: 0.3, y: 0.3),
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                // 高光
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 10, height: 10)
                                    .offset(x: -8, y: -8)
                            )
                    }
                    
                    // 手柄主体
                    ZStack {
                        // 主杆
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "E8D5B7"),
                                        Color(hex: "D4AF37"),
                                        Color(hex: "B8860B"),
                                        Color(hex: "8B7355")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 28, height: 85)
                        
                        // 纹理装饰带
                        VStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { i in
                                Rectangle()
                                    .fill(Color(hex: "6B5A3A").opacity(i % 2 == 0 ? 0.3 : 0))
                                    .frame(width: 26, height: 4)
                            }
                        }
                        .frame(height: 50)
                        .offset(y: 5)
                        
                        // 金属环
                        Capsule()
                            .stroke(Color(hex: "C9A55C"), lineWidth: 2)
                            .frame(width: 30, height: 10)
                            .offset(y: -30)
                        
                        Capsule()
                            .stroke(Color(hex: "C9A55C"), lineWidth: 2)
                            .frame(width: 30, height: 10)
                            .offset(y: 30)
                    }
                    
                    // 印头
                    ZStack {
                        // 底座
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "D4AF37"),
                                        Color(hex: "B8860B"),
                                        Color(hex: "8B7355")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 75, height: 22)
                        
                        // 印面
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "8B7355"), Color(hex: "6B5A3A")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 62, height: 62)
                            
                            // 皇冠图案（凸起）
                            Image(systemName: "crown.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "D4AF37"))
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                            
                            // 边框
                            Circle()
                                .stroke(Color(hex: "D4AF37"), lineWidth: 2.5)
                                .frame(width: 55, height: 55)
                        }
                        .offset(y: 8)
                    }
                }
                .offset(y: stampPressed ? 80 : stampOffset)
                .rotationEffect(.degrees(handleRotation))
                .shadow(color: .black.opacity(0.4), radius: stampPressed ? 5 : 15, y: stampPressed ? 5 : 15)
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("加盖印记")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("按下印章")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerStamp() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                brassGlow = 0.6
            }
        }
    }
    
    private func triggerStamp() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        // 蜡池出现
        withAnimation(.easeOut(duration: 0.25)) {
            waxPoolSize = 35
        }
        
        // 印章下压并轻微旋转
        withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
            stampPressed = true
            handleRotation = -5
        }
        
        // 生成蒸汽
        generateSteam()
        
        // 印记显现
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            withAnimation(.easeOut(duration: 0.25)) {
                imprintOpacity = 1
            }
        }
        
        // 印章抬起
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                stampPressed = false
                handleRotation = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            onTrigger()
        }
    }
    
    private func generateSteam() {
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.05) {
                let particle = SteamParticle(
                    id: UUID(),
                    x: CGFloat.random(in: -25...25),
                    y: 60,
                    size: CGFloat.random(in: 8...15),
                    opacity: 0.6
                )
                steamParticles.append(particle)
                
                withAnimation(.easeOut(duration: 1.2)) {
                    if let index = steamParticles.firstIndex(where: { $0.id == particle.id }) {
                        steamParticles[index].y = -30
                        steamParticles[index].opacity = 0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    steamParticles.removeAll { $0.id == particle.id }
                }
            }
        }
    }
}

struct SteamParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

// MARK: - 7️⃣ 记忆金库 - 瑞士银行（参考：古董保险箱）

struct MasterVaultWidget: View {
    let onTrigger: () -> Void
    
    @State private var dialRotation: Double = 0
    @State private var doorOpen = false
    @State private var handleRotation: Double = 0
    @State private var lockBolts: [Bool] = [false, false, false, false]
    @State private var innerGlow: Double = 0
    @State private var clickSequence: [Double] = []
    @State private var currentClick = 0
    
    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                // 环境光
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "C9A55C").opacity(innerGlow * 0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 160)
                    .offset(y: 50)
                    .blur(radius: 30)
                
                // ═══ 金库门 ═══
                ZStack {
                    // 门板主体
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "4A4A4C"),
                                    Color(hex: "3A3A3C"),
                                    Color(hex: "2C2C2E"),
                                    Color(hex: "1C1C1E")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 195, height: 195)
                        .overlay(
                            // 金属拉丝纹理
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.clear, Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "5A5A5C"), lineWidth: 2)
                        )
                    
                    // 铆钉
                    ForEach(0..<4, id: \.self) { i in
                        VaultRivet()
                            .offset(
                                x: CGFloat(i % 2 == 0 ? -78 : 78),
                                y: CGFloat(i < 2 ? -78 : 78)
                            )
                    }
                    
                    // 锁栓
                    ForEach(0..<4, id: \.self) { i in
                        VaultBolt(extended: lockBolts[i])
                            .offset(
                                x: i % 2 == 0 ? -95 : 95,
                                y: CGFloat(i < 2 ? -40 : 40)
                            )
                    }
                    
                    // ═══ 密码盘 ═══
                    ZStack {
                        // 盘面底座
                        Circle()
                            .fill(Color(hex: "1A1A1A"))
                            .frame(width: 105, height: 105)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "D4AF37"), Color(hex: "8B7355"), Color(hex: "D4AF37")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                        
                        // 刻度盘
                        ZStack {
                            // 刻度线（100个）
                            ForEach(0..<100, id: \.self) { i in
                                Rectangle()
                                    .fill(Color(hex: i % 10 == 0 ? "C9A55C" : "6A6A6C"))
                                    .frame(width: i % 10 == 0 ? 2 : 1, height: i % 10 == 0 ? 10 : 6)
                                    .offset(y: -42)
                                    .rotationEffect(.degrees(Double(i) * 3.6))
                            }
                            
                            // 数字（每10个）
                            ForEach([0, 10, 20, 30, 40, 50, 60, 70, 80, 90], id: \.self) { num in
                                Text("\(num)")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(hex: "C9A55C"))
                                    .offset(y: -32)
                                    .rotationEffect(.degrees(Double(num) * -3.6))
                                    .rotationEffect(.degrees(Double(num) * 3.6))
                            }
                        }
                        .rotationEffect(.degrees(dialRotation))
                        
                        // 指针
                        VStack {
                            Triangle()
                                .fill(Color(hex: "C9A55C"))
                                .frame(width: 10, height: 12)
                            Spacer()
                        }
                        .frame(height: 52)
                        
                        // 中心旋钮
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "3A3A3C"), Color(hex: "2A2A2C")],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 35, height: 35)
                            .overlay(
                                // 旋钮纹理
                                ForEach(0..<8, id: \.self) { i in
                                    Rectangle()
                                        .fill(Color(hex: "1A1A1A"))
                                        .frame(width: 2, height: 8)
                                        .offset(y: -10)
                                        .rotationEffect(.degrees(Double(i) * 45))
                                }
                            )
                    }
                    .offset(y: -25)
                    
                    // ═══ 把手 ═══
                    ZStack {
                        // 把手底座
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 75, height: 18)
                        
                        // 把手球
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "E8D5B7"), Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                    center: .init(x: 0.3, y: 0.3),
                                    startRadius: 0,
                                    endRadius: 12
                                )
                            )
                            .frame(width: 22, height: 22)
                            .offset(x: 32)
                    }
                    .rotationEffect(.degrees(handleRotation))
                    .offset(y: 60)
                    
                    // 品牌标识
                    VStack(spacing: 2) {
                        Text("SWISS VAULT")
                            .font(.system(size: 7, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "C9A55C").opacity(0.6))
                        
                        Text("EST. 1892")
                            .font(.system(size: 5, weight: .medium))
                            .foregroundColor(Color(hex: "6A6A6C"))
                    }
                    .offset(y: 85)
                }
                .rotation3DEffect(
                    .degrees(doorOpen ? -85 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    perspective: 0.35
                )
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                
                // 金库内部光芒（门打开时）
                if doorOpen {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFD700").opacity(0.4),
                                    Color(hex: "C9A55C").opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 150, height: 150)
                        .offset(x: -20)
                }
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("存入金库")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("转动密码盘")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerUnlock() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                innerGlow = 0.5
            }
            clickSequence = [72, 144, 252, 360]
        }
    }
    
    private func triggerUnlock() {
        // 密码盘转动序列
        for (index, rotation) in clickSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.easeOut(duration: 0.18)) {
                    dialRotation = rotation
                }
            }
        }
        
        // 锁栓收回
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85 + Double(i) * 0.08) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.15)) {
                    lockBolts[i] = true
                }
            }
        }
        
        // 把手转动
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                handleRotation = -55
            }
        }
        
        // 门打开
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                doorOpen = true
                innerGlow = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onTrigger()
        }
    }
}

struct VaultRivet: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "4A4A4C"))
                .frame(width: 16, height: 16)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "6A6A6C"), Color(hex: "3A3A3C")],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 12, height: 12)
        }
    }
}

struct VaultBolt: View {
    let extended: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "5A5A5C"), Color(hex: "3A3A3C")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: extended ? 8 : 20, height: 25)
    }
}

// MARK: - 8️⃣ 老式打字机 - Royal Quiet Deluxe

struct MasterTypewriterWidget: View {
    let onTrigger: () -> Void
    
    @State private var keyPressed: Int? = nil
    @State private var carriagePosition: CGFloat = 55
    @State private var paperOffset: CGFloat = 0
    @State private var typedText: String = ""
    @State private var hammerStrike = false
    @State private var bellRing = false
    @State private var ribbonPosition: CGFloat = 0
    
    private let displayText = "MEMORY"
    
    var body: some View {
        VStack(spacing: 18) {
            // ═══ 打字机主体 ═══
            ZStack {
                // 机身
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "3A3A3C"),
                                Color(hex: "2C2C2E"),
                                Color(hex: "1C1C1E")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 280, height: 175)
                    .overlay(
                        // 金属质感
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                
                VStack(spacing: 14) {
                    // ═══ 纸张和打印区 ═══
                    ZStack {
                        // 纸卷架
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "2A2A2A"))
                            .frame(width: 220, height: 58)
                        
                        // 纸张
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "F8F5F0"))
                                .frame(width: 200, height: 50)
                            
                            // 已打字文本
                            HStack(spacing: 0) {
                                Text(typedText)
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                
                                // 光标
                                Rectangle()
                                    .fill(Color(hex: "1A1A1A"))
                                    .frame(width: 8, height: 2)
                                    .opacity(typedText.isEmpty ? 0 : 1)
                            }
                            .offset(x: carriagePosition - 55)
                        }
                        .offset(y: paperOffset)
                        .mask(RoundedRectangle(cornerRadius: 4).frame(width: 210, height: 50))
                        
                        // 打印头
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 12, height: 35)
                            
                            // 字锤
                            Rectangle()
                                .fill(Color(hex: "C9A55C"))
                                .frame(width: 10, height: 8)
                                .offset(y: hammerStrike ? 12 : -8)
                        }
                        .offset(x: carriagePosition, y: 2)
                        
                        // 色带
                        HStack(spacing: 180) {
                            Circle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 14, height: 14)
                            Circle()
                                .fill(Color(hex: "1A1A1A"))
                                .frame(width: 14, height: 14)
                        }
                        .offset(y: 20)
                    }
                    
                    // ═══ 键盘 ═══
                    VStack(spacing: 5) {
                        // 第一排：数字
                        HStack(spacing: 3) {
                            ForEach(Array("1234567890".enumerated()), id: \.offset) { index, char in
                                TypewriterKeyV2(
                                    label: String(char),
                                    isPressed: keyPressed == index,
                                    size: .small
                                )
                            }
                        }
                        
                        // 第二排
                        HStack(spacing: 3) {
                            ForEach(Array("QWERTYUIOP".enumerated()), id: \.offset) { index, char in
                                TypewriterKeyV2(
                                    label: String(char),
                                    isPressed: keyPressed == index + 10,
                                    size: .medium
                                )
                            }
                        }
                        
                        // 第三排
                        HStack(spacing: 3) {
                            ForEach(Array("ASDFGHJKL".enumerated()), id: \.offset) { index, char in
                                TypewriterKeyV2(
                                    label: String(char),
                                    isPressed: keyPressed == index + 20,
                                    size: .medium
                                )
                            }
                        }
                        
                        // 第四排
                        HStack(spacing: 3) {
                            ForEach(Array("ZXCVBNM".enumerated()), id: \.offset) { index, char in
                                TypewriterKeyV2(
                                    label: String(char),
                                    isPressed: keyPressed == index + 29,
                                    size: .medium
                                )
                            }
                        }
                    }
                    
                    // 空格键
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4A4A4C"), Color(hex: "3A3A3C")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 120, height: 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(hex: "5A5A5C"), lineWidth: 0.5)
                        )
                }
                
                // 品牌标识
                Text("ROYAL")
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "C9A55C").opacity(0.5))
                    .offset(y: 82)
                
                // 回车铃（右上角）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                            center: .init(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 14, height: 14)
                    .scaleEffect(bellRing ? 1.2 : 1)
                    .offset(x: 125, y: -75)
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("敲击键盘")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("开始打字")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerType() }
    }
    
    private func triggerType() {
        typedText = ""
        carriagePosition = 55
        
        for (index, char) in displayText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.12) {
                // 按键音
                AudioServicesPlaySystemSound(1104)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                // 找到按键索引
                keyPressed = findKeyIndex(for: char)
                
                // 字锤击打
                withAnimation(.easeIn(duration: 0.025)) {
                    hammerStrike = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    withAnimation(.spring(response: 0.08)) {
                        hammerStrike = false
                        typedText += String(char)
                        carriagePosition -= 11
                    }
                    keyPressed = nil
                }
            }
        }
        
        // 换行（回车）
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(displayText.count) * 0.12 + 0.2) {
            // 铃声
            AudioServicesPlaySystemSound(1057)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            withAnimation(.spring(response: 0.15)) {
                bellRing = true
            }
            
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                carriagePosition = 55
                paperOffset -= 18
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                bellRing = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(displayText.count) * 0.12 + 0.5) {
            onTrigger()
        }
    }
    
    private func findKeyIndex(for char: Character) -> Int {
        let keyboard = "1234567890QWERTYUIOPASDFGHJKLZXCVBNM"
        if let index = keyboard.firstIndex(of: char) {
            return keyboard.distance(from: keyboard.startIndex, to: index)
        }
        return 0
    }
}

struct TypewriterKeyV2: View {
    let label: String
    let isPressed: Bool
    let size: KeySize
    
    enum KeySize {
        case small, medium
        
        var width: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 22
            }
        }
        
        var height: CGFloat { 18 }
    }
    
    var body: some View {
        ZStack {
            // 键帽
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: isPressed ? "3A3A3C" : "4A4A4C"),
                            Color(hex: isPressed ? "2A2A2C" : "3A3A3C")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width, height: size.height)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "5A5A5C"), lineWidth: 0.5)
                )
            
            // 圆形标签区
            Circle()
                .fill(Color(hex: "F8F5F0"))
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "1A1A1A"))
        }
        .offset(y: isPressed ? 2 : 0)
    }
}

// MARK: - 9️⃣ 日落狩猎 - 非洲草原（参考：塞伦盖蒂日落）

struct MasterSafariWidget: View {
    let onTrigger: () -> Void
    
    @State private var sunPosition: CGFloat = 0
    @State private var skyGradientShift: Double = 0
    @State private var glowIntensity: Double = 0.5
    @State private var birdsOffset: CGFloat = -120
    @State private var cloudOffset: CGFloat = 0
    @State private var silhouetteOpacity: Double = 0.8
    
    var body: some View {
        VStack(spacing: 18) {
            // ═══ 场景 ═══
            ZStack {
                // 天空渐变
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.08 + skyGradientShift * 0.02, saturation: 0.7, brightness: 0.95),
                                Color(hue: 0.05 + skyGradientShift * 0.03, saturation: 0.85, brightness: 0.85),
                                Color(hue: 0.02 + skyGradientShift * 0.04, saturation: 0.9, brightness: 0.7),
                                Color(hue: 0.95, saturation: 0.7, brightness: 0.5),
                                Color(hue: 0.85, saturation: 0.5, brightness: 0.35)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 280, height: 200)
                
                // 云层
                ForEach(0..<3, id: \.self) { i in
                    CloudShape()
                        .fill(Color.white.opacity(0.25 - Double(i) * 0.05))
                        .frame(width: CGFloat(80 - i * 15), height: CGFloat(25 - i * 5))
                        .offset(
                            x: cloudOffset + CGFloat(i * 60 - 40),
                            y: CGFloat(-70 + i * 20)
                        )
                }
                
                // ═══ 太阳 ═══
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFD700").opacity(glowIntensity * 0.5),
                                    Color(hex: "FF8C00").opacity(glowIntensity * 0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // 太阳主体
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFFF00"),
                                    Color(hex: "FFD700"),
                                    Color(hex: "FF8C00"),
                                    Color(hex: "FF4500")
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    // 太阳光芒
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700").opacity(0.6), Color.clear],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 3, height: 25)
                            .offset(y: -55)
                            .rotationEffect(.degrees(Double(i) * 30))
                    }
                }
                .offset(y: sunPosition)
                
                // ═══ 飞鸟群 ═══
                HStack(spacing: 20) {
                    ForEach(0..<5, id: \.self) { i in
                        BirdSilhouetteV2()
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: CGFloat(15 + i % 2 * 5), height: 8)
                            .offset(y: CGFloat(i % 3 * 8 - 8))
                    }
                }
                .offset(x: birdsOffset, y: -50)
                
                // ═══ 地平线剪影 ═══
                VStack {
                    Spacer()
                    
                    ZStack {
                        // 远山
                        MountainSilhouette()
                            .fill(Color.black.opacity(silhouetteOpacity * 0.6))
                            .frame(width: 280, height: 50)
                            .offset(y: 10)
                        
                        // 金合欢树
                        HStack(spacing: 0) {
                            AcaciaTreeSilhouette()
                                .fill(Color.black.opacity(silhouetteOpacity))
                                .frame(width: 70, height: 80)
                                .offset(x: -30)
                            
                            Spacer()
                            
                            AcaciaTreeSilhouette()
                                .fill(Color.black.opacity(silhouetteOpacity * 0.8))
                                .frame(width: 50, height: 60)
                                .offset(x: 20, y: 10)
                        }
                        .frame(width: 280)
                        .offset(y: 25)
                        
                        // 草地
                        GrassSilhouette()
                            .fill(Color.black.opacity(silhouetteOpacity))
                            .frame(width: 280, height: 30)
                            .offset(y: 35)
                    }
                }
                .frame(width: 280, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .shadow(color: Color(hex: "FF6B35").opacity(0.3), radius: 20, y: 8)
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("追逐落日")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("点击，进入黄昏")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerSunset() }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowIntensity = 0.8
            }
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                cloudOffset = 50
            }
        }
    }
    
    private func triggerSunset() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 太阳下沉
        withAnimation(.easeInOut(duration: 1.2)) {
            sunPosition = 70
            skyGradientShift = 1
        }
        
        // 剪影变暗
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            silhouetteOpacity = 1
        }
        
        // 飞鸟飞过
        withAnimation(.easeInOut(duration: 1.5)) {
            birdsOffset = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onTrigger()
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.7))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.4),
            control: CGPoint(x: rect.width * 0.15, y: rect.height * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.3),
            control: CGPoint(x: rect.width * 0.45, y: rect.height * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.6),
            control: CGPoint(x: rect.width * 0.85, y: rect.height * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.7),
            control: CGPoint(x: rect.width * 0.5, y: rect.height * 0.9)
        )
        
        return path
    }
}

struct BirdSilhouetteV2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.height * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.2),
            control: CGPoint(x: rect.width * 0.25, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.6),
            control: CGPoint(x: rect.width * 0.75, y: 0)
        )
        
        return path
    }
}

struct MountainSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct AcaciaTreeSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 树干
        path.move(to: CGPoint(x: rect.width * 0.45, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.48, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.52, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height))
        
        // 树冠（伞状）
        path.move(to: CGPoint(x: rect.width * 0.05, y: rect.height * 0.35))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1),
            control: CGPoint(x: rect.width * 0.2, y: rect.height * 0.05)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.35),
            control: CGPoint(x: rect.width * 0.8, y: rect.height * 0.05)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.05, y: rect.height * 0.35),
            control: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        )
        
        return path
    }
}

struct GrassSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        var x: CGFloat = 0
        while x < rect.width {
            let grassHeight = CGFloat.random(in: 0.3...0.8)
            path.addLine(to: CGPoint(x: x + 3, y: rect.height * grassHeight))
            path.addLine(to: CGPoint(x: x + 6, y: rect.height))
            x += 6
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - Part 3: 极光水晶球、星象仪、日式签筒、时光沙漏
// MARK: - ═══════════════════════════════════════════════════════════

// MARK: - 🔟 极光水晶球 - 北欧童话（参考：芬兰玻璃工艺）

struct MasterAuroraWidget: View {
    let onTrigger: () -> Void
    
    @State private var isShaking = false
    @State private var auroraPhase: Double = 0
    @State private var snowflakes: [MasterSnowflake] = []
    @State private var showSnow = false
    @State private var glowIntensity: Double = 0.3
    @State private var globeRotationY: Double = 0
    @State private var starTwinkle: [Double] = Array(repeating: 0.5, count: 30)
    
    var body: some View {
        ZStack {
            // ═══ 外层光晕 ═══
            ZStack {
                // 主光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "00CED1").opacity(glowIntensity * 0.45),
                                Color(hex: "9370DB").opacity(glowIntensity * 0.3),
                                Color(hex: "00FF7F").opacity(glowIntensity * 0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 75,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .blur(radius: 35)
                
                // 星尘粒子
                ForEach(0..<30, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .offset(
                            x: CGFloat.random(in: -160...160),
                            y: CGFloat.random(in: -160...160)
                        )
                        .opacity(starTwinkle[i])
                }
            }
            
            VStack(spacing: 0) {
                // ═══ 水晶球 ═══
                ZStack {
                    // 球体阴影
                    Ellipse()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 140, height: 30)
                        .blur(radius: 15)
                        .offset(y: 100)
                    
                    // 球体背景 - 深邃夜空
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "1E1E3F"),
                                    Color(hex: "0F0F2A"),
                                    Color(hex: "05051A"),
                                    Color(hex: "020210")
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 95
                            )
                        )
                        .frame(width: 190, height: 190)
                    
                    // 星空层
                    Canvas { context, size in
                        for _ in 0..<60 {
                            let x = Double.random(in: 15...(size.width - 15))
                            let y = Double.random(in: 15...(size.height - 15))
                            let starSize = Double.random(in: 0.5...2.5)
                            let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(.white.opacity(Double.random(in: 0.4...0.9)))
                            )
                        }
                    }
                    .frame(width: 175, height: 175)
                    .clipShape(Circle())
                    
                    // ═══ 极光层 - 多层叠加 ═══
                    ZStack {
                        // 第一层 - 青绿
                        AuroraBand(
                            phase: auroraPhase,
                            color: Color(hex: "00CED1"),
                            yOffset: 0,
                            amplitude: 25
                        )
                        
                        // 第二层 - 紫色
                        AuroraBand(
                            phase: auroraPhase + 45,
                            color: Color(hex: "9370DB"),
                            yOffset: 15,
                            amplitude: 20
                        )
                        
                        // 第三层 - 绿色
                        AuroraBand(
                            phase: auroraPhase + 90,
                            color: Color(hex: "00FF7F"),
                            yOffset: -12,
                            amplitude: 18
                        )
                        
                        // 第四层 - 粉色
                        AuroraBand(
                            phase: auroraPhase + 135,
                            color: Color(hex: "FF69B4"),
                            yOffset: 25,
                            amplitude: 15
                        )
                    }
                    .frame(width: 165, height: 165)
                    .clipShape(Circle())
                    .blur(radius: 15)
                    
                    // ═══ 雪花层 ═══
                    if showSnow {
                        ForEach(snowflakes) { flake in
                            SnowflakeCrystal(size: flake.size)
                                .foregroundColor(.white)
                                .offset(x: flake.x, y: flake.y)
                                .opacity(flake.opacity)
                                .rotationEffect(.degrees(flake.rotation))
                        }
                        .clipShape(Circle().scale(0.9))
                    }
                    
                    // ═══ 玻璃质感 ═══
                    // 主高光
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 190, height: 190)
                        .mask(
                            Ellipse()
                                .frame(width: 90, height: 55)
                                .offset(x: -45, y: -55)
                        )
                    
                    // 次高光
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 15, height: 15)
                        .offset(x: 55, y: 55)
                        .blur(radius: 3)
                    
                    // 边缘折射
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.65),
                                    Color(hex: "00CED1").opacity(0.4),
                                    Color(hex: "9370DB").opacity(0.3),
                                    Color.white.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 190, height: 190)
                    
                    // 内圈
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 178, height: 178)
                }
                .rotation3DEffect(
                    .degrees(isShaking ? 10 : -10),
                    axis: (x: 0, y: 1, z: 0.15)
                )
                .offset(y: isShaking ? -6 : 0)
                
                // ═══ 底座 ═══
                ZStack {
                    // 金属颈部
                    ZStack {
                        // 主体
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "F0E4C8"),
                                        Color(hex: "D4AF37"),
                                        Color(hex: "C9A55C"),
                                        Color(hex: "8B7355")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 68, height: 24)
                        
                        // 装饰环
                        Ellipse()
                            .stroke(Color(hex: "E8D5B7"), lineWidth: 1.5)
                            .frame(width: 62, height: 20)
                        
                        // 宝石装饰
                        ForEach([-25, 0, 25], id: \.self) { x in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white, Color(hex: "00CED1")],
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 3
                                    )
                                )
                                .frame(width: 5, height: 5)
                                .offset(x: CGFloat(x))
                        }
                    }
                    .offset(y: -10)
                    
                    // 木质底座
                    ZStack {
                        // 主体
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "A0522D"),
                                        Color(hex: "8B4513"),
                                        Color(hex: "654321"),
                                        Color(hex: "3E2723")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 125, height: 42)
                        
                        // 木纹
                        ForEach(0..<6, id: \.self) { i in
                            Ellipse()
                                .stroke(Color(hex: "B8733F").opacity(0.25), lineWidth: 1)
                                .frame(
                                    width: CGFloat(110 - i * 16),
                                    height: CGFloat(35 - i * 5)
                                )
                        }
                        
                        // 顶部高光
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 110, height: 20)
                            .offset(y: -10)
                        
                        // 底部阴影
                        Ellipse()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 115, height: 15)
                            .offset(y: 12)
                            .blur(radius: 5)
                    }
                    .offset(y: 8)
                }
                .offset(y: -12)
            }
            .shadow(color: Color(hex: "00CED1").opacity(0.35), radius: 35, y: 12)
            
            // ═══ 提示 ═══
            VStack {
                Spacer()
                VStack(spacing: 6) {
                    Text("摇晃水晶球")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "00CED1"))
                    
                    Text("封存你的极光")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 8)
            }
        }
        .frame(height: 360)
        .contentShape(Rectangle())
        .onTapGesture { triggerShake() }
        .gesture(
            DragGesture(minimumDistance: 25)
                .onEnded { _ in triggerShake() }
        )
        .onAppear {
            generateSnowflakes()
            
            // 极光动画
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                auroraPhase = 360
            }
            
            // 光晕呼吸
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowIntensity = 0.65
            }
            
            // 星星闪烁
            for i in 0..<30 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1...3))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
                ) {
                    starTwinkle[i] = Double.random(in: 0.3...1)
                }
            }
        }
    }
    
    private func generateSnowflakes() {
        snowflakes = (0..<50).map { _ in
            MasterSnowflake(
                id: UUID(),
                x: CGFloat.random(in: -80...80),
                y: CGFloat.random(in: -80...80),
                size: CGFloat.random(in: 4...12),
                opacity: 1,
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func triggerShake() {
        // 持续振动
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
            }
        }
        
        // 摇晃
        withAnimation(.spring(response: 0.08, dampingFraction: 0.22).repeatCount(14, autoreverses: true)) {
            isShaking = true
        }
        
        // 显示雪花
        showSnow = true
        
        // 雪花下落
        for i in 0..<snowflakes.count {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 0.9...2)
            
            withAnimation(.easeIn(duration: duration).delay(delay)) {
                snowflakes[i].y = 90
                snowflakes[i].opacity = 0
                snowflakes[i].rotation += Double.random(in: 120...360)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            isShaking = false
            onTrigger()
        }
    }
}

struct MasterSnowflake: Identifiable {
    let id: UUID
    let x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    var rotation: Double
}

struct AuroraBand: View {
    let phase: Double
    let color: Color
    let yOffset: CGFloat
    let amplitude: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let y = size.height * 0.4 + yOffset + sin(phase * .pi / 180) * amplitude
            var path = Path()
            path.addEllipse(in: CGRect(
                x: size.width * 0.03,
                y: y,
                width: size.width * 0.94,
                height: size.height * 0.28
            ))
            context.fill(path, with: .color(color.opacity(0.55)))
        }
    }
}

struct SnowflakeCrystal: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // 六臂
            ForEach(0..<6, id: \.self) { i in
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1.5, height: size / 2)
                    
                    // 分支
                    HStack(spacing: size / 6) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1, height: size / 5)
                            .rotationEffect(.degrees(-45))
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1, height: size / 5)
                            .rotationEffect(.degrees(45))
                    }
                    .offset(y: -size / 4)
                }
                .rotationEffect(.degrees(Double(i) * 60))
            }
            
            // 中心
            Circle()
                .fill(Color.white)
                .frame(width: 3, height: 3)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 1️⃣1️⃣ 星象仪 - 古典天文（参考：安提基特拉机械）

struct MasterAstrolabeWidget: View {
    let onTrigger: () -> Void
    
    @State private var outerRingRotation: Double = 0
    @State private var middleRingRotation: Double = 0
    @State private var innerRingRotation: Double = 0
    @State private var pointerRotation: Double = 0
    @State private var constellationOpacity: Double = 0.25
    @State private var starPulse: Double = 0.5
    @State private var centerGlow: Double = 0.3
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                // ═══ 环境光 ═══
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "9370DB").opacity(centerGlow * 0.5),
                                Color(hex: "4B0082").opacity(centerGlow * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .blur(radius: 25)
                
                // ═══ 星空背景 ═══
                ZStack {
                    Circle()
                        .fill(Color(hex: "080818"))
                        .frame(width: 220, height: 220)
                    
                    // 星星
                    ForEach(0..<40, id: \.self) { i in
                        Circle()
                            .fill(Color.white)
                            .frame(
                                width: CGFloat.random(in: 1...3),
                                height: CGFloat.random(in: 1...3)
                            )
                            .offset(
                                x: CGFloat.random(in: -95...95),
                                y: CGFloat.random(in: -95...95)
                            )
                            .opacity(starPulse * Double.random(in: 0.5...1))
                    }
                }
                
                // ═══ 外环 - 黄道带 ═══
                ZStack {
                    // 环体
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "D4AF37"),
                                    Color(hex: "C9A55C"),
                                    Color(hex: "8B7355"),
                                    Color(hex: "C9A55C"),
                                    Color(hex: "D4AF37")
                                ],
                                center: .center
                            ),
                            lineWidth: 12
                        )
                        .frame(width: 200, height: 200)
                    
                    // 刻度 - 360度
                    ForEach(0..<72, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: i % 6 == 0 ? "1A1A1A" : "3A3A3A"))
                            .frame(width: i % 6 == 0 ? 2 : 1, height: i % 6 == 0 ? 10 : 6)
                            .offset(y: -94)
                            .rotationEffect(.degrees(Double(i) * 5))
                    }
                    
                    // 黄道符号
                    ForEach(Array(["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"].enumerated()), id: \.offset) { index, symbol in
                        Text(symbol)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .offset(y: -82)
                            .rotationEffect(.degrees(Double(index) * -30))
                            .rotationEffect(.degrees(Double(index) * 30))
                    }
                }
                .rotationEffect(.degrees(outerRingRotation))
                
                // ═══ 中环 - 时间环 ═══
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "9370DB"), Color(hex: "6B238E")],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 5
                        )
                        .frame(width: 155, height: 155)
                    
                    // 罗马数字
                    ForEach(Array(["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"].enumerated()), id: \.offset) { index, num in
                        Text(num)
                            .font(.system(size: 7, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "9370DB"))
                            .offset(y: -68)
                            .rotationEffect(.degrees(Double(index) * -30))
                            .rotationEffect(.degrees(Double(index) * 30))
                    }
                }
                .rotationEffect(.degrees(middleRingRotation))
                
                // ═══ 内环 - 星座盘 ═══
                ZStack {
                    Circle()
                        .stroke(Color(hex: "4B0082").opacity(0.5), lineWidth: 2)
                        .frame(width: 115, height: 115)
                    
                    // 星座连线
                    ConstellationLinesV2()
                        .stroke(Color(hex: "9370DB"), lineWidth: 1)
                        .frame(width: 90, height: 90)
                        .opacity(constellationOpacity)
                    
                    // 星座星点
                    ConstellationStars()
                        .frame(width: 90, height: 90)
                        .opacity(constellationOpacity)
                }
                .rotationEffect(.degrees(innerRingRotation))
                
                // ═══ 中心指针组 ═══
                ZStack {
                    // 主指针
                    VStack(spacing: 0) {
                        // 指针头
                        PointerHead()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 12, height: 18)
                        
                        // 指针杆
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 4, height: 60)
                    }
                    .offset(y: -40)
                    
                    // 中心宝石
                    ZStack {
                        // 底座
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)
                        
                        // 宝石
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "E6E6FA"),
                                        Color(hex: "9370DB"),
                                        Color(hex: "4B0082")
                                    ],
                                    center: .init(x: 0.3, y: 0.3),
                                    startRadius: 0,
                                    endRadius: 10
                                )
                            )
                            .frame(width: 18, height: 18)
                            .overlay(
                                // 高光
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 6, height: 6)
                                    .offset(x: -4, y: -4)
                            )
                    }
                    .shadow(color: Color(hex: "9370DB").opacity(centerGlow), radius: 8)
                }
                .rotationEffect(.degrees(pointerRotation))
            }
            .shadow(color: Color(hex: "4B0082").opacity(0.4), radius: 20, y: 8)
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("观测星象")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("转动星盘")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerSpin() }
        .onAppear {
            // 外环缓慢转动
            withAnimation(.linear(duration: 80).repeatForever(autoreverses: false)) {
                outerRingRotation = 360
            }
            // 中环反向
            withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) {
                middleRingRotation = -360
            }
            // 内环
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                innerRingRotation = 360
            }
            // 星星闪烁
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                starPulse = 1
            }
            // 中心光晕
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                centerGlow = 0.7
            }
        }
    }
    
    private func triggerSpin() {
        // 齿轮转动触感
        for i in 0..<12 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.06) {
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }
        
        // 指针快速旋转
        withAnimation(.easeInOut(duration: 1.8)) {
            pointerRotation += 900
        }
        
        // 星座连线亮起
        withAnimation(.easeIn(duration: 0.6).delay(0.5)) {
            constellationOpacity = 1
        }
        
        // 中心光晕增强
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            centerGlow = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onTrigger()
        }
    }
}

struct ConstellationLinesV2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 北斗七星
        let points: [CGPoint] = [
            CGPoint(x: rect.width * 0.2, y: rect.height * 0.25),
            CGPoint(x: rect.width * 0.35, y: rect.height * 0.2),
            CGPoint(x: rect.width * 0.5, y: rect.height * 0.28),
            CGPoint(x: rect.width * 0.65, y: rect.height * 0.22),
            CGPoint(x: rect.width * 0.72, y: rect.height * 0.4),
            CGPoint(x: rect.width * 0.6, y: rect.height * 0.55),
            CGPoint(x: rect.width * 0.45, y: rect.height * 0.5)
        ]
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        // 猎户座
        let orion: [CGPoint] = [
            CGPoint(x: rect.width * 0.25, y: rect.height * 0.6),
            CGPoint(x: rect.width * 0.3, y: rect.height * 0.7),
            CGPoint(x: rect.width * 0.35, y: rect.height * 0.8),
            CGPoint(x: rect.width * 0.5, y: rect.height * 0.75),
            CGPoint(x: rect.width * 0.65, y: rect.height * 0.8),
            CGPoint(x: rect.width * 0.7, y: rect.height * 0.7),
            CGPoint(x: rect.width * 0.75, y: rect.height * 0.6)
        ]
        
        path.move(to: orion[0])
        for point in orion.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

struct ConstellationStars: View {
    var body: some View {
        ZStack {
            // 星点
            ForEach(0..<12, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: CGFloat.random(in: 2...5),
                        height: CGFloat.random(in: 2...5)
                    )
                    .offset(
                        x: CGFloat.random(in: -40...40),
                        y: CGFloat.random(in: -40...40)
                    )
            }
        }
    }
}

struct PointerHead: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.7))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - 1️⃣2️⃣ 日式签筒 - 浅草寺（参考：浅草寺御神籤）

struct MasterOmikujiWidget: View {
    let onTrigger: () -> Void
    
    @State private var isShaking = false
    @State private var selectedStick: Int? = nil
    @State private var stickOffset: CGFloat = 0
    @State private var sakuraParticles: [SakuraParticle] = []
    @State private var bellSwing: Double = 0
    @State private var cylinderRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // ═══ 神社装饰 ═══
            ZStack {
                // 鈴（铃铛）
                ZStack {
                    // 绳子
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "8B0000"), Color(hex: "DC143C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 8, height: 35)
                    
                    // 铃铛
                    ZStack {
                        // 铃身
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "B8860B"), Color(hex: "8B7355")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 28)
                        
                        // 铃口
                        Ellipse()
                            .fill(Color(hex: "1A1A1A"))
                            .frame(width: 20, height: 8)
                            .offset(y: 28)
                    }
                    .offset(y: 28)
                }
                .rotationEffect(.degrees(bellSwing), anchor: .top)
                .offset(y: -30)
                
                // 鸟居
                Text("⛩️")
                    .font(.system(size: 48))
                    .offset(y: -70)
            }
            
            ZStack {
                // ═══ 樱花粒子 ═══
                ForEach(sakuraParticles) { particle in
                    Text("🌸")
                        .font(.system(size: particle.size))
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
                
                // ═══ 签筒 ═══
                ZStack {
                    // 签筒主体
                    ZStack {
                        // 筒身
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "A0522D"),
                                        Color(hex: "8B4513"),
                                        Color(hex: "654321"),
                                        Color(hex: "8B4513"),
                                        Color(hex: "A0522D")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 105, height: 175)
                        
                        // 木纹
                        VStack(spacing: 0) {
                            ForEach(0..<12, id: \.self) { i in
                                Rectangle()
                                    .fill(Color(hex: i % 2 == 0 ? "8B5A2B" : "A0522D").opacity(0.15))
                                    .frame(height: 2)
                                Spacer()
                            }
                        }
                        .frame(width: 95, height: 165)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        
                        // 金属装饰环
                        VStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 100, height: 8)
                                .offset(y: 5)
                            Spacer()
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 100, height: 8)
                                .offset(y: -5)
                        }
                        .frame(height: 175)
                    }
                    
                    // ═══ 签 ═══
                    ForEach(0..<9, id: \.self) { i in
                        OmikujiStick(
                            index: i,
                            isSelected: selectedStick == i,
                            offset: selectedStick == i ? stickOffset : 0
                        )
                        .offset(x: CGFloat(i - 4) * 9, y: -35)
                    }
                    
                    // 筒口
                    ZStack {
                        Ellipse()
                            .fill(Color(hex: "5D4037"))
                            .frame(width: 105, height: 35)
                        
                        Ellipse()
                            .fill(Color(hex: "3E2723"))
                            .frame(width: 85, height: 25)
                        
                        // 边缘高光
                        Ellipse()
                            .stroke(Color(hex: "8B7355"), lineWidth: 2)
                            .frame(width: 105, height: 35)
                    }
                    .offset(y: -75)
                    
                    // 标签
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "F5F0E8"))
                            .frame(width: 55, height: 45)
                        
                        VStack(spacing: 2) {
                            Text("御神籤")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "8B0000"))
                            
                            Text("浅草寺")
                                .font(.system(size: 8))
                                .foregroundColor(Color(hex: "654321"))
                        }
                    }
                    .offset(y: 45)
                }
                .rotationEffect(.degrees(isShaking ? 6 : -6))
                .rotation3DEffect(.degrees(cylinderRotation), axis: (x: 0, y: 1, z: 0))
                .shadow(color: .black.opacity(0.25), radius: 15, y: 10)
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("抽取运势")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("摇晃签筒")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerShake() }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { _ in triggerShake() }
        )
        .onAppear {
            generateSakura()
        }
    }
    
    private func generateSakura() {
        sakuraParticles = (0..<12).map { _ in
            SakuraParticle(
                id: UUID(),
                x: CGFloat.random(in: -130...130),
                y: CGFloat.random(in: -100...100),
                size: CGFloat.random(in: 10...18),
                opacity: 0.7,
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func triggerShake() {
        // 碰撞声音
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: CGFloat.random(in: 0.4...0.8))
            }
        }
        
        // 摇晃动画
        withAnimation(.spring(response: 0.08, dampingFraction: 0.25).repeatCount(14, autoreverses: true)) {
            isShaking = true
        }
        
        // 铃铛摇摆
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3).repeatCount(6, autoreverses: true)) {
            bellSwing = 25
        }
        
        // 筒身旋转
        withAnimation(.easeInOut(duration: 0.8)) {
            cylinderRotation = 15
        }
        
        // 樱花飘落
        for i in 0..<sakuraParticles.count {
            withAnimation(.easeIn(duration: Double.random(in: 1.5...2.5)).delay(Double.random(in: 0...0.8))) {
                sakuraParticles[i].y = 250
                sakuraParticles[i].opacity = 0
                sakuraParticles[i].rotation += Double.random(in: 180...540)
            }
        }
        
        // 选择签
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            selectedStick = Int.random(in: 0..<9)
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                stickOffset = -160
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            isShaking = false
            bellSwing = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onTrigger()
        }
    }
}

struct OmikujiStick: View {
    let index: Int
    let isSelected: Bool
    let offset: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            // 签身
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5DEB3"),
                            Color(hex: "DEB887"),
                            Color(hex: "D2B48C")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 6, height: 115)
            
            // 签头（红色）
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "8B0000"))
                    .frame(width: 6, height: 20)
            }
        }
        .offset(y: offset)
    }
}

struct SakuraParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var rotation: Double
}

// MARK: - 1️⃣3️⃣ 时光沙漏 - 文艺复兴（参考：航海时代沙漏）

struct MasterHourglassWidget: View {
    let onTrigger: () -> Void
    
    @State private var rotation: Double = 0
    @State private var topSandLevel: CGFloat = 1
    @State private var bottomSandLevel: CGFloat = 0
    @State private var sandFalling = false
    @State private var glowIntensity: Double = 0.3
    @State private var sandParticles: [SandParticle] = []
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                // ═══ 环境光 ═══
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "F5A623").opacity(glowIntensity * 0.45),
                                Color(hex: "D4AF37").opacity(glowIntensity * 0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 150)
                    .offset(y: 80)
                    .blur(radius: 30)
                
                // ═══ 沙漏主体 ═══
                ZStack {
                    // 框架 - 上横梁
                    HourglassFrame()
                    
                    // 玻璃容器
                    ZStack {
                        // 上半球
                        ZStack {
                            // 玻璃
                            HourglassGlassTop()
                                .fill(Color(hex: "E8F4F8").opacity(0.15))
                                .frame(width: 85, height: 90)
                            
                            // 沙子
                            HourglassSandTop(level: topSandLevel)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F5A623"), Color(hex: "E09100")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 75, height: 80)
                                .offset(y: 5)
                            
                            // 玻璃高光
                            HourglassGlassTop()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.35), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 85, height: 90)
                                .mask(
                                    Ellipse()
                                        .frame(width: 40, height: 30)
                                        .offset(x: -15, y: -20)
                                )
                        }
                        .offset(y: -48)
                        
                        // 细颈
                        Rectangle()
                            .fill(Color(hex: "E8F4F8").opacity(0.1))
                            .frame(width: 12, height: 20)
                        
                        // 下半球
                        ZStack {
                            // 玻璃
                            HourglassGlassBottom()
                                .fill(Color(hex: "E8F4F8").opacity(0.15))
                                .frame(width: 85, height: 90)
                            
                            // 沙子
                            HourglassSandBottom(level: bottomSandLevel)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "E09100"), Color(hex: "F5A623")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 75, height: 80)
                                .offset(y: -5)
                            
                            // 玻璃高光
                            HourglassGlassBottom()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.25), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 85, height: 90)
                                .mask(
                                    Ellipse()
                                        .frame(width: 35, height: 25)
                                        .offset(x: -15, y: 15)
                                )
                        }
                        .offset(y: 48)
                        
                        // 落沙
                        if sandFalling {
                            ForEach(sandParticles) { particle in
                                Circle()
                                    .fill(Color(hex: "F5A623"))
                                    .frame(width: particle.size, height: particle.size)
                                    .offset(x: particle.x, y: particle.y)
                                    .opacity(particle.opacity)
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(rotation))
                .shadow(color: .black.opacity(0.35), radius: 20, y: 10)
            }
            
            // ═══ 提示 ═══
            VStack(spacing: 6) {
                Text("翻转时光")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                
                Text("点击翻转")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { triggerFlip() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
    }
    
    private func triggerFlip() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 翻转
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            rotation += 180
        }
        
        // 沙子动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            sandFalling = true
            generateSandParticles()
            
            // 沙子流动
            withAnimation(.linear(duration: 1)) {
                topSandLevel = 0
                bottomSandLevel = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onTrigger()
        }
    }
    
    private func generateSandParticles() {
        for i in 0..<20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                let particle = SandParticle(
                    id: UUID(),
                    x: CGFloat.random(in: -3...3),
                    y: -10,
                    size: CGFloat.random(in: 2...4),
                    opacity: 1
                )
                sandParticles.append(particle)
                
                withAnimation(.linear(duration: 0.5)) {
                    if let index = sandParticles.firstIndex(where: { $0.id == particle.id }) {
                        sandParticles[index].y = 10
                        sandParticles[index].opacity = 0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    sandParticles.removeAll { $0.id == particle.id }
                }
            }
        }
    }
}

struct SandParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

struct HourglassFrame: View {
    var body: some View {
        ZStack {
            // 上横梁
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355"), Color(hex: "D4AF37")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 110, height: 18)
                .offset(y: -100)
            
            // 下横梁
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355"), Color(hex: "D4AF37")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 110, height: 18)
                .offset(y: 100)
            
            // 左柱
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C9A55C"), Color(hex: "8B7355"), Color(hex: "C9A55C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 12, height: 190)
                .offset(x: -52)
            
            // 右柱
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C9A55C"), Color(hex: "8B7355"), Color(hex: "C9A55C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 12, height: 190)
                .offset(x: 52)
            
            // 装饰球
            ForEach([-52, 52], id: \.self) { x in
                ForEach([-100, 100], id: \.self) { y in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "E8D5B7"), Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 14, height: 14)
                        .offset(x: CGFloat(x), y: CGFloat(y))
                }
            }
        }
    }
}

struct HourglassGlassTop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.width * 0.1, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.5, y: rect.height),
            control: CGPoint(x: rect.width * 0.95, y: rect.height * 0.7)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.1, y: 0),
            control: CGPoint(x: rect.width * 0.05, y: rect.height * 0.7)
        )
        
        return path
    }
}

struct HourglassGlassBottom: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.width * 0.5, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.9, y: rect.height),
            control: CGPoint(x: rect.width * 0.95, y: rect.height * 0.3)
        )
        path.addLine(to: CGPoint(x: rect.width * 0.1, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.5, y: 0),
            control: CGPoint(x: rect.width * 0.05, y: rect.height * 0.3)
        )
        
        return path
    }
}

struct HourglassSandTop: Shape {
    var level: CGFloat // 0-1
    
    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.height * (1 - level)
        
        guard level > 0 else { return path }
        
        path.move(to: CGPoint(x: rect.width * 0.15, y: topY))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: topY))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.5, y: rect.height),
            control: CGPoint(x: rect.width * 0.9, y: rect.height * 0.7)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.15, y: topY),
            control: CGPoint(x: rect.width * 0.1, y: rect.height * 0.7)
        )
        
        return path
    }
}

struct HourglassSandBottom: Shape {
    var level: CGFloat // 0-1
    
    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard level > 0 else { return path }
        
        let peakY = rect.height * (1 - level * 0.8)
        let baseWidth = rect.width * (0.2 + level * 0.6)
        
        path.move(to: CGPoint(x: rect.width * 0.5, y: peakY))
        path.addLine(to: CGPoint(x: rect.width * 0.5 + baseWidth / 2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.5 - baseWidth / 2, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// ✅ 所有13个世界级互动风格组件已完成！
// 文件总计：约4200+行代码
// 下一步：更新路由器以使用这些完整组件


//
//  RitualHubWidgetsV2.swift
//  时光格 - 首页仪式入口 终极版
//
//  设计理念：
//  - 每个入口都是一件艺术品
//  - 交互必须有仪式感
//  - 动效必须惊艳
//  - 音效差异化
//
//  ⚠️ 建议：用这些入口替代中间Tab，更有仪式感！
//

import SwiftUI
import AVFoundation

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 入口风格枚举（精简版 - 保留最好的6个）
// MARK: - ═══════════════════════════════════════════════════════════

enum RitualHubStyleV2: String, CaseIterable, Identifiable {
    // 精选6种最有仪式感的入口
    case auroraGlobe = "极光水晶球"
    case leicaCamera = "徕卡相机"
    case polaroidCamera = "拍立得"
    case waxEnvelope = "火漆信封"
    case astrolabe = "星象仪"
    case omikuji = "日式签筒"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .auroraGlobe: return "摇晃水晶球，封存极光"
        case .leicaCamera: return "按下快门，定格永恒"
        case .polaroidCamera: return "咔嚓一声，显影时光"
        case .waxEnvelope: return "火漆封印，郑重其事"
        case .astrolabe: return "转动星盘，预见未来"
        case .omikuji: return "抽取签文，探索命运"
        }
    }
    
    // 每种入口的专属音效文件名
    var soundFileName: String {
        switch self {
        case .auroraGlobe: return "snow_globe_shake"    // 水晶球摇晃声
        case .leicaCamera: return "camera_shutter"       // 机械快门声
        case .polaroidCamera: return "polaroid_eject"    // 拍立得弹出声
        case .waxEnvelope: return "wax_seal_press"       // 火漆印章按压声
        case .astrolabe: return "astrolabe_spin"         // 星盘转动声
        case .omikuji: return "omikuji_shake"            // 签筒摇晃声
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔊 仪式音效管理器
// MARK: - ═══════════════════════════════════════════════════════════

class RitualSoundManager: ObservableObject {
    static let shared = RitualSoundManager()
    private var player: AVAudioPlayer?
    
    func playSound(for style: RitualHubStyleV2) {
        // 尝试播放对应音效，如果找不到则播放默认音效
        if let url = Bundle.main.url(forResource: style.soundFileName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                // 播放系统触感反馈作为后备
                playHapticFeedback(for: style)
            }
        } else {
            playHapticFeedback(for: style)
        }
    }
    
    private func playHapticFeedback(for style: RitualHubStyleV2) {
        switch style {
        case .auroraGlobe:
            // 持续的柔和振动（像摇晃）
            let generator = UIImpactFeedbackGenerator(style: .soft)
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    generator.impactOccurred(intensity: 0.5 + Double(i) * 0.1)
                }
            }
        case .leicaCamera:
            // 清脆的单击（快门声）
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred(intensity: 1.0)
        case .polaroidCamera:
            // 先快门再弹出
            let shutter = UIImpactFeedbackGenerator(style: .medium)
            shutter.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let eject = UIImpactFeedbackGenerator(style: .heavy)
                eject.impactOccurred()
            }
        case .waxEnvelope:
            // 厚重的按压感
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred(intensity: 1.0)
        case .astrolabe:
            // 转动的齿轮感
            let generator = UISelectionFeedbackGenerator()
            for i in 0..<8 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    generator.selectionChanged()
                }
            }
        case .omikuji:
            // 摇签筒的碰撞声
            let generator = UIImpactFeedbackGenerator(style: .light)
            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                    generator.impactOccurred(intensity: CGFloat.random(in: 0.3...0.8))
                }
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌌 1. 极光水晶球（最惊艳）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualAuroraGlobeWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isShaking = false
    @State private var snowOpacity: Double = 0
    @State private var auroraPhase: Double = 0
    @State private var glowPulse: Bool = false
    @State private var particles: [SnowParticle] = []
    
    var body: some View {
        ZStack {
            // 深蓝夜空背景
            RadialGradient(
                colors: [Color(hex: "0B1026"), Color(hex: "1A1A2E"), Color(hex: "0D0D1A")],
                center: .center,
                startRadius: 50,
                endRadius: 250
            )
            .ignoresSafeArea()
            
            // 星星背景
            StarsBackground()
            
            VStack(spacing: 25) {
                Text("极光水晶球")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(6)
                
                // 水晶球
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "00CED1").opacity(glowPulse ? 0.5 : 0.3),
                                    Color(hex: "9370DB").opacity(glowPulse ? 0.3 : 0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 80,
                                endRadius: 150
                            )
                        )
                        .frame(width: 280, height: 280)
                        .blur(radius: 30)
                    
                    // 玻璃球体
                    ZStack {
                        // 球体底色
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "0B1026").opacity(0.9),
                                        Color(hex: "1A1A2E")
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                        
                        // 极光效果
                        AuroraEffect(phase: auroraPhase)
                            .clipShape(Circle())
                        
                        // 雪花粒子
                        ForEach(particles) { particle in
                            Circle()
                                .fill(Color.white.opacity(particle.opacity))
                                .frame(width: particle.size, height: particle.size)
                                .offset(x: particle.x, y: particle.y)
                        }
                        .opacity(snowOpacity)
                        
                        // 玻璃高光
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                            .scaleEffect(0.85)
                            .offset(x: -20, y: -25)
                        
                        // 边框
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color(hex: "00CED1").opacity(0.3),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(isShaking ? 5 : -5))
                    .offset(y: isShaking ? -5 : 0)
                    
                    // 底座
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // 金属颈部
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 30, height: 15)
                        
                        // 木质底座
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "8B5A2B"), Color(hex: "5D4037")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 100, height: 25)
                            .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                    }
                    .frame(height: 220)
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("摇晃水晶球")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "00CED1"))
                    
                    Text("封存你的极光时刻")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerShake()
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { _ in
                    triggerShake()
                }
        )
        .onAppear {
            // 初始化雪花
            particles = (0..<30).map { _ in SnowParticle() }
            
            // 极光动画
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                auroraPhase = 360
            }
            
            // 光晕脉冲
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
    
    private func triggerShake() {
        RitualSoundManager.shared.playSound(for: .auroraGlobe)
        
        // 摇晃动画
        withAnimation(.spring(response: 0.15, dampingFraction: 0.3).repeatCount(6, autoreverses: true)) {
            isShaking = true
        }
        
        // 雪花飘落
        withAnimation(.easeIn(duration: 0.3)) {
            snowOpacity = 1
        }
        
        // 更新雪花位置
        for i in 0..<particles.count {
            withAnimation(.easeInOut(duration: Double.random(in: 1.5...3)).delay(Double.random(in: 0...0.5))) {
                particles[i].y = CGFloat.random(in: 30...80)
                particles[i].x = CGFloat.random(in: -70...70)
            }
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onTrigger()
        }
    }
}

// 雪花粒子
struct SnowParticle: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: -70...70)
    var y: CGFloat = CGFloat.random(in: -80...0)
    var size: CGFloat = CGFloat.random(in: 2...5)
    var opacity: Double = Double.random(in: 0.3...0.8)
}

// 极光效果
struct AuroraEffect: View {
    let phase: Double
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            // 多层极光
            for i in 0..<3 {
                let offset = Double(i) * 120 + phase
                let path = createAuroraPath(center: center, size: size, offset: offset)
                
                let colors: [Color] = [
                    Color(hex: "00CED1").opacity(0.6),
                    Color(hex: "9370DB").opacity(0.5),
                    Color(hex: "00FF7F").opacity(0.4)
                ]
                
                context.fill(path, with: .color(colors[i % 3]))
            }
        }
        .blur(radius: 15)
    }
    
    private func createAuroraPath(center: CGPoint, size: CGSize, offset: Double) -> Path {
        var path = Path()
        let amplitude: CGFloat = 30
        let frequency: CGFloat = 3
        
        path.move(to: CGPoint(x: 0, y: center.y))
        
        for x in stride(from: 0, to: size.width, by: 5) {
            let y = center.y + sin((x / size.width * frequency + offset / 180) * .pi) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        return path
    }
}

// 星星背景
struct StarsBackground: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<100 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let starSize = Double.random(in: 0.5...2)
                let opacity = Double.random(in: 0.3...0.8)
                
                let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📷 2. 徕卡相机（经典）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualLeicaCameraWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var flashOpacity: Double = 0
    @State private var shutterOffset: CGFloat = 0
    @State private var focusRingRotation: Double = 0
    
    var body: some View {
        ZStack {
            // 深灰背景
            LinearGradient(
                colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E"), Color(hex: "1C1C1E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 闪光效果
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("徕卡 M10")
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(4)
                
                // 相机主体
                ZStack {
                    // 相机机身
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2C2C2E"), Color(hex: "1A1A1A")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 260, height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    
                    HStack(spacing: 25) {
                        // 左侧取景器
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black)
                            .frame(width: 50, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "C9A55C"), lineWidth: 1)
                            )
                        
                        // 镜头
                        ZStack {
                            // 镜头底座
                            Circle()
                                .fill(Color.black)
                                .frame(width: 110, height: 110)
                            
                            // 对焦环
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [Color(hex: "4A4A4A"), Color(hex: "2A2A2A"), Color(hex: "4A4A4A")],
                                        center: .center
                                    ),
                                    lineWidth: 12
                                )
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(focusRingRotation))
                            
                            // 镜片
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "1A2F4A"), Color(hex: "0A1525")],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 40
                                    )
                                )
                                .frame(width: 70, height: 70)
                            
                            // 镜片反光
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 70, height: 70)
                            
                            // 光圈叶片纹理
                            ForEach(0..<8, id: \.self) { i in
                                Rectangle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 1, height: 30)
                                    .offset(y: -15)
                                    .rotationEffect(.degrees(Double(i) * 45))
                            }
                        }
                        
                        // 右侧Leica标志
                        VStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: "C41E3A"))
                                .frame(width: 12, height: 12)
                            
                            Text("Leica")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // 快门按钮
                    VStack {
                        HStack {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "C9A55C"), Color(hex: "8B7355")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 35, height: 35)
                                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                                
                                Circle()
                                    .fill(Color(hex: "1A1A1A"))
                                    .frame(width: 20, height: 20)
                            }
                            .offset(y: isPressed ? 3 : 0)
                            .scaleEffect(isPressed ? 0.95 : 1)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, -70)
                        
                        Spacer()
                    }
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("按下快门")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "C9A55C"))
                    
                    Text("定格这一刻")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerShutter()
        }
        .onAppear {
            // 对焦环缓慢转动
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                focusRingRotation = 360
            }
        }
    }
    
    private func triggerShutter() {
        RitualSoundManager.shared.playSound(for: .leicaCamera)
        
        // 按下效果
        withAnimation(.easeIn(duration: 0.05)) {
            isPressed = true
        }
        
        // 闪光
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 0.8
            }
            
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                flashOpacity = 0
            }
        }
        
        // 松开
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) {
                isPressed = false
            }
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📸 3. 拍立得（怀旧）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualPolaroidCameraWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var flashOpacity: Double = 0
    @State private var photoOffset: CGFloat = 0
    @State private var photoOpacity: Double = 0
    @State private var rainbowHue: Double = 0
    
    var body: some View {
        ZStack {
            // 浅灰背景
            LinearGradient(
                colors: [Color(hex: "F0F0F0"), Color(hex: "E5E5E5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 闪光效果
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Polaroid SX-70")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "1A1A1A").opacity(0.6))
                    .tracking(2)
                
                ZStack {
                    // 相机主体
                    VStack(spacing: 0) {
                        // 上半部分
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 200, height: 140)
                                .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
                            
                            // 彩虹条纹
                            HStack(spacing: 0) {
                                ForEach(0..<6, id: \.self) { i in
                                    Rectangle()
                                        .fill(rainbowColor(index: i))
                                        .frame(width: 8)
                                }
                            }
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .offset(x: -60)
                            
                            // 镜头
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color(hex: "1A2F4A"), Color(hex: "0A1525")],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 45, height: 45)
                                
                                // 反光
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 45, height: 45)
                                    .mask(
                                        LinearGradient(
                                            colors: [Color.white, Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
                                    )
                            }
                            .offset(x: 30)
                            
                            // 闪光灯
                            Circle()
                                .fill(Color(hex: "E0E0E0"))
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(flashOpacity > 0 ? 1 : 0.5))
                                        .frame(width: 15, height: 15)
                                )
                                .offset(x: 30, y: -45)
                        }
                        
                        // 出片口
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "1A1A1A"))
                            .frame(width: 160, height: 10)
                            .overlay(
                                // 弹出的照片
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 80, height: 100)
                                    .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                                    .offset(y: photoOffset)
                                    .opacity(photoOpacity)
                            )
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
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                        .scaleEffect(isPressed ? 0.9 : 1)
                        .offset(x: 0, y: -100)
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("按下快门")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "C41E3A"))
                    
                    Text("即刻显影你的记忆")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "1A1A1A").opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerCapture()
        }
        .onAppear {
            // 彩虹动画
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                rainbowHue = 1
            }
        }
    }
    
    private func rainbowColor(index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "C41E3A"), // 红
            Color(hex: "FF8C00"), // 橙
            Color(hex: "FFD700"), // 黄
            Color(hex: "228B22"), // 绿
            Color(hex: "1E90FF"), // 蓝
            Color(hex: "9370DB")  // 紫
        ]
        return colors[index % colors.count]
    }
    
    private func triggerCapture() {
        RitualSoundManager.shared.playSound(for: .polaroidCamera)
        
        // 按下
        withAnimation(.easeIn(duration: 0.05)) {
            isPressed = true
        }
        
        // 闪光
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                flashOpacity = 0
            }
        }
        
        // 松开
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) {
                isPressed = false
            }
        }
        
        // 照片弹出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                photoOffset = -80
                photoOpacity = 1
            }
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - ✉️ 4. 火漆信封（庄重）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualWaxEnvelopeWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isPressed = false
    @State private var sealScale: CGFloat = 1
    @State private var sealRotation: Double = 0
    @State private var envelopeOpen: Bool = false
    @State private var waxDrip: CGFloat = 0
    @State private var shimmer: Double = 0
    
    var body: some View {
        ZStack {
            // 米色羊皮纸背景
            LinearGradient(
                colors: [Color(hex: "FDF8F3"), Color(hex: "E8DCC8")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("皇家诏书")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "8B4513").opacity(0.8))
                    .tracking(6)
                
                // 信封
                ZStack {
                    // 信封主体
                    ZStack {
                        // 信封底部
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 50))
                            path.addLine(to: CGPoint(x: 130, y: 0))
                            path.addLine(to: CGPoint(x: 260, y: 50))
                            path.addLine(to: CGPoint(x: 260, y: 180))
                            path.addLine(to: CGPoint(x: 0, y: 180))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F5E6D3"), Color(hex: "E8D5C4")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
                        
                        // 信封盖（三角形）
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 50))
                            path.addLine(to: CGPoint(x: 130, y: envelopeOpen ? -30 : 120))
                            path.addLine(to: CGPoint(x: 260, y: 50))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "E8D5C4"), Color(hex: "D4C4B0")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                        
                        // 内部信纸（打开时可见）
                        if envelopeOpen {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 200, height: 120)
                                .overlay(
                                    VStack(spacing: 8) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 2)
                                        }
                                    }
                                    .padding()
                                )
                                .offset(y: -20)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .frame(width: 260, height: 180)
                    
                    // 火漆印章
                    ZStack {
                        // 蜡滴流动效果
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "8B0000"), Color(hex: "5C0000")],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 35
                                )
                            )
                            .frame(width: 60 + waxDrip, height: 55 + waxDrip * 0.5)
                        
                        // 主印章
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "C41E3A"), Color(hex: "8B0000")],
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                            
                            // 印章图案
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "FFD700").opacity(0.8))
                            
                            // 光泽
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .scaleEffect(0.6)
                                .offset(x: -8, y: -8)
                        }
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(hex: "5C0000").opacity(0.5), radius: 5, y: 3)
                    }
                    .scaleEffect(sealScale)
                    .rotationEffect(.degrees(sealRotation))
                    .offset(y: 60)
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("按压火漆印章")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text("郑重封存你的心意")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513").opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerSeal()
        }
        .onAppear {
            // 印章轻微晃动
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                sealRotation = 5
            }
        }
    }
    
    private func triggerSeal() {
        RitualSoundManager.shared.playSound(for: .waxEnvelope)
        
        // 按压效果
        withAnimation(.easeIn(duration: 0.1)) {
            sealScale = 0.85
        }
        
        // 蜡滴扩散
        withAnimation(.easeOut(duration: 0.3)) {
            waxDrip = 15
        }
        
        // 回弹
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.15)) {
            sealScale = 1.1
        }
        
        withAnimation(.spring(response: 0.3).delay(0.35)) {
            sealScale = 1
        }
        
        // 信封打开
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                envelopeOpen = true
            }
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - ⭐ 5. 星象仪（神秘）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualAstrolabeWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var outerRingRotation: Double = 0
    @State private var innerRingRotation: Double = 0
    @State private var starPulse: Bool = false
    @State private var isActivated = false
    @State private var constellationOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // 深蓝夜空背景
            RadialGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "0B1026"), Color(hex: "050510")],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            // 星星背景
            StarsBackground()
            
            VStack(spacing: 25) {
                Text("星象仪")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "9370DB").opacity(0.8))
                    .tracking(6)
                
                // 星盘
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "9370DB").opacity(starPulse ? 0.4 : 0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 80,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)
                        .blur(radius: 20)
                    
                    // 外环
                    ZStack {
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [Color(hex: "C9A55C"), Color(hex: "8B7355"), Color(hex: "C9A55C")],
                                    center: .center
                                ),
                                lineWidth: 8
                            )
                        
                        // 刻度
                        ForEach(0..<12, id: \.self) { i in
                            VStack {
                                Rectangle()
                                    .fill(Color(hex: "C9A55C"))
                                    .frame(width: 2, height: 12)
                                Spacer()
                            }
                            .rotationEffect(.degrees(Double(i) * 30))
                        }
                    }
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(outerRingRotation))
                    
                    // 内环
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "9370DB").opacity(0.5), lineWidth: 2)
                        
                        // 星座连线
                        Path { path in
                            path.move(to: CGPoint(x: 60, y: 30))
                            path.addLine(to: CGPoint(x: 80, y: 50))
                            path.addLine(to: CGPoint(x: 70, y: 80))
                            path.addLine(to: CGPoint(x: 90, y: 110))
                            path.addLine(to: CGPoint(x: 60, y: 100))
                        }
                        .stroke(Color(hex: "00CED1").opacity(constellationOpacity), lineWidth: 1)
                        
                        // 星点
                        ForEach(0..<7, id: \.self) { i in
                            Circle()
                                .fill(Color.white)
                                .frame(width: starPulse ? 6 : 4, height: starPulse ? 6 : 4)
                                .shadow(color: Color(hex: "00CED1"), radius: starPulse ? 8 : 4)
                                .offset(
                                    x: CGFloat.random(in: -50...50),
                                    y: CGFloat.random(in: -50...50)
                                )
                        }
                    }
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(innerRingRotation))
                    
                    // 中心指针
                    ZStack {
                        Circle()
                            .fill(Color(hex: "C9A55C"))
                            .frame(width: 20, height: 20)
                        
                        Path { path in
                            path.move(to: CGPoint(x: 10, y: 10))
                            path.addLine(to: CGPoint(x: 10, y: -50))
                        }
                        .stroke(Color(hex: "C9A55C"), lineWidth: 2)
                    }
                    .rotationEffect(.degrees(isActivated ? 720 : 0))
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("转动星盘")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "9370DB"))
                    
                    Text("预见你的命运")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerSpin()
        }
        .onAppear {
            // 缓慢旋转
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                outerRingRotation = 360
            }
            withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
                innerRingRotation = -360
            }
            // 星星脉冲
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                starPulse = true
            }
        }
    }
    
    private func triggerSpin() {
        RitualSoundManager.shared.playSound(for: .astrolabe)
        
        // 快速旋转
        withAnimation(.easeInOut(duration: 2)) {
            isActivated = true
        }
        
        // 星座连线亮起
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            constellationOpacity = 1
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎋 6. 日式签筒（禅意）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualOmikujiWidgetV2: View {
    let onTrigger: () -> Void
    
    @State private var isShaking = false
    @State private var stickOffset: CGFloat = 0
    @State private var stickOpacity: Double = 0
    @State private var selectedStick: Int = 0
    
    var body: some View {
        ZStack {
            // 和风背景
            LinearGradient(
                colors: [Color(hex: "FDF8F3"), Color(hex: "F5E6D3")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 樱花装饰
            ForEach(0..<8, id: \.self) { i in
                Text("🌸")
                    .font(.system(size: 20))
                    .opacity(0.3)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
            }
            
            VStack(spacing: 30) {
                // 神社鸟居
                HStack(spacing: 0) {
                    Text("⛩️")
                        .font(.system(size: 40))
                }
                
                Text("浅草寺 おみくじ")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "8B4513").opacity(0.8))
                    .tracking(4)
                
                // 签筒
                ZStack {
                    // 签筒主体
                    ZStack {
                        // 筒身
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "8B5A2B"), Color(hex: "654321")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 100, height: 180)
                        
                        // 木纹
                        ForEach(0..<5, id: \.self) { i in
                            Path { path in
                                path.move(to: CGPoint(x: -40, y: CGFloat(i) * 40 - 80))
                                path.addQuadCurve(
                                    to: CGPoint(x: 40, y: CGFloat(i) * 40 - 80),
                                    control: CGPoint(x: 0, y: CGFloat(i) * 40 - 70)
                                )
                            }
                            .stroke(Color(hex: "5D4037").opacity(0.3), lineWidth: 2)
                        }
                        
                        // 签（竹棒）
                        ForEach(0..<8, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F5DEB3"), Color(hex: "DEB887")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 6, height: 120)
                                .offset(
                                    x: CGFloat(i - 4) * 8,
                                    y: (i == selectedStick && stickOpacity > 0) ? stickOffset : -30
                                )
                                .opacity(i == selectedStick ? stickOpacity : 1)
                        }
                        
                        // 筒口装饰
                        Ellipse()
                            .fill(Color(hex: "5D4037"))
                            .frame(width: 100, height: 30)
                            .offset(y: -75)
                    }
                    .rotationEffect(.degrees(isShaking ? 5 : -5))
                }
                
                // 提示文字
                VStack(spacing: 8) {
                    Text("摇晃签筒")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text("探索今日运势")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513").opacity(0.5))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            triggerShake()
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { _ in
                    triggerShake()
                }
        )
    }
    
    private func triggerShake() {
        RitualSoundManager.shared.playSound(for: .omikuji)
        
        // 随机选择一根签
        selectedStick = Int.random(in: 0..<8)
        
        // 摇晃动画
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3).repeatCount(10, autoreverses: true)) {
            isShaking = true
        }
        
        // 签飞出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                stickOffset = -150
                stickOpacity = 1
            }
        }
        
        // 停止摇晃
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShaking = false
        }
        
        // 触发回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onTrigger()
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 入口容器（根据风格显示对应组件）
// MARK: - ═══════════════════════════════════════════════════════════

struct RitualHubContainerV2: View {
    let style: RitualHubStyleV2
    let onTrigger: () -> Void
    
    var body: some View {
        switch style {
        case .auroraGlobe:
            RitualAuroraGlobeWidgetV2(onTrigger: onTrigger)
        case .leicaCamera:
            RitualLeicaCameraWidgetV2(onTrigger: onTrigger)
        case .polaroidCamera:
            RitualPolaroidCameraWidgetV2(onTrigger: onTrigger)
        case .waxEnvelope:
            RitualWaxEnvelopeWidgetV2(onTrigger: onTrigger)
        case .astrolabe:
            RitualAstrolabeWidgetV2(onTrigger: onTrigger)
        case .omikuji:
            RitualOmikujiWidgetV2(onTrigger: onTrigger)
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 预览（已移除，避免与 ForgeHubWidgetsV2.swift 中的组件冲突）
// MARK: - ═══════════════════════════════════════════════════════════
// 
// 注意：这些组件的 Preview 已在 ForgeHubWidgetsV2.swift 中定义
// 如需预览，请使用 ForgeHubWidgetsV2.swift 中的组件


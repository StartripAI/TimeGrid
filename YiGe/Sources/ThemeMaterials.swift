import SwiftUI
import UIKit // 需要 UIKit 来实现 View 到 UIImage 的转换
import Foundation // 需要 Foundation 来使用 srand48/drand48

// MARK: - 🎨 六大工坊背景系统 V9.0 - 顶级设计师版
// 设计原则：
// 1. 克制 - 奢侈品从不堆砌，少即是多
// 2. 动态 - 微妙的光影流动，不是花哨的动画
// 3. 质感 - 每个像素都要有材质感
// 4. 留白 - 空间感是奢华的关键

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 1. THE EQUESTRIAN - 皮具工坊
// MARK: 灵感：爱马仕橙盒的仪式感、LV硬箱的旅行精神、皮革的油润光泽
// MARK: ═══════════════════════════════════════════════════════
struct EquestrianBackground: View {
    @State private var sheenOffset: CGFloat = -300
    @State private var claspGlow: Bool = false
    
    var body: some View {
        ZStack {
            // 深棕皮革基底 - 带温暖色调
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "1A0F08"), location: 0),
                    .init(color: Color(hex: "2D1A10"), location: 0.3),
                    .init(color: Color(hex: "3D2518"), location: 0.5),
                    .init(color: Color(hex: "2D1A10"), location: 0.7),
                    .init(color: Color(hex: "1A0F08"), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 皮革纹理 - 细腻的Saffiano十字纹
            LeatherTextureView()
            
            // 流动的金色光泽 - 模拟皮革油润感
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.4),
                            .init(color: Color(hex: "D4AF37").opacity(0.08), location: 0.45),
                            .init(color: Color(hex: "D4AF37").opacity(0.15), location: 0.5),
                            .init(color: Color(hex: "D4AF37").opacity(0.08), location: 0.55),
                            .init(color: .clear, location: 0.6),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: sheenOffset, y: sheenOffset)
                .rotationEffect(.degrees(45))
            
            // 精致缝线 - 马鞍针法
            HStack {
                StitchingLine()
                    .padding(.leading, 40)
                Spacer()
                StitchingLine()
                    .padding(.trailing, 40)
            }
            
            // 金属扣件 - 居中的黄铜圆环
            BrassClaspView(isGlowing: claspGlow)
        }
        .ignoresSafeArea()
        .onAppear {
            // 光泽流动动画
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                sheenOffset = 300
            }
            // 扣件呼吸光
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                claspGlow = true
            }
        }
    }
}

/// 皮革纹理层
struct LeatherTextureView: View {
    var body: some View {
        Canvas { context, size in
            // Saffiano十字压纹效果 - 比噪点更优雅
            let gridSize: CGFloat = 3
            for x in stride(from: 0, to: size.width, by: gridSize) {
                for y in stride(from: 0, to: size.height, by: gridSize) {
                    let opacity = Double.random(in: 0.02...0.06)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(rect), with: .color(.white.opacity(opacity)))
                }
            }
        }
        .blendMode(.overlay)
    }
}

/// 缝线
struct StitchingLine: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 16
                for y in stride(from: 0, to: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: 0, y: y + 8))
                }
            }
            .stroke(Color(hex: "D4AF37").opacity(0.4), lineWidth: 1)
        }
        .frame(width: 1)
    }
}

/// 黄铜扣件
struct BrassClaspView: View {
    let isGlowing: Bool
    
    var body: some View {
        ZStack {
            // 外圈
            Circle()
                .stroke(Color(hex: "D4AF37").opacity(0.3), lineWidth: 2)
                .frame(width: 60, height: 60)
            
            // 内圈
            Circle()
                .stroke(Color(hex: "D4AF37").opacity(0.2), lineWidth: 1)
                .frame(width: 44, height: 44)
            
            // 中心点
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "D4AF37").opacity(0.6),
                            Color(hex: "D4AF37").opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 8, height: 8)
        }
        .shadow(color: Color(hex: "D4AF37").opacity(isGlowing ? 0.3 : 0.1), radius: isGlowing ? 30 : 15)
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 2. THE CHRONOGRAPH - 机械工坊
// MARK: 灵感：百达翡丽蓝盘Nautilus、理查德米勒镂空机芯、日内瓦波纹
// MARK: ═══════════════════════════════════════════════════════
struct ChronographBackground: View {
    @State private var secondRotation: Double = 0
    @State private var gearRotation: Double = 0
    @State private var balanceAngle: Double = -15
    
    var body: some View {
        ZStack {
            // 深海蓝基底 - Nautilus Blue
            RadialGradient(
                colors: [
                    Color(hex: "1a2a4a"),
                    Color(hex: "0d1a30"),
                    Color(hex: "050a14")
                ],
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
            
            // 日内瓦波纹
            GenevaStripesView()
            
            // 大齿轮 - 缓慢旋转
            GearView(size: 180, opacity: 0.15)
                .rotationEffect(.degrees(gearRotation))
            
            // 小齿轮 - 反向旋转
            GearView(size: 80, opacity: 0.12)
                .offset(x: 80, y: -120)
                .rotationEffect(.degrees(-gearRotation * 2))
            
            // 微型齿轮
            GearView(size: 50, opacity: 0.1)
                .offset(x: -70, y: 100)
                .rotationEffect(.degrees(gearRotation * 3))
            
            // 摆轮 - 来回摆动
            Circle()
                .stroke(Color(hex: "C0C0C0").opacity(0.2), lineWidth: 1)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(balanceAngle))
                .offset(x: 60, y: 80)
            
            // 秒针
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C0C0C0").opacity(0.8), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 1, height: 70)
                .offset(y: -35)
                .rotationEffect(.degrees(secondRotation))
            
            // 中心轴
            Circle()
                .fill(Color(hex: "C0C0C0"))
                .frame(width: 8, height: 8)
                .shadow(color: Color(hex: "C0C0C0").opacity(0.5), radius: 10)
        }
        .ignoresSafeArea()
        .onAppear {
            // 秒针转动 - 60秒一圈
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                secondRotation = 360
            }
            // 齿轮缓慢旋转
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                gearRotation = 360
            }
            // 摆轮摆动
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                balanceAngle = 15
            }
        }
    }
}

/// 日内瓦波纹
struct GenevaStripesView: View {
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 6) {
                ForEach(0..<Int(geo.size.height / 8), id: \.self) { _ in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.015),
                                    Color.white.opacity(0.03),
                                    Color.white.opacity(0.015)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                }
            }
        }
    }
}

/// 齿轮视图
struct GearView: View {
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            // 外圈
            Circle()
                .stroke(Color(hex: "C0C0C0").opacity(opacity), lineWidth: 1)
                .frame(width: size, height: size)
            
            // 内圈虚线
            Circle()
                .stroke(
                    Color(hex: "C0C0C0").opacity(opacity * 0.6),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 4])
                )
                .frame(width: size * 0.8, height: size * 0.8)
            
            // 刻度线
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "C0C0C0").opacity(opacity),
                                .clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 1, height: size * 0.35)
                    .offset(y: -size * 0.25)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 3. THE GEMSTONE - 珠宝工坊
// MARK: 灵感：佳士得拍卖行的聚光灯、格拉夫钻石的火彩、丝绒展台
// MARK: ═══════════════════════════════════════════════════════
struct GemstoneBackground: View {
    @State private var spotlightPulse: Bool = false
    
    var body: some View {
        ZStack {
            // 皇室紫基底
            LinearGradient(
                colors: [
                    Color(hex: "0A0512"),
                    Color(hex: "150D1F"),
                    Color(hex: "1F1430"),
                    Color(hex: "150D1F"),
                    Color(hex: "0A0512")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 丝绒质感
            VelvetTextureView()
            
            // 聚光灯 - 从上方打下
            EllipticalGradient(
                colors: [
                    Color(hex: "E5E4E2").opacity(0.15),
                    Color(hex: "E5E4E2").opacity(0.05),
                    .clear
                ],
                center: .top,
                startRadiusFraction: 0,
                endRadiusFraction: 0.8
            )
            .scaleEffect(spotlightPulse ? 1.05 : 1)
            .opacity(spotlightPulse ? 1 : 0.8)
            
            // 钻石切面
            DiamondFacetsView()
                .offset(y: -30)
            
            // 火彩闪烁点
            ForEach(0..<8, id: \.self) { i in
                FireSparkle()
                    .position(
                        x: CGFloat.random(in: 80...280),
                        y: CGFloat.random(in: 150...400)
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                spotlightPulse = true
            }
        }
    }
}

/// 丝绒质感
struct VelvetTextureView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height / 50) {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0.01...0.03)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.white.opacity(opacity)))
            }
        }
    }
}

/// 钻石切面
struct DiamondFacetsView: View {
    @State private var facetOpacity: [Double] = [0.3, 0.5, 0.4]
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                DiamondFacet()
                    .frame(width: CGFloat(60 - i * 15), height: CGFloat(60 - i * 15))
                    .opacity(facetOpacity[i])
                    .offset(x: CGFloat(i * 5), y: CGFloat(i * 5))
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.5)
                ) {
                    facetOpacity[i] = Double.random(in: 0.7...1)
                }
            }
        }
    }
}

struct DiamondFacet: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 30, y: 0))
            path.addLine(to: CGPoint(x: 60, y: 30))
            path.addLine(to: CGPoint(x: 30, y: 60))
            path.addLine(to: CGPoint(x: 0, y: 30))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [.white.opacity(0.9), .white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

/// 火彩闪烁
struct FireSparkle: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 3, height: 3)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.5...3))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
                ) {
                    opacity = 1
                    scale = 1
                }
            }
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 4. THE FORMULA - 赛道工坊
// MARK: 灵感：F1摩纳哥夜赛、法拉利红、碳纤维座舱、起跑灯
// MARK: ═══════════════════════════════════════════════════════
struct FormulaBackground: View {
    @State private var lightsOn: [Bool] = [false, false, false, false, false]
    @State private var heatPulse: Bool = false
    
    var body: some View {
        ZStack {
            // 碳纤维黑
            Color(hex: "0A0A0A")
            
            // 碳纤维编织纹理
            CarbonWeaveView()
            
            // 起跑灯
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(lightsOn[i] ? Color(hex: "E10600") : Color(hex: "1A1A1A"))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "333333"), lineWidth: 2)
                        )
                        .shadow(
                            color: lightsOn[i] ? Color(hex: "E10600").opacity(0.8) : .clear,
                            radius: 15
                        )
                }
            }
            .offset(y: -180)
            
            // 速度线
            ForEach(0..<4, id: \.self) { i in
                SpeedLine(delay: Double(i) * 0.2)
                    .offset(y: CGFloat(i - 2) * 50)
            }
            
            // 底部热浪
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "E10600").opacity(heatPulse ? 0.2 : 0.1),
                            .clear
                        ],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )
                .frame(height: 300)
                .offset(y: 200)
        }
        .ignoresSafeArea()
        .onAppear {
            startLightSequence()
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                heatPulse = true
            }
        }
    }
    
    private func startLightSequence() {
        // F1起跑灯序列
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        lightsOn[i] = true
                    }
                }
            }
            // 全部熄灭
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.05)) {
                    for i in 0..<5 {
                        lightsOn[i] = false
                    }
                }
            }
        }
    }
}

/// 碳纤维编织
struct CarbonWeaveView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 4
            // 45度斜线
            for x in stride(from: -size.height, to: size.width + size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.02)), lineWidth: 0.5)
            }
            // -45度斜线
            for x in stride(from: 0, to: size.width + size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x - size.height, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.02)), lineWidth: 0.5)
            }
        }
    }
}

/// 速度线
struct SpeedLine: View {
    let delay: Double
    @State private var offset: CGFloat = -400
    @State private var opacity: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, Color(hex: "E10600").opacity(0.6), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: CGFloat.random(in: 100...200), height: 1)
            .offset(x: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .linear(duration: 0.8)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = 400
                }
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 1
                }
            }
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 5. THE CELESTIAL - 星际工坊
// MARK: 灵感：哈勃深空场、星际迷航界面、银河系旋臂
// MARK: ═══════════════════════════════════════════════════════
struct CelestialBackground: View {
    @State private var galaxyRotation: Double = 0
    @State private var nebulaOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 深空基底
            RadialGradient(
                colors: [
                    Color(hex: "0A0520"),
                    Color(hex: "050210"),
                    Color(hex: "020108")
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            
            // 星云层
            NebulaView(color: Color(hex: "581c87"), opacity: 0.3)
                .offset(x: -50 + nebulaOffset, y: -100)
            
            NebulaView(color: Color(hex: "1e3a8a"), opacity: 0.25)
                .offset(x: 80 - nebulaOffset, y: 150)
            
            // 星星
            ForEach(0..<30, id: \.self) { _ in
                StarView(
                    size: CGFloat.random(in: 1...3),
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.7)
                )
            }
            
            // 旋转星系
            GalaxyView()
                .rotationEffect(.degrees(galaxyRotation))
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                galaxyRotation = 360
            }
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                nebulaOffset = 20
            }
        }
    }
}

/// 星云
struct NebulaView: View {
    let color: Color
    let opacity: Double
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 300)
            .blur(radius: 60)
    }
}

/// 星星
struct StarView: View {
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .opacity(opacity)
            .position(x: x, y: y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...3))
                ) {
                    opacity = 1
                }
            }
    }
}

/// 星系
struct GalaxyView: View {
    @State private var corePulse: Bool = false
    
    var body: some View {
        ZStack {
            // 旋臂
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B5CF6").opacity(0.5), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 100, height: 2)
                    .offset(x: 50)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            // 核心
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.8),
                            Color(hex: "8B5CF6").opacity(0.5),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 20, height: 20)
                .shadow(
                    color: Color(hex: "8B5CF6").opacity(corePulse ? 0.8 : 0.5),
                    radius: corePulse ? 30 : 20
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                corePulse = true
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 6. THE BOTANICAL - 草本工坊
// MARK: 灵感：Aesop门店的琥珀色、Le Labo的极简、温室植物园的光影
// MARK: ═══════════════════════════════════════════════════════
struct BotanicalBackground: View {
    @State private var breathScale: CGFloat = 1
    @State private var dappleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 森林绿基底
            LinearGradient(
                colors: [
                    Color(hex: "0A1A0F"),
                    Color(hex: "122318"),
                    Color(hex: "1A3324"),
                    Color(hex: "122318"),
                    Color(hex: "0A1A0F")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 呼吸光晕 - 自然的生命感
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "4CAF50").opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .scaleEffect(breathScale)
            
            // 阳光斑点 - 穿过树叶的光
            ForEach(0..<3, id: \.self) { i in
                SunDapple(
                    size: CGFloat.random(in: 50...80),
                    delay: Double(i) * 2
                )
                .offset(
                    x: CGFloat([-60, 70, -20][i]),
                    y: CGFloat([-100, 50, 120][i]) + dappleOffset
                )
            }
            
            // 生长的藤蔓
            VineView()
                .offset(x: -120, y: 200)
            
            VineView()
                .offset(x: 130, y: 180)
                .scaleEffect(x: -1)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathScale = 1.3
            }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                dappleOffset = 20
            }
        }
    }
}

/// 阳光斑点
struct SunDapple: View {
    let size: CGFloat
    let delay: Double
    @State private var opacity: Double = 0.5
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "D4AF37").opacity(0.3), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 0.8
                }
            }
    }
}

/// 藤蔓
struct VineView: View {
    @State private var vineHeight: CGFloat = 100
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "4CAF50").opacity(0.3), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 2, height: vineHeight)
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    vineHeight = 200
                }
            }
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 7. THE PORCELAIN - 青瓷工坊
// MARK: 灵感：宋代汝窑的天青色、景德镇青花的缠枝莲、故宫馆藏的冰裂纹
// MARK: ═══════════════════════════════════════════════════════
struct PorcelainBackground: View {
    @State private var glazeOffset: CGFloat = -300
    
    var body: some View {
        ZStack {
            // 素白釉基底
            RadialGradient(
                colors: [
                    Color(hex: "F5F5F0"),
                    Color(hex: "E8E8E0"),
                    Color(hex: "DDDDD5")
                ],
                center: UnitPoint(x: 0.5, y: 0.3),
                startRadius: 0,
                endRadius: 500
            )
            
            // 釉面流动光泽
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.4),
                            .init(color: .white.opacity(0.4), location: 0.45),
                            .init(color: .white.opacity(0.6), location: 0.5),
                            .init(color: .white.opacity(0.4), location: 0.55),
                            .init(color: .clear, location: 0.6),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: glazeOffset, y: glazeOffset)
                .rotationEffect(.degrees(30))
            
            // 冰裂纹
            CracklePatternView()
            
            // 青花纹样 - 缠枝莲
            QinghuaPatternView()
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                glazeOffset = 300
            }
        }
    }
}

/// 冰裂纹
struct CracklePatternView: View {
    var body: some View {
        Canvas { context, size in
            // 绘制随机的冰裂纹线条
            for _ in 0..<20 {
                var path = Path()
                let startX = Double.random(in: 0...size.width)
                let startY = Double.random(in: 0...size.height)
                path.move(to: CGPoint(x: startX, y: startY))
                
                var currentX = startX
                var currentY = startY
                
                for _ in 0..<Int.random(in: 3...6) {
                    currentX += Double.random(in: -50...50)
                    currentY += Double.random(in: -50...50)
                    path.addLine(to: CGPoint(x: currentX, y: currentY))
                }
                
                context.stroke(
                    path,
                    with: .color(Color(hex: "1E407C").opacity(Double.random(in: 0.03...0.06))),
                    lineWidth: 0.5
                )
            }
        }
    }
}

/// 青花纹样
struct QinghuaPatternView: View {
    var body: some View {
        ZStack {
            // 外圈装饰带
            Circle()
                .stroke(Color(hex: "1E407C").opacity(0.15), lineWidth: 1)
                .frame(width: 260, height: 260)
            
            Circle()
                .stroke(
                    Color(hex: "1E407C").opacity(0.1),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 8])
                )
                .frame(width: 280, height: 280)
            
            // 缠枝纹
            ForEach(0..<6, id: \.self) { i in
                TendrilView()
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            
            // 中心圆
            Circle()
                .stroke(Color(hex: "1E407C").opacity(0.3), lineWidth: 2)
                .frame(width: 80, height: 80)
            
            Circle()
                .stroke(Color(hex: "1E407C").opacity(0.2), lineWidth: 1)
                .frame(width: 50, height: 50)
            
            // 莲花瓣
            ForEach(0..<6, id: \.self) { i in
                LotusPetalView()
                    .rotationEffect(.degrees(Double(i) * 60))
                    .offset(y: -100)
            }
        }
    }
}

/// 缠枝
struct TendrilView: View {
    var body: some View {
        Ellipse()
            .stroke(Color(hex: "1E407C").opacity(0.2), lineWidth: 1)
            .frame(width: 120, height: 40)
            .offset(x: 40)
    }
}

/// 莲花瓣
struct LotusPetalView: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: 50),
                control: CGPoint(x: 20, y: 25)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: 0),
                control: CGPoint(x: -20, y: 25)
            )
        }
        .stroke(Color(hex: "1E407C").opacity(0.25), lineWidth: 1)
        .background(
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: 50),
                    control: CGPoint(x: 20, y: 25)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: 0),
                    control: CGPoint(x: -20, y: 25)
                )
            }
            .fill(Color(hex: "1E407C").opacity(0.05))
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 8. HAUTE COUTURE - 高定工坊
// MARK: 灵感：Chanel粗花呢、Dior优雅、经典永恒
// MARK: ═══════════════════════════════════════════════════════
struct HauteCoutureBackground: View {
    var body: some View {
        ZStack {
            // 基底：经典的奶油色 (Classic Cream White)
            Color(hex: "F8F4F1").ignoresSafeArea()

            // 粗花呢纹理 (Tweed Texture Simulation)
            // 使用 Canvas 绘制更明显的粗花呢纹理
            Canvas { context, size in
                // 绘制交错的粗花呢纹理
                let tileSize: CGFloat = 8
                let rows = Int(size.height / tileSize) + 1
                let cols = Int(size.width / tileSize) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * tileSize
                        let y = CGFloat(row) * tileSize
                        
                        // 水平线条
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y + tileSize / 2))
                        path.addLine(to: CGPoint(x: x + tileSize, y: y + tileSize / 2))
                        context.stroke(path, with: .color(Color(hex: "C6AC8F").opacity(0.3)), lineWidth: 1)
                        
                        // 垂直线条
                        path = Path()
                        path.move(to: CGPoint(x: x + tileSize / 2, y: y))
                        path.addLine(to: CGPoint(x: x + tileSize / 2, y: y + tileSize))
                        context.stroke(path, with: .color(Color(hex: "C6AC8F").opacity(0.3)), lineWidth: 1)
                        
                        // 对角线纹理（形成斜纹效果）
                        if (row + col) % 2 == 0 {
                            path = Path()
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + tileSize, y: y + tileSize))
                            context.stroke(path, with: .color(Color(hex: "8B7355").opacity(0.15)), lineWidth: 0.5)
                        } else {
                            path = Path()
                            path.move(to: CGPoint(x: x + tileSize, y: y))
                            path.addLine(to: CGPoint(x: x, y: y + tileSize))
                            context.stroke(path, with: .color(Color(hex: "8B7355").opacity(0.15)), lineWidth: 0.5)
                        }
                    }
                }
            }
            .blendMode(.multiply)

            // 柔和的光影 (Soft Lighting)
            // 模拟高级面料的柔软感
            RadialGradient(
                colors: [
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.1)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            
            // 边缘暗角 (Vignette)
            RadialGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.15)
                ],
                center: .center,
                startRadius: 300,
                endRadius: 600
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 9. THE SHANSHUI - 水墨工坊
// MARK: 灵感：宋代山水、文人写意、留白美学
// MARK: ═══════════════════════════════════════════════════════
struct ShanshuiBackground: View {
    @State private var ripplePhase: CGFloat = 0
    @State private var birdsOffset: CGFloat = 0
    @State private var inkPulse: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: 1. 宣纸底色
                LinearGradient(
                    colors: [
                        Color(hex: "F8F6F0"),
                        Color(hex: "F0EDE5"),
                        Color(hex: "E8E4DA")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // MARK: 2. 宣纸纹理
                XuanPaperTexture()
                
                // MARK: 3. 远山 (淡墨)
                DistantMountains()
                    .offset(y: geo.size.height * 0.15)
                
                // MARK: 4. 近山 (浓墨)
                NearMountains()
                    .offset(y: geo.size.height * 0.25)
                
                // MARK: 5. 松树
                PineTree()
                    .offset(x: geo.size.width * 0.25, y: geo.size.height * 0.2)
                
                // MARK: 6. 水面涟漪
                WaterRipples(phase: ripplePhase)
                    .offset(y: geo.size.height * 0.32)
                
                // MARK: 7. 飞鸟
                FlyingBirds()
                    .offset(x: geo.size.width * 0.15 + birdsOffset, y: -geo.size.height * 0.25)
                
                // MARK: 8. 墨点飞溅
                InkSplashes(isPulsing: inkPulse)
                
                // MARK: 9. 题款 (无印章)
                Inscription()
                    .position(x: geo.size.width * 0.12, y: geo.size.height * 0.2)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // 水纹涟漪
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            ripplePhase = 1
        }
        
        // 飞鸟浮动
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            birdsOffset = 10
        }
        
        // 墨点呼吸
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            inkPulse = true
        }
    }
}

// MARK: - 水墨丹青辅助视图

// MARK: - 宣纸纹理
struct XuanPaperTexture: View {
    var body: some View {
        Canvas { context, size in
            // 模拟宣纸的细微纤维纹理
            for _ in 0..<Int(size.width * size.height / 200) {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0.01...0.03)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(Color.black.opacity(opacity)))
            }
        }
    }
}

// MARK: - 远山 (淡墨层次)
struct DistantMountains: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 第一层远山
                MountainShape(peaks: [0.3, 0.6, 0.2, 0.5, 0.25])
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "3C3C3C").opacity(0.08),
                                Color(hex: "3C3C3C").opacity(0.04),
                                .clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: geo.size.width * 0.6, height: 150)
                    .blur(radius: 2)
                    .offset(x: -geo.size.width * 0.1)
                
                // 第二层远山
                MountainShape(peaks: [0.4, 0.7, 0.3, 0.55])
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "3C3C3C").opacity(0.06),
                                Color(hex: "3C3C3C").opacity(0.03),
                                .clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: geo.size.width * 0.5, height: 120)
                    .blur(radius: 3)
                    .offset(x: geo.size.width * 0.2)
            }
        }
        .frame(height: 200)
    }
}

// MARK: - 近山 (浓墨)
struct NearMountains: View {
    var body: some View {
        GeometryReader { geo in
            MountainShape(peaks: [0.5, 0.7, 0.25, 0.55, 0.15, 0.45])
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1E1E1E").opacity(0.25),
                            Color(hex: "1E1E1E").opacity(0.15),
                            Color(hex: "1E1E1E").opacity(0.05),
                            .clear
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: geo.size.width * 0.7, height: 200)
                .offset(x: -geo.size.width * 0.1)
        }
        .frame(height: 250)
    }
}

// MARK: - 山形
struct MountainShape: Shape {
    let peaks: [Double] // 0-1 之间的峰值高度
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let segmentWidth = rect.width / CGFloat(peaks.count - 1)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        for (index, peak) in peaks.enumerated() {
            let x = CGFloat(index) * segmentWidth
            let y = rect.height * (1 - CGFloat(peak))
            
            if index == 0 {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                // 使用曲线连接，更自然
                let prevX = CGFloat(index - 1) * segmentWidth
                let controlX = (prevX + x) / 2
                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    control: CGPoint(x: controlX, y: min(path.currentPoint?.y ?? y, y) - 20)
                )
            }
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 松树
struct PineTree: View {
    var body: some View {
        ZStack {
            // 树干
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "28201A").opacity(0.6),
                            Color(hex: "28201A").opacity(0.3)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 3, height: 80)
                .offset(y: 40)
            
            // 树枝
            ForEach(0..<4, id: \.self) { i in
                PineBranch(
                    length: CGFloat(30 - i * 5),
                    angle: i % 2 == 0 ? -25 : 25
                )
                .offset(y: CGFloat(-20 + i * 12))
            }
            
            // 松针团 (模糊圆形)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "28321E").opacity(0.3),
                            Color(hex: "28321E").opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .blur(radius: 3)
                .offset(x: -5, y: -20)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "28321E").opacity(0.25),
                            Color(hex: "28321E").opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .blur(radius: 3)
                .offset(x: 10, y: -10)
        }
    }
}

struct PineBranch: View {
    let length: CGFloat
    let angle: Double
    
    var body: some View {
        Rectangle()
            .fill(Color(hex: "28201A").opacity(0.5))
            .frame(width: length, height: 2)
            .rotationEffect(.degrees(angle))
            .offset(x: angle < 0 ? -length/2 : length/2)
    }
}

// MARK: - 水面涟漪
struct WaterRipples: View {
    let phase: CGFloat
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<4, id: \.self) { i in
                RippleLine(
                    widthRatio: 1 - CGFloat(i) * 0.15,
                    delay: Double(i) * 0.4
                )
                .scaleEffect(x: 1 + phase * 0.1)
                .opacity(0.5 + Double(phase) * 0.5)
            }
        }
        .frame(height: 80)
    }
}

struct RippleLine: View {
    let widthRatio: CGFloat
    let delay: Double
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color(hex: "3C3C3C").opacity(0.1),
                            Color(hex: "3C3C3C").opacity(0.15),
                            Color(hex: "3C3C3C").opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geo.size.width * widthRatio, height: 1)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 1)
    }
}

// MARK: - 飞鸟
struct FlyingBirds: View {
    var body: some View {
        HStack(spacing: 15) {
            BirdShape().scaleEffect(0.8)
            BirdShape().scaleEffect(1.0).offset(y: 5)
            BirdShape().scaleEffect(0.7).offset(y: -3)
        }
    }
}

struct BirdShape: View {
    var body: some View {
        Path { path in
            // 左翼
            path.move(to: CGPoint(x: 0, y: 5))
            path.addLine(to: CGPoint(x: 10, y: 4))
            
            // 右翼
            path.move(to: CGPoint(x: 10, y: 4))
            path.addLine(to: CGPoint(x: 20, y: 5))
        }
        .stroke(Color(hex: "1E1E1E").opacity(0.4), lineWidth: 1.5)
        .frame(width: 20, height: 10)
    }
}

// MARK: - 墨点飞溅
struct InkSplashes: View {
    let isPulsing: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                InkDot(size: 8)
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.65)
                    .scaleEffect(isPulsing ? 1.1 : 1)
                    .opacity(isPulsing ? 0.6 : 0.3)
                
                InkDot(size: 5)
                    .position(x: geo.size.width * 0.25, y: geo.size.height * 0.62)
                    .scaleEffect(isPulsing ? 1.1 : 1)
                    .opacity(isPulsing ? 0.5 : 0.25)
                
                InkDot(size: 6)
                    .position(x: geo.size.width * 0.7, y: geo.size.height * 0.4)
                    .scaleEffect(isPulsing ? 1.1 : 1)
                    .opacity(isPulsing ? 0.55 : 0.28)
            }
        }
    }
}

struct InkDot: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color(hex: "1E1E1E").opacity(0.15))
            .frame(width: size, height: size)
    }
}

// MARK: - 题款
struct Inscription: View {
    var body: some View {
        Text("山高水长")
            .font(.custom("PingFang SC", size: 14))
            .fontWeight(.light)
            .foregroundColor(Color(hex: "1E1E1E").opacity(0.4))
            .tracking(4)
            .rotationEffect(.degrees(-90))
            .fixedSize()
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 10. THE MINIMALIST - 极简工坊
// MARK: 灵感：Muji无印良品、Apple极简、留白美学
// MARK: ═══════════════════════════════════════════════════════
struct MinimalistBackground: View {
    var body: some View {
        ZStack {
            // 纯白基底
            Color(hex: "FFFFFF").ignoresSafeArea()
            
            // 极简线条
            GeometryReader { geo in
                // 水平线
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height * 0.3))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.3))
                }
                .stroke(Color(hex: "808080").opacity(0.1), lineWidth: 1)
                
                // 垂直线
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width * 0.2, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width * 0.2, y: geo.size.height))
                }
                .stroke(Color(hex: "808080").opacity(0.1), lineWidth: 1)
            }
            
            // 微妙的阴影
            RadialGradient(
                colors: [
                    Color.gray.opacity(0.05),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - ═══════════════════════════════════════════════════════
// MARK: 11. THE ARTISAN - 手工艺坊
// MARK: 灵感：传统手工艺、匠心独运、手工质感
// MARK: ═══════════════════════════════════════════════════════
struct ArtisanBackground: View {
    var body: some View {
        ZStack {
            // 手工深棕基底
            LinearGradient(
                colors: [
                    Color(hex: "2F1B14"),
                    Color(hex: "3D2819"),
                    Color(hex: "2F1B14")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 手工纹理
            Canvas { context, size in
                // 模拟手工制作的粗糙质感
                for _ in 0..<Int(size.width * size.height / 100) {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.03...0.08)
                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(rect), with: .color(Color(hex: "8B4513").opacity(opacity)))
                }
            }
            .blendMode(.overlay)
            
            // 温暖的手工光晕
            RadialGradient(
                colors: [
                    Color(hex: "D2691E").opacity(0.1),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - 背景视图工厂
extension LuxuryTheme {
    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .equestrian:
            EquestrianBackground()
        case .chronograph:
            ChronographBackground()
        case .gemstone:
            GemstoneBackground()
        case .formula:
            FormulaBackground()
        case .celestial:
            CelestialBackground()
        case .botanical:
            BotanicalBackground()
        case .porcelain:
            PorcelainBackground()
                .preferredColorScheme(.light)
        case .hauteCouture:
            HauteCoutureBackground()
                .preferredColorScheme(.light)
        case .shanshui:
            ShanshuiBackground()
                .preferredColorScheme(.light)
        case .minimalist:
            MinimalistBackground()
                .preferredColorScheme(.light)
        case .artisan:
            ArtisanBackground()
        }
    }
}

// MARK: - 辅助扩展

// 辅助 View 扩展，用于条件性应用修改器
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // 将 View 转换为 UIImage (用于 ImagePaint)
    // 这是实现高效纹理平铺的关键
    @MainActor
    func asUIImage(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self.frame(width: size.width, height: size.height))
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        // 确保视图已布局
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        
        // 使用 layer.render 而不是 drawHierarchy，因为视图不在窗口层次结构中
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }
}

// 将 LinearGradient 转换为 UIImage
extension LinearGradient {
    @MainActor
    func asUIImage(size: CGSize) -> UIImage {
        let view = self.frame(width: size.width, height: size.height)
        return view.asUIImage(size: size)
    }
}

import SwiftUI

// MARK: - 💎 Luxury Components (奢华组件库)
// 这些组件是所有高定模版的基础，提供程序化纹理和物理质感。

// 1. 程序化纸张纹理 (Procedural Paper Texture)
// 模拟高级羊皮纸/棉纸的纤维感，通过正片叠底 (Multiply) 叠加在任何视图上
struct PaperTextureOverlay: View {
    var opacity: Double = 0.15
    var color: Color = Color(hex: "Fdfbf7") // 暖白
    
    var body: some View {
        ZStack {
            // 底色
            color.opacity(0.1)
            
            // 纤维噪点
            GeometryReader { _ in
                Canvas { context, size in
                    // 绘制高频噪点
                    for _ in 0..<3000 {
                        let x = Double.random(in: 0...size.width)
                        let y = Double.random(in: 0...size.height)
                        let rect = CGRect(x: x, y: y, width: 1, height: 1)
                        context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.3)))
                    }
                    // 绘制低频污渍 (Aging spots)
                    for _ in 0..<20 {
                        let x = Double.random(in: 0...size.width)
                        let y = Double.random(in: 0...size.height)
                        let size = Double.random(in: 10...50)
                        let rect = CGRect(x: x, y: y, width: size, height: size)
                        context.fill(Path(ellipseIn: rect), with: .color(Color(hex: "8B4513").opacity(0.02)))
                    }
                }
            }
        }
        .blendMode(.multiply) // 关键：正片叠底，融入背景
        .allowsHitTesting(false)
        .opacity(opacity)
    }
}

// 2. 电影胶片颗粒 (Cinematic Film Grain)
// 动态噪点，模拟 35mm 胶片的呼吸感
struct FilmGrainEffect: View {
    var intensity: Double = 0.2
    
    var body: some View {
        // 使用 TimelineView 实现每秒变化的噪点
        SwiftUI.TimelineView(.periodic(from: Date(), by: 1.0 / 24.0)) { timeline in
            let _ = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for _ in 0..<2000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let w = Double.random(in: 1...2)
                    let rect = CGRect(x: x, y: y, width: w, height: w)
                    // 随机黑白噪点
                    let gray = Double.random(in: 0...1)
                    context.fill(Path(ellipseIn: rect), with: .color(Color(white: gray).opacity(intensity)))
                }
            }
        }
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }
}

// 3. 程序化条形码 (Generative Barcode)
// 随机生成逼真的条形码
struct BarcodeView: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<40, id: \.self) { i in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: [1, 1, 2, 3, 1, 2].randomElement()!, height: [30, 30, 30, 30, 40].randomElement()!)
            }
        }
        .frame(height: 40)
        .overlay(
            Text("9 780201 37962")
                .font(.system(size: 8, design: .monospaced))
                .offset(y: 25)
        )
        .padding(.bottom, 10)
    }
}

// 4. 浮光全息贴纸 (Holographic Sticker)
// 模拟防伪标签的彩虹反光
struct HolographicSticker: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3), .pink.opacity(0.3), .yellow.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 2)
            
            // 扫光效果
            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: 20, height: 80)
                .rotationEffect(.degrees(45))
                .offset(x: -40)
                .mask(Circle().frame(width: 60, height: 60))
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// 5. 动态阴影 (Dynamic Shadow)
// 模拟物体悬浮感
extension View {
    func floatingShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


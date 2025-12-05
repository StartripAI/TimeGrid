import SwiftUI

// MARK: - 🎨 Luxury Developing Background (Hermes-Inspired)
// 羊皮纸质感 + 金色装饰线条，打造奢华显影背景

struct LuxuryDevelopingBackground: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Base: Cream parchment color
            Color(hex: "F5F0E8")
            
            // Layer 1: Subtle noise texture (paper grain)
            Canvas { context, size in
                for _ in 0..<1500 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1.5, height: 1.5)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color(hex: "8B7355").opacity(0.08))
                    )
                }
            }
            
            // Layer 2: Vignette (darker edges)
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.15)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .blendMode(.multiply)
            
            // Layer 3: Hermes orange accent stripes (subtle)
            GeometryReader { geo in
                VStack(spacing: geo.size.height / 5) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FF8C42").opacity(0.02),
                                        Color(hex: "FF8C42").opacity(0.04),
                                        Color(hex: "FF8C42").opacity(0.02)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                    }
                }
            }
            
            // Layer 4: Gold foil shimmer animation (Hermes signature)
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hex: "D4AF37").opacity(0.15),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 150)
            .blur(radius: 30)
            .offset(x: shimmerOffset)
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 600
                }
            }
            
            // Layer 5: Top embossed title (like Hermes box lid)
            VStack {
                Text("TIME CAPSULE")
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .tracking(3)
                    .foregroundColor(Color(hex: "8B7355").opacity(0.25))
                    .padding(.top, 80)
                
                Spacer()
            }
        }
    }
}



import SwiftUI

struct LuxuryTabBar: View {
    @Binding var selectedTab: Int
    var onMintTap: () -> Void
    
    // 材质引擎引用 (为了拿到当前的主题色)
    @ObservedObject var themeEngine = ThemeEngine.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 2. 五列网格布局（移除顶部金线，让背景无缝连接）
            HStack(spacing: 0) {
                // Col 1: 时光 (Archive)
                tabButton(icon: "clock.arrow.circlepath", text: "时光", tag: 0)
                
                // Col 2: 日历 (Calendar)
                tabButton(icon: "calendar", text: "日历", tag: 1)
                
                // Col 3: 铸造 (Forge)
                tabButton(icon: "sparkles", text: "铸造", tag: 2)
                
                // Col 4: 今日 (Today)
                tabButton(icon: "sun.max.fill", text: "今日", tag: 3)
                
                // Col 5: 我的 (Profile)
                tabButton(icon: "person.crop.circle", text: "我的", tag: 4)
            }
            .frame(height: 60) // 缩短高度，参考TikTok/Instagram
            .padding(.vertical, 4) // 上下内边距
            // 背景：使用主题背景色，确保无缝连接
            .background(
                themeEngine.currentTheme.backgroundColor
                    .opacity(0.98)
            )
            .background(.ultraThinMaterial)
        }
        // 移除中间悬浮按钮，因为现在有5个Tab了
    }
    
    // MARK: - Tab Button Component
    func tabButton(icon: String, text: String, tag: Int) -> some View {
        Button(action: {
            print("🔘 Tab button tapped: \(tag)") // 调试日志
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: tag == selectedTab ? .semibold : .regular)) // 增大图标，参考TikTok/Instagram
                    .foregroundColor(tag == selectedTab ? Color(hex: "D4AF37") : Color.white.opacity(0.6))
                    .scaleEffect(tag == selectedTab ? 1.1 : 1.0)
                
                Text(text)
                    .font(.system(size: 12, weight: tag == selectedTab ? .medium : .regular)) // 增大字体
                    .foregroundColor(tag == selectedTab ? Color(hex: "D4AF37") : Color.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60) // 匹配新的高度
            .contentShape(Rectangle()) // 确保整个区域可点击
        }
        .buttonStyle(PlainButtonStyle()) // 使用 PlainButtonStyle 避免默认样式干扰
    }
}

// MARK: - Golden Aperture Icon (IconSystem)
struct ApertureIcon: View {
    var body: some View {
        ZStack {
            // 外圈金环
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "FFE082"), Color(hex: "B8860B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .background(Circle().fill(Color(hex: "382822"))) // 皮革填充
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            
            // 光圈叶片
            Image(systemName: "camera.aperture")
                .font(.system(size: 28, weight: .light)) // 稍微缩小以适应新的状态栏高度
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 2)
        }
        .frame(width: 56, height: 56) // 稍微缩小以适应新的状态栏高度
    }
}

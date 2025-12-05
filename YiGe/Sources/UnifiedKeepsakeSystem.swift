//
//  UnifiedKeepsakeSystem.swift
//  时光格 - 统一信物系统
//
//  核心原则：一个信物类型 = 统一的名字 + 统一的icon + 统一的入口 + 统一的预览 + 统一的产出
//  中Tab入口、右Tab选择、最终信物卡片 完全统一
//

import SwiftUI

// MARK: - ============================================
// MARK: - 核心：统一信物类型枚举
// MARK: - ============================================

enum UnifiedKeepsakeStyle: String, CaseIterable, Identifiable, Codable {
    // 影像类
    case polaroid           // 拍立得
    case leicaFilm          // 徕卡胶片
    case filmRoll           // 胶卷冲洗

    // 票据类
    case movieTicket        // 电影票
    case trainTicket        // 火车票
    case concertTicket      // 演唱会票

    // 书信类
    case waxEnvelope        // 火漆信封
    case postcard           // 明信片
    case journalPage        // 日记页

    // 收藏类
    case vinylRecord        // 黑胶唱片
    case bookmark           // 书签
    case pressedFlower      // 干花标本

    var id: String { rawValue }

    // MARK: - 统一名称（三处完全一致）
    var displayName: String {
        switch self {
        case .polaroid:      return "拍立得"
        case .leicaFilm:     return "徕卡胶片"
        case .filmRoll:      return "胶卷冲洗"
        case .waxEnvelope:   return "火漆信封"
        case .postcard:      return "明信片"
        case .journalPage:   return "日记页"
        case .vinylRecord:   return "黑胶唱片"
        case .bookmark:      return "书签"
        case .pressedFlower: return "干花标本"
        }
    }

    // MARK: - 统一描述
    var subtitle: String {
        switch self {
        case .polaroid:      return "即拍即得的生活瞬间"
        case .leicaFilm:     return "珍藏的光影记忆"
        case .filmRoll:      return "等待显影的惊喜"
        case .movieTicket:   return "银幕前的故事"
        case .trainTicket:   return "旅途中的风景"
        case .concertTicket: return "现场的感动"
        case .waxEnvelope:   return "郑重封存的话语"
        case .postcard:      return "远方寄来的问候"
        case .journalPage:   return "写给自己的私语"
        case .vinylRecord:   return "旋律里的时光"
        case .bookmark:      return "书页间的感悟"
        case .pressedFlower: return "定格自然之美"
        }
    }

    // MARK: - 新手引导相关属性
    var onboardingTitle: String {
        switch self {
        case .polaroid:      return "CAPTURE"
        case .waxEnvelope:   return "PRESERVE"
        case .movieTicket:   return "RELIVE"
        case .leicaFilm:     return "CAPTURE"
        case .filmRoll:      return "DEVELOP"
        case .trainTicket:   return "JOURNEY"
        case .concertTicket: return "CELEBRATE"
        case .postcard:      return "CONNECT"
        case .journalPage:   return "REFLECT"
        case .vinylRecord:   return "REMEMBER"
        case .bookmark:      return "MARK"
        case .pressedFlower: return "CHERISH"
        }
    }

    var onboardingSubtitle: String {
        switch self {
        case .polaroid:      return "定格生活瞬间"
        case .waxEnvelope:   return "郑重封存时光"
        case .movieTicket:   return "重温精彩时刻"
        case .leicaFilm:     return "捕捉光影记忆"
        case .filmRoll:      return "等待惊喜显影"
        case .trainTicket:   return "记录旅途风景"
        case .concertTicket: return "封存现场感动"
        case .postcard:      return "传递远方问候"
        case .journalPage:   return "写给未来的自己"
        case .vinylRecord:   return "收藏旋律时光"
        case .bookmark:      return "标记重要感悟"
        case .pressedFlower: return "珍藏自然之美"
        }
    }

    var onboardingDescription: String {
        switch self {
        case .polaroid:
            return "经典拍立得风格，瞬间捕捉生活美好。白色边框配以手写文字，将每一天化作可触摸的艺术品。"
        case .waxEnvelope:
            return "英式火漆信封，搭配花体时间戳。古典的封印仪式，让记忆更加郑重和珍贵。"
        case .movieTicket:
            return "电影票风格，复古热敏打印。记录生活中的精彩瞬间，如同电影般重温每一个美好时刻。"
        case .leicaFilm:
            return "徕卡相机风格，专业胶片质感。捕捉那些值得珍藏的光影瞬间，专业摄影师的选择。"
        case .filmRoll:
            return "传统胶卷冲洗风格，等待显影的惊喜。适合记录那些需要时间沉淀的珍贵时刻。"
        case .trainTicket:
            return "火车票风格，记录旅途风景。适合收藏旅行中的美好回忆和人生旅程。"
        case .concertTicket:
            return "演唱会门票风格，金色奢华。适合记录生活中的庆祝时刻和精彩演出。"
        case .postcard:
            return "明信片风格，传递远方问候。适合记录想分享给朋友和家人的美好时光。"
        case .journalPage:
            return "日记本风格，手写私语。适合记录个人反思和写给未来的自己。"
        case .vinylRecord:
            return "黑胶唱片风格，旋律时光。适合记录那些伴随着音乐的美好回忆。"
        case .bookmark:
            return "书签风格，书页感悟。适合标记生活中的重要时刻和读书心得。"
        case .pressedFlower:
            return "干花标本风格，自然馈赠。适合记录那些自然而美好的瞬间。"
        }
    }

    // MARK: - 统一图标（SF Symbol）
    var icon: String {
        switch self {
        case .polaroid:      return "camera.fill"
        case .leicaFilm:     return "camera.aperture"
        case .filmRoll:      return "film"
        case .movieTicket:   return "ticket.fill"
        case .trainTicket:   return "tram.fill"
        case .concertTicket: return "music.mic"
        case .waxEnvelope:   return "envelope.fill"
        case .postcard:      return "photo.on.rectangle"
        case .journalPage:   return "book.fill"
        case .vinylRecord:   return "opticaldisc.fill"
        case .bookmark:      return "bookmark.fill"
        case .pressedFlower: return "leaf.fill"
        }
    }

    // MARK: - 统一颜色
    var primaryColor: Color {
        switch self {
        case .polaroid:      return Color(hex: "#FFFFFF")
        case .leicaFilm:     return Color(hex: "#1C1C1C")
        case .filmRoll:      return Color(hex: "#2C1810")
        case .movieTicket:   return Color(hex: "#C41E3A")
        case .trainTicket:   return Color(hex: "#1E5631")
        case .concertTicket: return Color(hex: "#1C1C1C")
        case .waxEnvelope:   return Color(hex: "#D2B48C")
        case .postcard:      return Color(hex: "#87CEEB")
        case .journalPage:   return Color(hex: "#FFF8DC")
        case .vinylRecord:   return Color(hex: "#1C1C1C")
        case .bookmark:      return Color(hex: "#722F37")
        case .pressedFlower: return Color(hex: "#228B22")
        }
    }

    var accentColor: Color {
        switch self {
        case .polaroid:      return Color(hex: "#1C1C1C")
        case .leicaFilm:     return Color(hex: "#C41E3A")
        case .filmRoll:      return Color(hex: "#FF6B35")
        case .movieTicket:   return Color(hex: "#FFD700")
        case .trainTicket:   return Color(hex: "#C41E3A")
        case .concertTicket: return Color(hex: "#FFD700")
        case .waxEnvelope:   return Color(hex: "#8B0000")
        case .postcard:      return Color(hex: "#FF6B6B")
        case .journalPage:   return Color(hex: "#4A4A4A")
        case .vinylRecord:   return Color(hex: "#C41E3A")
        case .bookmark:      return Color(hex: "#FFD700")
        case .pressedFlower: return Color(hex: "#DEB887")
        }
    }

    // MARK: - 分类
    var category: KeepsakeCategory {
        switch self {
        case .polaroid, .leicaFilm, .filmRoll:
            return .photography
        case .movieTicket, .trainTicket, .concertTicket:
            return .tickets
        case .waxEnvelope, .postcard, .journalPage:
            return .writing
        case .vinylRecord, .bookmark, .pressedFlower:
            return .collection
        }
    }
}

enum KeepsakeCategory: String, CaseIterable {
    case photography = "影像"
    case tickets = "票据"
    case writing = "书信"
    case collection = "收藏"

    var icon: String {
        switch self {
        case .photography: return "camera"
        case .tickets: return "ticket"
        case .writing: return "envelope"
        case .collection: return "star"
        }
    }

    var styles: [UnifiedKeepsakeStyle] {
        UnifiedKeepsakeStyle.allCases.filter { $0.category == self }
    }
}

// MARK: - ============================================
// MARK: - 1. 中Tab入口视图（TodayHub）
// MARK: - ============================================

/// 中Tab入口 - 每种信物类型有独特的入口外观
struct KeepsakeHubEntry: View {
    let style: UnifiedKeepsakeStyle
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            // 震动反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onTap()
            }
        }) {
            hubContent
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var hubContent: some View {
        switch style {
        case .polaroid:
            PolaroidHubEntry(isPressed: isPressed)
        case .leicaFilm:
            LeicaHubEntry(isPressed: isPressed)
        case .filmRoll:
            FilmRollHubEntry(isPressed: isPressed)
        case .movieTicket:
            MovieTicketHubEntry(isPressed: isPressed)
        case .trainTicket:
            TrainTicketHubEntry(isPressed: isPressed)
        case .concertTicket:
            ConcertTicketHubEntry(isPressed: isPressed)
        case .waxEnvelope:
            WaxEnvelopeHubEntry(isPressed: isPressed)
        case .postcard:
            PostcardHubEntry(isPressed: isPressed)
        case .journalPage:
            JournalHubEntry(isPressed: isPressed)
        case .vinylRecord:
            VinylRecordHubEntry(isPressed: isPressed)
        case .bookmark:
            BookmarkHubEntry(isPressed: isPressed)
        case .pressedFlower:
            PressedFlowerHubEntry(isPressed: isPressed)
        }
    }
}

// MARK: - 各类型Hub入口实现

/// 拍立得入口 - 相机外观
struct PolaroidHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 相机机身
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#F5F5F5"), Color(hex: "#E0E0E0")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 240)

            VStack(spacing: 12) {
                // 取景窗
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#87CEEB").opacity(0.5))
                    .frame(width: 40, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#4A4A4A"), lineWidth: 2)
                    )

                // 镜头
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#2C2C2C"), Color(hex: "#1C1C1C")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#4A90A4"), Color(hex: "#2C5F7C")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)

                    // 反光
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .offset(x: -10, y: -10)
                }

                // 出片口
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#2C2C2C"))
                    .frame(width: 140, height: 8)

                // 彩虹条纹
                HStack(spacing: 0) {
                    ForEach(["#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#8B00FF"], id: \.self) { hex in
                        Rectangle()
                            .fill(Color(hex: hex))
                            .frame(width: 20, height: 4)
                    }
                }
            }

            // 闪光灯
            Circle()
                .fill(Color(hex: "#FFD700"))
                .frame(width: 24, height: 24)
                .offset(x: -70, y: -90)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
    }
}

/// 徕卡入口 - 经典相机
struct LeicaHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 相机机身
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1C1C1C"))
                .frame(width: 220, height: 140)

            HStack(spacing: 16) {
                // 镜头
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#3C3C3C"), Color(hex: "#1C1C1C")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    // 光圈
                    ForEach(0..<8) { i in
                        Rectangle()
                            .fill(Color(hex: "#2C2C2C"))
                            .frame(width: 2, height: 30)
                            .offset(y: -15)
                            .rotationEffect(.degrees(Double(i) * 45))
                    }

                    Circle()
                        .fill(Color(hex: "#1A1A1A"))
                        .frame(width: 30, height: 30)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Leica 标志
                    Text("LEICA")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)

                    // 红点
                    Circle()
                        .fill(Color(hex: "#C41E3A"))
                        .frame(width: 12, height: 12)

                    // 快门按钮
                    Circle()
                        .fill(Color(hex: "#C0C0C0"))
                        .frame(width: 20, height: 20)
                }
            }

            // 取景器
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#2C2C2C"))
                .frame(width: 30, height: 20)
                .offset(x: 80, y: -50)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
    }
}

/// 胶卷入口
struct FilmRollHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 胶卷罐
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#4A4A4A"), Color(hex: "#2C2C2C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 80, height: 160)

            // 胶片拉出
            VStack(spacing: 0) {
                // 齿孔
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "#1A0F0A"))
                            .frame(width: 8, height: 12)
                    }
                }

                Rectangle()
                    .fill(Color(hex: "#2C1810"))
                    .frame(width: 100, height: 60)
                    .overlay(
                        // 负片效果
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: "#FF6B35").opacity(0.5))
                                    .frame(width: 25, height: 40)
                            }
                        }
                    )

                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "#1A0F0A"))
                            .frame(width: 8, height: 12)
                    }
                }
            }
            .offset(x: 60)

            // 品牌标签
            VStack {
                Text("KODAK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#FFD700"))
                Text("400")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
            }
            .offset(x: -20)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

/// 电影票入口
struct MovieTicketHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 票面
            HStack(spacing: 0) {
                // 主票
                VStack(alignment: .leading, spacing: 8) {
                    Text("CINEMA")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "#8B0000"))

                    Text("🎬")
                        .font(.system(size: 40))

                    Text("ADMIT ONE")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#4A4A4A"))
                }
                .padding(16)
                .frame(width: 140, height: 180)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FFF8E7"), Color(hex: "#FFEBCD")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // 锯齿分割
                TicketPerforationView()
                    .frame(width: 2, height: 180)

                // 副券
                VStack {
                    Text("★")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .frame(width: 40, height: 180)
                .background(Color(hex: "#FFF8E7"))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "#C41E3A"), lineWidth: 2)
            )
            .cornerRadius(8)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotationEffect(.degrees(-3))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

/// 锯齿分割线
struct TicketPerforationView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<12, id: \.self) { _ in
                Circle()
                    .fill(Color(hex: "#F5F0E8"))
                    .frame(width: 8, height: 8)
                Spacer()
                    .frame(height: 6)
            }
        }
    }
}

/// 火车票入口
struct TrainTicketHubEntry: View {
    let isPressed: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 顶部色带
            Rectangle()
                .fill(Color(hex: "#1E5631"))
                .frame(height: 12)

            VStack(spacing: 16) {
                // 路线
                HStack {
                    VStack {
                        Text("始")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("此刻")
                            .font(.system(size: 18, weight: .bold))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#1E5631"))

                    Spacer()

                    VStack {
                        Text("终")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("远方")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundColor(Color(hex: "#1C1C1C"))

                // 列车图标
                Image(systemName: "tram.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#1E5631"))
            }
            .padding(20)
            .background(Color.white)
        }
        .frame(width: 200, height: 140)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#1E5631").opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

/// 演唱会票入口
struct ConcertTicketHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1C1C1C"))
                .frame(width: 180, height: 220)

            // 金色边框
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#FFD700"), Color(hex: "#B8860B"), Color(hex: "#FFD700")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 180, height: 220)

            VStack(spacing: 12) {
                // 星星
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color(hex: "#FFD700"))

                Image(systemName: "music.mic")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "#FFD700"))

                Text("LIVE")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(6)
                    .foregroundColor(.white)

                Text("CONCERT")
                    .font(.system(size: 10))
                    .tracking(4)
                    .foregroundColor(Color(hex: "#B8B8B8"))
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: Color(hex: "#FFD700").opacity(0.3), radius: 15, y: 5)
    }
}

/// 火漆信封入口
struct WaxEnvelopeHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 信封主体
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#DEB887"), Color(hex: "#D2B48C")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 140)

            // 封口三角
            Triangle()
                .fill(Color(hex: "#C9A96A"))
                .frame(width: 200, height: 70)
                .offset(y: -35)

            // 纹理线条
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "#C4A67C").opacity(0.5))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)

            // 火漆印章
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#8B0000"), Color(hex: "#5C0000")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)

                Text("封")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .offset(y: -20)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

/// 三角形
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

/// 明信片入口
struct PostcardHubEntry: View {
    let isPressed: Bool

    var body: some View {
        HStack(spacing: 0) {
            // 左侧风景
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#87CEEB"), Color(hex: "#4682B4")],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    Text("✈️")
                        .font(.system(size: 36))
                    Text("WISH YOU")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                    Text("WERE HERE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 100, height: 140)

            // 右侧书写区
            VStack(alignment: .trailing, spacing: 8) {
                // 邮票
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 30, height: 40)
                    Rectangle()
                        .stroke(Color(hex: "#C41E3A"), lineWidth: 1)
                        .frame(width: 26, height: 36)
                    Text("📮")
                        .font(.system(size: 16))
                }

                Spacer()

                // 地址线
                VStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(hex: "#D3D3D3"))
                            .frame(height: 1)
                    }
                }
            }
            .padding(12)
            .frame(width: 100, height: 140)
            .background(Color(hex: "#FFF8E7"))
        }
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#D3D3D3"), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotationEffect(.degrees(2))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

/// 日记本入口
struct JournalHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 封面
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#8B4513"))
                .frame(width: 160, height: 200)

            // 书脊
            Rectangle()
                .fill(Color(hex: "#6B3410"))
                .frame(width: 15, height: 200)
                .offset(x: -72.5)

            // 装饰边框
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#FFD700").opacity(0.5), lineWidth: 1)
                .frame(width: 130, height: 170)

            VStack(spacing: 16) {
                // 标题
                Text("MY JOURNAL")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700"))

                // 日记图标
                Image(systemName: "book.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#DEB887"))

                // 日期
                Text("2024")
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(Color(hex: "#DEB887"))
            }

            // 书签丝带
            Rectangle()
                .fill(Color(hex: "#C41E3A"))
                .frame(width: 8, height: 30)
                .offset(x: 50, y: 100)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

/// 黑胶唱片入口
struct VinylRecordHubEntry: View {
    let isPressed: Bool
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // 唱片封套
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#1C1C1C"))
                .frame(width: 180, height: 180)

            // 唱片（露出部分）
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color(hex: "#1C1C1C"),
                            Color(hex: "#3C3C3C"),
                            Color(hex: "#1C1C1C"),
                            Color(hex: "#3C3C3C"),
                            Color(hex: "#1C1C1C")
                        ],
                        center: .center
                    )
                )
                .frame(width: 150, height: 150)
                .overlay(
                    // 中心标签
                    Circle()
                        .fill(Color(hex: "#C41E3A"))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("♪")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        )
                )
                .rotationEffect(.degrees(rotation))
                .offset(x: 30)

            // 封套标题
            VStack(alignment: .leading, spacing: 4) {
                Text("VINYL")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("RECORD")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#888888"))
            }
            .offset(x: -50, y: 60)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// 书签入口
struct BookmarkHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 书签形状
            BookmarkShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#722F37"), Color(hex: "#4A1C24")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 70, height: 200)

            // 金边
            BookmarkShape()
                .stroke(Color(hex: "#FFD700").opacity(0.6), lineWidth: 1)
                .frame(width: 66, height: 196)

            VStack(spacing: 16) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#FFD700"))

                Text("阅")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)

                Text("读")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)

                Text("时")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)

                Text("光")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)
            }
            .offset(y: -10)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

/// 书签形状
struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: rect.width - 8, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 8), control: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 30))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height - 30))
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 0, y: 0))

        return path
    }
}

/// 干花标本入口
struct PressedFlowerHubEntry: View {
    let isPressed: Bool

    var body: some View {
        ZStack {
            // 标本纸
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#FFF8E7"))
                .frame(width: 160, height: 200)

            // 边框
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#DEB887"), lineWidth: 1)
                .frame(width: 160, height: 200)

            VStack(spacing: 12) {
                // 干花图案
                ZStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.6))
                        .rotationEffect(.degrees(-30))
                        .offset(x: -25, y: 10)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.5))
                        .rotationEffect(.degrees(20))
                        .offset(x: 20, y: -5)

                    Text("🌸")
                        .font(.system(size: 50))
                }

                // 学名风格文字
                Text("Botanical")
                    .font(.custom("Bradley Hand", size: 14))
                    .italic()
                    .foregroundColor(Color(hex: "#6B5344"))

                Text("Specimen")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#8B7355"))
            }

            // 胶带
            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.8))
                .frame(width: 50, height: 16)
                .rotationEffect(.degrees(-8))
                .offset(x: -40, y: -85)

            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.8))
                .frame(width: 40, height: 14)
                .rotationEffect(.degrees(10))
                .offset(x: 50, y: 80)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }
}

// MARK: - ============================================
// MARK: - 2. 右Tab预览动画（选择时展示）
// MARK: - ============================================

/// 信物预览动画 - 用于右Tab选择时展示
struct KeepsakePreviewAnimation: View {
    let style: UnifiedKeepsakeStyle
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#F5F0E8"))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

            // 预览内容
            previewContent
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0)
        }
        .frame(width: 280, height: 360)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        switch style {
        case .polaroid:
            PolaroidPreviewAnimation(isAnimating: isAnimating)
        case .leicaFilm:
            LeicaPreviewAnimation(isAnimating: isAnimating)
        case .filmRoll:
            FilmRollPreviewAnimation(isAnimating: isAnimating)
        case .movieTicket:
            MovieTicketPreviewAnimation(isAnimating: isAnimating)
        case .trainTicket:
            TrainTicketPreviewAnimation(isAnimating: isAnimating)
        case .concertTicket:
            ConcertTicketPreviewAnimation(isAnimating: isAnimating)
        case .waxEnvelope:
            WaxEnvelopePreviewAnimation(isAnimating: isAnimating)
        case .postcard:
            PostcardPreviewAnimation(isAnimating: isAnimating)
        case .journalPage:
            JournalPreviewAnimation(isAnimating: isAnimating)
        case .vinylRecord:
            VinylPreviewAnimation(isAnimating: isAnimating)
        case .bookmark:
            BookmarkPreviewAnimation(isAnimating: isAnimating)
        case .pressedFlower:
            PressedFlowerPreviewAnimation(isAnimating: isAnimating)
        }
    }
}

// MARK: - 预览动画实现

/// 拍立得预览 - 照片从相机吐出
struct PolaroidPreviewAnimation: View {
    let isAnimating: Bool
    @State private var photoOffset: CGFloat = -100
    @State private var photoOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // 相机
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#E8E8E8"))
                    .frame(width: 160, height: 120)

                // 镜头
                Circle()
                    .fill(Color(hex: "#2C2C2C"))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .fill(Color(hex: "#4A90A4"))
                            .frame(width: 30, height: 30)
                    )
            }

            // 出片口
            Rectangle()
                .fill(Color(hex: "#2C2C2C"))
                .frame(width: 140, height: 6)

            // 照片吐出
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 120, height: 140)

                VStack(spacing: 8) {
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 100, height: 80)

                    Text("瞬间")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#4A4A4A"))
                }
            }
            .offset(y: photoOffset)
            .opacity(photoOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                photoOffset = 20
                photoOpacity = 1
            }
        }
    }
}

/// 徕卡预览 - 快门动画
struct LeicaPreviewAnimation: View {
    let isAnimating: Bool
    @State private var shutterScale: CGFloat = 1
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            // 相机
            LeicaHubEntry(isPressed: false)
                .scaleEffect(0.9)

            // 闪光效果
            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .opacity(flashOpacity)

            // 底片效果
            if isAnimating {
                FilmNegativeCard()
                    .offset(y: 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            // 快门动画
            withAnimation(.easeIn(duration: 0.1).delay(0.5)) {
                shutterScale = 0.95
            }
            withAnimation(.easeOut(duration: 0.1).delay(0.6)) {
                shutterScale = 1
            }

            // 闪光
            withAnimation(.easeIn(duration: 0.05).delay(0.55)) {
                flashOpacity = 0.8
            }
            withAnimation(.easeOut(duration: 0.2).delay(0.6)) {
                flashOpacity = 0
            }
        }
    }
}

/// 小型底片卡片
struct FilmNegativeCard: View {
    var body: some View {
        HStack(spacing: 0) {
            // 齿孔
            VStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#1A0F0A"))
                        .frame(width: 6, height: 8)
                }
            }

            Rectangle()
                .fill(Color(hex: "#FF6B35").opacity(0.5))
                .frame(width: 60, height: 40)

            VStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#1A0F0A"))
                        .frame(width: 6, height: 8)
                }
            }
        }
        .padding(4)
        .background(Color(hex: "#2C1810"))
        .cornerRadius(4)
    }
}

/// 胶卷预览
struct FilmRollPreviewAnimation: View {
    let isAnimating: Bool
    @State private var rollOffset: CGFloat = 0

    var body: some View {
        FilmRollHubEntry(isPressed: false)
            .scaleEffect(0.8)
            .offset(x: rollOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rollOffset = 20
                }
            }
    }
}

/// 电影票预览 - 撕票动画
struct MovieTicketPreviewAnimation: View {
    let isAnimating: Bool
    @State private var ticketRotation: Double = 0
    @State private var sparkle: Bool = false

    var body: some View {
        ZStack {
            MovieTicketHubEntry(isPressed: false)
                .rotationEffect(.degrees(ticketRotation))

            // 星星闪烁
            if sparkle {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "#FFD700"))
                        .font(.system(size: 12))
                        .offset(
                            x: CGFloat.random(in: -80...80),
                            y: CGFloat.random(in: -80...80)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.3)) {
                ticketRotation = -3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    sparkle = true
                }
            }
        }
    }
}

/// 火车票预览
struct TrainTicketPreviewAnimation: View {
    let isAnimating: Bool
    @State private var trainOffset: CGFloat = -50

    var body: some View {
        VStack {
            TrainTicketHubEntry(isPressed: false)

            // 火车移动
            Image(systemName: "tram.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "#1E5631"))
                .offset(x: trainOffset)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                trainOffset = 50
            }
        }
    }
}

/// 演唱会票预览
struct ConcertTicketPreviewAnimation: View {
    let isAnimating: Bool
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        ConcertTicketHubEntry(isPressed: false)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#FFD700"), lineWidth: 2)
                    .opacity(glowOpacity)
                    .blur(radius: 4)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.8
                }
            }
    }
}

/// 火漆信封预览 - 盖章动画
struct WaxEnvelopePreviewAnimation: View {
    let isAnimating: Bool
    @State private var sealScale: CGFloat = 1.5
    @State private var sealOpacity: Double = 0

    var body: some View {
        ZStack {
            // 信封
            WaxEnvelopeHubEntry(isPressed: false)
                .scaleEffect(0.9)

            // 火漆印章落下
            ZStack {
                Circle()
                    .fill(Color(hex: "#8B0000"))
                    .frame(width: 50, height: 50)

                Text("封")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            .scaleEffect(sealScale)
            .opacity(sealOpacity)
            .offset(y: -20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                sealScale = 1
                sealOpacity = 1
            }
        }
    }
}

/// 明信片预览
struct PostcardPreviewAnimation: View {
    let isAnimating: Bool
    @State private var rotation3D: Double = 0

    var body: some View {
        PostcardHubEntry(isPressed: false)
            .rotation3DEffect(.degrees(rotation3D), axis: (x: 0, y: 1, z: 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    rotation3D = 15
                }
            }
    }
}

/// 日记预览 - 翻页动画
struct JournalPreviewAnimation: View {
    let isAnimating: Bool
    @State private var pageFlip: Double = 0

    var body: some View {
        JournalHubEntry(isPressed: false)
            .rotation3DEffect(.degrees(pageFlip), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pageFlip = 10
                }
            }
    }
}

/// 黑胶预览 - 旋转
struct VinylPreviewAnimation: View {
    let isAnimating: Bool

    var body: some View {
        VinylRecordHubEntry(isPressed: false)
    }
}

/// 书签预览
struct BookmarkPreviewAnimation: View {
    let isAnimating: Bool
    @State private var swingAngle: Double = 0

    var body: some View {
        BookmarkHubEntry(isPressed: false)
            .rotationEffect(.degrees(swingAngle), anchor: .top)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    swingAngle = 5
                }
            }
    }
}

/// 干花预览
struct PressedFlowerPreviewAnimation: View {
    let isAnimating: Bool
    @State private var flowerScale: CGFloat = 0.9

    var body: some View {
        PressedFlowerHubEntry(isPressed: false)
            .scaleEffect(flowerScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    flowerScale = 1.0
                }
            }
    }
}

// MARK: - ============================================
// MARK: - 3. 右Tab信物选择器（带预览动画）
// MARK: - ============================================

struct KeepsakeStylePicker: View {
    @Binding var selectedStyle: UnifiedKeepsakeStyle
    @State private var previewStyle: UnifiedKeepsakeStyle?
    @State private var showPreview = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F0E8").ignoresSafeArea()

                VStack(spacing: 0) {
                    // 预览区域
                    previewArea
                        .frame(height: 400)

                    // 分类滚动选择
                    categoryPicker
                }
            }
            .navigationTitle("选择信物样式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#D4A574"))
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - 预览区域
    private var previewArea: some View {
        ZStack {
            // 当前选中样式的预览动画
            KeepsakePreviewAnimation(style: previewStyle ?? selectedStyle)
                .id(previewStyle ?? selectedStyle) // 强制刷新动画

            // 样式名称
            VStack {
                Spacer()

                VStack(spacing: 4) {
                    Text((previewStyle ?? selectedStyle).displayName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#2C2C2C"))

                    Text((previewStyle ?? selectedStyle).subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#8B8B8B"))
                }
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - 分类选择器
    private var categoryPicker: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(KeepsakeCategory.allCases, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        // 分类标题
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14))
                            Text(category.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#4A4A4A"))
                        .padding(.horizontal, 20)

                        // 样式卡片
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(category.styles) { style in
                                    StyleCard(
                                        style: style,
                                        isSelected: selectedStyle == style,
                                        isHighlighted: previewStyle == style
                                    ) {
                                        // 点击选中
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedStyle = style
                                            previewStyle = style
                                        }

                                        // 震动反馈
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

/// 样式卡片（带缩略图标）
struct StyleCard: View {
    let style: UnifiedKeepsakeStyle
    let isSelected: Bool
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // 图标圆圈
                ZStack {
                    Circle()
                        .fill(style.primaryColor)
                        .frame(width: 56, height: 56)

                    Circle()
                        .stroke(style.accentColor.opacity(0.5), lineWidth: 2)
                        .frame(width: 56, height: 56)

                    Image(systemName: style.icon)
                        .font(.system(size: 24))
                        .foregroundColor(style.accentColor)
                }
                .overlay(
                    // 选中指示
                    Circle()
                        .stroke(Color(hex: "#D4A574"), lineWidth: 3)
                        .frame(width: 64, height: 64)
                        .opacity(isSelected ? 1 : 0)
                )
                .scaleEffect(isHighlighted ? 1.1 : 1.0)

                // 名称
                Text(style.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "#D4A574") : Color(hex: "#4A4A4A"))
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ============================================
// MARK: - 辅助扩展
// MARK: - ============================================





// MARK: - ============================================
// MARK: - 预览
// MARK: - ============================================

#Preview("信物选择器") {
    KeepsakeStylePicker(selectedStyle: .constant(.polaroid))
}

#Preview("所有Hub入口") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 30) {
            ForEach(UnifiedKeepsakeStyle.allCases) { style in
                VStack {
                    Text(style.displayName)
                        .font(.headline)
                    KeepsakeHubEntry(style: style) {}
                }
            }
        }
        .padding()
    }
    .background(Color(hex: "#F5F0E8"))
}

#Preview("预览动画") {
    VStack {
        KeepsakePreviewAnimation(style: .polaroid)
    }
    .background(Color(hex: "#F5F0E8"))
}

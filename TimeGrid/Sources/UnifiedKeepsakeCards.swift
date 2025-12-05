//
//  UnifiedKeepsakeCards.swift
//  时光格 - 统一信物卡片（最终产出）
//
//  与 UnifiedKeepsakeSystem.swift 配合使用
//  每种信物类型都有独特的最终卡片样式
//

import SwiftUI

// MARK: - ============================================
// MARK: - 信物卡片统一入口
// MARK: - ============================================

/// 信物卡片 - 根据样式自动选择对应视图
struct UnifiedKeepsakeCard: View {
    let style: UnifiedKeepsakeStyle
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?

    var body: some View {
        switch style {
        case .polaroid:
            PolaroidCard(content: content, date: date, mood: mood, photo: photo)
        case .leicaFilm:
            LeicaFilmCard(content: content, date: date, mood: mood, photo: photo)
        case .filmRoll:
            FilmRollCard(content: content, date: date, mood: mood, photo: photo)
        case .movieTicket:
            MovieTicketCard(content: content, date: date, mood: mood)
        case .trainTicket:
            TrainTicketCard(content: content, date: date, mood: mood)
        case .concertTicket:
            ConcertTicketCard(content: content, date: date, mood: mood)
        case .waxEnvelope:
            WaxEnvelopeCard(content: content, date: date, mood: mood)
        case .postcard:
            PostcardCard(content: content, date: date, mood: mood, photo: photo)
        case .journalPage:
            JournalPageCard(content: content, date: date, mood: mood)
        case .vinylRecord:
            VinylRecordCard(content: content, date: date, mood: mood)
        case .bookmark:
            BookmarkCard(content: content, date: date, mood: mood)
        case .pressedFlower:
            PressedFlowerCard(content: content, date: date, mood: mood)
        }
    }
}

// MARK: - ============================================
// MARK: - 1. 拍立得卡片
// MARK: - ============================================

struct PolaroidCard: View {
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            // 照片区域
            ZStack {
                Rectangle()
                    .fill(Color(hex: "#1C1C1C"))

                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 12) {
                        Text(mood.emoji)
                            .font(.system(size: 60))

                        Text(content.prefix(40))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .lineLimit(2)
                    }
                }
            }
            .frame(height: 220)
            .clipped()

            // 底部白边
            VStack(spacing: 6) {
                Text(content.prefix(50))
                    .font(.custom("Bradley Hand", size: 15))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)

                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#9A9A9A"))
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .frame(width: 240)
        .background(Color.white)
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        .rotationEffect(.degrees(-2))
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 2. 徕卡胶片卡片
// MARK: - ============================================

struct LeicaFilmCard: View {
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?

    var body: some View {
        HStack(spacing: 0) {
            // 左侧齿孔
            filmPerforations

            // 主体
            VStack(spacing: 8) {
                // 帧号
                HStack {
                    Text("LEICA M")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "#C41E3A"))
                    Spacer()
                    Text("→ 24")
                        .font(.system(size: 8))
                        .foregroundColor(Color(hex: "#FF6B35"))
                }

                // 底片效果
                ZStack {
                    if let photo = photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .colorInvert()
                            .saturation(0.3)
                            .opacity(0.8)
                    } else {
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF6B35").opacity(0.4),
                                Color(hex: "#2C1810")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 40))
                            Text(content.prefix(20))
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#FF6B35").opacity(0.8))
                        }
                    }
                }
                .frame(height: 160)
                .clipped()

                // 底部信息
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 7))
                    Spacer()
                    Text(content.prefix(12))
                        .font(.system(size: 7))
                }
                .foregroundColor(Color(hex: "#FF6B35").opacity(0.8))
            }
            .padding(10)
            .frame(width: 200)

            // 右侧齿孔
            filmPerforations
        }
        .background(Color(hex: "#2C1810"))
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }

    private var filmPerforations: some View {
        VStack(spacing: 8) {
            ForEach(0..<10, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "#1A0F0A"))
                    .frame(width: 10, height: 14)
            }
        }
        .padding(.vertical, 10)
        .frame(width: 18)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 3. 胶卷冲洗卡片
// MARK: - ============================================

struct FilmRollCard: View {
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            // 照片主体 - 复古色调
            ZStack {
                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .saturation(0.8)
                        .contrast(1.1)
                        .overlay(Color(hex: "#D4A574").opacity(0.15))
                } else {
                    LinearGradient(
                        colors: [Color(hex: "#FFF8E7"), Color(hex: "#E8DCC8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 16) {
                        Text(mood.emoji)
                            .font(.system(size: 56))

                        Text(content.prefix(60))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5A4A3A"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(3)
                    }
                }
            }
            .frame(height: 220)
            .clipped()

            // 冲印店信息
            HStack {
                Text("FUJIFILM")
                    .font(.system(size: 9, weight: .bold))
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 9))
                Spacer()
                Text("PRINT")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(Color(hex: "#FF6B35"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#FFF8E7"))
        }
        .frame(width: 220)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(hex: "#E0D5C5"), lineWidth: 1)
        )
        // 照片堆叠效果
        .background(
            Color.white
                .offset(x: 4, y: 4)
                .shadow(color: .black.opacity(0.08), radius: 2)
        )
        .background(
            Color.white
                .offset(x: 8, y: 8)
                .shadow(color: .black.opacity(0.04), radius: 1)
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 4. 电影票根卡片
// MARK: - ============================================

struct MovieTicketCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        HStack(spacing: 0) {
            // 主票面
            VStack(alignment: .leading, spacing: 10) {
                Text("GOLDEN AGE CINEMA")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#8B0000"))

                Text(content.prefix(24))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1C"))
                    .lineLimit(2)

                Spacer()

                // 场次信息
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DATE")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedShortDate)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TIME")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedTime)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("SEAT")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("G-12")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                }

                // 心情评分
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < moodStars ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#FFD700"))
                    }
                    Spacer()
                    Text(mood.emoji)
                        .font(.system(size: 22))
                }
            }
            .padding(14)
            .frame(width: 200, height: 160)

            // 锯齿分割
            TicketTearLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundColor(Color(hex: "#C41E3A").opacity(0.4))
                .frame(width: 1)

            // 副券
            VStack(spacing: 6) {
                Text("ADMIT")
                    .font(.system(size: 8, weight: .bold))
                Text("ONE")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Text("NO.")
                    .font(.system(size: 6))
                Text(ticketNumber)
                    .font(.system(size: 8, design: .monospaced))
            }
            .foregroundColor(Color(hex: "#8B0000"))
            .padding(10)
            .frame(width: 55, height: 160)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFF8E7"), Color(hex: "#FFEBCD")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#C41E3A"), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private var formattedShortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private var moodStars: Int {
        switch mood {
        case .joyful: return 5
        case .peaceful: return 4
        case .neutral: return 3
        case .sad: return 2
        case .anxious: return 2
        case .angry: return 1
        }
    }

    private var ticketNumber: String {
        String(format: "%06d", abs(date.hashValue) % 1000000)
    }
}

struct TicketTearLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

// MARK: - ============================================
// MARK: - 5. 火车票卡片
// MARK: - ============================================

struct TrainTicketCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        VStack(spacing: 0) {
            // 顶部色带
            Rectangle()
                .fill(Color(hex: "#1E5631"))
                .frame(height: 10)

            VStack(spacing: 14) {
                // 路线
                HStack {
                    VStack(alignment: .leading) {
                        Text("FROM")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("此刻")
                            .font(.system(size: 20, weight: .bold))
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 22))
                        Text(mood.emoji)
                            .font(.system(size: 18))
                    }
                    .foregroundColor(Color(hex: "#1E5631"))

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("TO")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("远方")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .foregroundColor(Color(hex: "#1C1C1C"))

                // 分隔线
                Rectangle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(height: 1)

                // 内容
                Text(content.prefix(40))
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 底部信息
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("DATE")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedDate)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }

                    Spacer()

                    VStack(spacing: 3) {
                        Text("CAR")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("08")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }

                    Spacer()

                    VStack(spacing: 3) {
                        Text("SEAT")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("15A")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }

                    Spacer()

                    // 二维码
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "#1C1C1C"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "qrcode")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(18)
            .foregroundColor(Color(hex: "#1C1C1C"))
        }
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#1E5631").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 6. 演唱会票卡片
// MARK: - ============================================

struct ConcertTicketCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        ZStack {
            // 黑色背景
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#1C1C1C"))

            // 金色边框
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "#FFD700"),
                            Color(hex: "#B8860B"),
                            Color(hex: "#FFD700")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )

            VStack(spacing: 18) {
                // 顶部星星
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color(hex: "#FFD700"))

                // 演出名
                Text(content.prefix(24))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("LIVE CONCERT")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(5)
                    .foregroundColor(Color(hex: "#FFD700"))

                // 心情
                Text(mood.emoji)
                    .font(.system(size: 40))

                // 日期时间
                VStack(spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 13, design: .monospaced))
                    Text(formattedTime)
                        .font(.system(size: 11, design: .monospaced))
                }
                .foregroundColor(Color(hex: "#B8B8B8"))

                // 底部星星
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color(hex: "#FFD700"))
            }
            .padding(24)
        }
        .frame(width: 220, height: 300)
        .shadow(color: Color(hex: "#FFD700").opacity(0.3), radius: 15, y: 8)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 7. 火漆信封卡片
// MARK: - ============================================

struct WaxEnvelopeCard: View {
    let content: String
    let date: Date
    let mood: Mood

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
                .frame(width: 260, height: 180)

            // 纹理线条
            VStack(spacing: 24) {
                ForEach(0..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "#C4A67C").opacity(0.5))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 35)
            .padding(.top, 50)

            // 封口三角
            TriangleShape()
                .fill(Color(hex: "#C9A96A"))
                .frame(width: 260, height: 90)
                .offset(y: -45)

            // 火漆印章
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#8B0000"), Color(hex: "#5C0000")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                // 印章图案
                VStack(spacing: 2) {
                    Text(mood.emoji)
                        .font(.system(size: 20))
                    Text("封")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            .shadow(color: .black.opacity(0.35), radius: 4, y: 3)
            .offset(y: -20)

            // 日期戳
            Text(formattedDate)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(Color(hex: "#6B5344"))
                .offset(x: 80, y: 60)

            // 内容预览（斜角）
            Text(content.prefix(20) + "...")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "#8B7355"))
                .offset(x: -50, y: 60)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - ============================================
// MARK: - 8. 明信片卡片
// MARK: - ============================================

struct PostcardCard: View {
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?

    var body: some View {
        HStack(spacing: 0) {
            // 左侧 - 图片/风景
            ZStack {
                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color(hex: "#87CEEB"), Color(hex: "#4682B4")],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(spacing: 8) {
                        Text("✈️")
                            .font(.system(size: 44))
                        Text("GREETINGS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 155, height: 200)
            .clipped()

            // 右侧 - 书写区
            VStack(alignment: .trailing, spacing: 10) {
                // 邮票
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 36, height: 48)

                    Rectangle()
                        .stroke(Color(hex: "#C41E3A"), lineWidth: 1)
                        .frame(width: 32, height: 44)

                    Text(mood.emoji)
                        .font(.system(size: 18))
                }

                // 地址线
                VStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(hex: "#D3D3D3"))
                            .frame(height: 1)
                    }
                }

                Spacer()

                // 手写内容
                Text(content.prefix(50))
                    .font(.custom("Bradley Hand", size: 12))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 日期
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#9A9A9A"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .frame(width: 155, height: 200)
            .background(Color(hex: "#FFF8E7"))
        }
        .background(Color.white)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#D3D3D3"), lineWidth: 1)
        )
        .rotationEffect(.degrees(2))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 9. 日记页卡片
// MARK: - ============================================

struct JournalPageCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        ZStack {
            // 纸张背景
            Rectangle()
                .fill(Color(hex: "#FFF8DC"))

            // 横线
            VStack(spacing: 28) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "#B8D4E3").opacity(0.5))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 70)

            // 红色边线
            Rectangle()
                .fill(Color(hex: "#C41E3A").opacity(0.5))
                .frame(width: 1)
                .offset(x: -100)

            // 内容
            VStack(alignment: .leading, spacing: 18) {
                // 日期头
                HStack {
                    Text(formattedDateCN)
                        .font(.system(size: 15, weight: .medium))

                    Spacer()

                    Text(weekday)
                        .font(.system(size: 13))

                    Text(mood.emoji)
                        .font(.system(size: 20))
                }
                .foregroundColor(Color(hex: "#4A4A4A"))

                // 手写内容
                Text(content)
                    .font(.custom("Bradley Hand", size: 15))
                    .foregroundColor(Color(hex: "#2C2C2C"))
                    .lineSpacing(12)
                    .lineLimit(7)
            }
            .padding(.horizontal, 35)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // 装订孔
            VStack(spacing: 50) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "#4A4A4A").opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .offset(x: -115)
        }
        .frame(width: 240, height: 320)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var formattedDateCN: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 10. 黑胶唱片卡片
// MARK: - ============================================

struct VinylRecordCard: View {
    let content: String
    let date: Date
    let mood: Mood

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // 封套
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#1C1C1C"))
                .frame(width: 220, height: 220)

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
                .frame(width: 180, height: 180)
                .overlay(
                    // 纹路
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .stroke(Color(hex: "#2C2C2C"), lineWidth: 0.5)
                            .frame(width: CGFloat(40 + i * 25))
                    }
                )
                .overlay(
                    // 中心标签
                    Circle()
                        .fill(Color(hex: "#C41E3A"))
                        .frame(width: 60, height: 60)
                        .overlay(
                            VStack(spacing: 2) {
                                Text(mood.emoji)
                                    .font(.system(size: 18))
                                Text("SIDE A")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        )
                )
                .rotationEffect(.degrees(rotation))
                .offset(x: 35)

            // 封面信息
            VStack(alignment: .leading, spacing: 8) {
                Text(content.prefix(20))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text("VINYL RECORD")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: "#888888"))

                Spacer()

                Text(formattedYear)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#666666"))
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 220, height: 220)
        .shadow(color: .black.opacity(0.25), radius: 15, y: 8)
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private var formattedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 11. 书签卡片
// MARK: - ============================================

struct BookmarkCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        ZStack {
            // 书签形状
            BookmarkCardShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#722F37"), Color(hex: "#4A1C24")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 90, height: 280)

            // 金边
            BookmarkCardShape()
                .stroke(Color(hex: "#FFD700").opacity(0.6), lineWidth: 1)
                .frame(width: 86, height: 276)

            // 内容
            VStack(spacing: 18) {
                // 图标
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#FFD700"))

                // 引号
                Text("「")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.6))

                // 内容
                Text(content.prefix(60))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .padding(.horizontal, 10)

                Text("」")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.6))

                Spacer()

                // 心情和日期
                VStack(spacing: 6) {
                    Text(mood.emoji)
                        .font(.system(size: 22))
                    Text(formattedDate)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 35)
        }
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

struct BookmarkCardShape: Shape {
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

// MARK: - ============================================
// MARK: - 12. 干花标本卡片
// MARK: - ============================================

struct PressedFlowerCard: View {
    let content: String
    let date: Date
    let mood: Mood

    var body: some View {
        ZStack {
            // 标本纸
            Rectangle()
                .fill(Color(hex: "#FFF8E7"))

            // 纸张纹理
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "#E8DCC8").opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 18) {
                // 干花图案
                ZStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.6))
                        .rotationEffect(.degrees(-30))
                        .offset(x: -35, y: 12)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.5))
                        .rotationEffect(.degrees(20))
                        .offset(x: 30, y: -8)

                    Text(flowerEmoji)
                        .font(.system(size: 60))
                }
                .frame(height: 100)

                // 学名风格
                Text(content.prefix(40))
                    .font(.custom("Bradley Hand", size: 13))
                    .italic()
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16)

                // 标本信息
                VStack(spacing: 6) {
                    Rectangle()
                        .fill(Color(hex: "#DEB887"))
                        .frame(width: 70, height: 1)

                    Text(mood.label)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#8B7355"))

                    Text(formattedDate)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#A0926E"))
                }
            }
            .padding(24)

            // 胶带装饰
            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.75))
                .frame(width: 60, height: 22)
                .rotationEffect(.degrees(-6))
                .offset(x: -55, y: -105)

            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.75))
                .frame(width: 50, height: 18)
                .rotationEffect(.degrees(8))
                .offset(x: 60, y: 100)
        }
        .frame(width: 200, height: 260)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#DEB887"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var flowerEmoji: String {
        switch mood {
        case .joyful: return "🌻"
        case .peaceful: return "🌸"
        case .neutral: return "🌿"
        case .sad: return "🥀"
        case .anxious: return "🍂"
        case .angry: return "🌵"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - Mood 枚举（如果尚未定义）
// MARK: - ============================================

enum Mood: String, CaseIterable, Codable, Identifiable {
    case joyful = "欢乐"
    case peaceful = "平静"
    case neutral = "一般"
    case sad = "难过"
    case anxious = "焦虑"
    case angry = "生气"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .joyful: return "😊"
        case .peaceful: return "😌"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .angry: return "😤"
        }
    }

    var label: String { rawValue }
}

// MARK: - ============================================
// MARK: - 预览
// MARK: - ============================================

#Preview("所有信物卡片") {
    ScrollView {
        VStack(spacing: 40) {
            ForEach(UnifiedKeepsakeStyle.allCases) { style in
                VStack(spacing: 12) {
                    Text(style.displayName)
                        .font(.headline)

                    UnifiedKeepsakeCard(
                        style: style,
                        content: "今天是美好的一天，阳光正好，微风不燥，一切都刚刚好。",
                        date: Date(),
                        mood: .joyful,
                        photo: nil
                    )
                }
            }
        }
        .padding()
    }
    .background(Color(hex: "#F5F0E8"))
}

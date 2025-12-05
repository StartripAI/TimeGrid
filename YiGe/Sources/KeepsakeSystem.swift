//
//  KeepsakeSystem.swift
//  时光格 V4.2 - 完整信物系统
//
//  12种信物，与中Tab样式一一呼应
//

import SwiftUI
import UIKit

// MARK: - ============================================
// MARK: - 信物类型枚举
// MARK: - ============================================

public enum KeepsakeType: String, CaseIterable, Codable, Identifiable {
    // 影像类
    case polaroidPhoto      // 拍立得照片
    case filmNegative       // 胶片底片
    case developedPhoto     // 冲洗照片
    
    // 票据类
    case movieTicket        // 电影票根
    case trainTicket        // 车票
    case concertTicket      // 演出票
    
    // 书信类
    case waxSealEnvelope    // 火漆信封
    case postcard           // 手写明信片
    case journalPage        // 日记内页
    
    // 收藏类
    case vinylSleeve        // 唱片封套
    case bookmark           // 书签
    case pressedFlower      // 干花标本
    
    public var id: String { rawValue }
    
    // MARK: - 基础属性
    
    var displayName: String {
        switch self {
        case .polaroidPhoto: return "拍立得"
        case .filmNegative: return "胶片底片"
        case .developedPhoto: return "冲洗照片"
        case .movieTicket: return "电影票根"
        case .trainTicket: return "车票"
        case .concertTicket: return "演出票"
        case .waxSealEnvelope: return "火漆信封"
        case .postcard: return "明信片"
        case .journalPage: return "日记页"
        case .vinylSleeve: return "唱片封套"
        case .bookmark: return "书签"
        case .pressedFlower: return "干花标本"
        }
    }
    
    var description: String {
        switch self {
        case .polaroidPhoto: return "即拍即得的生活瞬间"
        case .filmNegative: return "珍藏的光影记忆"
        case .developedPhoto: return "等待显影的惊喜"
        case .movieTicket: return "银幕前的故事"
        case .trainTicket: return "旅途中的风景"
        case .concertTicket: return "现场的感动"
        case .waxSealEnvelope: return "郑重封存的话语"
        case .postcard: return "远方寄来的问候"
        case .journalPage: return "写给自己的私语"
        case .vinylSleeve: return "旋律里的时光"
        case .bookmark: return "书页间的感悟"
        case .pressedFlower: return "定格自然之美"
        }
    }
    
    var icon: String {
        switch self {
        case .polaroidPhoto: return "camera.fill"
        case .filmNegative: return "film"
        case .developedPhoto: return "photo.on.rectangle"
        case .movieTicket: return "ticket.fill"
        case .trainTicket: return "tram.fill"
        case .concertTicket: return "music.note"
        case .waxSealEnvelope: return "envelope.fill"
        case .postcard: return "rectangle.portrait.on.rectangle.portrait"
        case .journalPage: return "book.fill"
        case .vinylSleeve: return "opticaldisc.fill"
        case .bookmark: return "bookmark.fill"
        case .pressedFlower: return "leaf.fill"
        }
    }
    
    // MARK: - 对应的中Tab样式
    
    var matchingHubStyles: [String] {
        switch self {
        case .polaroidPhoto: return ["polaroid", "polaroidAlbum"]
        case .filmNegative: return ["leicaCamera", "filmRoll"]
        case .developedPhoto: return ["filmRoll", "darkroom"]
        case .movieTicket: return ["movieTicket", "cinema"]
        case .trainTicket: return ["travel", "journey"]
        case .concertTicket: return ["vinylRecord", "concert"]
        case .waxSealEnvelope: return ["envelope", "letter"]
        case .postcard: return ["postcard", "travel"]
        case .journalPage: return ["journal", "notebook"]
        case .vinylSleeve: return ["vinylRecord", "musicPlayer"]
        case .bookmark: return ["journal", "library"]
        case .pressedFlower: return ["botanical", "nature"]
        }
    }
    
    // MARK: - 颜色主题
    
    var primaryColor: Color {
        switch self {
        case .polaroidPhoto: return Color(hex: "#F5F5F5")
        case .filmNegative: return Color(hex: "#2C1810")
        case .developedPhoto: return Color(hex: "#FFF8E7")
        case .movieTicket: return Color(hex: "#C41E3A")
        case .trainTicket: return Color(hex: "#1E5631")
        case .concertTicket: return Color(hex: "#FFD700")
        case .waxSealEnvelope: return Color(hex: "#8B4513")
        case .postcard: return Color(hex: "#87CEEB")
        case .journalPage: return Color(hex: "#FFF8DC")
        case .vinylSleeve: return Color(hex: "#1C1C1C")
        case .bookmark: return Color(hex: "#722F37")
        case .pressedFlower: return Color(hex: "#228B22")
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .polaroidPhoto: return Color(hex: "#1C1C1C")
        case .filmNegative: return Color(hex: "#FF6B35")
        case .developedPhoto: return Color(hex: "#D4A574")
        case .movieTicket: return Color(hex: "#FFD700")
        case .trainTicket: return Color(hex: "#C41E3A")
        case .concertTicket: return Color(hex: "#1C1C1C")
        case .waxSealEnvelope: return Color(hex: "#C41E3A")
        case .postcard: return Color(hex: "#FF6B6B")
        case .journalPage: return Color(hex: "#4A4A4A")
        case .vinylSleeve: return Color(hex: "#FFFFFF")
        case .bookmark: return Color(hex: "#FFD700")
        case .pressedFlower: return Color(hex: "#DEB887")
        }
    }
    
    // MARK: - 分类
    
    var category: KeepsakeCategory {
        switch self {
        case .polaroidPhoto, .filmNegative, .developedPhoto:
            return .photography
        case .movieTicket, .trainTicket, .concertTicket:
            return .tickets
        case .waxSealEnvelope, .postcard, .journalPage:
            return .writing
        case .vinylSleeve, .bookmark, .pressedFlower:
            return .collection
        }
    }
    
    // MARK: - 根据TodayHub样式推荐
    
    public static func recommended(for hubStyle: String) -> KeepsakeType {
        switch hubStyle {
        case "polaroid", "polaroidAlbum":
            return .polaroidPhoto
        case "leicaCamera":
            return .filmNegative
        case "filmRoll", "darkroom":
            return .developedPhoto
        case "movieTicket", "cinema":
            return .movieTicket
        case "vinylRecord":
            return .vinylSleeve
        case "postcard":
            return .postcard
        case "journal", "notebook":
            return .journalPage
        case "envelope", "letter":
            return .waxSealEnvelope
        default:
            return .polaroidPhoto
        }
    }
    
}

// MARK: - 信物分类

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
    
    var types: [KeepsakeType] {
        KeepsakeType.allCases.filter { $0.category == self }
    }
}

// MARK: - ============================================
// MARK: - 信物卡片 - 统一入口
// MARK: - ============================================

/// 信物卡片 - 统一入口
struct KeepsakeCardView: View {
    let type: KeepsakeType
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?
    
    var body: some View {
        switch type {
        case .polaroidPhoto:
            PolaroidKeepsakeView(content: content, date: date, mood: mood, photo: photo)
        case .filmNegative:
            FilmNegativeKeepsakeView(content: content, date: date, mood: mood, photo: photo)
        case .developedPhoto:
            DevelopedPhotoKeepsakeView(content: content, date: date, mood: mood, photo: photo)
        case .movieTicket:
            MovieTicketKeepsakeView(content: content, date: date, mood: mood)
        case .trainTicket:
            TrainTicketKeepsakeView(content: content, date: date, mood: mood)
        case .concertTicket:
            ConcertTicketKeepsakeView(content: content, date: date, mood: mood)
        case .waxSealEnvelope:
            WaxSealEnvelopeKeepsakeView(content: content, date: date, mood: mood)
        case .postcard:
            PostcardKeepsakeView(content: content, date: date, mood: mood, photo: photo)
        case .journalPage:
            JournalPageKeepsakeView(content: content, date: date, mood: mood)
        case .vinylSleeve:
            VinylSleeveKeepsakeView(content: content, date: date, mood: mood)
        case .bookmark:
            BookmarkKeepsakeView(content: content, date: date, mood: mood)
        case .pressedFlower:
            PressedFlowerKeepsakeView(content: content, date: date, mood: mood)
        }
    }
}

// MARK: - ============================================
// MARK: - 影像类信物视图
// MARK: - ============================================

// MARK: - 1. 拍立得照片

struct PolaroidKeepsakeView: View {
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
                    // 无照片时显示心情
                    VStack(spacing: 8) {
                        Text(mood.emoji)
                            .font(.system(size: 48))
                        Text(content.prefix(30))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                }
            }
            .frame(height: 200)
            .clipped()
            
            // 底部白边 - 手写文字
            VStack(spacing: 4) {
                Text(content.prefix(40))
                    .font(.custom("Bradley Hand", size: 14))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .lineLimit(2)
                
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#9A9A9A"))
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .frame(width: 220)
        .background(Color.white)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        // 轻微倾斜
        .rotationEffect(.degrees(-2))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - 2. 胶片底片

struct FilmNegativeKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    let photo: UIImage?
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧齿孔
            filmPerforations
            
            // 主体内容
            VStack(spacing: 8) {
                // 帧号
                HStack {
                    Text("KODAK 400")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "#FF6B35"))
                    Spacer()
                    Text("→ 24A")
                        .font(.system(size: 8))
                        .foregroundColor(Color(hex: "#FF6B35"))
                }
                
                // 底片效果（负片色调）
                ZStack {
                    if let photo = photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .colorInvert()
                            .saturation(0.3)
                            .opacity(0.8)
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF6B35").opacity(0.3),
                                        Color(hex: "#2C1810")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(mood.emoji)
                            .font(.system(size: 36))
                            .colorInvert()
                    }
                }
                .frame(height: 140)
                .clipped()
                
                // 底部信息
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 7))
                    Spacer()
                    Text(content.prefix(15))
                        .font(.system(size: 7))
                }
                .foregroundColor(Color(hex: "#FF6B35").opacity(0.8))
            }
            .padding(8)
            .frame(width: 180)
            
            // 右侧齿孔
            filmPerforations
        }
        .background(Color(hex: "#2C1810"))
        .cornerRadius(4)
    }
    
    private var filmPerforations: some View {
        VStack(spacing: 6) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "#1A0F0A"))
                    .frame(width: 8, height: 12)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 16)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 3. 冲洗照片

struct DevelopedPhotoKeepsakeView: View {
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
                        .overlay(
                            Color(hex: "#D4A574").opacity(0.15)
                        )
                } else {
                    LinearGradient(
                        colors: [
                            Color(hex: "#FFF8E7"),
                            Color(hex: "#E8DCC8")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(spacing: 12) {
                        Text(mood.emoji)
                            .font(.system(size: 48))
                        Text(content.prefix(50))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5A4A3A"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .frame(height: 200)
            .clipped()
            
            // 冲印店信息条
            HStack {
                Text("FUJIFILM")
                    .font(.system(size: 8, weight: .bold))
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 8))
                Spacer()
                Text("PRINT")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundColor(Color(hex: "#FF6B35"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "#FFF8E7"))
        }
        .frame(width: 200)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(hex: "#E0D5C5"), lineWidth: 1)
        )
        // 照片堆叠效果
        .background(
            Color.white
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                .offset(x: 3, y: 3)
        )
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                .offset(x: 6, y: 6)
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 票据类信物视图
// MARK: - ============================================

// MARK: - 4. 电影票根

struct MovieTicketKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        HStack(spacing: 0) {
            // 主票面
            VStack(alignment: .leading, spacing: 8) {
                // 影院名
                Text("GOLDEN AGE CINEMA")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#8B0000"))
                
                // 电影名（用户内容）
                Text(content.prefix(20))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1C"))
                    .lineLimit(2)
                
                Spacer()
                
                // 场次信息
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DATE")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TIME")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedTime)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SEAT")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("G-12")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                }
                
                // 心情作为评分
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < moodStars ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FFD700"))
                    }
                    Spacer()
                    Text(mood.emoji)
                        .font(.system(size: 20))
                }
            }
            .padding(12)
            .frame(width: 180, height: 140)
            
            // 锯齿分割线
            TicketPerforationLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundColor(Color(hex: "#C41E3A").opacity(0.5))
                .frame(width: 1)
            
            // 副券
            VStack(spacing: 4) {
                Text("ADMIT")
                    .font(.system(size: 8, weight: .bold))
                Text("ONE")
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
                
                Text("NO.")
                    .font(.system(size: 6))
                Text(ticketNumber)
                    .font(.system(size: 8, design: .monospaced))
            }
            .foregroundColor(Color(hex: "#8B0000"))
            .padding(8)
            .frame(width: 50, height: 140)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFF8E7"), Color(hex: "#FFEBCD")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#C41E3A"), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    private var formattedDate: String {
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
        case .tired: return 2
        }
    }
    
    private var ticketNumber: String {
        String(format: "%06d", abs(date.hashValue) % 1000000)
    }
}

// MARK: - 锯齿线

struct TicketPerforationLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

// MARK: - 5. 车票

struct TrainTicketKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部色带
            Rectangle()
                .fill(Color(hex: "#1E5631"))
                .frame(height: 8)
            
            VStack(spacing: 12) {
                // 路线
                HStack {
                    VStack(alignment: .leading) {
                        Text("FROM")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("此刻")
                            .font(.system(size: 18, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // 箭头
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                        Text(mood.emoji)
                            .font(.system(size: 16))
                    }
                    .foregroundColor(Color(hex: "#1E5631"))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("TO")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("远方")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundColor(Color(hex: "#1C1C1C"))
                
                // 分隔线
                Rectangle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(height: 1)
                
                // 内容
                Text(content.prefix(30))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 底部信息
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DATE")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("SEAT")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                        Text("08A")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    
                    Spacer()
                    
                    // 二维码占位
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "#1C1C1C"))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "qrcode")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .foregroundColor(Color(hex: "#1C1C1C"))
        }
        .frame(width: 260)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#1E5631").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - 6. 演出票

struct ConcertTicketKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        ZStack {
            // 背景 - 黑金配色
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1C1C1C"))
            
            // 金色边框
            RoundedRectangle(cornerRadius: 12)
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
                    lineWidth: 2
                )
            
            VStack(spacing: 16) {
                // 星星装饰
                HStack {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                    }
                }
                .foregroundColor(Color(hex: "#FFD700"))
                
                // 演出名
                Text(content.prefix(20))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("LIVE CONCERT")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(4)
                    .foregroundColor(Color(hex: "#FFD700"))
                
                // 心情
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                // 日期
                Text(formattedDate)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(hex: "#B8B8B8"))
                
                // 底部装饰
                HStack {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                    }
                }
                .foregroundColor(Color(hex: "#FFD700"))
            }
            .padding(20)
        }
        .frame(width: 200, height: 260)
        .shadow(color: Color(hex: "#FFD700").opacity(0.3), radius: 10, y: 5)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 书信类信物视图
// MARK: - ============================================

// MARK: - 7. 火漆信封

struct WaxSealEnvelopeKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    @State private var isSealed = true
    
    var body: some View {
        ZStack {
            // 信封主体
            EnvelopeShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#DEB887"), Color(hex: "#D2B48C")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 240, height: 160)
            
            // 信封纹理线条
            VStack(spacing: 20) {
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(Color(hex: "#C4A67C").opacity(0.5))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 40)
            
            // 封口三角
            EnvelopeFlapShape()
                .fill(Color(hex: "#C9A96A"))
                .frame(width: 240, height: 80)
                .offset(y: -40)
            
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
                
                // 印章图案
                Text(mood.emoji)
                    .font(.system(size: 24))
            }
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            .offset(y: -20)
            
            // 日期戳
            Text(formattedDate)
                .font(.system(size: 10, design: .serif))
                .foregroundColor(Color(hex: "#6B5344"))
                .offset(x: 70, y: 50)
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - 信封形状

struct EnvelopeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 8, height: 8))
        return path
    }
}

struct EnvelopeFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - 8. 明信片

struct PostcardKeepsakeView: View {
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
                    
                    VStack {
                        Text("✈️")
                            .font(.system(size: 40))
                        Text("GREETINGS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 140, height: 180)
            .clipped()
            
            // 右侧 - 书写区
            VStack(alignment: .leading, spacing: 8) {
                // 邮票
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 40, height: 50)
                    
                    Rectangle()
                        .stroke(Color(hex: "#C41E3A"), lineWidth: 1)
                        .frame(width: 36, height: 46)
                    
                    Text(mood.emoji)
                        .font(.system(size: 20))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                // 分隔线
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(Color(hex: "#D3D3D3"))
                        .frame(height: 1)
                }
                
                Spacer()
                
                // 手写内容
                Text(content.prefix(40))
                    .font(.custom("Bradley Hand", size: 11))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .lineLimit(3)
                
                // 日期
                Text(formattedDate)
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "#9A9A9A"))
            }
            .padding(12)
            .frame(width: 140, height: 180)
            .background(Color(hex: "#FFF8E7"))
        }
        .background(Color.white)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#D3D3D3"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - 9. 日记内页

struct JournalPageKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        ZStack {
            // 纸张背景
            Rectangle()
                .fill(Color(hex: "#FFF8DC"))
            
            // 横线
            VStack(spacing: 24) {
                ForEach(0..<8) { _ in
                    Rectangle()
                        .fill(Color(hex: "#B8D4E3").opacity(0.5))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // 红色边线
            Rectangle()
                .fill(Color(hex: "#C41E3A").opacity(0.5))
                .frame(width: 1)
                .offset(x: -90)
            
            // 内容
            VStack(alignment: .leading, spacing: 16) {
                // 日期头
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Text(weekday)
                        .font(.system(size: 12))
                    
                    Text(mood.emoji)
                        .font(.system(size: 18))
                }
                .foregroundColor(Color(hex: "#4A4A4A"))
                
                // 手写内容
                Text(content)
                    .font(.custom("Bradley Hand", size: 14))
                    .foregroundColor(Color(hex: "#2C2C2C"))
                    .lineSpacing(10)
                    .lineLimit(6)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // 装订孔
            VStack(spacing: 40) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color(hex: "#4A4A4A").opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .offset(x: -105)
        }
        .frame(width: 220, height: 280)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    private var formattedDate: String {
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
// MARK: - 收藏类信物视图
// MARK: - ============================================

// MARK: - 10. 唱片封套

struct VinylSleeveKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        ZStack {
            // 封套背景
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#1C1C1C"))
            
            // 黑胶唱片（露出一部分）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#1C1C1C"),
                            Color(hex: "#2C2C2C"),
                            Color(hex: "#1C1C1C")
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    // 唱片纹路
                    Circle()
                        .stroke(Color(hex: "#3C3C3C"), lineWidth: 0.5)
                        .frame(width: 100)
                )
                .overlay(
                    // 中心标签
                    Circle()
                        .fill(Color(hex: "#C41E3A"))
                        .frame(width: 40)
                        .overlay(
                            Text(mood.emoji)
                                .font(.system(size: 16))
                        )
                )
                .offset(x: 40)
            
            // 封面信息
            VStack(alignment: .leading, spacing: 8) {
                Text(content.prefix(20))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("SIDE A")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#888888"))
                
                Spacer()
                
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#666666"))
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 200, height: 200)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - 11. 书签

struct BookmarkKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
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
            
            // 金色边框装饰
            BookmarkShape()
                .stroke(Color(hex: "#FFD700").opacity(0.6), lineWidth: 1)
                .padding(4)
            
            // 内容
            VStack(spacing: 16) {
                // 顶部装饰
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                // 引言内容
                Text("「")
                    .font(.system(size: 24, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.6))
                
                Text(content.prefix(50))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 12)
                
                Text("」")
                    .font(.system(size: 24, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.6))
                
                Spacer()
                
                // 心情和日期
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.system(size: 20))
                    Text(formattedDate)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .frame(width: 80, height: 240)
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - 书签形状

struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 顶部圆角
        path.move(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: rect.width - 8, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 8),
            control: CGPoint(x: rect.width, y: 0)
        )
        
        // 右边
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 30))
        
        // 底部V形
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height - 30))
        
        // 左边
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addQuadCurve(
            to: CGPoint(x: 8, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        return path
    }
}

// MARK: - 12. 干花标本

struct PressedFlowerKeepsakeView: View {
    let content: String
    let date: Date
    let mood: Mood
    
    var body: some View {
        ZStack {
            // 标本纸背景
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
            
            VStack(spacing: 16) {
                // 干花图案（用emoji表示，实际可用图片）
                ZStack {
                    // 叶子装饰
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.6))
                        .rotationEffect(.degrees(-30))
                        .offset(x: -30, y: 10)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#228B22").opacity(0.5))
                        .rotationEffect(.degrees(20))
                        .offset(x: 25, y: -5)
                    
                    // 中心花朵
                    Text(flowerEmoji)
                        .font(.system(size: 50))
                }
                .frame(height: 80)
                
                // 手写学名风格
                Text(content.prefix(30))
                    .font(.custom("Bradley Hand", size: 12))
                    .italic()
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // 标本信息
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(Color(hex: "#DEB887"))
                        .frame(width: 60, height: 1)
                    
                    Text(mood.label)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#8B7355"))
                    
                    Text(formattedDate)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "#A0926E"))
                }
            }
            .padding(20)
            
            // 胶带效果
            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.7))
                .frame(width: 60, height: 20)
                .rotationEffect(.degrees(-5))
                .offset(x: -50, y: -90)
            
            Rectangle()
                .fill(Color(hex: "#FFF5D7").opacity(0.7))
                .frame(width: 50, height: 18)
                .rotationEffect(.degrees(8))
                .offset(x: 55, y: 85)
        }
        .frame(width: 180, height: 220)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "#DEB887"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    private var flowerEmoji: String {
        switch mood {
        case .joyful: return "🌻"
        case .peaceful: return "🌸"
        case .neutral: return "🌿"
        case .sad: return "🥀"
        case .tired: return "🌧"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - ============================================
// MARK: - 信物选择器视图
// MARK: - ============================================

struct KeepsakePickerView: View {
    @Binding var selectedType: KeepsakeType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(KeepsakeCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            // 分类标题
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color("TextPrimary"))
                            .padding(.horizontal, 20)
                            
                            // 信物列表
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(category.types) { type in
                                        KeepsakeTypeCard(
                                            type: type,
                                            isSelected: selectedType == type
                                        ) {
                                            selectedType = type
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
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("选择信物样式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

// MARK: - 信物类型卡片

struct KeepsakeTypeCard: View {
    let type: KeepsakeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // 图标
                ZStack {
                    Circle()
                        .fill(type.primaryColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(type.secondaryColor)
                }
                
                // 名称
                Text(type.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                // 描述
                Text(type.description)
                    .font(.system(size: 10))
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color("PrimaryWarm") : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}



// MARK: - ============================================
// MARK: - 预览
// MARK: - ============================================

#Preview("所有信物") {
    ScrollView {
        VStack(spacing: 40) {
            ForEach(KeepsakeType.allCases) { type in
                VStack {
                    Text(type.displayName)
                        .font(.headline)
                    
                    KeepsakeCardView(
                        type: type,
                        content: "今天是美好的一天，阳光正好，微风不燥。",
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



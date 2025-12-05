//
//  MasterArtifacts_Tickets.swift
//  时光格 - 世界级信物模板：票据系列 🎫
//
//  包含：
//  1. 时光小票 (MonoTicket) - 1950s复古电影票
//  2. 流光邀约 (GalaInvite) - 奥斯卡颁奖邀请函
//  3. 演出门票 (ConcertTicket) - Live House演出票
//
//  设计参考：
//  - 1950s好莱坞电影票
//  - 奥斯卡颁奖典礼邀请函
//  - 现代Live House演出票
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎬 时光小票 (MonoTicket)
// MARK: - 参考：1950s好莱坞电影票、复古影院美学
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterMonoTicketView: View {
    let record: DayRecord
    
    @State private var shimmerOffset: CGFloat = -100
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机电影信息
    private var movieInfo: MovieTicketData {
        MovieTicketData.random(from: record.date)
    }
    
    var body: some View {
        ZStack {
            // ═══ 票纸背景 ═══
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5E6D3"),
                            Color(hex: "EED9C4"),
                            Color(hex: "E8D0B5")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 纸张纹理
            Canvas { context, size in
                for _ in 0..<3000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.02)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(spacing: 0) {
                // ═══ 顶部：影院名称 ═══
                VStack(spacing: 4) {
                    Text(movieInfo.theaterName)
                        .font(.system(size: 18, weight: .black, design: .serif))
                        .foregroundColor(Color(hex: "8B0000"))
                        .tracking(2)
                    
                    Rectangle()
                        .fill(Color(hex: "8B0000"))
                        .frame(height: 2)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                // ═══ 电影信息区 ═══
                HStack(spacing: 0) {
                    // ═══ 左侧：电影海报/照片 ═══
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "D0C0B0"))
                            .frame(width: 100, height: 140)
                        
                        if let photo = photos.first {
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 96, height: 136)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .saturation(0.7) // 复古去色
                        } else {
                            VStack(spacing: 8) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 40))
                                
                                Text("MEMORY")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: "8B7355"))
                            }
                        }
                        
                        // 胶片齿孔效果
                        VStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { i in
                                HStack(spacing: 0) {
                                    Circle()
                                        .fill(Color(hex: "F5E6D3"))
                                        .frame(width: 3, height: 3)
                                    Spacer()
                                    Circle()
                                        .fill(Color(hex: "F5E6D3"))
                                        .frame(width: 3, height: 3)
                                }
                                .frame(height: 17)
                            }
                        }
                        .frame(width: 100, height: 140)
                    }
                    .padding(.leading, 15)
                    .padding(.top, 15)
                    
                    // ═══ 右侧：详细信息 ═══
                    VStack(alignment: .leading, spacing: 10) {
                        // 电影标题
                        Text(movieInfo.movieTitle)
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .lineLimit(2)
                        
                        // 日期和时间
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "8B7355"))
                                Text(movieInfo.date)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "5D4037"))
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "8B7355"))
                                Text(movieInfo.time)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "5D4037"))
                            }
                        }
                        
                        // 座位信息
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SEAT")
                                    .font(.system(size: 7))
                                    .foregroundColor(Color(hex: "8B7355"))
                                Text(movieInfo.seat)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(hex: "8B0000"))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PRICE")
                                    .font(.system(size: 7))
                                    .foregroundColor(Color(hex: "8B7355"))
                                Text(movieInfo.price)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                            }
                        }
                        
                        Spacer()
                        
                        // 心情
                        Text(record.mood.emoji)
                            .font(.system(size: 24))
                            .padding(.bottom, 10)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 15)
                    .padding(.top, 15)
                }
                
                // ═══ 打孔边缘 ═══
                HStack(spacing: 0) {
                    ForEach(0..<20, id: \.self) { i in
                        Circle()
                            .fill(Color(hex: "F5E6D3"))
                            .frame(width: 6, height: 6)
                        if i < 19 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 15)
                
                // ═══ 存根区 ═══
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ADMIT ONE")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "8B0000"))
                            .tracking(2)
                        
                        Text(movieInfo.theaterName)
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(Color(hex: "5D4037"))
                        
                        Text(movieInfo.seat)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "8B0000"))
                    }
                    
                    Spacer()
                    
                    // 条形码
                    BarcodeView(width: 80, height: 25)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(Color(hex: "E8D5C4"))
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "8B7355").opacity(0.3), lineWidth: 1)
        }
        .frame(width: 280, height: 220)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }
}

// MARK: - 电影票数据
struct MovieTicketData {
    let movieTitle: String
    let theaterName: String
    let date: String
    let time: String
    let seat: String
    let price: String
    
    static func random(from date: Date) -> MovieTicketData {
        let movies = [
            "MEMORY", "时光之旅", "昨日重现", "永恒瞬间",
            "THE MOMENT", "时光定格", "记忆碎片", "流年"
        ]
        
        let theaters = [
            "GRAND THEATER", "时光影院", "CLASSIC CINEMA", "记忆剧场"
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let dateStr = formatter.string(from: date).uppercased()
        
        let hour = Int.random(in: 14...22)
        let minute = [0, 15, 30, 45].randomElement()!
        let timeStr = String(format: "%02d:%02d", hour, minute)
        
        let row = ["A", "B", "C", "D", "E", "F", "G", "H"].randomElement()!
        let num = Int.random(in: 1...20)
        let seat = "\(row)\(num)"
        
        let prices = ["¥35", "¥45", "¥55", "¥65"]
        
        return MovieTicketData(
            movieTitle: movies.randomElement()!,
            theaterName: theaters.randomElement()!,
            date: dateStr,
            time: timeStr,
            seat: seat,
            price: prices.randomElement()!
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🏆 流光邀约 (GalaInvite)
// MARK: - 参考：奥斯卡颁奖典礼邀请函、金色流光效果
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterGalaInviteView: View {
    let record: DayRecord
    
    @State private var goldShimmer: CGFloat = -200
    @State private var shimmerAngle: Double = 0
    
    private var photos: [UIImage] {
        record.photos.prefix(2).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 深色背景 ═══
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1A1A1A"),
                            Color(hex: "0D0D0D"),
                            Color(hex: "1A1A1A")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 暗纹图案
            Canvas { context, size in
                // 装饰性几何图案
                for i in 0..<8 {
                    let angle = Double(i) * 45.0 * .pi / 180.0
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius: CGFloat = 80
                    let start = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    let end = CGPoint(
                        x: center.x + cos(angle) * (radius + 40),
                        y: center.y + sin(angle) * (radius + 40)
                    )
                    
                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)
                    context.stroke(path, with: .color(Color(hex: "D4AF37").opacity(0.1)), lineWidth: 1)
                }
            }
            
            VStack(spacing: 0) {
                // ═══ 顶部装饰 ═══
                HStack {
                    // 左上角装饰
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(Color(hex: "D4AF37"))
                            .frame(width: 30, height: 2)
                        Rectangle()
                            .fill(Color(hex: "D4AF37"))
                            .frame(width: 20, height: 2)
                    }
                    
                    Spacer()
                    
                    // 右上角装饰
                    VStack(alignment: .trailing, spacing: 4) {
                        Rectangle()
                            .fill(Color(hex: "D4AF37"))
                            .frame(width: 30, height: 2)
                        Rectangle()
                            .fill(Color(hex: "D4AF37"))
                            .frame(width: 20, height: 2)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                // ═══ 主标题 ═══
                VStack(spacing: 8) {
                    Text("YIGE")
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37"))
                        .tracking(8)
                    
                    Text("GALA INVITATION")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37").opacity(0.7))
                        .tracking(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37").opacity(0.3),
                                    Color(hex: "D4AF37").opacity(0.6),
                                    Color(hex: "D4AF37").opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                // ═══ 照片区域（如有）═══
                if !photos.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(0..<min(2, photos.count), id: \.self) { i in
                            Image(uiImage: photos[i])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: photos.count == 1 ? 200 : 120, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hex: "D4AF37").opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 20)
                }
                
                // ═══ 邀请文字 ═══
                VStack(spacing: 12) {
                    Text("You are cordially invited")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37").opacity(0.8))
                        .tracking(2)
                    
                    Text(record.content.isEmpty ? "To celebrate this moment" : String(record.content.prefix(50)))
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                    
                    Text(formattedDate)
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37").opacity(0.7))
                        .tracking(2)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // ═══ 底部装饰和签名 ═══
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "D4AF37").opacity(0.3),
                                    Color(hex: "D4AF37").opacity(0.6),
                                    Color(hex: "D4AF37").opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                    
                    Text("RSVP")
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37").opacity(0.6))
                        .tracking(3)
                }
                .padding(.bottom, 25)
            }
            
            // ═══ 流光效果 ═══
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "D4AF37").opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100, height: 400)
                .offset(x: goldShimmer)
                .rotationEffect(.degrees(shimmerAngle))
                .mask(RoundedRectangle(cornerRadius: 12))
            
            // ═══ 金色边框 ═══
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "D4AF37").opacity(0.6),
                            Color(hex: "D4AF37").opacity(0.3),
                            Color(hex: "D4AF37").opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .frame(width: 300, height: 420)
        .shadow(color: Color(hex: "D4AF37").opacity(0.3), radius: 20, y: 10)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                goldShimmer = 400
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                shimmerAngle = 360
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: record.date).uppercased()
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎸 演出门票 (ConcertTicket)
// MARK: - 参考：Live House演出票、霓虹光效
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterConcertTicketView: View {
    let record: DayRecord
    
    @State private var neonGlow: Double = 0.5
    @State private var gradientShift: Double = 0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机演出信息
    private var concertInfo: ConcertTicketData {
        ConcertTicketData.random(from: record.date)
    }
    
    var body: some View {
        ZStack {
            // ═══ 深色背景 ═══
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0A0A0A"),
                            Color(hex: "1A0A1A"),
                            Color(hex: "0A0A0A")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 0) {
                // ═══ 顶部：演出名称 ═══
                VStack(spacing: 6) {
                    Text(concertInfo.venueName)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "FF006E"))
                        .tracking(2)
                    
                    Text(concertInfo.eventName)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF006E"),
                                    Color(hex: "8338EC"),
                                    Color(hex: "3A86FF")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // ═══ 照片区域（如有）═══
                if let photo = photos.first {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FF006E").opacity(0.6),
                                            Color(hex: "8338EC").opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.top, 15)
                } else {
                    // 无照片时显示心情和装饰
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FF006E").opacity(0.2),
                                        Color(hex: "8338EC").opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 240, height: 120)
                        
                        Text(record.mood.emoji)
                            .font(.system(size: 50))
                    }
                    .padding(.top, 15)
                }
                
                // ═══ 演出信息 ═══
                VStack(spacing: 10) {
                    // 日期和时间
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DATE")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8338EC").opacity(0.7))
                            Text(concertInfo.date)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TIME")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8338EC").opacity(0.7))
                            Text(concertInfo.time)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("PRICE")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8338EC").opacity(0.7))
                            Text(concertInfo.price)
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "FF006E"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    // 内容
                    if !record.content.isEmpty {
                        Text(String(record.content.prefix(60)))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 20)
                    }
                    
                    // 座位/区域
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SECTION")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8338EC").opacity(0.7))
                            Text(concertInfo.section)
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "FF006E"))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("TICKET NO.")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8338EC").opacity(0.7))
                            Text(concertInfo.ticketNumber)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // ═══ 底部：二维码和条形码 ═══
                VStack(spacing: 8) {
                    // 二维码占位
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "qrcode")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.3))
                        )
                    
                    // 条形码
                    BarcodeView(width: 180, height: 30)
                }
                .padding(.bottom, 20)
            }
            
            // ═══ 霓虹光效 ═══
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "FF006E").opacity(neonGlow),
                            Color(hex: "8338EC").opacity(neonGlow),
                            Color(hex: "3A86FF").opacity(neonGlow),
                            Color(hex: "FF006E").opacity(neonGlow)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .blur(radius: 2)
        }
        .frame(width: 280, height: 380)
        .shadow(color: Color(hex: "FF006E").opacity(0.4), radius: 15, y: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                neonGlow = 0.9
            }
        }
    }
}

// MARK: - 演出票数据
struct ConcertTicketData {
    let eventName: String
    let venueName: String
    let date: String
    let time: String
    let price: String
    let section: String
    let ticketNumber: String
    
    static func random(from date: Date) -> ConcertTicketData {
        let events = [
            "MEMORY LIVE", "时光音乐会", "NIGHT SESSION", "记忆现场",
            "THE MOMENT", "时光回响", "LIVE HOUSE", "记忆碎片"
        ]
        
        let venues = [
            "BLUE NOTE", "时光音乐厅", "LIVE HOUSE", "记忆剧场"
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let dateStr = formatter.string(from: date).uppercased()
        
        let hour = Int.random(in: 19...22)
        let minute = [0, 30].randomElement()!
        let timeStr = String(format: "%02d:%02d", hour, minute)
        
        let prices = ["¥180", "¥280", "¥380", "¥580"]
        let sections = ["STANDING", "VIP", "FLOOR", "BALCONY"]
        
        let ticketNum = String(format: "%06d", Int.random(in: 100000...999999))
        
        return ConcertTicketData(
            eventName: events.randomElement()!,
            venueName: venues.randomElement()!,
            date: dateStr,
            time: timeStr,
            price: prices.randomElement()!,
            section: sections.randomElement()!,
            ticketNumber: ticketNum
        )
    }
}


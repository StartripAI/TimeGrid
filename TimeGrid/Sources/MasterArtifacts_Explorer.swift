//
//  MasterArtifacts_Explorer.swift
//  时光格 - 世界级信物模板：探索者系列 🌍
//
//  包含：
//  1. 探险日志 (Safari) - 维多利亚时代探险日志
//  2. 极光幻境 (Aurora) - 北欧极光夜空
//  3. 星象仪 (Astrolabe) - 中世纪星象仪
//  4. 御神籤 (Omikuji) - 日本神社绘马
//  5. 时光沙漏 (Hourglass) - 古典沙漏
//
//  设计参考：
//  - 维多利亚时代探险日志
//  - 北欧极光夜空
//  - 中世纪星象仪
//  - 日本神社绘马
//  - 古典沙漏
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🗺️ 探险日志 (Safari)
// MARK: - 参考：维多利亚时代探险日志、国家地理杂志
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterSafariJournalView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(2).compactMap { UIImage(data: $0) }
    }
    
    // 随机探险信息
    private var expeditionInfo: ExpeditionData {
        ExpeditionData.random(from: record.date)
    }
    
    var body: some View {
        ZStack {
            // ═══ 日志本背景 ═══
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F4A460"),
                            Color(hex: "DEB887"),
                            Color(hex: "CD853F")
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
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.03)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(spacing: 0) {
                // ═══ 顶部：日志标题 ═══
                VStack(spacing: 6) {
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "8B4513"))
                            .frame(height: 2)
                        
                        Text("EXPEDITION LOG")
                            .font(.system(size: 12, weight: .black, design: .serif))
                            .foregroundColor(Color(hex: "8B4513"))
                            .tracking(3)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .fill(Color(hex: "8B4513"))
                            .frame(height: 2)
                    }
                    .padding(.horizontal, 20)
                    
                    Text(expeditionInfo.location)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: "654321"))
                }
                .padding(.top, 20)
                
                // ═══ 日期和坐标 ═══
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DATE:")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "654321"))
                        Text(formattedDate)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("COORDINATES:")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "654321"))
                        Text(expeditionInfo.coordinates)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // ═══ 照片区域 ═══
                if !photos.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(0..<photos.count, id: \.self) { i in
                            Image(uiImage: photos[i])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: photos.count == 1 ? 220 : 130, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hex: "8B4513"), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.top, 15)
                } else {
                    // 无照片时的占位
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "DEB887").opacity(0.5))
                        .frame(width: 220, height: 140)
                        .overlay(
                            VStack(spacing: 8) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 40))
                                Text("DISCOVERY")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: "654321"))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                        .padding(.top, 15)
                }
                
                // ═══ 日志内容 ═══
                VStack(alignment: .leading, spacing: 10) {
                    Text(record.content.isEmpty ? "Today's discovery..." : record.content)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(Color(hex: "654321"))
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                    
                    Spacer()
                    
                    // ═══ 底部：印章和签名 ═══
                    HStack {
                        // 印章
                        VStack(spacing: 4) {
                            Text("EXPEDITION")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text("APPROVED")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8B4513"))
                        }
                        .padding(8)
                        .overlay(
                            Rectangle()
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                        
                        Spacer()
                        
                        // 签名
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("EXPLORER")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "654321"))
                            Rectangle()
                                .fill(Color(hex: "8B4513"))
                                .frame(width: 60, height: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "8B4513"), lineWidth: 3)
        }
        .frame(width: 280, height: 420)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: record.date).uppercased()
    }
}

// MARK: - 探险数据
struct ExpeditionData {
    let location: String
    let coordinates: String
    
    static func random(from date: Date) -> ExpeditionData {
        let locations = [
            "SAHARA DESERT", "AMAZON RAINFOREST", "HIMALAYAS",
            "ANTARCTICA", "GALAPAGOS ISLANDS", "SERENGETI"
        ]
        
        let coords = [
            "23°N 13°E", "3°S 60°W", "28°N 84°E",
            "75°S 0°E", "0°N 91°W", "2°S 35°E"
        ]
        
        let index = Int.random(in: 0..<locations.count)
        return ExpeditionData(
            location: locations[index],
            coordinates: coords[index]
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌌 极光幻境 (Aurora)
// MARK: - 参考：北欧极光、挪威特罗姆瑟
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterAuroraView: View {
    let record: DayRecord
    
    @State private var auroraOffset1: CGFloat = -100
    @State private var auroraOffset2: CGFloat = 100
    @State private var auroraOpacity: Double = 0.8
    @State private var starTwinkle: Double = 1.0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 深蓝夜空 ═══
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0A0E27"),
                            Color(hex: "1A1F3A"),
                            Color(hex: "0A0E27")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // ═══ 星星 ═══
            Canvas { context, size in
                for _ in 0..<100 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let radius = Double.random(in: 0.5...2)
                    let opacity = Double.random(in: 0.5...1.0) * starTwinkle
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
            
            // ═══ 极光层1（绿色）═══
            VStack {
                LinearGradient(
                    colors: [
                        Color(hex: "00FF88").opacity(0.7 * auroraOpacity),
                        Color(hex: "00D4FF").opacity(0.5 * auroraOpacity),
                        Color(hex: "00FF88").opacity(0.6 * auroraOpacity)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 180)
                .blur(radius: 25)
                .offset(x: auroraOffset1)
            }
            
            // ═══ 极光层2（紫色）═══
            VStack {
                LinearGradient(
                    colors: [
                        Color(hex: "FF00FF").opacity(0.4 * auroraOpacity),
                        Color(hex: "00D4FF").opacity(0.3 * auroraOpacity),
                        Color(hex: "FF00FF").opacity(0.35 * auroraOpacity)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 150)
                .blur(radius: 30)
                .offset(x: auroraOffset2)
                .offset(y: 30)
            }
            
            VStack(spacing: 20) {
                // ═══ 照片（如有）═══
                if let photo = photos.first {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "00FF88").opacity(0.6),
                                            Color(hex: "00D4FF").opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color(hex: "00FF88").opacity(0.4), radius: 15)
                        .padding(.top, 50)
                } else {
                    // 无照片时的占位
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 240, height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 50))
                                Text("AURORA")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(hex: "00FF88"))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "00FF88").opacity(0.6),
                                            Color(hex: "00D4FF").opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.top, 50)
                }
                
                // ═══ 内容 ═══
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .shadow(color: Color(hex: "00FF88").opacity(0.6), radius: 8)
                }
                
                Spacer()
                
                // ═══ 底部：位置信息 ═══
                Text("TROMSØ, NORWAY")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "00D4FF").opacity(0.7))
                    .tracking(2)
                    .padding(.bottom, 25)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "00FF88").opacity(0.3),
                            Color(hex: "00D4FF").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .frame(width: 300, height: 450)
        .shadow(color: Color(hex: "00FF88").opacity(0.3), radius: 20, y: 10)
        .onAppear {
            // 极光移动
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                auroraOffset1 = 100
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                auroraOffset2 = -100
            }
            // 极光闪烁
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                auroraOpacity = 0.5
            }
            // 星星闪烁
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                starTwinkle = 0.6
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔭 星象仪 (Astrolabe)
// MARK: - 参考：中世纪星象仪、阿拉伯天文学
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterAstrolabeView: View {
    let record: DayRecord
    
    @State private var outerRotation: Double = 0
    @State private var innerRotation: Double = 0
    @State private var starTwinkle: Double = 1.0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 深蓝星空 ═══
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "000428"),
                            Color(hex: "004e92"),
                            Color(hex: "000428")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // ═══ 星星背景 ═══
            Canvas { context, size in
                for _ in 0..<80 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let radius = Double.random(in: 0.5...2.5)
                    let opacity = Double.random(in: 0.6...1.0) * starTwinkle
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
            
            VStack(spacing: 20) {
                // ═══ 星象仪 ═══
                ZStack {
                    // 外圈
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFA500"),
                                    Color(hex: "FFD700")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(outerRotation))
                    
                    // 中圈
                    Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.6), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(innerRotation))
                    
                    // 内圈
                    Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.4), lineWidth: 1)
                        .frame(width: 140, height: 140)
                    
                    // 中心照片
                    if let photo = photos.first {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "FFD700"), lineWidth: 2)
                            )
                    } else {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 130, height: 130)
                            .overlay(
                                VStack(spacing: 8) {
                                    Text(record.mood.emoji)
                                        .font(.system(size: 40))
                                    Text("STELLA")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(hex: "FFD700"))
                                }
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "FFD700"), lineWidth: 2)
                            )
                    }
                    
                    // 刻度线
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: "FFD700").opacity(0.6))
                            .frame(width: 2, height: 15)
                            .offset(y: -100)
                            .rotationEffect(.degrees(Double(i) * 30))
                    }
                }
                .padding(.top, 50)
                
                // ═══ 内容 ═══
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 5)
                }
                
                Spacer()
                
                // ═══ 底部：星座信息 ═══
                Text("STELLAR MAP")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "FFD700").opacity(0.7))
                    .tracking(2)
                    .padding(.bottom, 25)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
        }
        .frame(width: 300, height: 450)
        .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20, y: 10)
        .onAppear {
            // 外圈旋转
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                outerRotation = 360
            }
            // 内圈旋转
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                innerRotation = -360
            }
            // 星星闪烁
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                starTwinkle = 0.5
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - ⛩️ 御神籤 (Omikuji)
// MARK: - 参考：日本神社绘马、传统和风
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterOmikujiView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机签文
    private var fortune: FortuneData {
        FortuneData.random()
    }
    
    var body: some View {
        ZStack {
            // ═══ 木色背景 ═══
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "DEB887"),
                            Color(hex: "CD853F"),
                            Color(hex: "DEB887")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 木纹纹理
            Canvas { context, size in
                for _ in 0..<200 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let width = Double.random(in: 50...150)
                    let height = Double.random(in: 2...4)
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    context.fill(Path(rect), with: .color(Color(hex: "8B4513").opacity(0.1)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(spacing: 0) {
                // ═══ 顶部：神社装饰 ═══
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(hex: "8B4513"))
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    Text("⛩️")
                        .font(.system(size: 32))
                    
                    Spacer()
                    
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(hex: "8B4513"))
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                // ═══ 签文等级 ═══
                Text(fortune.level)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(fortune.color)
                    .padding(.top, 15)
                
                // ═══ 照片（如有）═══
                if let photo = photos.first {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                        .padding(.top, 15)
                } else {
                    // 无照片时的占位
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "CD853F").opacity(0.5))
                        .frame(width: 200, height: 180)
                        .overlay(
                            VStack(spacing: 8) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 50))
                                Text("願い事")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "654321"))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                        .padding(.top, 15)
                }
                
                // ═══ 签文内容 ═══
                VStack(spacing: 10) {
                    Text(fortune.text)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "654321"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                    
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "654321").opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 25)
                    }
                }
                
                Spacer()
                
                // ═══ 底部：日期和签名 ═══
                VStack(spacing: 6) {
                    Text(formattedDate)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text("願い事")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "8B4513"))
                }
                .padding(.bottom, 25)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "8B4513"), lineWidth: 3)
        }
        .frame(width: 280, height: 450)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: record.date)
    }
}

// MARK: - 签文数据
struct FortuneData {
    let level: String
    let text: String
    let color: Color
    
    static func random() -> FortuneData {
        let fortunes: [(String, String, Color)] = [
            ("大吉", "すべてが順調に進みます", Color(hex: "FF0000")),
            ("中吉", "良いことが起こります", Color(hex: "FF6600")),
            ("小吉", "少しずつ良くなります", Color(hex: "FFAA00")),
            ("吉", "平穏な日々が続きます", Color(hex: "0066CC")),
            ("末吉", "努力が実を結びます", Color(hex: "0066CC"))
        ]
        
        let selected = fortunes.randomElement()!
        return FortuneData(level: selected.0, text: selected.1, color: selected.2)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - ⏳ 时光沙漏 (Hourglass)
// MARK: - 参考：古典沙漏、时间流逝
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterHourglassView: View {
    let record: DayRecord
    
    @State private var sandProgress: Double = 0
    @State private var sandOffset: CGFloat = 0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 沙色背景 ═══
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5DEB3"),
                            Color(hex: "DEB887"),
                            Color(hex: "F5DEB3")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 纸张纹理
            Canvas { context, size in
                for _ in 0..<2000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.02)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 0) {
                // ═══ 顶部标题 ═══
                Text("TEMPVS FVGIT")
                    .font(.system(size: 12, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "8B4513"))
                    .tracking(3)
                    .padding(.top, 30)
                
                // ═══ 沙漏图标 ═══
                ZStack {
                    // 沙漏外框
                    Image(systemName: "hourglass")
                        .font(.system(size: 100))
                        .foregroundColor(Color(hex: "8B4513").opacity(0.2))
                    
                    // 中心照片
                    if let photo = photos.first {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "8B4513"), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    } else {
                        Circle()
                            .fill(Color(hex: "DEB887").opacity(0.5))
                            .frame(width: 180, height: 180)
                            .overlay(
                                VStack(spacing: 12) {
                                    Text(record.mood.emoji)
                                        .font(.system(size: 60))
                                    Text("TIME")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(hex: "654321"))
                                }
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "8B4513"), lineWidth: 4)
                            )
                    }
                }
                .padding(.top, 30)
                
                // ═══ 内容 ═══
                VStack(spacing: 12) {
                    Text(record.content.isEmpty ? "Time flows like sand..." : record.content)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "654321"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                    
                    // ═══ 流沙效果 ═══
                    ZStack {
                        // 沙漏底部
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "8B4513").opacity(0.3))
                            .frame(width: 40, height: 80)
                        
                        // 流沙
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "8B4513"),
                                            Color(hex: "A0522D")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 35, height: CGFloat(sandProgress * 70))
                                .offset(y: sandOffset)
                        }
                        .frame(width: 40, height: 80)
                    }
                    .padding(.top, 15)
                }
                
                Spacer()
                
                // ═══ 底部：日期 ═══
                Text(formattedDate)
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "8B4513"))
                    .padding(.bottom, 30)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "8B4513"), lineWidth: 2)
        }
        .frame(width: 300, height: 450)
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        .onAppear {
            // 流沙动画
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                sandProgress = 1.0
                sandOffset = 35
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: record.date).uppercased()
    }
}


//
//  MasterArtifacts_Royal.swift
//  时光格 - 世界级信物模板：皇家系列
//
//  包含：皇家诏书、火漆信封、皇家御玺、机密档案
//
//  设计标准：
//  - 每个信物都是博物馆级藏品
//  - 真实材质模拟（羊皮纸、火漆、黄铜、皮革）
//  - 精密的光影和纹理
//  - 支持1-6张彩色照片
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📜 皇家诏书 (envelope / waxEnvelope)
// MARK: - 参考：维多利亚时代官方文书、中世纪皇室诏书
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterRoyalDecreeView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(6).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // ═══ 羊皮纸背景 ═══
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "F5E6D3"),
                                Color(hex: "EED9C4"),
                                Color(hex: "E8D0B5"),
                                Color(hex: "F0DCC8")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // ═══ 羊皮纸纹理 ═══
                ParchmentTextureV2()
                
                // ═══ 陈旧边缘 ═══
                AgedEdgeOverlay()
                
                VStack(spacing: 0) {
                    // ═══ 顶部皇家徽章 ═══
                    RoyalEmblem()
                        .frame(height: 60)
                        .padding(.top, 25)
                    
                    // ═══ 装饰分隔线 ═══
                    RoyalDivider()
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                    
                    // ═══ 日期（书法体） ═══
                    Text(formattedDate)
                        .font(.custom("Snell Roundhand", size: 16))
                        .foregroundColor(Color(hex: "5D4037"))
                        .tracking(2)
                    
                    // ═══ 照片区域 ═══
                    if !photos.isEmpty {
                        RoyalPhotoGrid(photos: photos)
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                    }
                    
                    // ═══ 正文内容 ═══
                    Text(record.content)
                        .font(.custom("Georgia", size: 15))
                        .foregroundColor(Color(hex: "3E2723"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    
                    Spacer(minLength: 25)
                    
                    // ═══ 心情徽章 ═══
                    HStack(spacing: 15) {
                        // 天气
                        if let weather = record.weather {
                            WeatherBadgeRoyal(weather: weather)
                        }
                        
                        // 心情
                        MoodBadgeRoyal(mood: record.mood)
                    }
                    .padding(.bottom, 15)
                    
                    // ═══ 火漆印章 ═══
                    RoyalWaxSeal()
                        .frame(width: 75, height: 75)
                        .padding(.bottom, 30)
                }
                
                // ═══ 金色边框 ═══
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "D4AF37"),
                                Color(hex: "C9A55C"),
                                Color(hex: "8B7355"),
                                Color(hex: "C9A55C"),
                                Color(hex: "D4AF37")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .padding(2)
                
                // ═══ 内边框 ═══
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(hex: "8B7355").opacity(0.5), lineWidth: 1)
                    .padding(8)
            }
        }
        .frame(width: 300, height: 520)
        .shadow(color: .black.opacity(0.25), radius: 15, y: 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: record.date)
    }
}

// MARK: - 皇家徽章
struct RoyalEmblem: View {
    var body: some View {
        ZStack {
            // 外圈装饰
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 55, height: 55)
            
            // 皇冠
            Image(systemName: "crown.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "D4AF37"))
                .shadow(color: Color(hex: "8B7355").opacity(0.5), radius: 2, y: 1)
            
            // 装饰射线
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: "D4AF37").opacity(0.3))
                    .frame(width: 1, height: 8)
                    .offset(y: -32)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
    }
}

// MARK: - 皇家分隔线
struct RoyalDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            // 左侧线
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color(hex: "C9A55C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            // 中央装饰
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: "C9A55C"))
                    .rotationEffect(.degrees(180))
                
                Circle()
                    .fill(Color(hex: "D4AF37"))
                    .frame(width: 5, height: 5)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: "C9A55C"))
            }
            
            // 右侧线
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C9A55C"), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
}

// MARK: - 皇家照片网格
struct RoyalPhotoGrid: View {
    let photos: [UIImage]
    
    var body: some View {
        switch photos.count {
        case 1:
            RoyalPhotoFrame(image: photos[0], width: 220, height: 165)
        case 2:
            HStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { i in
                    RoyalPhotoFrame(image: photos[i], width: 108, height: 85)
                }
            }
        case 3:
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    RoyalPhotoFrame(image: photos[i], width: 70, height: 65)
                }
            }
        case 4:
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 108, height: 78)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(2..<4, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 108, height: 78)
                    }
                }
            }
        case 5:
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 108, height: 75)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(2..<5, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 70, height: 58)
                    }
                }
            }
        case 6:
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 70, height: 60)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(3..<6, id: \.self) { i in
                        RoyalPhotoFrame(image: photos[i], width: 70, height: 60)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 皇家照片框
struct RoyalPhotoFrame: View {
    let image: UIImage
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // 照片
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width - 8, height: height - 8)
                .clipped()
            
            // 金色边框
            RoundedRectangle(cornerRadius: 3)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "8B7355")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .frame(width: width, height: height)
            
            // 角装饰
            ForEach(0..<4, id: \.self) { i in
                CornerOrnament()
                    .foregroundColor(Color(hex: "D4AF37"))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: i % 2 == 0 ? -(width/2 - 6) : (width/2 - 6),
                        y: i < 2 ? -(height/2 - 6) : (height/2 - 6)
                    )
                    .rotationEffect(.degrees(Double(i) * 90))
            }
        }
        .frame(width: width, height: height)
    }
}

struct CornerOrnament: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: - 火漆印章
struct RoyalWaxSeal: View {
    @State private var shimmer: CGFloat = -50
    
    var body: some View {
        ZStack {
            // 蜡滴边缘
            Circle()
                .fill(Color(hex: "8B0000").opacity(0.3))
                .frame(width: 78, height: 78)
                .blur(radius: 5)
            
            // 主蜡体
            ZStack {
                // 蜡基底
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "DC3545"),
                                Color(hex: "C41E3A"),
                                Color(hex: "8B0000"),
                                Color(hex: "5C0000")
                            ],
                            center: .init(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 38
                        )
                    )
                    .frame(width: 70, height: 70)
                
                // 蜡的光泽
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 70, height: 70)
                    .mask(
                        Ellipse()
                            .frame(width: 30, height: 18)
                            .offset(x: -15, y: -18)
                    )
                
                // 流光效果
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.2), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 20, height: 70)
                    .offset(x: shimmer)
                    .mask(Circle().frame(width: 70, height: 70))
                
                // 印章图案
                VStack(spacing: 2) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "FFD700").opacity(0.75))
                    
                    Text("已封")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700").opacity(0.6))
                }
                .shadow(color: Color(hex: "3D0000"), radius: 1, y: 1)
                
                // 边缘压痕
                Circle()
                    .stroke(Color(hex: "5C0000").opacity(0.4), lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
            .shadow(color: Color(hex: "3D0000").opacity(0.6), radius: 6, y: 4)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmer = 50
            }
        }
    }
}

// MARK: - 心情徽章
struct MoodBadgeRoyal: View {
    let mood: MoodType
    
    var body: some View {
        HStack(spacing: 6) {
            Text(mood.emoji)
                .font(.system(size: 18))
            
            Text(mood.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "5D4037"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "F5E6D3"))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "C9A55C"), lineWidth: 1)
                )
        )
    }
}

// MARK: - 天气徽章
struct WeatherBadgeRoyal: View {
    let weather: WeatherType
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: weather.icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8B7355"))
            
            Text(weather.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "5D4037"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "F5E6D3"))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "C9A55C"), lineWidth: 1)
                )
        )
    }
}

// MARK: - 羊皮纸纹理
struct ParchmentTextureV2: View {
    var body: some View {
        Canvas { context, size in
            // 纤维纹理
            for _ in 0..<5000 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let w = Double.random(in: 0.5...2)
                let h = Double.random(in: 0.5...1.5)
                let rect = CGRect(x: x, y: y, width: w, height: h)
                let grain = Double.random(in: 0.02...0.08)
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(grain)))
            }
            
            // 咖啡渍
            for _ in 0..<15 {
                let x = Double.random(in: 20...(size.width - 20))
                let y = Double.random(in: 20...(size.height - 20))
                let s = Double.random(in: 30...80)
                let rect = CGRect(x: x - s/2, y: y - s/2, width: s, height: s)
                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: "8B4513").opacity(0.02)))
            }
        }
    }
}

// MARK: - 陈旧边缘
struct AgedEdgeOverlay: View {
    var body: some View {
        ZStack {
            // 四边渐变
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B7355").opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 40)
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color(hex: "8B7355").opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 40)
            }
            
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B7355").opacity(0.12), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30)
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color(hex: "8B7355").opacity(0.12)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30)
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔐 机密档案 (vault)
// MARK: - 参考：CIA机密文件、冷战时期档案
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterClassifiedView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(6).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 牛皮纸文件夹 ═══
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "C9B896"),
                            Color(hex: "B8A67C"),
                            Color(hex: "A89462")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // 纸张纹理
            ManillaTextureV2()
            
            VStack(spacing: 0) {
                // ═══ 顶部档案标签 ═══
                HStack {
                    // 红色机密标签
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "C41E3A"))
                            .frame(width: 90, height: 28)
                        
                        Text("TOP SECRET")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                    }
                    .rotationEffect(.degrees(-3))
                    
                    Spacer()
                    
                    // 档案编号
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("FILE NO.")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "5D4037"))
                        
                        Text(generateFileNumber())
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // ═══ 日期戳 ═══
                HStack {
                    DateStampView(date: record.date)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // ═══ 照片区域（档案照片风格） ═══
                if !photos.isEmpty {
                    ClassifiedPhotoGrid(photos: photos)
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                }
                
                // ═══ 内容 ═══
                ZStack {
                    // 打字机风格文本框
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(hex: "5D4037").opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(record.content)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .padding(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                Spacer(minLength: 15)
                
                // ═══ 底部印章区 ═══
                HStack(spacing: 20) {
                    // 心情
                    ClassifiedBadge(text: record.mood.label, icon: record.mood.emoji)
                    
                    // 天气
                    if let weather = record.weather {
                        ClassifiedBadge(text: weather.label, systemIcon: weather.icon)
                    }
                    
                    Spacer()
                    
                    // CLASSIFIED 印章
                    ClassifiedStamp()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            
            // ═══ 文件夹边缘 ═══
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "8B7355").opacity(0.5), lineWidth: 2)
        }
        .frame(width: 300, height: 500)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }
    
    private func generateFileNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        let numbers = String(format: "%05d", Int.random(in: 10000...99999))
        return "\(prefix)-\(numbers)"
    }
}

// MARK: - 日期戳
struct DateStampView: View {
    let date: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(hex: "1A1A1A"), lineWidth: 2)
                .frame(width: 100, height: 35)
            
            VStack(spacing: 1) {
                Text("DATE")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "5D4037"))
                
                Text(formattedDate)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
        }
        .rotationEffect(.degrees(-2))
    }
}

// MARK: - 机密照片网格
struct ClassifiedPhotoGrid: View {
    let photos: [UIImage]
    
    var body: some View {
        switch photos.count {
        case 1:
            ClassifiedPhotoCell(image: photos[0], width: 200, height: 150)
        case 2:
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    ClassifiedPhotoCell(image: photos[i], width: 115, height: 90)
                }
            }
        case 3...6:
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0..<min(3, photos.count), id: \.self) { i in
                        ClassifiedPhotoCell(image: photos[i], width: 78, height: 60)
                    }
                }
                if photos.count > 3 {
                    HStack(spacing: 6) {
                        ForEach(3..<photos.count, id: \.self) { i in
                            ClassifiedPhotoCell(image: photos[i], width: 78, height: 60)
                        }
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 机密照片单元
struct ClassifiedPhotoCell: View {
    let image: UIImage
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // 照片（轻微去色，档案风格）
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width - 6, height: height - 6)
                .saturation(0.8)
                .clipped()
            
            // 照片边框
            Rectangle()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: width, height: height)
            
            // 胶带效果
            Rectangle()
                .fill(Color(hex: "F5DEB3").opacity(0.7))
                .frame(width: width * 0.3, height: 12)
                .offset(y: -height/2 + 6)
                .rotationEffect(.degrees(Double.random(in: -5...5)))
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
    }
}

// MARK: - 机密徽章
struct ClassifiedBadge: View {
    let text: String
    var icon: String? = nil
    var systemIcon: String? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Text(icon)
                    .font(.system(size: 12))
            }
            if let systemIcon = systemIcon {
                Image(systemName: systemIcon)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "5D4037"))
            }
            Text(text)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "1A1A1A"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(hex: "5D4037").opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - CLASSIFIED 印章
struct ClassifiedStamp: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "C41E3A"), lineWidth: 3)
                .frame(width: 75, height: 30)
            
            Text("CLASSIFIED")
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Color(hex: "C41E3A"))
        }
        .rotationEffect(.degrees(-8))
        .opacity(0.8)
    }
}

// MARK: - 牛皮纸纹理
struct ManillaTextureV2: View {
    var body: some View {
        Canvas { context, size in
            // 纤维
            for _ in 0..<3000 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let w = Double.random(in: 0.5...2)
                let rect = CGRect(x: x, y: y, width: w, height: w)
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.03)))
            }
            
            // 污渍
            for _ in 0..<8 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let s = Double.random(in: 40...100)
                let rect = CGRect(x: x - s/2, y: y - s/2, width: s, height: s)
                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: "8B7355").opacity(0.04)))
            }
        }
    }
}

// MARK: - Color Hex 扩展
// 注意：Color(hex:) 已在 Models.swift 中定义，这里不再重复定义


//
//  OptimizedArtifactsV5.swift
//  优化的信物设计 V5.0
//
//  修正问题：
//  1. 唱片封套 - 添加唱片套和更多细节
//  2. 书签 - 更精致的设计
//  3. 干花标本 - 花不再被压住
//  4. 探险日志 - 添加人猿泰山、狮子王元素
//

import SwiftUI

// MARK: - 💿 黑胶唱片 V5 (带唱片封套)
struct VinylRecordV5: View {
    let record: DayRecord
    
    // 随机唱片公司
    private let labels = ["MEMORY RECORDS", "TIME AUDIO", "NOSTALGIA MUSIC", "PAST SOUNDS"]
    private let randomLabel: String
    private let randomYear: Int
    private let randomRPM = ["33⅓", "45", "78"].randomElement()!
    
    init(record: DayRecord) {
        self.record = record
        self.randomLabel = labels.randomElement()!
        self.randomYear = Int.random(in: 1965...1989)
    }
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "1A1A1A")
            
            HStack(spacing: -30) {
                // ═══════════ 唱片封套 ═══════════
                ZStack {
                    // 封套底
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2C2C2C"), Color(hex: "1A1A1A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 4, y: 4)
                    
                    // 封面图片
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130)
                            .clipped()
                            .overlay(
                                // 复古滤镜
                                Color.orange.opacity(0.1)
                                    .blendMode(.overlay)
                            )
                            .cornerRadius(2)
                    } else {
                        // 无图片时的占位设计
                        ZStack {
                            Color(hex: "8B0000")
                            
                            VStack(spacing: 8) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 40))
                                Text("MEMORY")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 130, height: 130)
                        .cornerRadius(2)
                    }
                    
                    // 封套文字
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(randomLabel)
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(randomYear)")
                                    .font(.system(size: 5))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                        }
                        .padding(6)
                    }
                    .frame(width: 130, height: 130)
                }
                .zIndex(1)
                
                // ═══════════ 黑胶唱片 ═══════════
                ZStack {
                    // 唱片主体
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "1A1A1A"), Color(hex: "0D0D0D")],
                                center: .center,
                                startRadius: 20,
                                endRadius: 65
                            )
                        )
                        .frame(width: 130, height: 130)
                    
                    // 唱片纹路
                    ForEach(0..<15, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.03), lineWidth: 0.5)
                            .frame(width: CGFloat(25 + i * 7), height: CGFloat(25 + i * 7))
                    }
                    
                    // 反光效果
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center
                            )
                        )
                        .frame(width: 130, height: 130)
                    
                    // 中心标签
                    Circle()
                        .fill(Color(hex: "8B0000"))
                        .frame(width: 45, height: 45)
                        .overlay(
                            VStack(spacing: 1) {
                                Text(record.mood.emoji)
                                    .font(.system(size: 14))
                                Text(randomLabel)
                                    .font(.system(size: 4, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(randomRPM) RPM")
                                    .font(.system(size: 3))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        )
                    
                    // 中心孔
                    Circle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(width: 6, height: 6)
                }
                .rotationEffect(.degrees(15)) // 轻微旋转，像从封套中抽出
                .zIndex(0)
            }
            
            // ═══════════ 底部信息 ═══════════
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.formattedDate)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // 内容预览
                    if !record.content.isEmpty {
                        Text(record.content.prefix(20) + "...")
                            .font(.system(size: 7))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .frame(width: 255, height: 200) // 调整为更合适的尺寸
        .cornerRadius(4)
    }
}

// MARK: - 📑 书签 V5 (更精致)
struct BookmarkV5: View {
    let record: DayRecord
    
    // 随机元素
    private let bookstoreNames = ["时光书店", "记忆书屋", "往事图书馆", "岁月书局"]
    private let randomBookstore: String
    private let randomISBN: String
    
    init(record: DayRecord) {
        self.record = record
        self.randomBookstore = bookstoreNames.randomElement()!
        self.randomISBN = "978-\(Int.random(in: 1000...9999))-\(Int.random(in: 1000...9999))-\(Int.random(in: 0...9))"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ═══════════ 主体 ═══════════
            ZStack {
                // 书签背景（深红色皮革质感）
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B0000"), Color(hex: "660000")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // 皮革纹理
                BookmarkLeatherTexture()
                
                VStack(spacing: 12) {
                    // ═══════════ 顶部打孔 + 丝带 ═══════════
                    ZStack {
                        // 打孔
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Circle()
                            .stroke(Color(hex: "D4AF37"), lineWidth: 1)
                            .frame(width: 12, height: 12)
                    }
                    .overlay(
                        // 丝带
                        Rectangle()
                            .fill(Color(hex: "D4AF37"))
                            .frame(width: 3, height: 30)
                            .offset(y: -20)
                    )
                    .padding(.top, 12)
                    
                    Spacer().frame(height: 8)
                    
                    // ═══════════ 书店名 ═══════════
                    Text(randomBookstore)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                        .tracking(2)
                    
                    // 装饰线
                    HStack(spacing: 8) {
                        Rectangle().fill(Color(hex: "D4AF37")).frame(width: 20, height: 0.5)
                        Image(systemName: "book.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "D4AF37"))
                        Rectangle().fill(Color(hex: "D4AF37")).frame(width: 20, height: 0.5)
                    }
                    
                    Spacer().frame(height: 8)
                    
                    // ═══════════ 照片（如有）═══════════
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 80)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color(hex: "D4AF37"), lineWidth: 1)
                            )
                            .cornerRadius(2)
                    }
                    
                    // ═══════════ 引用语 ═══════════
                    VStack(spacing: 4) {
                        Text("\"")
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(Color(hex: "D4AF37").opacity(0.6))
                        
                        Text(record.content.isEmpty ? "每一天都值得铭记" : record.content)
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .lineSpacing(4)
                            .padding(.horizontal, 12)
                        
                        Text("\"")
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(Color(hex: "D4AF37").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // ═══════════ 日期 ═══════════
                    Text(record.formattedDate)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                    
                    // ═══════════ ISBN条码 ═══════════
                    VStack(spacing: 2) {
                        // 简化条码
                        HStack(spacing: 0.5) {
                            ForEach(0..<25, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: CGFloat.random(in: 0.5...1.5), height: 15)
                            }
                        }
                        
                        Text(randomISBN)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 8)
                }
            }
            .frame(width: 140, height: 320)
            
            // ═══════════ 底部尖角 ═══════════
            BookmarkPointedTip()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "660000"), Color(hex: "4A0000")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 30)
        }
        .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 5)
    }
}

struct BookmarkPointedTip: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct BookmarkLeatherTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<200 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(Double.random(in: 0.05...0.15))))
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 🌸 干花标本 V5 (花不再被压住)
struct PressedFlowerV5: View {
    let record: DayRecord
    
    // 随机元素
    private let specimenNumber = Int.random(in: 1...999)
    private let latinNames = ["Rosa memoria", "Tempus florens", "Nostalgia petalis", "Momentum fragrans"]
    private let randomLatinName: String
    private let collectionSites = ["上海植物园", "杭州西湖", "苏州拙政园", "南京玄武湖"]
    private let randomSite: String
    
    init(record: DayRecord) {
        self.record = record
        self.randomLatinName = latinNames.randomElement()!
        self.randomSite = collectionSites.randomElement()!
    }
    
    var body: some View {
        ZStack {
            // ═══════════ 牛皮纸背景 ═══════════
            Color(hex: "F2E8D5")
            
            // 纸张纹理
            PaperGrainTexture()
            
            VStack(spacing: 0) {
                // ═══════════ 博物馆标题栏 ═══════════
                HStack {
                    Rectangle()
                        .fill(Color(hex: "2C5530"))
                        .frame(height: 2)
                    
                    Text("HERBARIUM")
                        .font(.system(size: 8, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "2C5530"))
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .fill(Color(hex: "2C5530"))
                        .frame(height: 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Text("时光植物标本馆")
                    .font(.system(size: 6))
                    .foregroundColor(Color(hex: "2C5530").opacity(0.7))
                    .padding(.top, 2)
                
                Spacer().frame(height: 16)
                
                // ═══════════ 标本区域 ═══════════
                ZStack {
                    // 标本纸
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 180, height: 180)
                        .shadow(color: .black.opacity(0.05), radius: 2)
                    
                    // 照片/干花
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 160, maxHeight: 160)
                            .saturation(0.7) // 轻微褪色效果
                            .overlay(
                                // 压花效果：轻微扁平化
                                Color.brown.opacity(0.05)
                                    .blendMode(.multiply)
                            )
                    } else {
                        // 无图片时显示装饰性干花图案
                        VStack(spacing: 8) {
                            Text("🌸")
                                .font(.system(size: 50))
                            Text(record.mood.emoji)
                                .font(.system(size: 30))
                        }
                    }
                    
                    // 透明胶带固定效果
                    VStack {
                        HStack {
                            SimpleTapeStrip()
                                .rotationEffect(.degrees(-15))
                                .offset(x: -60, y: -70)
                            Spacer()
                            SimpleTapeStrip()
                                .rotationEffect(.degrees(15))
                                .offset(x: 60, y: -70)
                        }
                        Spacer()
                    }
                }
                
                Spacer().frame(height: 16)
                
                // ═══════════ 标本信息卡 ═══════════
                VStack(alignment: .leading, spacing: 6) {
                    // 拉丁学名
                    HStack {
                        Text("Species:")
                            .font(.system(size: 8, weight: .medium))
                        Text(randomLatinName)
                            .font(.system(size: 8, design: .serif))
                            .italic()
                    }
                    .foregroundColor(Color(hex: "2C5530"))
                    
                    // 采集地点
                    HStack {
                        Text("Loc:")
                            .font(.system(size: 8, weight: .medium))
                        Text(randomSite)
                            .font(.system(size: 8))
                        
                        Spacer()
                        
                        // GPS坐标
                        Text("N31.2° E121.5°")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(Color(hex: "2C5530"))
                    
                    // 采集日期
                    HStack {
                        Text("Date:")
                            .font(.system(size: 8, weight: .medium))
                        Text(record.formattedDate)
                            .font(.system(size: 8))
                        
                        Spacer()
                        
                        // 标本编号
                        Text("No. \(String(format: "%03d", specimenNumber))")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "8B0000"))
                    }
                    .foregroundColor(Color(hex: "2C5530"))
                    
                    // 内容/备注
                    if !record.content.isEmpty {
                        Text("Note: \(record.content)")
                            .font(.system(size: 7))
                            .foregroundColor(Color(hex: "2C5530").opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // ═══════════ 底部收藏章 ═══════════
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "8B0000"), lineWidth: 1)
                            .frame(width: 35, height: 35)
                        
                        VStack(spacing: 1) {
                            Text("COLLECTED")
                                .font(.system(size: 4, weight: .bold))
                            Text("收藏")
                                .font(.system(size: 6))
                        }
                        .foregroundColor(Color(hex: "8B0000"))
                    }
                    .rotationEffect(.degrees(-15))
                    .opacity(0.7)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 220, height: 340)
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(hex: "2C5530").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// 重命名以避免与 MasterArtifacts_Nature.swift 中的 TapeStrip 冲突
struct SimpleTapeStrip: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.5))
            .frame(width: 40, height: 12)
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }
}

struct PaperGrainTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<300 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                let color = Bool.random() ? Color.brown : Color.gray
                context.fill(Path(rect), with: .color(color.opacity(Double.random(in: 0.02...0.08))))
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 🦁 探险日志 V5 (添加动物和书籍元素)
struct SafariJournalV5: View {
    let record: DayRecord
    
    // 随机探险元素
    private let expeditionNames = ["泰山探险队", "狮子王远征", "丛林考察团", "非洲之心"]
    private let randomExpedition: String
    private let animalEmojis = ["🦁", "🐘", "🦒", "🦓", "🐆", "🦏", "🐗", "🦍"]
    private let randomAnimals: [String]
    private let campSites = ["塞伦盖蒂", "马赛马拉", "克鲁格", "恩戈罗恩戈罗"]
    private let randomCamp: String
    
    init(record: DayRecord) {
        self.record = record
        self.randomExpedition = expeditionNames.randomElement()!
        self.randomAnimals = Array(animalEmojis.shuffled().prefix(3))
        self.randomCamp = campSites.randomElement()!
    }
    
    var body: some View {
        ZStack {
            // ═══════════ 皮革封面背景 ═══════════
            Color(hex: "8B4513")
            SafariLeatherTexture()
            
            VStack(spacing: 0) {
                // ═══════════ 顶部探险队标题 ═══════════
                HStack {
                    // 指南针图标
                    Image(systemName: "safari")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    Text(randomExpedition)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    Spacer()
                    
                    // 动物图标
                    HStack(spacing: 2) {
                        ForEach(randomAnimals, id: \.self) { animal in
                            Text(animal)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // 装饰线
                Rectangle()
                    .fill(Color(hex: "D4AF37"))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                // ═══════════ 日志内页 ═══════════
                ZStack {
                    // 旧纸张
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "F5E6D3"))
                    
                    PaperGrainTexture()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // 日期和地点
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("EXPEDITION LOG")
                                    .font(.system(size: 8, weight: .bold, design: .serif))
                                    .foregroundColor(Color(hex: "8B4513"))
                                
                                Text(record.formattedDate)
                                    .font(.system(size: 10, design: .serif))
                                    .foregroundColor(Color(hex: "8B4513").opacity(0.8))
                            }
                            
                            Spacer()
                            
                            // 营地信息
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("CAMP: \(randomCamp)")
                                    .font(.system(size: 7, weight: .medium))
                                Text("S 2.3° E 34.8°")
                                    .font(.system(size: 6, design: .monospaced))
                            }
                            .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                        }
                        
                        // 照片区域
                        if let data = record.photos.first, let uiImage = UIImage(data: data) {
                            ZStack {
                                // 胶带效果
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 100)
                                    .clipped()
                                    .rotationEffect(.degrees(-2))
                                    .overlay(
                                        // 复古滤镜
                                        Color.orange.opacity(0.1)
                                            .blendMode(.overlay)
                                    )
                                
                                // 角落胶带
                                VStack {
                                    HStack {
                                        SimpleTapeStrip()
                                            .rotationEffect(.degrees(-30))
                                            .offset(x: -10, y: -5)
                                        Spacer()
                                    }
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        SimpleTapeStrip()
                                            .rotationEffect(.degrees(30))
                                            .offset(x: 10, y: 5)
                                    }
                                }
                            }
                            .frame(width: 160, height: 100)
                        }
                        
                        // 日志内容
                        VStack(alignment: .leading, spacing: 4) {
                            // 手写体标题
                            Text("Today's Observation:")
                                .font(.custom("Snell Roundhand", size: 12))
                                .foregroundColor(Color(hex: "8B4513"))
                            
                            Text(record.content.isEmpty ? "又是在大草原上探险的一天..." : record.content)
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "8B4513").opacity(0.9))
                                .lineLimit(4)
                                .lineSpacing(4)
                        }
                        
                        Spacer()
                        
                        // 底部装饰
                        HStack {
                            // 天气
                            if let weather = record.weather {
                                HStack(spacing: 4) {
                                    Image(systemName: weather.icon)
                                        .font(.system(size: 10))
                                    Text(weather.label)
                                        .font(.system(size: 8))
                                }
                                .foregroundColor(Color(hex: "8B4513").opacity(0.6))
                            }
                            
                            Spacer()
                            
                            // 心情
                            Text(record.mood.emoji)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(12)
                }
                .frame(height: 260)
                .padding(.horizontal, 12)
                
                Spacer()
                
                // ═══════════ 底部书脊装饰 ═══════════
                HStack(spacing: 8) {
                    // 书籍图标
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    Text("FIELD NOTES")
                        .font(.system(size: 8, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    Spacer()
                    
                    // 狮子王/泰山装饰
                    Text("🌿🦁🌴")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 220, height: 340)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "D4AF37"), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 5)
    }
}

struct SafariLeatherTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<400 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(Double.random(in: 0.05...0.2))))
            }
        }
        .allowsHitTesting(false)
    }
}


//
//  MasterArtifacts_Nature.swift
//  时光格 - 世界级信物模板：自然书写系列 🌿
//
//  包含：
//  1. 干花标本 (PressedFlower) - 维多利亚植物标本馆
//  2. 日记内页 (JournalPage) - Moleskine日记本
//  3. 打字机手稿 (Typewriter) - 海明威打字机手稿
//
//  设计参考：
//  - 维多利亚时代植物标本馆
//  - Moleskine经典日记本
//  - 海明威打字机手稿
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🌸 干花标本 (PressedFlower)
// MARK: - 参考：维多利亚植物标本馆、Herbarium标本卡
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterPressedFlowerView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机标本信息
    private var specimenInfo: SpecimenData {
        SpecimenData.random(from: record.date)
    }
    
    var body: some View {
        ZStack {
            // ═══ 标本卡背景 ═══
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5F0E8"),
                            Color(hex: "F2E8D5"),
                            Color(hex: "EED9C4")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 纸张纹理
            Canvas { context, size in
                for _ in 0..<4000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.02)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 0) {
                // ═══ 顶部：博物馆标题 ═══
                VStack(spacing: 6) {
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "2C5530"))
                            .frame(height: 2)
                        
                        Text("HERBARIUM")
                            .font(.system(size: 10, weight: .black, design: .serif))
                            .foregroundColor(Color(hex: "2C5530"))
                            .tracking(3)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .fill(Color(hex: "2C5530"))
                            .frame(height: 2)
                    }
                    .padding(.horizontal, 20)
                    
                    Text("时光植物标本馆")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color(hex: "2C5530").opacity(0.7))
                }
                .padding(.top, 20)
                
                // ═══ 标本展示区 ═══
                ZStack {
                    // 标本纸
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 200, height: 200)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    
                    // 照片/干花
                    if let photo = photos.first {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 180, maxHeight: 180)
                            .saturation(0.6) // 褪色效果
                            .overlay(
                                // 压花效果
                                Color(hex: "8B7355").opacity(0.08)
                                    .blendMode(.multiply)
                            )
                    } else {
                        // 无照片时显示装饰性干花
                        VStack(spacing: 6) {
                            Text("🌸")
                                .font(.system(size: 60))
                            Text(record.mood.emoji)
                                .font(.system(size: 32))
                        }
                    }
                    
                    // 透明胶带固定效果（四角）
                    VStack {
                        HStack {
                            TapeStrip()
                                .rotationEffect(.degrees(-25))
                                .offset(x: -75, y: -75)
                            Spacer()
                            TapeStrip()
                                .rotationEffect(.degrees(25))
                                .offset(x: 75, y: -75)
                        }
                        Spacer()
                        HStack {
                            TapeStrip()
                                .rotationEffect(.degrees(25))
                                .offset(x: -75, y: 75)
                            Spacer()
                            TapeStrip()
                                .rotationEffect(.degrees(-25))
                                .offset(x: 75, y: 75)
                        }
                    }
                    .frame(width: 200, height: 200)
                }
                .padding(.top, 20)
                
                // ═══ 标本信息标签 ═══
                VStack(alignment: .leading, spacing: 8) {
                    // 拉丁学名
                    HStack(spacing: 6) {
                        Text("Species:")
                            .font(.system(size: 9, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "2C5530"))
                        Text(specimenInfo.latinName)
                            .font(.system(size: 10, design: .serif))
                            .italic()
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                    
                    // 中文名
                    HStack(spacing: 6) {
                        Text("Name:")
                            .font(.system(size: 9, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "2C5530"))
                        Text(specimenInfo.chineseName)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                    
                    // 采集信息
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Location:")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(Color(hex: "5D4037"))
                            Text(specimenInfo.location)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Date:")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(Color(hex: "5D4037"))
                            Text(formattedDate)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Specimen No.")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "8B0000"))
                            Text(specimenInfo.number)
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "8B0000"))
                        }
                    }
                    
                    // 备注
                    if !record.content.isEmpty {
                        Text("Note: \(String(record.content.prefix(80)))")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "5D4037").opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 20)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "8B7355").opacity(0.3), lineWidth: 1.5)
        }
        .frame(width: 280, height: 400)
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: record.date).uppercased()
    }
}

// MARK: - 胶带条
struct TapeStrip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(hex: "D3D3D3").opacity(0.7))
            .frame(width: 35, height: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            )
    }
}

// MARK: - 标本数据
struct SpecimenData {
    let latinName: String
    let chineseName: String
    let location: String
    let number: String
    
    static func random(from date: Date) -> SpecimenData {
        let specimens: [(String, String, String)] = [
            ("Rosa memoria", "记忆玫瑰", "上海植物园"),
            ("Tempus florens", "时光花", "杭州西湖"),
            ("Nostalgia petalis", "怀旧花瓣", "苏州拙政园"),
            ("Momentum fragrans", "瞬间香", "南京玄武湖"),
            ("Memoria rosea", "记忆蔷薇", "北京植物园"),
            ("Tempus rosae", "时光蔷薇", "成都植物园")
        ]
        
        let selected = specimens.randomElement()!
        let number = String(format: "YIGE-%03d", Int.random(in: 1...999))
        
        return SpecimenData(
            latinName: selected.0,
            chineseName: selected.1,
            location: selected.2,
            number: number
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📖 日记内页 (JournalPage)
// MARK: - 参考：Moleskine经典日记本、手写字体
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterJournalPageView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(2).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 日记本纸张 ═══
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "FFFEF7"))
            
            // 纸张纹理
            Canvas { context, size in
                for _ in 0..<2000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.015)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(spacing: 0) {
                // ═══ 顶部：日期和心情 ═══
                HStack {
                    Text(formattedDate)
                        .font(.custom("Snell Roundhand", size: 20))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Spacer()
                    
                    Text(record.mood.emoji)
                        .font(.system(size: 24))
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                // ═══ 横线纸 ═══
                VStack(spacing: 0) {
                    ForEach(0..<18, id: \.self) { i in
                        HStack {
                            Rectangle()
                                .fill(Color(hex: "E8E8E0").opacity(0.6))
                                .frame(height: 1)
                                .padding(.leading, 25)
                            
                            Spacer()
                        }
                        .padding(.top, CGFloat(i) * 22 + 15)
                    }
                }
                
                // ═══ 内容区域 ═══
                VStack(alignment: .leading, spacing: 15) {
                    // 照片（如有）
                    if !photos.isEmpty {
                        HStack(spacing: 10) {
                            ForEach(0..<photos.count, id: \.self) { i in
                                Image(uiImage: photos[i])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: photos.count == 1 ? 180 : 120, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: "D0D0D0"), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.leading, 25)
                        .padding(.top, 10)
                    }
                    
                    // 文字内容
                    Text(record.content.isEmpty ? "今天..." : record.content)
                        .font(.custom("Bradley Hand", size: 15))
                        .foregroundColor(Color(hex: "2F2F2F"))
                        .lineSpacing(6)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // 天气（如有）
                    if let weather = record.weather {
                        HStack(spacing: 6) {
                            Image(systemName: weather.icon)
                                .font(.system(size: 12))
                            Text(weather.label)
                                .font(.custom("Bradley Hand", size: 12))
                        }
                        .foregroundColor(Color(hex: "8B7355"))
                        .padding(.leading, 25)
                        .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // ═══ 左侧红色边线 ═══
            Rectangle()
                .fill(Color(hex: "C41E3A").opacity(0.4))
                .frame(width: 3)
                .offset(x: -138)
            
            // ═══ 装订孔 ═══
            VStack(spacing: 0) {
                Spacer()
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "E0E0E0"))
                        .frame(width: 6, height: 6)
                    Spacer()
                }
            }
            .frame(width: 6)
            .offset(x: -138)
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "D0D0D0"), lineWidth: 1)
        }
        .frame(width: 280, height: 420)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: record.date)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - ⌨️ 打字机手稿 (Typewriter)
// MARK: - 参考：海明威打字机手稿、Royal Quiet Deluxe
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterTypewriterManuscriptView: View {
    let record: DayRecord
    
    @State private var typingProgress: CGFloat = 0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 打字机纸张 ═══
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "FFFEF7"))
            
            // 纸张纹理
            Canvas { context, size in
                for _ in 0..<3000 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.02)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(spacing: 0) {
                // ═══ 顶部：标题和日期 ═══
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("MANUSCRIPT")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .tracking(3)
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "5D4037"))
                    }
                    
                    Rectangle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 1)
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                // ═══ 照片（如有）═══
                if let photo = photos.first {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(hex: "1A1A1A").opacity(0.2), lineWidth: 1)
                        )
                        .padding(.top, 15)
                }
                
                // ═══ 打字机文字内容 ═══
                VStack(alignment: .leading, spacing: 12) {
                    Text(record.content.isEmpty ? "The moment..." : record.content)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .lineSpacing(8)
                        .tracking(0.5)
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                    
                    Spacer()
                    
                    // 底部：签名和心情
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Rectangle()
                                .fill(Color(hex: "1A1A1A").opacity(0.3))
                                .frame(width: 80, height: 1)
                            
                            Text("AUTHOR")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "5D4037"))
                        }
                        
                        Spacer()
                        
                        Text(record.mood.emoji)
                            .font(.system(size: 20))
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
            
            // ═══ 打字机字符效果（模拟打字机字体）═══
            // 通过字体和间距模拟
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "1A1A1A").opacity(0.2), lineWidth: 1)
        }
        .frame(width: 280, height: 420)
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: record.date).uppercased()
    }
}


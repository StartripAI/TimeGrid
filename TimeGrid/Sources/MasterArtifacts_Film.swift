//
//  MasterArtifacts_Film.swift
//  时光格 - 世界级信物模板：影像系列 🎬
//
//  包含：
//  1. 冲洗照片 (DevelopedPhoto) - 王家卫暗房美学
//  2. 胶片底片 (FilmNegative) - 柯达胶片底片
//
//  设计参考：
//  - 王家卫电影美学（《花样年华》《2046》）
//  - 柯达胶片底片
//  - 暗房冲洗工艺
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎞️ 冲洗照片 (DevelopedPhoto)
// MARK: - 参考：王家卫电影美学、暗房冲洗工艺
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterDevelopedPhotoView: View {
    let record: DayRecord
    
    @State private var neonFlicker: Double = 1.0
    @State private var scanlineOffset: CGFloat = 0
    @State private var photoScale: CGFloat = 1.0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 照片主体 ═══
            if let photo = photos.first {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 450)
                    .scaleEffect(photoScale)
                    .blur(radius: 1.5) // 王家卫式朦胧
                    .overlay(
                        // 绿色滤镜（王家卫标志性）
                        LinearGradient(
                            colors: [
                                Color(hex: "006400").opacity(0.35),
                                Color(hex: "228B22").opacity(0.25),
                                Color(hex: "006400").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // 霓虹光晕
                        RadialGradient(
                            colors: [
                                Color(hex: "00FF00").opacity(0.1 * neonFlicker),
                                .clear
                            ],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
            } else {
                // 无照片时的占位
                ZStack {
                    Color.black
                    
                    VStack(spacing: 12) {
                        Text(record.mood.emoji)
                            .font(.system(size: 60))
                        
                        Text("MEMORY")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "00FF00"))
                    }
                }
            }
            
            VStack {
                Spacer()
                
                // ═══ 台词字幕 ═══
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFFF00"),
                                    Color(hex: "FFD700")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 1, y: 1)
                        .shadow(color: Color(hex: "FFFF00").opacity(0.5 * neonFlicker), radius: 5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 65)
                        .opacity(neonFlicker)
                }
                
                // ═══ LED电子表时间 ═══
                HStack {
                    Spacer()
                    ZStack {
                        // LED背景光
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "00FF00").opacity(0.2 * neonFlicker))
                            .blur(radius: 8)
                            .frame(width: 120, height: 35)
                        
                        Text(formatTime(record.date))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "00FF00"))
                            .shadow(color: Color(hex: "00FF00").opacity(0.8 * neonFlicker), radius: 8)
                    }
                    .padding(20)
                }
            }
            
            // ═══ CRT扫描线效果 ═══
            VStack(spacing: 0) {
                ForEach(0..<225, id: \.self) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.black.opacity(0.05),
                                    Color.black.opacity(0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .offset(x: sin(Double(i) * 0.1 + scanlineOffset) * 2)
                }
            }
            .allowsHitTesting(false)
            
            // ═══ 白色边框（相纸效果）═══
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.white, lineWidth: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "F0F0F0"), lineWidth: 8)
                        .padding(2)
                )
        }
        .frame(width: 300, height: 450)
        .shadow(color: Color(hex: "4169E1").opacity(0.2), radius: 12, y: 6)
        .onAppear {
            // 霓虹闪烁
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                neonFlicker = 0.7
            }
            // 扫描线移动
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
                scanlineOffset += 0.5
            }
            // 照片缩放（镜头推进）
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                photoScale = 1.02
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎞️ 胶片底片 (FilmNegative)
// MARK: - 参考：柯达胶片底片、35mm胶片
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterFilmNegativeView: View {
    let record: DayRecord
    
    @State private var filmAdvance: CGFloat = 0
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        ZStack {
            // ═══ 胶片背景（深色）═══
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1A0F0A"),
                            Color(hex: "0D0805"),
                            Color(hex: "1A0F0A")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 0) {
                // ═══ 顶部：胶片齿孔和编号 ═══
                HStack {
                    // 左侧齿孔
                    FilmPerforations()
                    
                    Spacer()
                    
                    // 胶片编号
                    VStack(spacing: 2) {
                        Text("KODAK")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(2)
                        
                        Text("35mm")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text(generateFilmNumber())
                            .font(.system(size: 6, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // 右侧齿孔
                    FilmPerforations()
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                // ═══ 底片画面区域 ═══
                ZStack {
                    // 底片背景（反转的深色）
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "0A0503"))
                        .frame(width: 240, height: 160)
                    
                    // 照片（反转效果）
                    if let photo = photos.first {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 230, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .colorInvert() // 底片反转效果
                            .saturation(0.3)
                            .contrast(1.2)
                            .overlay(
                                // 底片特有的高对比度
                                Color.white.opacity(0.1)
                                    .blendMode(.overlay)
                            )
                    } else {
                        // 无照片时的占位
                        VStack(spacing: 8) {
                            Text(record.mood.emoji)
                                .font(.system(size: 40))
                                .colorInvert()
                            
                            Text("NEGATIVE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    
                    // 底片边框
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 240, height: 160)
                }
                .padding(.top, 12)
                
                // ═══ 底部信息 ═══
                VStack(spacing: 6) {
                    // 日期和帧号
                    HStack {
                        Text(formattedDate)
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text("FRAME \(Int.random(in: 1...36))")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 20)
                    
                    // 内容（如有）
                    if !record.content.isEmpty {
                        Text(String(record.content.prefix(40)))
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                            .lineLimit(1)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 15)
                
                // ═══ 底部齿孔 ═══
                HStack {
                    FilmPerforations()
                    Spacer()
                    FilmPerforations()
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
        .frame(width: 280, height: 280)
        .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMMyy"
        return formatter.string(from: record.date).uppercased()
    }
    
    private func generateFilmNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        let numbers = String(format: "%04d", Int.random(in: 1000...9999))
        return "\(prefix)\(numbers)"
    }
}

// MARK: - 胶片齿孔
struct FilmPerforations: View {
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "1A0F0A"))
                    .frame(width: 8, height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            }
        }
    }
}


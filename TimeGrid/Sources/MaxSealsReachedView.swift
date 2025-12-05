//
//  MaxSealsReachedView.swift
//  时光格 V3.5.1 - 今日封存次数已达上限
//
//  当用户尝试第三次封存时，显示已封存的内容和一句名言
//

import SwiftUI
import UIKit  // V4.1: ImageFileManager 需要 UIKit

struct MaxSealsReachedView: View {
    @Environment(\.dismiss) var dismiss
    let record: DayRecord
    let quotesManager: QuotesManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 顶部提示
                        VStack(spacing: 12) {
                            Image(systemName: "seal.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color("SealColor"))
                            
                            Text("今日封存次数已满")
                                .font(.system(size: 24, weight: .semibold, design: .serif))
                                .foregroundColor(Color("TextPrimary"))
                            
                            Text("您今日已封存两次时光")
                                .font(.system(size: 16))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        .padding(.top, 40)
                        
                        // 名言卡片（使用优雅字体）
                        let quote = quotesManager.getRandomQuote()
                        VStack(spacing: 16) {
                            Text("「\(quote.text)」")
                                .font(.system(size: 20, weight: .light, design: .serif))
                                .foregroundColor(Color("TextPrimary"))
                                .lineSpacing(8)
                                .multilineTextAlignment(.center)
                                .italic()
                            
                            if let originalText = quote.originalText {
                                Text(originalText)
                                    .font(.system(size: 16, weight: .light, design: .serif))
                                    .foregroundColor(Color("TextSecondary").opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text("— \(quote.source)")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(Color("TextSecondary"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 8)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                        )
                        .padding(.horizontal, 20)
                        
                        // 已封存的内容预览
                        VStack(alignment: .leading, spacing: 16) {
                            Text("今日已封存的内容")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(Color("TextPrimary"))
                            
                            // V4.0: 使用 StyledArtifactView 显示预览
                            StyledArtifactView(record: record)
                                .scaleEffect(0.8) // 预览模式缩小显示
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

// MARK: - 预览用的经典信件视图（简化版）
struct ClassicLetterView: View {
    let record: DayRecord
    let isPreview: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !record.content.isEmpty {
                Text(record.content)
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(Color("TextPrimary"))
                    .lineSpacing(6)
            }
            
            // V4.0: 使用 photos 数组
            if !record.photos.isEmpty {
                HStack {
                    ForEach(0..<min(record.photos.count, 3), id: \.self) { index in
                        if let uiImage = UIImage(data: record.photos[index]) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            HStack {
                Text(record.mood.emoji)
                    .font(.system(size: 20))
                
                if let weather = record.weather {
                    Image(systemName: weather.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                Text(record.formattedDate)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
    }
}


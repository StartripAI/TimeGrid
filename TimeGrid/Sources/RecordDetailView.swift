//
//  RecordDetailView.swift
//  时光格 V3.0 - 记录详情（拆封仪式）
//

import SwiftUI

struct RecordDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let record: DayRecord
    
    @State private var isUnsealing = false
    @State private var showContent = false
    @State private var envelopeOffset: CGFloat = 0
    @State private var contentOpacity: Double = 0
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()
                
                // V4.0: 移除封存检查 - 所有记录都可以立即查看
                styledRecordContent
                    .opacity(1)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(record.formattedDate)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                }
            }
        }
        .onAppear {
            // V4.0: 记录始终可见，直接显示内容
            showContent = true
            contentOpacity = 1
        }
    }
    
    // V4.0: 移除所有封存相关的视图和方法
    // 记录始终可见，不再需要等待视图和拆封动画
    
    // MARK: - 样式化记录内容
    
    private var styledRecordContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // V4.2: 使用 StyledArtifactView 显示信物
                StyledArtifactView(record: record)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                
                // 时间戳（所有样式共用）
                timestampSection
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private var timestampSection: some View {
        VStack(spacing: 6) {
            // V4.0: 移除封存时间戳显示
            // 只显示记录日期
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text("记录于 \(formatTime(record.date))")
            }
            .font(.system(size: 13))
            .foregroundColor(Color("TextSecondary"))
        }
        .padding(.top, 20)
    }
    
    // V4.0: 移除 recordContentView，直接使用 EnvelopeArtifactView
    // 照片展示功能已集成在 EnvelopeArtifactView 中
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 信封形状


// MARK: - 信封盖子形状


#Preview {
    // V4.0: 移除封存相关参数
    RecordDetailView(record: DayRecord(
        content: "今天是美好的一天，阳光很好。去了咖啡馆，读了一本好书。",
        mood: .joyful,
        weather: .sunny
    ))
    .environmentObject(DataManager())
}

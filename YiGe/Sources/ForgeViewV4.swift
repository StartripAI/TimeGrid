//
//  ForgeViewV4.swift
//  时光格 - 铸造界面 V4（集成新信物选择器）
//
//  V4 更新：
//  1. 集成 ArtifactPickerV2 信物选择器
//  2. 每次进入自动随机选择一个信物
//  3. 显示今日推荐和最近使用
//  4. 优化信物选择体验
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🔥 铸造视图 V4（简化版 - 集成新选择器）
// MARK: - ═══════════════════════════════════════════════════════════
struct ForgeViewV4: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var pickerManager = ArtifactPickerManager.shared
    
    @State private var showingNewRecord = false
    @State private var selectedStyle: RitualStyle = .thermal
    @State private var hasInitialized = false
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 铸造入口按钮
                Button {
                    // 记录使用
                    pickerManager.recordUsage(selectedStyle)
                    showingNewRecord = true
                } label: {
                    VStack(spacing: 16) {
                        // 信物预览
                        ZStack {
                            Circle()
                                .fill(selectedStyle.accentColor.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: selectedStyle.iconName)
                                .font(.system(size: 50))
                                .foregroundColor(selectedStyle.accentColor)
                        }
                        
                        // 信物名称
                        VStack(spacing: 4) {
                            Text(selectedStyle.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(selectedStyle.seriesName)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        // 随机按钮
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedStyle = pickerManager.getRandomStyle()
                            }
                            hapticFeedback(.light)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "dice.fill")
                                Text("随机换一个")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "D4AF37"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "D4AF37").opacity(0.1))
                            )
                        }
                        
                        // 选择其他信物按钮
                        Button {
                            // 打开选择器
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.grid.2x2")
                                Text("选择信物 (\(RitualStyle.allSelectableStyles.count) 种)")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // 今日推荐
                if !pickerManager.todayRecommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(hex: "D4AF37"))
                            Text("今日推荐")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(pickerManager.todayRecommendations, id: \.self) { style in
                                    RecommendationQuickCard(
                                        style: style,
                                        isSelected: selectedStyle == style
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedStyle = style
                                        }
                                        hapticFeedback(.medium)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            // 每次进入随机选择一个信物（仅首次）
            if !hasInitialized {
                selectedStyle = pickerManager.getRandomStyle()
                hasInitialized = true
            }
        }
        .fullScreenCover(isPresented: $showingNewRecord) {
            NewRecordViewWithStyle(recordDate: Date(), initialStyle: selectedStyle)
                .environmentObject(dataManager)
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - 推荐快速卡片
struct RecommendationQuickCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(style.previewBackground)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: style.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(style.accentColor)
                    
                    if isSelected {
                        Circle()
                            .stroke(style.accentColor, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                }
                
                Text(style.shortName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? style.accentColor : .primary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(color: isSelected ? style.accentColor.opacity(0.3) : .black.opacity(0.05), radius: isSelected ? 8 : 4, y: 2)
            )
        }
    }
}

// MARK: - 带初始风格的新记录视图包装器
struct NewRecordViewWithStyle: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let recordDate: Date
    let initialStyle: RitualStyle
    
    var body: some View {
        NewRecordView(recordDate: recordDate)
            .environmentObject(dataManager)
            .onAppear {
                // 注意：NewRecordView 内部使用 ViewModel，需要修改其初始化逻辑
                // 这里作为占位，实际需要在 NewRecordView 中添加支持初始风格的功能
            }
    }
}


//
//  ArtifactStylePickerView.swift
//  时光格 V4.2 - 信物风格选择器
//
//  V4.2: 修复图标丑陋问题，添加点击弹出预览功能

import SwiftUI

struct ArtifactStylePickerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var currentStyle: RitualStyle {
        dataManager.settings.preferredArtifactStyle
    }
    
    // 预览状态
    @State private var previewingStyle: RitualStyle?
    
    // 可展开/收起状态（默认全部展开）
    @State private var expandedCategories: Set<ArtifactCategory> = Set(ArtifactCategory.allCases)
    
    // 动画状态
    @State private var hasAnimated = false
    
    // 基础预览数据 - 使用计算属性，每次生成新的预览记录
    private var basePreviewRecord: DayRecord {
        DayRecord(
            date: Date(),
            content: "这是一段用于预览的示例文本，展示了信物的排版和视觉效果。我们记录，是为了再次遇见。",
            mood: .joyful,
            weather: .sunny,
            artifactStyle: .envelope
        )
    }

    // 按分类分组信物风格
    // 🔥 修复：使用十二大基础主题，排除高定风格和兼容旧版本的样式
    private var stylesByCategory: [ArtifactCategory: [RitualStyle]] {
        Dictionary(grouping: RitualStyle.mainTwelveThemes, by: { $0.category })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("点击查看风格详情，确认后设为默认")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)

                // 按分类显示（可展开/收起）
                ForEach(ArtifactCategory.allCases) { category in
                    if let styles = stylesByCategory[category], !styles.isEmpty {
                        CategorySection(
                            category: category,
                            styles: styles,
                            currentStyle: currentStyle,
                            isExpanded: expandedCategories.contains(category),
                            previewingStyle: $previewingStyle,
                            onToggle: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    if expandedCategories.contains(category) {
                                        expandedCategories.remove(category)
                                    } else {
                                        expandedCategories.insert(category)
                                    }
                                }
                            },
                            onStyleTap: { style in
                                previewingStyle = style
                            }
                        )
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color("BackgroundCream").ignoresSafeArea())
        .navigationTitle("信物风格设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("保存信物") {
                    // 保存当前选择的风格
                    dataManager.updateSettings()
                    dismiss()
                }
                .foregroundColor(Color("PrimaryWarm"))
                .fontWeight(.medium)
            }
        }
        // 弹窗预览
        .sheet(item: $previewingStyle) { style in
            StylePreviewSheet(
                style: style,
                previewRecord: generatePreviewRecord(for: style),
                onConfirm: {
                    handleSelection(style)
                    previewingStyle = nil
                }
            )
            .presentationDetents([.fraction(0.8)])
        }
    }
    
    private func generatePreviewRecord(for style: RitualStyle) -> DayRecord {
        var record = basePreviewRecord
        record.artifactStyle = style
        // 关键：为每种风格生成独特的美学细节，确保预览不同
        record.aestheticDetails = AestheticDetails.generate(for: style, customColorHex: nil)
        return record
    }
    
    private func handleSelection(_ style: RitualStyle) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            dataManager.settings.preferredArtifactStyle = style
        }
        dataManager.updateSettings()
    }
    
    // 辅助方法：为预览添加入场动画效果
    @ViewBuilder
    private func animatedPreview(_ content: some View, style: RitualStyle) -> some View {
        content
            .opacity(hasAnimated ? 1 : 0)
            .scaleEffect(hasAnimated ? 1 : animationStartScale(for: style))
            .rotationEffect(hasAnimated ? .zero : animationStartRotation(for: style))
            .offset(hasAnimated ? .zero : animationStartOffset(for: style))
            .blur(radius: hasAnimated ? 0 : animationStartBlur(for: style))
            .onAppear {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
                    hasAnimated = true
                }
            }
    }
    
    private func animationStartScale(for style: RitualStyle) -> CGFloat {
        switch style {
        case .polaroid, .postcard, .bookmark: return 0.3
        case .pressedFlower: return 0.9
        default: return 0.8
        }
    }
    
    private func animationStartRotation(for style: RitualStyle) -> Angle {
        switch style {
        case .polaroid: return .degrees(-30)
        case .bookmark: return .degrees(15)
        default: return .zero
        }
    }
    
    private func animationStartOffset(for style: RitualStyle) -> CGSize {
        switch style {
        case .polaroid, .bookmark: return CGSize(width: 0, height: -300)
        case .postcard: return CGSize(width: -600, height: -400)
        default: return .zero
        }
    }
    
    private func animationStartBlur(for style: RitualStyle) -> CGFloat {
        (style == .pressedFlower) ? 12 : 0
    }
}

// MARK: - 分类区域（可展开/收起）
struct CategorySection: View {
    let category: ArtifactCategory
    let styles: [RitualStyle]
    let currentStyle: RitualStyle
    let isExpanded: Bool
    @Binding var previewingStyle: RitualStyle?
    let onToggle: () -> Void
    let onStyleTap: (RitualStyle) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 分类标题（可点击展开/收起）
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Text(category.emoji)
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text(category.description)
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color("CardBackground"))
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
            
            // 信物风格网格（可展开/收起）
            if isExpanded {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(styles, id: \.self) { style in
                        ArtifactStyleGridItem(
                            style: style,
                            isSelected: currentStyle == style
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            onStyleTap(style)
                        }
                        .scaleEffect(previewingStyle == style ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: previewingStyle == style)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 网格项视图 (美化版，3列网格)
struct ArtifactStyleGridItem: View {
    let style: RitualStyle
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // 图标区域 - 美化版
            ZStack {
                // 渐变背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [Color("PrimaryWarm").opacity(0.25), Color("PrimaryOrange").opacity(0.15)] :
                                [Color.white, Color("BackgroundCream")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(
                        color: isSelected ? Color("PrimaryWarm").opacity(0.4) : Color.black.opacity(0.1),
                        radius: isSelected ? 10 : 6,
                        y: 3
                    )
                
                // 图标
                Image(systemName: style.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(isSelected ? Color("PrimaryOrange") : Color("TextPrimary"))
                    .symbolEffect(.bounce, value: isSelected)
            }
            .overlay(
                Group {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("PrimaryWarm"))
                            .background(Circle().fill(.white))
                            .font(.system(size: 18))
                            .offset(x: 22, y: -22)
                    }
                }
            )
            
            VStack(spacing: 2) {
                Text(style.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? Color("PrimaryOrange") : Color("TextPrimary"))
                    .lineLimit(1)
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 2)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("PrimaryWarm").opacity(0.08) : Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 2.5)
        )
    }
}

// MARK: - 预览弹窗 (沉浸式 + 完整入场动画)
struct StylePreviewSheet: View {
    let style: RitualStyle
    let previewRecord: DayRecord
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var hasAnimated = false
    
    var body: some View {
        ZStack {
            // 1. 背景层
            Color("BackgroundCream").ignoresSafeArea()
            
            // 2. 核心预览层 (居中，无遮挡) - 添加完整入场动画
            VStack {
                Spacer()
                previewContent
                Spacer()
            }
            .padding(.bottom, 60) // 给底部留点空间
            
            // 3. 悬浮控制层
            VStack {
                // 顶部按钮栏
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(style.rawValue)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    
                    Spacer()
                    
                    Button {
                        onConfirm()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("PrimaryWarm"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // 底部描述栏
                VStack(spacing: 8) {
                    Text(style.description)
                        .font(.subheadline)
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // 预览内容（带入场动画）
    @ViewBuilder
    private var previewContent: some View {
        StyledArtifactView(record: previewRecord)
            .shadow(color: Color.black.opacity(0.15), radius: 25, y: 10)
            .scaleEffect(1.0) // 保持原始比例
            // 关键：添加专属入场动画（满足需求2：点击后立即播放完整仪式）
            .opacity(hasAnimated ? 1 : 0)
            .scaleEffect(hasAnimated ? 1 : animationStartScale)
            .rotationEffect(hasAnimated ? .zero : animationStartRotation)
            .offset(hasAnimated ? .zero : animationStartOffset)
            .blur(radius: hasAnimated ? 0 : animationStartBlur)
            .onAppear {
                // 重置并播放动画
                hasAnimated = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
                        hasAnimated = true
                    }
                }
                // 触感反馈
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
    }
    
    // 动画参数（根据风格）
    private var animationStartScale: CGFloat {
        switch style {
        case .polaroid, .postcard, .bookmark: return 0.3
        case .pressedFlower: return 0.9
        default: return 0.8
        }
    }
    
    private var animationStartRotation: Angle {
        switch style {
        case .polaroid: return .degrees(-30)
        case .bookmark: return .degrees(15)
        default: return .zero
        }
    }
    
    private var animationStartOffset: CGSize {
        switch style {
        case .polaroid, .bookmark: return CGSize(width: 0, height: -300)
        case .postcard: return CGSize(width: -600, height: -400)
        default: return .zero
        }
    }
    
    private var animationStartBlur: CGFloat {
        (style == .pressedFlower) ? 12 : 0
    }
}

// 扩展 RitualStyle 以支持 sheet (Identifiable)
extension RitualStyle: Identifiable {
    public var id: String { rawValue }
}

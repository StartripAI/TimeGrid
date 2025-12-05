//
//  HubStylePickerView.swift
//  时光格 V4.0 - 首页入口风格选择器
//
//  V4.0: 用于选择首页交互风格（入口风格）

import SwiftUI

struct HubStylePickerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. 顶部预览区域 (固定)
                VStack(spacing: 16) {
                    Text("当前效果预览")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 10)
                    
                    RitualHubWidgetContainer(
                        style: dataManager.settings.todayHubStyle,
                        hasRecordToday: false,
                        onTrigger: {},
                        onShowRecord: {}
                    )
                    .scaleEffect(0.9) // 稍微缩小以适应
                    .frame(height: 240) // 限制高度
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                .background(Color("BackgroundCream"))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .zIndex(1)
                
                // 2. 底部选择列表 (可滚动)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("选择交互风格")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(TodayHubStyle.allCases) { style in
                                StyleOptionCard(
                                    style: style,
                                    isSelected: dataManager.settings.todayHubStyle == style
                                ) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.3)) {
                                        dataManager.settings.todayHubStyle = style
                                    }
                                    dataManager.updateSettings()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .background(Color("CardBackground"))
            }
            .navigationTitle("首页仪式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(width: 30, height: 30)
                            .background(Color("TextSecondary").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

// MARK: - 样式选项卡片
struct StyleOptionCard: View {
    let style: TodayHubStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColorForStyle(style))
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    
                    styleIcon
                }
                
                VStack(spacing: 4) {
                    Text(style.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextPrimary"))
                    
                    Text(style.description)
                        .font(.system(size: 10))
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var styleIcon: some View {
        switch style {
        case .simple:
            Image(systemName: "plus.circle")
                .font(.system(size: 28))
                .foregroundColor(Color("PrimaryWarm"))
        case .leicaCamera:
            Image(systemName: "camera.fill")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.9))
        case .jewelryBox:
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#C9A55C"))
        case .polaroidCamera:
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 28))
                .foregroundColor(Color("TextPrimary").opacity(0.8))
        case .waxEnvelope:
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#8B5A2B"))
        case .waxStamp:
            Image(systemName: "seal.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#C9A55C"))
        case .vault:
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#C9A55C"))
        case .typewriter:
            Image(systemName: "keyboard")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#C9A55C"))
        case .safari:
            Image(systemName: "sun.horizon.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#FF6B35"))
        case .aurora:
            Image(systemName: "snowflake")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#00CED1"))
        case .astrolabe:
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#9370DB"))
        case .omikuji:
            Image(systemName: "leaf.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#8B4513"))
        case .hourglass:
            Image(systemName: "hourglass")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "#F5A623"))
        }
    }
}


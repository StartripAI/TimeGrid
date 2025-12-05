//
//  StyleCarouselView.swift
//  时光格 V3.6 - 3D轮播选择器
//

import SwiftUI

struct StyleCarouselView: View {
    @Binding var selectedStyle: TodayHubStyle
    @Environment(\.dismiss) var dismiss
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    let styles = TodayHubStyle.allCases
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("选择入口风格")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // 3D轮播
                    ZStack {
                        ForEach(styles.indices, id: \.self) { index in
                            StyleCardView(style: styles[index])
                                .scaleEffect(scaleFor(index: index))
                                .offset(x: offsetFor(index: index))
                                .opacity(opacityFor(index: index))
                                .zIndex(zIndexFor(index: index))
                                .rotation3DEffect(
                                    .degrees(rotationFor(index: index)),
                                    axis: (x: 0, y: 1, z: 0),
                                    perspective: 0.5
                                )
                        }
                    }
                    .frame(height: 250)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold {
                                    // 向右滑 - 上一个
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentIndex = max(0, currentIndex - 1)
                                    }
                                } else if value.translation.width < -threshold {
                                    // 向左滑 - 下一个
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentIndex = min(styles.count - 1, currentIndex + 1)
                                    }
                                }
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                    )
                    
                    // 当前风格信息
                    VStack(spacing: 8) {
                        Text(styles[currentIndex].rawValue)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(styles[currentIndex].hint)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(styles[currentIndex].subhint)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // 指示点
                    HStack(spacing: 6) {
                        ForEach(styles.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentIndex ? Color(hex: "F5A623") : Color.white.opacity(0.3))
                                .frame(width: index == currentIndex ? 20 : 6, height: 6)
                                .animation(.spring(), value: currentIndex)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // 选择按钮
                    Button {
                        selectedStyle = styles[currentIndex]
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Text("使用此风格")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "F5A623"), Color(hex: "D4574B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                // 找到当前选中的索引
                if let index = styles.firstIndex(of: selectedStyle) {
                    currentIndex = index
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private func offsetFor(index: Int) -> CGFloat {
        let diff = CGFloat(index - currentIndex)
        let baseOffset = diff * 120
        let dragContribution = dragOffset * 0.3
        return baseOffset + dragContribution
    }
    
    private func scaleFor(index: Int) -> CGFloat {
        let diff = abs(index - currentIndex)
        if diff == 0 {
            return 1.0
        } else if diff == 1 {
            return 0.8
        } else {
            return 0.6
        }
    }
    
    private func opacityFor(index: Int) -> Double {
        let diff = abs(index - currentIndex)
        if diff == 0 {
            return 1.0
        } else if diff == 1 {
            return 0.7
        } else if diff == 2 {
            return 0.4
        } else {
            return 0
        }
    }
    
    private func rotationFor(index: Int) -> Double {
        let diff = index - currentIndex
        return Double(diff) * 30
    }
    
    private func zIndexFor(index: Int) -> Double {
        let diff = abs(index - currentIndex)
        return Double(10 - diff)
    }
}

// MARK: - 风格卡片

struct StyleCardView: View {
    let style: TodayHubStyle
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColorForStyle(style))
                .frame(width: 140, height: 200)
                .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
            
            VStack(spacing: 12) {
                // 使用风格对应的图标
                Text(styleIcon(for: style))
                    .font(.system(size: 50))
                
                Text(style.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(style.textColor)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func styleIcon(for style: TodayHubStyle) -> String {
        switch style {
        case .simple: return "⭕"
        case .leicaCamera: return "📷"
        case .jewelryBox: return "💎"
        case .polaroidCamera: return "📷"
        case .waxEnvelope: return "📮"
        case .waxStamp: return "🔴"
        case .vault: return "🔐"
        case .typewriter: return "⌨️"
        case .safari: return "🌅"
        case .aurora: return "❄️"
        case .astrolabe: return "🔮"
        case .omikuji: return "🎋"
        case .hourglass: return "⏳"
        }
    }
}


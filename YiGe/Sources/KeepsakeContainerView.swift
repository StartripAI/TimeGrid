//
//  KeepsakeContainerView.swift
//  时光格 V4.0 - 统一信物容器
//
//  统一尺寸：所有信物卡片统一外层容器
//  内部自由，外部尺寸一致 240×300（可缩放）
//

import SwiftUI

// MARK: - 统一信物容器
struct KeepsakeContainerView<Content: View>: View {
    let content: Content
    let style: RitualStyle
    let scale: CGFloat
    
    init(style: RitualStyle, scale: CGFloat = 1.0, @ViewBuilder content: () -> Content) {
        self.style = style
        self.scale = scale
        self.content = content()
    }
    
    private var theme: KeepsakeTheme {
        style.theme
    }
    
    var body: some View {
        ZStack {
            // 统一容器背景
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)
                .shadow(
                    color: theme.shadowColor,
                    radius: 12 * scale,
                    x: 0,
                    y: 4 * scale
                )
            
            // 内容区域（可自由布局）
            content
                .padding(16 * scale)
        }
        .frame(width: 240 * scale, height: 300 * scale)
    }
}

// MARK: - 便捷扩展
extension View {
    func keepsakeContainer(style: RitualStyle, scale: CGFloat = 1.0) -> some View {
        KeepsakeContainerView(style: style, scale: scale) {
            self
        }
    }
}


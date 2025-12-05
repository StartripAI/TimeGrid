//
//  Extensions.swift
//  YiGe
//
//  Created by Alfred on 2025/11/27.
//

import SwiftUI
import UIKit

// MARK: - 辅助函数：递归查找 ScrollView
@MainActor
private func findScrollViewInView(_ view: UIView?) -> UIScrollView? {
    guard let view = view else { return nil }
    
    if let scrollView = view as? UIScrollView {
        return scrollView
    }
    
    for subview in view.subviews {
        if let scrollView = findScrollViewInView(subview) {
            return scrollView
        }
    }
    
    return nil
}

// MARK: - 全局辅助函数：渲染视图为图片（用于解决扩展方法识别问题）

@MainActor
func renderViewToImage(_ view: AnyView, width: CGFloat = 700, scale: CGFloat = 2.0) -> UIImage? {
    let controller = UIHostingController(rootView: view.ignoresSafeArea())
    let uiView = controller.view
    
    // 创建临时窗口以确保视图处于视图层级中
    let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 2000)))
    window.rootViewController = controller
    window.isHidden = true
    
    // 强制计算布局
    let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
    uiView?.bounds = CGRect(origin: .zero, size: targetSize)
    uiView?.backgroundColor = .clear
    
    let size = uiView?.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel
    ) ?? CGSize(width: width, height: 1000)
    
    // 更新 Frame 并触发布局更新
    uiView?.bounds = CGRect(origin: .zero, size: size)
    window.frame = CGRect(origin: .zero, size: size)
    uiView?.layoutIfNeeded()
    
    // 渲染
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    format.opaque = false
    
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    
    return renderer.image { context in
        uiView?.drawHierarchy(in: uiView!.bounds, afterScreenUpdates: true)
    }
}

// MARK: - View Extensions

extension View {
    /// 应用全局奢华主题 (V7.3)
    /// 注意：此方法现在通过 .background() 和 ThemeEngine 实现，不再需要传入 style
    /// 为了兼容性，保留函数签名，但内部实现已更新
    func applyLuxuryTheme(style: TodayHubStyle) -> some View {
        self.modifier(LuxuryContainerModifier())
    }
    
    /// 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Snapshot Extension

extension View {
    /// 生成高质量快照 (解决 ImageRenderer 渲染不全/模糊/空白问题)
    /// 
    /// 输出分辨率：约 1400x2100 像素 (短图) 或 1400x动态 (长图)
    /// 文件大小：约 1-2MB (JPEG 压缩后)
    /// 
    /// - Parameters:
    ///   - width: 目标宽度，默认 700pt (类似 iPhone 照片宽度)
    ///   - scale: 渲染缩放倍数，默认 2.0 (生成约 1400px 宽)
    @MainActor
    func snapshot(width: CGFloat = 700, scale: CGFloat = 2.0) -> UIImage? {
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view
        
        // 1. 创建临时窗口以确保视图处于视图层级中 (解决 drawHierarchy 失败问题)
        // 对于长条形内容，使用更大的初始高度
        let initialHeight: CGFloat = 5000
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: width, height: initialHeight)))
        window.rootViewController = controller
        window.isHidden = true // 保持隐藏
        
        // 2. 强制计算布局
        view?.bounds = CGRect(origin: .zero, size: CGSize(width: width, height: initialHeight))
        view?.backgroundColor = .clear
        
        // 3. 对于包含 ScrollView 的视图，需要特殊处理来计算完整内容高度
        // 先设置一个大的 frame，让内容完全展开
        view?.frame = CGRect(origin: .zero, size: CGSize(width: width, height: initialHeight))
        window.frame = CGRect(origin: .zero, size: CGSize(width: width, height: initialHeight))
        view?.setNeedsLayout()
        view?.layoutIfNeeded()
        
        // 4. 等待布局完成，然后计算实际内容高度
        // 查找 ScrollView 并获取其内容大小
        var contentHeight: CGFloat = initialHeight
        if let scrollView = findScrollViewInView(view) {
            // 获取 ScrollView 的内容高度
            let contentSize = scrollView.contentSize
            if contentSize.height > 0 {
                contentHeight = max(contentSize.height, 1000) // 至少 1000，但使用实际内容高度
            }
        } else {
            // 没有 ScrollView，使用 systemLayoutSizeFitting
            let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            let fittedSize = view?.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ) ?? CGSize(width: width, height: 2000)
            contentHeight = max(fittedSize.height, 1000)
        }
        
        // 5. 更新到实际大小
        let finalSize = CGSize(width: width, height: contentHeight)
        view?.bounds = CGRect(origin: .zero, size: finalSize)
        view?.frame = CGRect(origin: .zero, size: finalSize)
        window.frame = CGRect(origin: .zero, size: finalSize)
        view?.setNeedsLayout()
        view?.layoutIfNeeded()
        
        // 6. 再次等待布局完成
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        // 7. 渲染
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: finalSize, format: format)
        
        return renderer.image { context in
            // afterScreenUpdates: true 确保在捕获前完成所有屏幕更新
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Modifiers

// 全局容器修饰符：自动应用当前主题背景
struct LuxuryContainerModifier: ViewModifier {
    @ObservedObject var themeEngine = ThemeEngine.shared
    
    func body(content: Content) -> some View {
        ZStack {
            // 动态背景层 (ThemeMaterials 2.swift)
            LuxuryBackground()
                .ignoresSafeArea()
            
            // 内容层
            content
                .foregroundColor(themeEngine.currentTheme.accentColor) // 自动适配文字颜色
        }
    }
}

// 颜色初始化扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// Helpers.swift
import SwiftUI
import UIKit

// 注意：Color(hex:) 扩展已在 Models.swift 中定义，此处不再重复定义

// MARK: - TodayHubStyle 辅助函数

/// 将 preferredBackground (some View) 转换为 Color，用于 fill() 方法
func backgroundColorForStyle(_ style: TodayHubStyle) -> Color {
    switch style {
    case .simple, .polaroidCamera:
        return Color("BackgroundCream")
    case .leicaCamera, .vault:
        return Color(hex: "1C1C1E")
    case .jewelryBox, .waxStamp, .hourglass:
        return Color(hex: "2C1810")
    case .waxEnvelope, .omikuji:
        return Color(hex: "FDF8F3")
    case .typewriter:
        return Color(hex: "2A2A2A")
    case .safari:
        return Color(hex: "FFF5E6")
    case .aurora, .astrolabe:
        return Color(hex: "0B1026")
    }
}

/// 获取卡片背景颜色
func cardBackgroundForStyle(_ style: TodayHubStyle) -> Color {
    if style.isDarkTheme {
        return Color.white.opacity(0.1)
    } else {
        return Color.white.opacity(0.8)
    }
}

// UIColor hex扩展
extension UIColor {
    convenience init?(hex: String) {
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
            return nil
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// 圆角辅助
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// 毛玻璃辅助
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

// 圆角扩展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - UIImage 扩展：裁切白色边框
extension UIImage {
    /// 裁切掉图片四周的白色边框，返回裁切后的图片
    func croppingWhiteBorders() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // 🔥 对于长条形图片（高度/宽度比例 > 2.0 或宽度/高度比例 > 2.0），不裁切
        // 避免裁切掉热敏小票、收据等长条形内容
        let aspectRatio = max(CGFloat(width) / CGFloat(height), CGFloat(height) / CGFloat(width))
        if aspectRatio > 2.0 {
            print("🔍 DEBUG: croppingWhiteBorders - 长条形图片（比例: \(aspectRatio)），跳过裁切")
            return self
        }
        
        // 🔥 如果图片高度远大于宽度（竖向长条形），也不裁切
        if CGFloat(height) / CGFloat(width) > 1.8 {
            print("🔍 DEBUG: croppingWhiteBorders - 竖向长条形图片（高度/宽度: \(CGFloat(height) / CGFloat(width))），跳过裁切")
            return self
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // 读取所有像素数据
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 检查像素是否为白色或浅色（允许更大的容差，因为可能有抗锯齿和浅色背景）
        func isWhitePixel(x: Int, y: Int, tolerance: UInt8 = 30) -> Bool {
            let pixelIndex = (y * width + x) * bytesPerPixel
            let r = pixelData[pixelIndex]
            let g = pixelData[pixelIndex + 1]
            let b = pixelData[pixelIndex + 2]
            // 如果 RGB 都接近 255，认为是白色（增加容差以处理浅色背景）
            return r >= (255 - tolerance) && g >= (255 - tolerance) && b >= (255 - tolerance)
        }
        
        // 从顶部开始查找第一个非白色行
        var top = 0
        for y in 0..<height {
            var hasNonWhite = false
            for x in 0..<width {
                if !isWhitePixel(x: x, y: y) {
                    hasNonWhite = true
                    break
                }
            }
            if hasNonWhite {
                top = y
                break
            }
        }
        
        // 从底部开始查找第一个非白色行
        var bottom = height - 1
        for y in stride(from: height - 1, through: 0, by: -1) {
            var hasNonWhite = false
            for x in 0..<width {
                if !isWhitePixel(x: x, y: y) {
                    hasNonWhite = true
                    break
                }
            }
            if hasNonWhite {
                bottom = y
                break
            }
        }
        
        // 从左边开始查找第一个非白色列
        var left = 0
        for x in 0..<width {
            var hasNonWhite = false
            for y in 0..<height {
                if !isWhitePixel(x: x, y: y) {
                    hasNonWhite = true
                    break
                }
            }
            if hasNonWhite {
                left = x
                break
            }
        }
        
        // 从右边开始查找第一个非白色列
        var right = width - 1
        for x in stride(from: width - 1, through: 0, by: -1) {
            var hasNonWhite = false
            for y in 0..<height {
                if !isWhitePixel(x: x, y: y) {
                    hasNonWhite = true
                    break
                }
            }
            if hasNonWhite {
                right = x
                break
            }
        }
        
        // 如果整个图片都是白色，返回原图
        if top >= bottom || left >= right {
            return self
        }
        
        // 添加一些边距（避免裁切太紧）
        let margin = 10
        let cropRect = CGRect(
            x: max(0, left - margin),
            y: max(0, top - margin),
            width: min(width - max(0, left - margin), right - left + margin * 2),
            height: min(height - max(0, top - margin), bottom - top + margin * 2)
        )
        
        // 裁切图片
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
        }
        
        return self
    }
}


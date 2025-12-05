import SwiftUI
import UIKit

// MARK: - 📱 信物输出规格系统 V3.0
// 针对手机屏幕和分享场景优化

// MARK: - 🎯 输出质量档位
enum OutputQuality: String, CaseIterable, Identifiable {
    case standard = "标准"      // 适合快速分享
    case hd = "高清"           // 适合相册保存
    case ultra = "超高清"      // 适合打印/壁纸
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard: return "快速分享，文件小"
        case .hd: return "相册保存，清晰锐利"
        case .ultra: return "打印/壁纸，极致细节"
        }
    }
    
    /// 渲染倍率
    var scale: CGFloat {
        switch self {
        case .standard: return 2.0   // @2x
        case .hd: return 3.0         // @3x
        case .ultra: return 4.0      // @4x
        }
    }
    
    /// 预估文件大小（KB）
    func estimatedFileSize(for size: CGSize) -> Int {
        let pixels = size.width * size.height * pow(scale, 2)
        // JPEG 压缩后约 0.5-1 byte/pixel
        return Int(pixels * 0.7 / 1024)
    }
}

// MARK: - 📏 信物输出规格
struct ArtifactOutputSpec {
    
    // MARK: - 基准尺寸（逻辑点数 pt）
    // 这是 View 的设计尺寸
    let designWidth: CGFloat
    let designHeight: CGFloat
    
    // MARK: - 输出尺寸（像素 px）
    // 针对不同质量档位的实际输出
    
    /// 标准质量输出尺寸 (@2x)
    var standardSize: CGSize {
        CGSize(
            width: designWidth * OutputQuality.standard.scale,
            height: designHeight * OutputQuality.standard.scale
        )
    }
    
    /// 高清质量输出尺寸 (@3x)
    var hdSize: CGSize {
        CGSize(
            width: designWidth * OutputQuality.hd.scale,
            height: designHeight * OutputQuality.hd.scale
        )
    }
    
    /// 超高清质量输出尺寸 (@4x)
    var ultraSize: CGSize {
        CGSize(
            width: designWidth * OutputQuality.ultra.scale,
            height: designHeight * OutputQuality.ultra.scale
        )
    }
    
    /// 宽高比
    var aspectRatio: CGFloat {
        designWidth / designHeight
    }
    
    /// 是否是竖向（适合手机屏幕）
    var isPortrait: Bool {
        designHeight > designWidth
    }
    
    /// 是否是横向（如黑胶唱片）
    var isLandscape: Bool {
        designWidth > designHeight
    }
    
    /// 是否是方形
    var isSquare: Bool {
        abs(designWidth - designHeight) < 10
    }
}

// MARK: - 🎨 每个信物的输出规格
extension RitualStyle {
    
    /// 获取信物的输出规格
    var outputSpec: ArtifactOutputSpec {
        switch self {
            
        // ══════════════════════════════════════════════════════════════
        // 📐 标准竖向信物 (约 2:3 比例)
        // 设计尺寸：300×450pt → 输出：900×1350px (@3x)
        // 在 iPhone 15 Pro (1179px宽) 上占屏幕宽度 76%，非常适合观看
        // ══════════════════════════════════════════════════════════════
            
        case .vault, .pressedFlower, .waxStamp, .typewriter, .journalPage,
             .postcard, .developedPhoto, .simple,
             .safari, .aurora, .astrolabe, .hourglass, .monoTicket, .galaInvite:
            return ArtifactOutputSpec(designWidth: 300, designHeight: 450)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 较大竖向信物
        // 设计尺寸：320×520pt → 输出：960×1560px (@3x)
        // ══════════════════════════════════════════════════════════════
            
        case .envelope, .waxEnvelope:
            return ArtifactOutputSpec(designWidth: 320, designHeight: 520)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 宝丽来 (接近正方形)
        // 设计尺寸：300×400pt → 输出：900×1200px (@3x)
        // 经典宝丽来比例，非常适合 Instagram (4:5)
        // ══════════════════════════════════════════════════════════════
            
        case .polaroid:
            return ArtifactOutputSpec(designWidth: 300, designHeight: 400)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 窄型信物 (书签)
        // 设计尺寸：200×450pt → 输出：600×1350px (@3x)
        // 窄型设计，适合作为手机壁纸的一部分
        // ══════════════════════════════════════════════════════════════
            
        case .bookmark:
            return ArtifactOutputSpec(designWidth: 200, designHeight: 450)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 收据型信物 (可变长度)
        // 设计尺寸：260×550pt → 输出：780×1650px (@3x)
        // 保持足够长度以容纳内容
        // ══════════════════════════════════════════════════════════════
            
        case .receipt:
            return ArtifactOutputSpec(designWidth: 260, designHeight: 550)
            
        case .thermal:
            return ArtifactOutputSpec(designWidth: 240, designHeight: 600)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 票据型信物
        // 设计尺寸：280×450pt → 输出：840×1350px (@3x)
        // ══════════════════════════════════════════════════════════════
            
        case .omikuji:
            return ArtifactOutputSpec(designWidth: 280, designHeight: 450)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 横向信物 (黑胶唱片)
        // 设计尺寸：350×300pt → 输出：1050×900px (@3x)
        // 横向布局，在手机上需要横屏或缩小查看
        // ⚠️ 特殊处理：可选择旋转90度输出为竖向
        // ══════════════════════════════════════════════════════════════
            
        case .vinylRecord:
            return ArtifactOutputSpec(designWidth: 350, designHeight: 300)
            
        // 默认
        default:
            return ArtifactOutputSpec(designWidth: 300, designHeight: 450)
        }
    }
}

// MARK: - 🖼️ 输出格式配置
struct OutputFormatConfig {
    let format: ImageFormat
    let quality: CGFloat  // 0.0-1.0，仅对 JPEG 有效
    
    enum ImageFormat {
        case jpeg
        case png
        case heic  // iOS 原生高效格式
    }
    
    /// 相册保存推荐配置
    static let photoLibrary = OutputFormatConfig(format: .jpeg, quality: 0.92)
    
    /// 分享推荐配置（较小文件）
    static let sharing = OutputFormatConfig(format: .jpeg, quality: 0.85)
    
    /// 最高质量（透明背景支持）
    static let lossless = OutputFormatConfig(format: .png, quality: 1.0)
    
    /// 苹果设备优化
    static let appleOptimized = OutputFormatConfig(format: .heic, quality: 0.9)
}

// MARK: - 🎯 最终输出配置
struct FinalOutputConfig {
    let spec: ArtifactOutputSpec
    let quality: OutputQuality
    let format: OutputFormatConfig
    
    /// 最终输出像素尺寸
    var outputSize: CGSize {
        switch quality {
        case .standard: return spec.standardSize
        case .hd: return spec.hdSize
        case .ultra: return spec.ultraSize
        }
    }
    
    /// 渲染倍率
    var renderScale: CGFloat {
        quality.scale
    }
    
    /// 预估文件大小 (KB)
    var estimatedFileSize: Int {
        quality.estimatedFileSize(for: CGSize(width: spec.designWidth, height: spec.designHeight))
    }
    
    /// 是否适合作为手机壁纸
    var suitableForWallpaper: Bool {
        // 壁纸需要足够高的分辨率
        let minWallpaperHeight: CGFloat = 2000
        return outputSize.height >= minWallpaperHeight && spec.isPortrait
    }
    
    /// 是否适合 Instagram
    var suitableForInstagram: Bool {
        // Instagram 推荐 4:5 或 1:1
        let ratio = spec.aspectRatio
        return (ratio >= 0.8 && ratio <= 1.0) || (ratio >= 0.65 && ratio <= 0.75)
    }
}

// MARK: - 📱 推荐输出配置
struct RecommendedOutputConfig {
    
    /// 获取信物的推荐输出配置
    static func getRecommended(for style: RitualStyle, usage: OutputUsage) -> FinalOutputConfig {
        let spec = style.outputSpec
        
        switch usage {
        case .quickShare:
            // 快速分享：标准质量，JPEG 压缩
            return FinalOutputConfig(
                spec: spec,
                quality: .standard,
                format: .sharing
            )
            
        case .photoLibrary:
            // 保存到相册：高清质量，高质量 JPEG
            return FinalOutputConfig(
                spec: spec,
                quality: .hd,
                format: .photoLibrary
            )
            
        case .socialMedia:
            // 社交媒体：高清质量，适度压缩
            return FinalOutputConfig(
                spec: spec,
                quality: .hd,
                format: .sharing
            )
            
        case .wallpaper:
            // 壁纸：超高清质量，最高质量
            return FinalOutputConfig(
                spec: spec,
                quality: .ultra,
                format: .photoLibrary
            )
            
        case .print:
            // 打印：超高清质量，PNG 无损
            return FinalOutputConfig(
                spec: spec,
                quality: .ultra,
                format: .lossless
            )
        }
    }
    
    /// 使用场景
    enum OutputUsage: String, CaseIterable {
        case quickShare = "快速分享"
        case photoLibrary = "保存相册"
        case socialMedia = "社交媒体"
        case wallpaper = "手机壁纸"
        case print = "打印输出"
        
        var icon: String {
            switch self {
            case .quickShare: return "paperplane.fill"
            case .photoLibrary: return "photo.fill"
            case .socialMedia: return "square.and.arrow.up.fill"
            case .wallpaper: return "iphone"
            case .print: return "printer.fill"
            }
        }
    }
}

// MARK: - 🔍 输出预览信息
struct OutputPreviewInfo: View {
    let style: RitualStyle
    let quality: OutputQuality
    
    private var config: FinalOutputConfig {
        FinalOutputConfig(
            spec: style.outputSpec,
            quality: quality,
            format: .photoLibrary
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 尺寸信息
            HStack {
                Image(systemName: "aspectratio")
                    .foregroundColor(.blue)
                Text("输出尺寸")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text("\(Int(config.outputSize.width)) × \(Int(config.outputSize.height)) px")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // 文件大小预估
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.orange)
                Text("预估大小")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text("约 \(config.estimatedFileSize) KB")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // 适用场景
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("适用场景")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                HStack(spacing: 8) {
                    if config.suitableForInstagram {
                        Label("Instagram", systemImage: "camera.fill")
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(4)
                    }
                    if config.suitableForWallpaper {
                        Label("壁纸", systemImage: "iphone")
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


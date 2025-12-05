import SwiftUI
import UIKit

// MARK: - 🖼️ 信物图片渲染器 V2.0
// 为每个信物提供精确的1对1渲染配置，彻底解决下载问题

struct ArtifactImageRenderer {
    
    // MARK: - 渲染配置结构
    struct RenderConfig {
        let width: CGFloat
        let height: CGFloat
        let scale: CGFloat
        let isAnimated: Bool           // 是否有动画，需要等待
        let animationDelay: Double     // 动画延迟时间
        let needsBackground: Bool      // 是否需要添加背景色
        let backgroundColor: UIColor
        let cornerRadius: CGFloat
        
        init(
            width: CGFloat,
            height: CGFloat,
            scale: CGFloat = 3.0,      // 默认3倍渲染，保证清晰度
            isAnimated: Bool = false,
            animationDelay: Double = 0,
            needsBackground: Bool = true,
            backgroundColor: UIColor = .white,
            cornerRadius: CGFloat = 0
        ) {
            self.width = width
            self.height = height
            self.scale = scale
            self.isAnimated = isAnimated
            self.animationDelay = animationDelay
            self.needsBackground = needsBackground
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
        }
    }
    
    // MARK: - 🎯 核心：每个信物的精确配置
    static func getConfig(for style: RitualStyle) -> RenderConfig {
        switch style {
            
        // ══════════════════════════════════════════════════════════════
        // 🏛 Collection I: The Archivist (皇家档案馆)
        // ══════════════════════════════════════════════════════════════
            
        case .envelope: // 皇家诏书 StyleRoyalDecreeView
            return RenderConfig(
                width: 320,
                height: 520,
                isAnimated: true,
                animationDelay: 3.0,  // 墨水书写动画需要2.5秒
                backgroundColor: UIColorFromHex("F5F0E6")
            )
            
        case .waxEnvelope: // 同上
            return RenderConfig(
                width: 320,
                height: 520,
                isAnimated: true,
                animationDelay: 3.0,
                backgroundColor: UIColorFromHex("F5F0E6")
            )
            
        case .vault: // 绝密档案 StyleClassifiedView
            return RenderConfig(
                width: 300,
                height: 480,
                isAnimated: true,
                animationDelay: 2.0,  // 打字机效果1.5秒
                backgroundColor: UIColorFromHex("D7C9AA")
            )
            
        case .pressedFlower: // 植物学家 StyleBotanistView
            return RenderConfig(
                width: 300,
                height: 460,
                backgroundColor: UIColorFromHex("F2E8D5")
            )
            
        case .waxStamp: // 皇家御玺 StyleWaxStampView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 火漆光泽动画
                backgroundColor: UIColorFromHex( "F5E6D3")
            )
            
        case .typewriter: // 作家手稿 StyleTypewriterView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 2.5,  // 打字动画2秒
                backgroundColor: UIColorFromHex( "F9F9F6")
            )
            
        case .journalPage: // 日记内页 StyleJournalPageView
            return RenderConfig(
                width: 300,
                height: 450,
                backgroundColor: UIColorFromHex( "FFFEF7")
            )
            
        // ══════════════════════════════════════════════════════════════
        // 🎬 Collection II: The Director (电影大师)
        // ══════════════════════════════════════════════════════════════
            
        case .postcard: // 韦斯安德森 StyleWesAndersonView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 缩放动画
                backgroundColor: UIColorFromHex( "FFC0CB")
            )
            
        case .developedPhoto: // 王家卫 StyleWongKarWaiView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 霓虹闪烁
                backgroundColor: .black
            )
        case .filmNegative: // 胶片底片 MasterFilmNegativeView
            return RenderConfig(
                width: 320,
                height: 130,
                isAnimated: false,
                animationDelay: 0,
                backgroundColor: .black
            )
            
        // ══════════════════════════════════════════════════════════════
        // 👠 Collection III: The Vogue (时尚女魔头)
        // ══════════════════════════════════════════════════════════════
            
        case .simple: // 杂志封面 StyleVogueCoverView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 标题呼吸光
                backgroundColor: UIColorFromHex( "2C2C2C")
            )
            
        case .polaroid: // 宝丽来 StylePolaroidSX70View
            return RenderConfig(
                width: 300,
                height: 400,  // 注意：宝丽来比其他信物短
                isAnimated: true,
                animationDelay: 4.5,  // 显影动画需要4秒
                backgroundColor: .white
            )
            
        // ══════════════════════════════════════════════════════════════
        // 💿 Collection V: The Collector (顶级藏家)
        // ══════════════════════════════════════════════════════════════
            
        case .vinylRecord: // 黑胶唱片 StyleVinylView
            return RenderConfig(
                width: 350,
                height: 300,  // 注意：横向布局
                isAnimated: true,
                animationDelay: 0.5,  // 旋转动画
                backgroundColor: UIColorFromHex( "1A1A1A")
            )
            
        case .receipt: // 收据 StyleReceiptView
            // ⚠️ 重点：收据是动态高度，需要特殊处理
            return RenderConfig(
                width: 260,
                height: 600,  // 使用固定最大高度，避免动态计算问题
                backgroundColor: .white,
                cornerRadius: 2
            )
            
        case .thermal: // 热敏小票
            // ⚠️ 重点：热敏小票也是动态高度
            return RenderConfig(
                width: 240,  // 热敏小票更窄
                height: 700,  // 热敏小票可能更长
                backgroundColor: .white,
                cornerRadius: 2
            )
            
        case .bookmark: // 书签 StyleBookmarkView
            return RenderConfig(
                width: 200,  // 窄型
                height: 450,
                backgroundColor: UIColorFromHex( "8B0000")
            )
            
        // ══════════════════════════════════════════════════════════════
        // 🌍 Collection VI: The Explorer (探索者系列)
        // ══════════════════════════════════════════════════════════════
            
        case .safari: // 探险日志 StyleSafariView
            return RenderConfig(
                width: 300,
                height: 450,
                backgroundColor: UIColorFromHex( "F4A460")
            )
            
        case .aurora: // 极光幻境 StyleAuroraView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 极光漂移
                backgroundColor: UIColorFromHex( "0A0E27")
            )
            
        case .astrolabe: // 星象仪 StyleAstrolabeView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 旋转动画
                backgroundColor: UIColorFromHex( "000428")
            )
            
        case .omikuji: // 神社绘马 StyleOmikujiView
            return RenderConfig(
                width: 280,
                height: 450,
                backgroundColor: UIColorFromHex( "DEB887")
            )
            
        case .hourglass: // 流沙时光 StyleHourglassView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 3.5,  // 流沙动画3秒
                backgroundColor: UIColorFromHex( "F5DEB3")
            )
            
        // ══════════════════════════════════════════════════════════════
        // 🕰 兼容旧版本
        // ══════════════════════════════════════════════════════════════
            
        case .monoTicket: // 时光小票 StyleMonoTicketView
            return RenderConfig(
                width: 260,
                height: 450,
                backgroundColor: .white
            )
            
        case .galaInvite: // 流光邀约 StyleGalaInviteView
            return RenderConfig(
                width: 300,
                height: 450,
                isAnimated: true,
                animationDelay: 0.5,  // 流光动画
                backgroundColor: UIColorFromHex( "1A1A2E")
            )
            
        // ══════════════════════════════════════════════════════════════
        // ✈️ Collection VII: Aviation (航空系列)
        // ══════════════════════════════════════════════════════════════
            
        case .boardingPass: // 登机牌 MasterBoardingPassView
            return RenderConfig(
                width: 200,
                height: 400,
                isAnimated: true,
                animationDelay: 0.5,  // 光泽动画
                backgroundColor: UIColorFromHex("1E3A5F")
            )
            
        case .aircraftType: // 机型证 MasterAircraftTypeRatingView
            return RenderConfig(
                width: 300,
                height: 420,
                isAnimated: true,
                animationDelay: 0.5,  // 全息图动画
                backgroundColor: UIColorFromHex("F5F5F0")
            )
            
        case .flightLog: // 航空日志 MasterFlightLogView
            return RenderConfig(
                width: 300,
                height: 450,
                backgroundColor: UIColorFromHex("F5F5F0")
            )
            
        case .luggageTag: // 行李牌 MasterLuggageTagView
            return RenderConfig(
                width: 200,
                height: 300,
                backgroundColor: UIColorFromHex("E8D5C4")
            )
            
        // ══════════════════════════════════════════════════════════════
        // 🎫 Collection VIII: Tickets (票据系列)
        // ══════════════════════════════════════════════════════════════
            
        case .concertTicket: // 演出门票 MasterConcertTicketView
            return RenderConfig(
                width: 280,
                height: 450,
                backgroundColor: UIColorFromHex("1A1A2E")
            )
        }
    }
    
    // MARK: - 🎨 主渲染方法（异步）
    @MainActor
    static func render(record: DayRecord, completion: @escaping (UIImage?) -> Void) {
        let config = getConfig(for: record.artifactStyle)
        
        // 创建用于渲染的静态View（禁用动画状态）
        let staticView = createStaticView(for: record, config: config)
        
        // 如果是动画信物，需要等待动画完成
        if config.isAnimated {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDelay) {
                let image = renderToImage(view: staticView, config: config)
                completion(image)
            }
        } else {
            let image = renderToImage(view: staticView, config: config)
            completion(image)
        }
    }
    
    // MARK: - 创建静态渲染View
    @MainActor
    private static func createStaticView(for record: DayRecord, config: RenderConfig) -> some View {
        // 使用工厂方法获取View
        ArtifactTemplateFactory.makeView(for: record)
            .frame(width: config.width, height: config.height)
            .clipped()
    }
    
    // MARK: - 核心渲染逻辑
    @MainActor
    private static func renderToImage<V: View>(view: V, config: RenderConfig) -> UIImage? {
        // 创建渲染容器
        let containerView = ZStack {
            // 背景层
            if config.needsBackground {
                Color(config.backgroundColor)
            }
            
            // 信物层
            view
        }
        .frame(width: config.width, height: config.height)
        
        // 使用 UIHostingController 进行渲染
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = config.backgroundColor
        
        // 设置精确尺寸
        let targetSize = CGSize(width: config.width, height: config.height)
        hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
        
        // 强制布局
        hostingController.view.layoutIfNeeded()
        
        // 使用 UIGraphicsImageRenderer 进行高质量渲染
        let format = UIGraphicsImageRendererFormat()
        format.scale = config.scale  // 高分辨率
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let image = renderer.image { context in
            // 填充背景色（防止透明导致的黑色/白色问题）
            config.backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // 渲染View
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
        
        // 如果需要圆角
        if config.cornerRadius > 0 {
            return image.withRoundedCorners(radius: config.cornerRadius * config.scale)
        }
        
        return image
    }
    
    // MARK: - 同步渲染方法（用于简单信物）
    @MainActor
    static func renderSync(record: DayRecord) -> UIImage? {
        let config = getConfig(for: record.artifactStyle)
        let staticView = createStaticView(for: record, config: config)
        return renderToImage(view: staticView, config: config)
    }
}

// MARK: - 辅助扩展
// 注意：UIColor(hex:) 扩展已在 Helpers.swift 中定义，此处不再重复定义

// 辅助函数：将可选的 UIColor(hex:) 转换为非可选
private func UIColorFromHex(_ hex: String) -> UIColor {
    return UIColor(hex: hex) ?? .white
}

extension UIImage {
    func withRoundedCorners(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
            draw(in: rect)
        }
    }
}

// MARK: - 🔧 调试工具
#if DEBUG
extension ArtifactImageRenderer {
    /// 打印所有信物的渲染配置
    static func printAllConfigs() {
        let allStyles: [RitualStyle] = [
            .envelope, .vault, .pressedFlower, .waxEnvelope, .waxStamp, .typewriter, .journalPage,
            .postcard, .developedPhoto,
            .simple, .polaroid,
            .vinylRecord, .receipt, .thermal, .bookmark,
            .safari, .aurora, .astrolabe, .omikuji, .hourglass,
            .monoTicket, .galaInvite
        ]
        
        print("═══════════════════════════════════════════")
        print("📋 信物渲染配置清单")
        print("═══════════════════════════════════════════")
        
        for style in allStyles {
            let config = getConfig(for: style)
            print("\(style.rawValue):")
            print("  尺寸: \(Int(config.width)) x \(Int(config.height))")
            print("  动画: \(config.isAnimated ? "✓ (\(config.animationDelay)秒)" : "✗")")
            print("───────────────────────────────────────────")
        }
    }
}
#endif


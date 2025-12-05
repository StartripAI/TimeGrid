import SwiftUI
import UIKit

// MARK: - 🩹 问题信物专用渲染补丁
// 针对以下问题信物的特殊处理：
// 1. 收据/热敏小票 - 动态高度
// 2. 黑胶唱片 - 横向布局
// 3. 书签 - 窄型+尖角
// 4. 宝丽来 - 显影动画

// MARK: - 问题信物清单
enum ProblematicArtifact: String, CaseIterable {
    case receipt = "收据"
    case thermal = "热敏小票"
    case vinylRecord = "黑胶唱片"
    case bookmark = "书签"
    case polaroid = "宝丽来"
    
    var description: String {
        switch self {
        case .receipt:
            return "动态高度，内容越多越长"
        case .thermal:
            return "动态高度，比收据更窄更长"
        case .vinylRecord:
            return "横向布局350x300，唱片会旋转出界"
        case .bookmark:
            return "窄型200x450，底部有尖角"
        case .polaroid:
            return "显影动画4秒，必须等待完成"
        }
    }
}

// MARK: - 📋 收据专用渲染器
struct ReceiptSpecialRenderer {
    
    /// 计算收据的实际高度
    static func calculateReceiptHeight(record: DayRecord) -> CGFloat {
        var height: CGFloat = 0
        
        // 基础高度（店铺信息、分隔线等）
        height += 150
        
        // 照片高度
        let photoCount = record.photos.count
        if photoCount == 1 {
            height += 150  // 单张照片
        } else if photoCount == 2 {
            height += 100   // 两张水平排列
        } else if photoCount > 2 {
            height += 100   // 滚动区域固定高度
        }
        
        // 商品列表高度（每行约25px）
        let contentLines = record.content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let itemCount = min(contentLines.isEmpty ? 3 : contentLines.count, 8)
        height += CGFloat(itemCount) * 25
        
        // 总计区域
        height += 80
        
        // 底部信息和条形码
        height += 100
        
        // 最小/最大高度限制
        return min(max(height, 400), 800)
    }
    
    /// 渲染收据为图片
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        let width: CGFloat = 280
        let height = calculateReceiptHeight(record: record)
        
        // 创建固定尺寸的容器
        let containerView = ZStack {
            Color.white
            
            // 使用固定frame包装收据View
            ReceiptArtifactView(record: record)
                .frame(width: width)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, height: height)
        .clipped()
        
        // 渲染
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = .white
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        }
    }
}

// MARK: - 🧾 热敏小票专用渲染器
struct ThermalSpecialRenderer {
    
    /// 计算热敏小票的实际高度
    static func calculateThermalHeight(record: DayRecord) -> CGFloat {
        var height: CGFloat = 0
        
        // 基础高度
        height += 120
        
        // 照片高度
        let photoCount = record.photos.count
        if photoCount == 1 {
            height += 130
        } else if photoCount == 2 {
            height += 90
        } else if photoCount > 2 {
            height += 90
        }
        
        // 商品列表高度
        let contentLines = record.content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let itemCount = min(contentLines.isEmpty ? 4 : contentLines.count, 6)
        height += CGFloat(itemCount) * 30
        
        // 总计区域
        height += 80
        
        // 底部信息
        height += 100
        
        return min(max(height, 450), 900)
    }
    
    /// 渲染热敏小票为图片
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        let width: CGFloat = 240
        let height = calculateThermalHeight(record: record)
        
        let containerView = ZStack {
            Color.white
            
            ThermalArtifactView(record: record)
                .frame(width: width)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, height: height)
        .clipped()
        
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = .white
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        }
    }
}

// MARK: - 🎵 黑胶唱片专用渲染器
struct VinylSpecialRenderer {
    
    /// 渲染黑胶唱片（停止旋转状态）
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        let width: CGFloat = 350
        let height: CGFloat = 300
        
        // 创建静态版本的黑胶唱片View（不带动画）
        let staticVinylView = StaticVinylView(record: record)
        
        let bgColor = UIColor(hex: "1A1A1A") ?? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        let containerView = ZStack {
            Color(bgColor)
            staticVinylView
        }
        .frame(width: width, height: height)
        .clipped()
        
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = bgColor
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        
        return renderer.image { context in
            bgColor.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        }
    }
}

// 静态黑胶唱片View（无动画）
struct StaticVinylView: View {
    let record: DayRecord
    
    var body: some View {
        // 使用工厂方法创建View，但禁用动画
        ArtifactTemplateFactory.makeView(for: record)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
    }
}

// MARK: - 📑 书签专用渲染器
struct BookmarkSpecialRenderer {
    
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        let width: CGFloat = 200
        let height: CGFloat = 450
        
        // 书签有尖角，需要特殊处理透明背景
        let containerView = ZStack {
            // 透明背景
            Color.clear
            
            BookmarkArtifactView(record: record)
        }
        .frame(width: width, height: height)
        
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.layoutIfNeeded()
        
        // 使用非opaque格式以支持透明
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = false  // 支持透明
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        
        return renderer.image { context in
            // 不填充背景色，保持透明
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        }
    }
}

// MARK: - 📸 宝丽来专用渲染器
struct PolaroidSpecialRenderer {
    
    /// 渲染完全显影状态的宝丽来
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        let width: CGFloat = 300
        let height: CGFloat = 400
        
        // 创建完全显影状态的宝丽来View（禁用动画）
        let fullyDevelopedView = PolaroidArtifactView(record: record)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
        
        let containerView = ZStack {
            Color.white
            fullyDevelopedView
        }
        .frame(width: width, height: height)
        .clipped()
        
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.backgroundColor = .white
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        }
    }
}

// MARK: - 🎯 统一调用入口
struct SpecialArtifactRenderer {
    
    /// 检查是否是问题信物
    static func isProblematicArtifact(_ style: RitualStyle) -> Bool {
        switch style {
        case .receipt, .thermal, .vinylRecord, .bookmark, .polaroid:
            return true
        default:
            return false
        }
    }
    
    /// 使用专用渲染器渲染问题信物
    @MainActor
    static func render(record: DayRecord) -> UIImage? {
        switch record.artifactStyle {
        case .receipt:
            return ReceiptSpecialRenderer.render(record: record)
        case .thermal:
            return ThermalSpecialRenderer.render(record: record)
        case .vinylRecord:
            return VinylSpecialRenderer.render(record: record)
        case .bookmark:
            return BookmarkSpecialRenderer.render(record: record)
        case .polaroid:
            return PolaroidSpecialRenderer.render(record: record)
        default:
            return nil
        }
    }
}


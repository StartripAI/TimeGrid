import SwiftUI
import UIKit
import Photos

// MARK: - 📥 信物下载管理器 V3.0
// 整合输出规格配置，支持多种输出质量，针对手机屏幕优化

class ArtifactDownloadManager: ObservableObject {
    static let shared = ArtifactDownloadManager()
    
    @Published var isDownloading = false
    @Published var downloadProgress: String = ""
    @Published var lastError: String?
    
    // MARK: - 默认配置
    /// 默认输出质量：高清 (适合大多数场景)
    var defaultQuality: OutputQuality = .hd
    
    /// 默认输出格式
    var defaultFormat: OutputFormatConfig = .photoLibrary
    
    // MARK: - 主下载方法
    /// 下载信物（使用默认配置）
    @MainActor
    func downloadArtifact(record: DayRecord, completion: @escaping (Bool, String) -> Void) {
        downloadArtifact(record: record, quality: defaultQuality, completion: completion)
    }
    
    /// 下载信物（指定质量）
    @MainActor
    func downloadArtifact(
        record: DayRecord,
        quality: OutputQuality,
        format: OutputFormatConfig = .photoLibrary,
        completion: @escaping (Bool, String) -> Void
    ) {
        isDownloading = true
        downloadProgress = "准备中..."
        lastError = nil
        
        // 1. 检查权限
        checkPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            
            if !granted {
                self.finishWithError("需要相册访问权限", completion: completion)
                return
            }
            
            // 2. 获取输出配置 (V4: 使用新的输出规格)
            let v4Spec = record.artifactStyle.outputSpecV4
            let legacySpec = ArtifactOutputSpec(
                designWidth: v4Spec.designWidth,
                designHeight: v4Spec.designHeight
            )
            // V4: 应用额外分辨率倍数
            let finalScale = quality.scale * v4Spec.extraScale
            let adjustedQuality = OutputQuality.allCases.first { $0.scale == finalScale } ?? quality
            let config = FinalOutputConfig(
                spec: legacySpec,
                quality: adjustedQuality,
                format: format
            )
            
            DispatchQueue.main.async {
                self.downloadProgress = "正在生成 \(quality.rawValue) 图片..."
                self.renderAndSave(record: record, config: config, completion: completion)
            }
        }
    }
    
    // MARK: - 渲染并保存
    @MainActor
    private func renderAndSave(
        record: DayRecord,
        config: FinalOutputConfig,
        completion: @escaping (Bool, String) -> Void
    ) {
        let style = record.artifactStyle
        
        // 检查是否是问题信物
        if SpecialArtifactRenderer.isProblematicArtifact(style) {
            downloadProgress = "处理特殊信物..."
            renderProblematicArtifact(record: record, config: config, completion: completion)
            return
        }
        
        // 检查是否有动画
        let animationDelay = getAnimationDelay(for: style)
        
        if animationDelay > 0 {
            downloadProgress = "等待效果完成..."
            renderAnimatedArtifact(record: record, config: config, delay: animationDelay, completion: completion)
        } else {
            renderStaticArtifact(record: record, config: config, completion: completion)
        }
    }
    
    // MARK: - 静态信物渲染
    @MainActor
    private func renderStaticArtifact(
        record: DayRecord,
        config: FinalOutputConfig,
        completion: @escaping (Bool, String) -> Void
    ) {
        let spec = config.spec
        
        // 创建渲染容器
        let containerView = ZStack {
            // 背景色
            Color(getBackgroundColor(for: record.artifactStyle))
            
            // 信物View
            ArtifactTemplateFactory.makeView(for: record)
                .transaction { $0.animation = nil }
        }
        .frame(width: spec.designWidth, height: spec.designHeight)
        .clipped()
        
        // 渲染
        let image = renderView(containerView, config: config, record: record)
        saveToPhotoLibrary(image: image, config: config, completion: completion)
    }
    
    // MARK: - 动画信物渲染
    @MainActor
    private func renderAnimatedArtifact(
        record: DayRecord,
        config: FinalOutputConfig,
        delay: Double,
        completion: @escaping (Bool, String) -> Void
    ) {
        let spec = config.spec
        
        // 创建View
        let artifactView = ArtifactTemplateFactory.makeView(for: record)
            .frame(width: spec.designWidth, height: spec.designHeight)
        
        // 使用 UIHostingController 承载动画
        let hostingController = UIHostingController(rootView: AnyView(artifactView))
        hostingController.view.backgroundColor = getBackgroundColor(for: record.artifactStyle)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: spec.designWidth, height: spec.designHeight)
        
        // 添加到临时窗口触发动画
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            hostingController.view.alpha = 0.01
            window.addSubview(hostingController.view)
            hostingController.view.layoutIfNeeded()
        }
        
        // 等待动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            // 截图 (V4: 应用额外分辨率)
            let v4Spec = record.artifactStyle.outputSpecV4
            let finalScale = config.renderScale * v4Spec.extraScale
            let image = self.captureHostingController(hostingController, config: config, finalScale: finalScale, record: record)
            
            // 清理
            hostingController.view.removeFromSuperview()
            
            // 保存
            self.saveToPhotoLibrary(image: image, config: config, completion: completion)
        }
    }
    
    // MARK: - 问题信物渲染
    @MainActor
    private func renderProblematicArtifact(
        record: DayRecord,
        config: FinalOutputConfig,
        completion: @escaping (Bool, String) -> Void
    ) {
        var image: UIImage?
        
        switch record.artifactStyle {
        case .receipt, .thermal:
            image = renderReceipt(record: record, config: config)
        case .vinylRecord:
            image = renderVinyl(record: record, config: config)
        case .bookmark:
            image = renderBookmark(record: record, config: config)
        case .polaroid:
            image = renderPolaroid(record: record, config: config)
        default:
            break
        }
        
        saveToPhotoLibrary(image: image, config: config, completion: completion)
    }
    
    // MARK: - 专用渲染方法
    @MainActor
    private func renderReceipt(record: DayRecord, config: FinalOutputConfig) -> UIImage? {
        let width = config.spec.designWidth
        let height = config.spec.designHeight
        
        let containerView = ZStack {
            Color.white
            ReceiptArtifactView(record: record)
                .frame(width: width)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, height: height)
        .clipped()
        
        return renderView(containerView, config: config)
    }
    
    @MainActor
    private func renderVinyl(record: DayRecord, config: FinalOutputConfig) -> UIImage? {
        let containerView = ZStack {
            Color(UIColor(hex: "1A1A1A"))
            StaticVinylView(record: record)
        }
        .frame(width: config.spec.designWidth, height: config.spec.designHeight)
        .clipped()
        
        return renderView(containerView, config: config)
    }
    
    @MainActor
    private func renderBookmark(record: DayRecord, config: FinalOutputConfig) -> UIImage? {
        let containerView = BookmarkArtifactView(record: record)
            .frame(width: config.spec.designWidth, height: config.spec.designHeight)
        
        return renderView(containerView, config: config, opaque: false)
    }
    
    @MainActor
    private func renderPolaroid(record: DayRecord, config: FinalOutputConfig) -> UIImage? {
        let containerView = ZStack {
            Color.white
            PolaroidArtifactView(record: record)
                .transaction { $0.animation = nil }
        }
        .frame(width: config.spec.designWidth, height: config.spec.designHeight)
        .clipped()
        
        return renderView(containerView, config: config)
    }
    
    // MARK: - 核心渲染方法
    @MainActor
    private func renderView<V: View>(_ view: V, config: FinalOutputConfig, record: DayRecord? = nil, opaque: Bool = true) -> UIImage? {
        let spec = config.spec
        let targetSize = CGSize(width: spec.designWidth, height: spec.designHeight)
        
        // V4: 获取额外分辨率倍数
        let extraScale: CGFloat
        if let record = record {
            extraScale = record.artifactStyle.outputSpecV4.extraScale
        } else {
            extraScale = 1.0
        }
        let finalScale = config.renderScale * extraScale
        
        // iOS 16+ 使用 ImageRenderer
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: view)
            renderer.scale = finalScale
            renderer.isOpaque = opaque
            return renderer.uiImage
        }
        
        // iOS 15 fallback
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = opaque ? getBackgroundColor(for: .simple) : .clear
        hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
        hostingController.view.layoutIfNeeded()
        
        return captureHostingController(hostingController, config: config, finalScale: finalScale, record: record, opaque: opaque)
    }
    
    @MainActor
    private func captureHostingController(
        _ controller: UIHostingController<AnyView>,
        config: FinalOutputConfig,
        finalScale: CGFloat,
        record: DayRecord? = nil,
        opaque: Bool = true
    ) -> UIImage? {
        let spec = config.spec
        let targetSize = CGSize(width: spec.designWidth, height: spec.designHeight)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = finalScale
        format.opaque = opaque
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        return renderer.image { context in
            if opaque {
                controller.view.backgroundColor?.setFill()
                context.fill(CGRect(origin: .zero, size: targetSize))
            }
            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
    
    // MARK: - 保存到相册
    private func saveToPhotoLibrary(
        image: UIImage?,
        config: FinalOutputConfig,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let image = image else {
            finishWithError("图片生成失败", completion: completion)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.downloadProgress = "正在保存..."
        }
        
        // 转换为指定格式的 Data
        var imageData: Data?
        
        switch config.format.format {
        case .jpeg:
            imageData = image.jpegData(compressionQuality: config.format.quality)
        case .png:
            imageData = image.pngData()
        case .heic:
            // HEIC 格式在 iOS 中需要使用 ImageIO 框架
            // 为了简化，这里使用高质量 JPEG 作为替代
            imageData = image.jpegData(compressionQuality: config.format.quality)
        }
        
        guard let data = imageData, let finalImage = UIImage(data: data) else {
            finishWithError("图片转换失败", completion: completion)
            return
        }
        
        // 保存到相册
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
        } completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                
                if success {
                    let size = config.outputSize
                    self?.downloadProgress = "已保存 \(Int(size.width))×\(Int(size.height))"
                    completion(true, "已保存到相册")
                } else {
                    self?.lastError = error?.localizedDescription
                    completion(false, "保存失败")
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    private func finishWithError(_ message: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.isDownloading = false
            self?.lastError = message
            completion(false, message)
        }
    }
    
    private func getAnimationDelay(for style: RitualStyle) -> Double {
        switch style {
        case .envelope, .waxEnvelope: return 3.0
        case .vault: return 2.0
        case .typewriter: return 2.5
        case .postcard, .developedPhoto, .simple, .aurora, .astrolabe: return 0.5
        case .galaInvite: return 0.5
        case .hourglass: return 3.5
        case .polaroid: return 4.5
        default: return 0
        }
    }
    
    private func getBackgroundColor(for style: RitualStyle) -> UIColor {
        switch style {
        case .envelope, .waxEnvelope: return UIColor(hex: "F5F0E6")
        case .vault: return UIColor(hex: "D7C9AA")
        case .pressedFlower: return UIColor(hex: "F2E8D5")
        case .waxStamp: return UIColor(hex: "F5E6D3")
        case .typewriter: return UIColor(hex: "F9F9F6")
        case .journalPage: return UIColor(hex: "FFFEF7")
        case .postcard: return UIColor(hex: "FFC0CB")
        case .developedPhoto, .simple: return UIColor(hex: "2C2C2C")
        case .polaroid, .receipt, .thermal, .monoTicket: return .white
        case .bookmark: return UIColor(hex: "8B0000")
        case .galaInvite: return UIColor(hex: "1A1A2E")
        case .vinylRecord: return UIColor(hex: "1A1A1A")
        case .safari: return UIColor(hex: "F4A460")
        case .aurora: return UIColor(hex: "0A0E27")
        case .astrolabe: return UIColor(hex: "000428")
        case .omikuji: return UIColor(hex: "DEB887")
        case .hourglass: return UIColor(hex: "F5DEB3")
        default: return .white
        }
    }
    
    // MARK: - 权限检查
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
}

// MARK: - 🔘 下载按钮组件 V3
struct ArtifactDownloadButton: View {
    let record: DayRecord
    @StateObject private var manager = ArtifactDownloadManager.shared
    
    @State private var showQualityPicker = false
    @State private var selectedQuality: OutputQuality = .hd
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 主下载按钮
            Button(action: { showQualityPicker = true }) {
                HStack(spacing: 8) {
                    if manager.isDownloading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 18))
                    }
                    
                    Text(manager.isDownloading ? manager.downloadProgress : "保存到相册")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(manager.isDownloading ? Color.gray : Color.blue)
                )
            }
            .disabled(manager.isDownloading)
            
            // 输出信息
            let spec = record.artifactStyle.outputSpec
            let outputSize = selectedQuality == .standard ? spec.standardSize :
                             selectedQuality == .hd ? spec.hdSize : spec.ultraSize
            
            Text("\(Int(outputSize.width)) × \(Int(outputSize.height)) px")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showQualityPicker) {
            QualityPickerSheet(
                record: record,
                selectedQuality: $selectedQuality,
                onConfirm: downloadWithQuality
            )
            .presentationDetents([.medium])
        }
        .overlay(
            ToastView(isShowing: $showToast, message: toastMessage, isSuccess: toastSuccess)
                .offset(y: -80)
        )
    }
    
    private func downloadWithQuality() {
        showQualityPicker = false
        
        manager.downloadArtifact(record: record, quality: selectedQuality) { success, message in
            toastSuccess = success
            toastMessage = message
            
            withAnimation { showToast = true }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showToast = false }
            }
        }
    }
}

// MARK: - 质量选择器
struct QualityPickerSheet: View {
    let record: DayRecord
    @Binding var selectedQuality: OutputQuality
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("选择输出质量")
                    .font(.headline)
                    .padding(.top)
                
                // 质量选项
                ForEach(OutputQuality.allCases) { quality in
                    QualityOptionRow(
                        quality: quality,
                        spec: record.artifactStyle.outputSpec,
                        isSelected: selectedQuality == quality
                    )
                    .onTapGesture {
                        selectedQuality = quality
                    }
                }
                
                Spacer()
                
                // 确认按钮
                Button(action: onConfirm) {
                    Text("保存 \(selectedQuality.rawValue) 图片")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QualityOptionRow: View {
    let quality: OutputQuality
    let spec: ArtifactOutputSpec
    let isSelected: Bool
    
    private var outputSize: CGSize {
        switch quality {
        case .standard: return spec.standardSize
        case .hd: return spec.hdSize
        case .ultra: return spec.ultraSize
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quality.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if quality == .hd {
                        Text("推荐")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                Text("\(Int(outputSize.width)) × \(Int(outputSize.height)) px")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text(quality.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("~\(quality.estimatedFileSize(for: CGSize(width: spec.designWidth, height: spec.designHeight))) KB")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.system(size: 22))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Toast 组件
struct ToastView: View {
    @Binding var isShowing: Bool
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        if isShowing {
            HStack(spacing: 8) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isSuccess ? .green : .red)
                Text(message)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}


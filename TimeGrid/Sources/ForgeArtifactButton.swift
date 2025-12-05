//
//  ForgeArtifactButton.swift
//  铸造信物按钮 V5.0
//
//  使用十大工坊主题设计
//  简化界面：删除分享、删除保存选项
//

import SwiftUI
import Photos

// MARK: - 工坊主题枚举
enum AtelierTheme: String, CaseIterable {
    case inkWash = "水墨丹青"
    case equestrian = "雅仕鞍具"
    case horology = "精密时计"
    case jewelry = "稀世珠宝"
    case motorsport = "赛道极速"
    case cosmos = "深空星际"
    case couture = "高定工坊"
    case nautical = "奢华航海"
    case archive = "皇家档案"
    case cinema = "影像大师"
    
    // 主题色
    var primaryColor: Color {
        switch self {
        case .inkWash: return Color(hex: "1A1A1A") // 墨黑
        case .equestrian: return Color(hex: "8B4513") // 焦糖棕
        case .horology: return Color(hex: "1E3A5F") // 深蓝
        case .jewelry: return Color(hex: "1B365D") // 宝石蓝
        case .motorsport: return Color(hex: "C41E3A") // 法拉利红
        case .cosmos: return Color(hex: "2E1A47") // 星云紫
        case .couture: return Color(hex: "C9A962") // 香槟金
        case .nautical: return Color(hex: "1C2841") // 海军蓝
        case .archive: return Color(hex: "8B0000") // 火漆红
        case .cinema: return Color(hex: "0D0D0D") // 胶片黑
        }
    }
    
    // 辅助色
    var secondaryColor: Color {
        switch self {
        case .inkWash: return Color(hex: "C41E3A") // 朱砂红
        case .equestrian: return Color(hex: "D4AF37") // 烫金
        case .horology: return Color(hex: "B76E79") // 玫瑰金
        case .jewelry: return Color(hex: "E5E4E2") // 铂金
        case .motorsport: return Color(hex: "C0C0C0") // 银
        case .cosmos: return Color(hex: "FFD700") // 星光
        case .couture: return Color(hex: "FFFFF0") // 象牙白
        case .nautical: return Color(hex: "B8860B") // 黄铜
        case .archive: return Color(hex: "F5E6D3") // 羊皮纸
        case .cinema: return Color(hex: "FFBF00") // 琥珀
        }
    }
    
    // 图标
    var icon: String {
        switch self {
        case .inkWash: return "paintbrush.pointed.fill"
        case .equestrian: return "figure.equestrian.sports"
        case .horology: return "clock.fill"
        case .jewelry: return "diamond.fill"
        case .motorsport: return "car.fill"
        case .cosmos: return "sparkles"
        case .couture: return "scissors"
        case .nautical: return "sailboat.fill"
        case .archive: return "envelope.fill"
        case .cinema: return "film.fill"
        }
    }
    
    // 渐变色
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, primaryColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // 根据信物类型选择主题
    static func theme(for style: RitualStyle) -> AtelierTheme {
        switch style {
        case .envelope, .waxEnvelope, .waxStamp, .vault:
            return .archive
        case .developedPhoto, .polaroid:
            return .cinema
        case .vinylRecord:
            return .cosmos
        case .receipt, .thermal:
            return .couture
        case .bookmark, .journalPage:
            return .inkWash
        case .safari, .aurora, .astrolabe:
            return .nautical
        default:
            return .horology
        }
    }
}

// MARK: - 🔨 铸造信物按钮 (主题版)
struct ForgeArtifactButton: View {
    let record: DayRecord
    var theme: AtelierTheme? = nil
    var onComplete: ((Bool, String) -> Void)?
    
    @State private var isForging = false
    @State private var forgeProgress: String = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = false
    
    // 锻造动画
    @State private var glowIntensity: CGFloat = 0
    @State private var hammerRotation: Double = 0
    
    private var selectedTheme: AtelierTheme {
        theme ?? AtelierTheme.theme(for: record.artifactStyle)
    }
    
    var body: some View {
        Button(action: startForging) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTheme.gradient)
                    .shadow(color: selectedTheme.primaryColor.opacity(0.4), radius: 8, y: 4)
                
                // 发光效果（锻造中）
                if isForging {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedTheme.secondaryColor, lineWidth: 2)
                        .blur(radius: glowIntensity)
                }
                
                // 内容
                HStack(spacing: 12) {
                    // 图标
                    ZStack {
                        Circle()
                            .fill(selectedTheme.secondaryColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        if isForging {
                            // 锻造动画
                            Image(systemName: "hammer.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(selectedTheme.secondaryColor)
                                .rotationEffect(.degrees(hammerRotation))
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(selectedTheme.secondaryColor)
                        }
                    }
                    
                    // 文字
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isForging ? "铸造中..." : "铸造信物")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(isForging ? forgeProgress : "保存到相册 & 时光胶囊")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // 进度指示器
                    if isForging {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: selectedTheme.secondaryColor))
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(height: 64)
        .disabled(isForging)
        .onAppear {
            // 启动发光动画
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowIntensity = 4
            }
        }
        .overlay(
            ToastOverlay(isShowing: $showToast, message: toastMessage, isSuccess: toastSuccess, theme: selectedTheme)
                .offset(y: -80)
        )
    }
    
    private func startForging() {
        isForging = true
        forgeProgress = "准备工坊..."
        
        // 锤子动画
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            hammerRotation = 15
        }
        
        // 检查权限
        checkPhotoLibraryPermission { granted in
            if !granted {
                finishForging(success: false, message: "需要相册访问权限")
                return
            }
            
            DispatchQueue.main.async {
                forgeProgress = "熔炼记忆..."
            }
            
            // 开始渲染
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                forgeProgress = "锻造信物..."
                renderAndSave()
            }
        }
    }
    
    private func renderAndSave() {
        // 获取输出规格
        let spec = record.artifactStyle.specV5
        
        // 创建渲染View
        let artifactView = createArtifactView()
        
        // 渲染
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            forgeProgress = "精雕细琢..."
            
            if let image = renderArtifact(view: artifactView, spec: spec) {
                forgeProgress = "封存时光..."
                saveToPhotoLibrary(image: image)
            } else {
                finishForging(success: false, message: "铸造失败")
            }
        }
    }
    
    @ViewBuilder
    private func createArtifactView() -> some View {
        switch record.artifactStyle {
        case .thermal:
            ThermalReceiptV9(record: record)
        case .receipt:
            ReceiptV9(record: record)
        case .vinylRecord:
            VinylRecordV5(record: record)
        case .bookmark:
            BookmarkV5(record: record)
        case .pressedFlower:
            PressedFlowerV5(record: record)
        case .safari:
            SafariJournalV5(record: record)
        default:
            ArtifactTemplateFactory.makeView(for: record)
        }
    }
    
    private func renderArtifact<V: View>(view: V, spec: ArtifactOutputSpecV5) -> UIImage? {
        let targetSize = CGSize(width: spec.width, height: spec.height)
        let scale: CGFloat = 3.0 * spec.extraScale
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: 
                view
                    .frame(width: spec.width, height: spec.height)
                    .clipped()
            )
            renderer.scale = scale
            renderer.isOpaque = true
            return renderer.uiImage
        }
        
        // iOS 15 fallback
        let hostingController = UIHostingController(rootView: AnyView(
            view
                .frame(width: spec.width, height: spec.height)
                .clipped()
        ))
        hostingController.view.backgroundColor = .white
        hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
        hostingController.view.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { context in
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
    
    private func saveToPhotoLibrary(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.92),
              let finalImage = UIImage(data: imageData) else {
            finishForging(success: false, message: "图片转换失败")
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    // 同时保存到时光胶囊（这里调用你的保存逻辑）
                    // TimeCapsuleManager.shared.save(record)
                    
                    finishForging(success: true, message: "铸造完成！已保存到相册")
                } else {
                    finishForging(success: false, message: "保存失败")
                }
            }
        }
    }
    
    private func finishForging(success: Bool, message: String) {
        // 停止锤子动画
        withAnimation(.none) {
            hammerRotation = 0
        }
        
        isForging = false
        toastSuccess = success
        toastMessage = message
        
        withAnimation { showToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showToast = false }
        }
        
        onComplete?(success, message)
    }
    
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

// MARK: - Toast覆盖层
struct ToastOverlay: View {
    @Binding var isShowing: Bool
    let message: String
    let isSuccess: Bool
    let theme: AtelierTheme
    
    var body: some View {
        if isShowing {
            HStack(spacing: 10) {
                Image(systemName: isSuccess ? "checkmark.seal.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isSuccess ? .green : .red)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: theme.primaryColor.opacity(0.2), radius: 10, y: 4)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}


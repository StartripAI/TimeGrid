//
//  MintFlowView.swift
//  TimeGrid
//
//  Created by Alfred on 2025/12/1.
//

import SwiftUI
import PhotosUI
import UIKit
import Photos

// MARK: - 状态机 / ViewModel

final class MintFlowViewModel: ObservableObject {
    @Published var selectedStyleIndex: Int = 0
    @Published var content: String = ""
    @Published var selectedMood: Mood = .neutral
    @Published var selectedWeather: Weather?
    @Published var selectedDate: Date = Date()
    @Published var selectedImageData: Data?
    
    @Published var mintedRecord: DayRecord?
    @Published var mintedImage: UIImage?
    @Published var isRendering: Bool = false
    
    /// 当前可用的风格集合（过滤掉未开放的风格）
    let availableStyles: [RitualStyle] = RitualStyle.allCases.filter { $0 != .monoTicket && $0 != .galaInvite }
    
    func clampedStyleIndex(_ index: Int) -> Int {
        guard !availableStyles.isEmpty else { return 0 }
        return min(max(index, 0), availableStyles.count - 1)
    }
    
    func currentStyle(for index: Int) -> RitualStyle {
        availableStyles[clampedStyleIndex(index)]
    }
    
    /// 生成记录（包含随机修饰）
    func generateRecord(
        date: Date,
        content: String,
        mood: Mood,
        photoData: Data?,
        weather: Weather?,
        styleIndex: Int
    ) -> DayRecord {
        let style = currentStyle(for: styleIndex)
        var details = AestheticDetails.generate(for: style)
        details = addRandomDecorations(to: details)
        
        return DayRecord(
            date: date,
            content: content,
            mood: mood,
            photos: photoData.map { [$0] } ?? [],
            weather: weather,
            artifactStyle: style,
            aestheticDetails: details
        )
    }
    
    /// 占位图（避免预览黑屏）
    func placeholderImage() -> UIImage {
        let size = CGSize(width: 800, height: 1200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        (UIColor(hex: "F5F0E8") ?? UIColor.systemBackground).setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let placeholder = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return placeholder ?? UIImage()
    }
    
    /// 将信物渲染为图片（同步执行，建议在后台队列或 Task 中调用）
    @MainActor
    func renderImage(for record: DayRecord, width: CGFloat = 700, scale: CGFloat = 2.0) -> UIImage {
        let artifactView = StyledArtifactView(record: record)
        let controller = UIHostingController(rootView: AnyView(artifactView).ignoresSafeArea())
        let uiView = controller.view
        
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 2000)))
        window.rootViewController = controller
        window.isHidden = true
        
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        uiView?.bounds = CGRect(origin: .zero, size: targetSize)
        uiView?.backgroundColor = .clear
        
        let size = uiView?.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ) ?? CGSize(width: width, height: 1000)
        
        uiView?.bounds = CGRect(origin: .zero, size: size)
        window.frame = CGRect(origin: .zero, size: size)
        uiView?.layoutIfNeeded()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            uiView?.drawHierarchy(in: uiView!.bounds, afterScreenUpdates: true)
        }
    }
    
    // MARK: - Private helpers
    
    private func addRandomDecorations(to details: AestheticDetails) -> AestheticDetails {
        var newDetails = details
        
        if Bool.random() {
            newDetails.qrCodeContent = "YIGE-\(UUID().uuidString.prefix(8))"
        }
        
        let stickers = ["✨", "💫", "🌟", "🎨", "📸", "❤️", "🌸", "🍃", "📷", "🎬", "✉️", "📮"]
        if Bool.random() {
            newDetails.customStickers = [stickers.randomElement()!]
        }
        
        if Bool.random() {
            newDetails.sealRotationDegrees = Double.random(in: -15...15)
        }
        
        return newDetails
    }
}

@inline(__always)
fileprivate func mintLog(_ message: String) {
    #if DEBUG
    print("🔍 DEBUG: \(message)")
    #endif
}

// MARK: - Mint Flow (V7.5: The Hermès Studio)
// 全屏画布，正面编辑，Instagram 风格

struct MintFlowView: View {
    @StateObject private var viewModel = MintFlowViewModel()
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int // 用于跳转到 "Timeline" Tab
    @ObservedObject var themeEngine = ThemeEngine.shared
    
    // 信物选择状态
    private var availableStyles: [RitualStyle] { viewModel.availableStyles }
    private var selectedStyle: RitualStyle { viewModel.currentStyle(for: viewModel.selectedStyleIndex) }
    
    // 照片状态
    @State private var selectedImage: UIImage?
    @State private var showingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    // 文字编辑状态
    @State private var showingTextEditor = false
    
    // 预览记录
    @State private var previewRecord: DayRecord = DayRecord(date: Date(), content: "", mood: .neutral, artifactStyle: .envelope)
    
    // 铸造后的预览状态
    @State private var showingMintedPreview = false
    
    var body: some View {
        mainContentView
            .fullScreenCover(isPresented: $showingMintedPreview) {
                // 🔥 使用最简单的实现，确保背景始终可见
            let _ = { mintLog("fullScreenCover 闭包执行 - showingMintedPreview: true, record: \(viewModel.mintedRecord != nil), image: \(viewModel.mintedImage != nil)") }()
                
        ZStack {
                    // 背景色（使用系统颜色确保一定能显示）
                    Color(UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1.0))
                        .ignoresSafeArea(.all)
                    
                    // 内容
                    if let record = viewModel.mintedRecord, let image = viewModel.mintedImage {
                        let _ = { mintLog("fullScreenCover - 显示预览内容，record ID: \(record.id.uuidString)") }()
                        MintedArtifactPreviewView(
                            record: record,
                            renderedImage: image,
                            onDismiss: {
                                showingMintedPreview = false
                                viewModel.mintedRecord = nil
                                viewModel.mintedImage = nil
                            },
                            onSave: {
                                dataManager.addOrUpdateRecord(record)
                                SensoryManager.shared.playRitualFeedback(for: record.artifactStyle, phase: .mintingComplete)
                                showingMintedPreview = false
                                viewModel.mintedRecord = nil
                                viewModel.mintedImage = nil
                                selectedTab = 0
                                dismiss()
                            },
                            onRedo: {
                                showingMintedPreview = false
                                viewModel.mintedRecord = nil
                                viewModel.mintedImage = nil
                            }
                    )
                } else {
                        let _ = { mintLog("fullScreenCover - 显示加载状态，record: \(viewModel.mintedRecord != nil), image: \(viewModel.mintedImage != nil)") }()
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.orange)
                            Text("正在准备预览...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onAppear {
                    mintLog("fullScreenCover onAppear - record: \(viewModel.mintedRecord != nil), image: \(viewModel.mintedImage != nil)")
                }
            }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerSheet(
                onPhotoSelected: { image, data in
                    selectedImage = image
                    viewModel.selectedImageData = data
                    updatePreview()
                },
                onCamera: {
                    imagePickerSourceType = .camera
                    showingImagePicker = true
                }
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imagePickerSourceType) { image in
                selectedImage = image
                viewModel.selectedImageData = image.jpegData(compressionQuality: 0.8)
                updatePreview()
            }
        }
        .onAppear {
            updatePreview()
        }
        .onChange(of: viewModel.selectedStyleIndex) { _, _ in
            updatePreview()
        }
        .onChange(of: viewModel.content) { _, _ in
            updatePreview()
        }
        .onChange(of: viewModel.selectedImageData) { _, _ in
            updatePreview()
        }
        .onChange(of: viewModel.selectedMood) { _, _ in
            updatePreview()
        }
        .onChange(of: viewModel.selectedWeather) { _, _ in
            updatePreview()
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            // 1. 背景：浅色米黄色背景（拒绝黑色）
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            mainContentStack
            
            // 4. 文字编辑弹窗（白色背景，黑色字体）
            if showingTextEditor {
                MintTextEditorSheet(
                    content: $viewModel.content,
                    isPresented: $showingTextEditor
                )
            }
            
            // 🔥 渲染加载状态（避免黑屏）
            if viewModel.isRendering {
                ZStack {
                    Color(hex: "F5F0E8")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(hex: "D4AF37"))
                        
                        Text("正在铸造信物...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "8B7355"))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContentStack: some View {
        VStack(spacing: 0) {
            topToolbar
            artifactStylePicker
            artifactPreviewArea
            mintButton
        }
    }
    
    @ViewBuilder
    private var topToolbar: some View {
                                        HStack {
            Button(action: { dismiss() }) {
                Text("退出")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "8B7355"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            
                                            Spacer()
            
            // 1. 文字添加按钮（顶部，点击效率高）
            Button(action: {
                showingTextEditor = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "textformat")
                        .font(.system(size: 14, weight: .medium))
                    Text("添加文字")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "D4AF37"))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var artifactStylePicker: some View {
        ArtifactStylePickerBar(
            selectedStyleIndex: $viewModel.selectedStyleIndex,
            availableStyles: viewModel.availableStyles,
            selectedMood: $viewModel.selectedMood,
            selectedWeather: $viewModel.selectedWeather,
            selectedDate: $viewModel.selectedDate
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var artifactPreviewArea: some View {
        GeometryReader { geo in
            artifactPreviewSection(geo: geo)
        }
        .frame(minHeight: UIScreen.main.bounds.height * 0.7, maxHeight: .infinity) // 🔥 确保预览区域至少占屏幕70%
    }
    
    @ViewBuilder
    private var mintButton: some View {
        Button(action: {
            mintLog("mintButton 被点击")
            saveRecord()
        }) {
            Text("铸造时光信物")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "D4AF37"))
                .cornerRadius(16)
                .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 10, y: 5)
        }
        .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                        }
    
    @ViewBuilder
    private func mintedPreviewContent() -> some View {
                
        // 🔥 确保始终有内容显示，避免黑屏 - 多重保护
        ZStack {
            // 🔥 第一层：背景色（必须始终存在）
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            // 🔥 第二层：内容
            if let record = viewModel.mintedRecord {
                // 确保有图片，如果没有则使用占位图
                let image = viewModel.mintedImage ?? createPlaceholderImage()
                
                                
        MintedArtifactPreviewView(
            record: record,
            renderedImage: image,
            onDismiss: {
                showingMintedPreview = false
                viewModel.mintedRecord = nil
                viewModel.mintedImage = nil
            },
            onSave: {
                // 保存到时光Tab
                if let record = viewModel.mintedRecord {
                    dataManager.addOrUpdateRecord(record)
                    SensoryManager.shared.playRitualFeedback(for: record.artifactStyle, phase: .mintingComplete)
                }
                showingMintedPreview = false
                viewModel.mintedRecord = nil
                viewModel.mintedImage = nil
                selectedTab = 0
                dismiss()
            },
            onRedo: {
                // 重做：关闭预览，继续编辑
                showingMintedPreview = false
                viewModel.mintedRecord = nil
                viewModel.mintedImage = nil
            }
        )
    } else {
        // 🔥 如果record也没有，显示加载或错误提示（而不是黑屏）
        VStack(spacing: 20) {
                    if viewModel.isRendering {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(hex: "D4AF37"))
                        Text("正在加载...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "8B7355"))
                    } else {
                        Text("加载失败")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "8B7355"))
                        
                        Button("关闭") {
                            showingMintedPreview = false
                            viewModel.mintedRecord = nil
                            viewModel.mintedImage = nil
                        }
                            .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color(hex: "D4AF37"))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var errorPreviewView: some View {
        ZStack {
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                Text("渲染失败")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "8B7355"))
                
                Button("关闭") {
                    showingMintedPreview = false
                }
                            .foregroundColor(.white)
                .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color(hex: "D4AF37"))
                            .cornerRadius(12)
                    }
        }
    }
    
    private func createPlaceholderImage() -> UIImage {
        let size = CGSize(width: 400, height: 600)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let color = UIColor(hex: "F5F0E8") {
            color.setFill()
        } else {
            UIColor.systemBackground.setFill()
        }
        UIRectFill(CGRect(origin: .zero, size: size))
        let placeholder = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return placeholder ?? UIImage()
    }
    
    // MARK: - Actions
    
    private func updatePreview() {
        previewRecord = viewModel.generateRecord(
            date: viewModel.selectedDate,
            content: viewModel.content,
            mood: viewModel.selectedMood,
            photoData: viewModel.selectedImageData,
            weather: viewModel.selectedWeather,
            styleIndex: viewModel.selectedStyleIndex
        )
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func artifactPreviewSection(geo: GeometryProxy) -> some View {
        // 🔥 预览区域占满整个空间，不包含文本框
        TabView(selection: $viewModel.selectedStyleIndex) {
            ForEach(Array(availableStyles.enumerated()), id: \.element) { index, style in
                MintArtifactPreviewCard(
                    style: style,
                    content: viewModel.content,
                    photoData: viewModel.selectedImageData,
                    mood: viewModel.selectedMood,
                    weather: viewModel.selectedWeather,
                    onAddPhoto: {
                        showingPhotoPicker = true
                    },
                    onAddText: {
                        showingTextEditor = true
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: geo.size.height) // 🔥 占满整个可用高度
    }
    
    // MARK: - Actions
    
    func saveRecord() {
        mintLog("========== saveRecord() 函数开始执行 ==========")
        
        let record = viewModel.generateRecord(
            date: viewModel.selectedDate,
            content: viewModel.content,
            mood: viewModel.selectedMood,
            photoData: viewModel.selectedImageData,
            weather: viewModel.selectedWeather,
            styleIndex: viewModel.selectedStyleIndex
        )
        
        let placeholder = viewModel.placeholderImage()
        
        viewModel.mintedRecord = record
        viewModel.mintedImage = placeholder
        viewModel.isRendering = true
        
        guard viewModel.mintedRecord != nil, viewModel.mintedImage != nil else {
            mintLog("❌ 错误：状态不完整，无法显示预览 - record: \(viewModel.mintedRecord != nil), image: \(viewModel.mintedImage != nil)")
            return
        }
        
        showingMintedPreview = true
        mintLog("saveRecord - showingMintedPreview 已设置为 true")
        
        Task {
            let rendered = await MainActor.run { viewModel.renderImage(for: record) }
            viewModel.mintedImage = rendered
            viewModel.isRendering = false
        }
    }
}

// MARK: - DayRecord Mock Extension (用于预览)
extension DayRecord {
    static func mock(image: UIImage, style: RitualStyle) -> DayRecord {
        // 创建一个假的记录用于预览渲染
        // 关键：生成对应风格的美学细节，确保预览正确
        let details = AestheticDetails.generate(for: style)
        
        return DayRecord(
            id: UUID(),
            date: Date(),
            content: "预览内容...",
            mood: .joyful,
            photos: [image.jpegData(compressionQuality: 0.5) ?? Data()],
            weather: .sunny,
            isSealed: false,
            hasBeenOpened: true,
            artifactStyle: style,
            aestheticDetails: details
        )
    }
}

// MARK: - Canvas Editor View (画布核心)
struct CanvasEditorView: View {
    let image: UIImage
    let style: RitualStyle
    @Binding var overlays: [CanvasElement]
    @Binding var weather: Weather?
    @Binding var mood: Mood
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 🔥 修复：确保信物模板正确显示
                let tempRecord = DayRecord(
                    date: Date(),
                    content: overlays.compactMap {
                        if case .text(let t) = $0.type { return t }
                        return nil
                    }.joined(separator: "\n"),
                    mood: mood,
                    photos: [image.jpegData(compressionQuality: 0.8) ?? Data()],
                    weather: weather,
                    artifactStyle: style,
                    aestheticDetails: AestheticDetails.generate(for: style)
                )
                
                // 🔥 修复：使用正确的尺寸和比例
                let artifactWidth: CGFloat = 320
                let artifactHeight: CGFloat = 500
                let scale = min(geo.size.width / artifactWidth, geo.size.height / artifactHeight) * 0.85
                
                ArtifactTemplateFactory.makeView(for: tempRecord)
                    .frame(width: artifactWidth, height: artifactHeight)
                    .scaleEffect(scale)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .clipped()
                
                // 2. 用户添加的组件层 (Overlays) - 需要根据缩放调整位置
                ForEach(Array(overlays.enumerated()), id: \.element.id) { index, element in
                    DraggableElementView(element: Binding(
                        get: { overlays[index] },
                        set: { overlays[index] = $0 }
                    ))
                    .scaleEffect(scale)
                }
            }
        }
    }
}

// MARK: - Canvas Element (画布元素)
struct CanvasElement: Identifiable {
    let id = UUID()
    var type: ElementType
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var fontSize: CGFloat = 24 // 🔥 新增：字号
    var fontName: String = "Didot" // 🔥 新增：字体名称
    
    enum ElementType {
        case text(String)
        case weather(Weather)
        case mood(Mood)
        case sticker(String)
    }
}

// 🔥 可拖拽、可缩放、可旋转组件视图
struct DraggableElementView: View {
    @Binding var element: CanvasElement
    @State private var lastScale: CGFloat = 1.0
    @State private var lastRotation: Angle = .zero
    
    var body: some View {
        Group {
            switch element.type {
            case .text(let text):
                Text(text)
                    .font(.custom(element.fontName, size: element.fontSize * element.scale))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            case .weather(let weather):
                VStack(spacing: 4) {
                    Image(systemName: weather.icon)
                        .font(.system(size: 30 * element.scale))
                    Text(weather.label)
                        .font(.system(size: 12 * element.scale, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                .shadow(radius: 2)
            case .mood(let mood):
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.system(size: 40 * element.scale))
                    Text(mood.label)
                        .font(.system(size: 12 * element.scale, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            case .sticker(let sticker):
                Text(sticker)
                    .font(.system(size: 40 * element.scale))
            }
        }
        .position(element.position)
        .scaleEffect(element.scale)
        .rotationEffect(element.rotation)
        .gesture(
            SimultaneousGesture(
                // 拖拽手势
                DragGesture()
                    .onChanged { value in
                        element.position = value.location
                    },
                // 缩放手势
                MagnificationGesture()
                    .onChanged { value in
                        element.scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = element.scale
                    }
            )
        )
        .simultaneousGesture(
            // 旋转手势
            RotationGesture()
                .onChanged { angle in
                    element.rotation = lastRotation + angle
                }
                .onEnded { _ in
                    lastRotation = element.rotation
                }
        )
        .onTapGesture(count: 2) {
            // 双击删除
            // TODO: 实现删除逻辑
        }
    }
}

// MARK: - 辅助组件

struct ToolButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ToolButtonContent(icon: icon, label: label)
        }
    }
}

struct ToolButtonContent: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(Color(hex: "382822")) // Hermès Brown
        .frame(width: 50)
    }
}

struct MintStylePickerItem: View {
    let style: RitualStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "D4AF37") : Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(style.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "D4AF37") : .gray)
            }
        }
    }
}

// MARK: - 🔥 爱马仕工作室背景 (Hermès Studio Background)
struct HermesStudioBackground: View {
    var body: some View {
        ZStack {
            // 基础：温暖的米白色 (Hermès Cream)
            Color(hex: "F5F0E8")
            
            // 纹理层：细腻的皮革质感
            Canvas { context, size in
                // 绘制微妙的纹理线条
                for i in stride(from: 0, through: size.height, by: 4) {
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: i))
                        p.addLine(to: CGPoint(x: size.width, y: i))
                    }
                    context.stroke(path, with: .color(.white.opacity(0.03)), lineWidth: 0.5)
                }
            }
            
            // 装饰：金色缝线暗示
            VStack {
                HStack {
                    Rectangle()
                        .fill(Color(hex: "D4AF37").opacity(0.1))
                        .frame(width: 1, height: 200)
                    Spacer()
                    Rectangle()
                        .fill(Color(hex: "D4AF37").opacity(0.1))
                        .frame(width: 1, height: 200)
                }
                Spacer()
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - 🔥 照片预览窗口 (大尺寸,精致背景)
struct PhotoPreviewView: View {
    let image: UIImage
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // 背景：模糊的Hermès背景
            HermesStudioBackground()
                .ignoresSafeArea()
                .blur(radius: 20)
            
            VStack(spacing: 30) {
                Spacer()
                
                // 照片预览 (大尺寸)
                ZStack {
                    // 阴影层
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.6)
                        .offset(x: 4, y: 4)
                    
                    // 照片容器
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.6)
                        .overlay(
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        )
                        .overlay(
                            // 底部"已显影"标签
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("已显影")
                                        .font(.system(size: 12, weight: .medium, design: .serif))
                                        .foregroundColor(Color(hex: "D4AF37"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(12)
                                        .padding(.trailing, 16)
                                        .padding(.bottom, 16)
                                }
                            }
                        )
                        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                }
                
                // 操作按钮
                HStack(spacing: 30) {
                    Button(action: onCancel) {
                        Text("重选")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "382822"))
                            .frame(width: 120, height: 50)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    }
                    
                    Button(action: onConfirm) {
                        Text("使用这张照片")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(width: 180, height: 50)
                            .background(Color(hex: "D4AF37"))
                            .cornerRadius(25)
                            .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 10, y: 4)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - UIImagePickerController Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - 信物样式选择视图
struct RitualStyleSelectionView: View {
    @Binding var selectedStyle: RitualStyle
    var onStyleSelected: () -> Void
    var onDismiss: () -> Void
    @StateObject private var themeEngine = ThemeEngine.shared
    
    // 过滤掉兼容旧版本的样式
    private var availableStyles: [RitualStyle] {
        RitualStyle.allCases.filter { style in
            style != .monoTicket && style != .galaInvite
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("选择信物样式")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                
                Spacer()
                
                // 占位，保持居中
                Circle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 30)
            
            // 信物样式网格
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 20) {
                    ForEach(availableStyles, id: \.self) { style in
                        MintRitualStyleCard(
                            style: style,
                            isSelected: selectedStyle == style,
                            theme: themeEngine.currentTheme
                        ) {
                            selectedStyle = style
                            onStyleSelected()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 信物样式卡片（Mint Flow专用）
struct MintRitualStyleCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let theme: LuxuryTheme
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            SensoryManager.shared.playUIFeedback(.buttonTap)
            action()
        }) {
            VStack(spacing: 12) {
                // 图标/Emoji
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected ?
                            theme.accentColor.opacity(0.2) :
                            Color.white.opacity(0.1)
                        )
                        .frame(width: 70, height: 70)
                    
                    Text(style.emoji)
                        .font(.system(size: 36))
                }
                
                // 名称
                Text(style.label)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // 选中指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.accentColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                        theme.accentColor.opacity(0.15) :
                        Color.white.opacity(0.05)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? theme.accentColor : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? theme.accentColor.opacity(0.3) : .black.opacity(0.2),
                radius: isSelected ? 10 : 5
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 照片选择视图
struct PhotoSelectionView: View {
    let selectedStyle: RitualStyle
    @Binding var showingImagePicker: Bool
    @Binding var imagePickerSourceType: UIImagePickerController.SourceType
    var onPhotoSelected: (UIImage) -> Void
    var onBack: () -> Void
    var onDismiss: () -> Void
    
    @State private var showingPhotoPicker = false
    @StateObject private var themeEngine = ThemeEngine.shared
    
    var body: some View {
        VStack(spacing: 30) {
            // 顶部栏
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("选择照片")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(selectedStyle.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeEngine.currentTheme.accentColor)
                }
                .shadow(color: .black.opacity(0.5), radius: 3)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
            
            // 信物预览卡片
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 280)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(themeEngine.currentTheme.accentColor.opacity(0.3), lineWidth: 2)
                        )
                    
                    VStack(spacing: 15) {
                        Text(selectedStyle.emoji)
                            .font(.system(size: 60))
                        
                        Text(selectedStyle.label)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                
                Text("为你的\(selectedStyle.label)\n选择一张照片")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 3)
            }
            
            // 照片选择按钮
            Button(action: {
                SensoryManager.shared.playUIFeedback(.buttonTap)
                showingPhotoPicker = true
            }) {
                HStack(spacing: 15) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                    
                    Text("选择照片")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [
                            themeEngine.currentTheme.accentColor,
                            themeEngine.currentTheme.accentColor.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: themeEngine.currentTheme.accentColor.opacity(0.4), radius: 15, y: 5)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .confirmationDialog("选择照片", isPresented: $showingPhotoPicker, titleVisibility: .visible) {
            Button("拍照") {
                imagePickerSourceType = .camera
                showingImagePicker = true
            }
            Button("从相册选择") {
                imagePickerSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("取消", role: .cancel) { }
        }
    }
}

// MARK: - 🔥 信物预览卡片（大尺寸，占50%以上）
struct MintArtifactPreviewCard: View {
    let style: RitualStyle
    let content: String
    let photoData: Data?
    let mood: Mood
    let weather: Weather?
    let onAddPhoto: () -> Void
    let onAddText: () -> Void
    
    @State private var previewRecord: DayRecord
    
    init(style: RitualStyle, content: String, photoData: Data?, mood: Mood, weather: Weather?, onAddPhoto: @escaping () -> Void, onAddText: @escaping () -> Void) {
        self.style = style
        self.content = content
        self.photoData = photoData
        self.mood = mood
        self.weather = weather
        self.onAddPhoto = onAddPhoto
        self.onAddText = onAddText
        
        var details = AestheticDetails.generate(for: style)
        // 添加随机装饰元素
        details = Self.addRandomDecorations(to: details)
        
        self._previewRecord = State(initialValue: DayRecord(
            date: Date(),
            content: content,
            mood: mood,
            photos: photoData != nil ? [photoData!] : [],
            weather: weather,
            artifactStyle: style,
            aestheticDetails: details
        ))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 🔥 信物预览（超大尺寸，至少大2倍）
                // 使用屏幕尺寸作为基准，确保信物足够大
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                let baseSize = min(screenWidth, screenHeight) * 0.9 // 使用屏幕尺寸的90%作为基准
                // 🔥 至少大2倍：使用更大的倍数，确保清晰可见
                let artifactSize = baseSize * 2.5 // 增大到2.5倍，确保清晰可见
                let artifactHeight = artifactSize * 1.4
                
                StyledArtifactView(record: previewRecord)
                    .frame(width: artifactSize, height: artifactHeight)
                    .shadow(color: .black.opacity(0.3), radius: 25, y: 15)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                
                // 添加照片按钮（移到右下角，始终在最上层，避免被照片覆盖）
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                Button(action: onAddPhoto) {
                    ZStack {
                                // 圆形背景（更紧凑）
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 50, height: 50)
                        
                                // 加号图标
                                Image(systemName: photoData == nil ? "plus.circle.fill" : "photo.badge.plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
                .zIndex(1000) // 确保按钮始终在最上层
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: content) { oldValue, newValue in
            updatePreview()
        }
        .onChange(of: photoData) { oldValue, newValue in
            updatePreview()
        }
        .onChange(of: mood) { oldValue, newValue in
            updatePreview()
        }
        .onChange(of: weather) { oldValue, newValue in
            updatePreview()
        }
    }
    
    private func updatePreview() {
        var details = AestheticDetails.generate(for: style)
        details = Self.addRandomDecorations(to: details)
        
        previewRecord = DayRecord(
            date: Date(),
            content: content,
            mood: mood,
            photos: photoData != nil ? [photoData!] : [],
            weather: weather,
            artifactStyle: style,
            aestheticDetails: details
        )
    }
    
    static func addRandomDecorations(to details: AestheticDetails) -> AestheticDetails {
        var newDetails = details
        
        // 随机添加二维码（70%概率）
        if Double.random(in: 0...1) < 0.7 {
            newDetails.qrCodeContent = "YIGE-\(UUID().uuidString.prefix(8))"
        }
        
        // 随机添加多个贴纸/表情包（美观优先）
        let aestheticStickers = [
            "✨", "💫", "🌟", "⭐️", "🎨", "📸", "❤️", "💕", "🌸", "🌺", "🍃", "🌿",
            "📷", "🎬", "✉️", "📮", "🎯", "🎪", "🎭", "🎪", "🏆", "🎖️", "🎗️", "🎟️",
            "💎", "🔮", "🎁", "🎀", "🎊", "🎉", "🎈", "🎁", "💌", "📝", "✍️", "🖋️"
        ]
        let stickerCount = Int.random(in: 1...3)
        var selectedStickers: [String] = []
        for _ in 0..<stickerCount {
            if let sticker = aestheticStickers.randomElement() {
                selectedStickers.append(sticker)
            }
        }
        if !selectedStickers.isEmpty {
            newDetails.customStickers = selectedStickers
        }
        
        // 随机添加印章旋转（增加视觉趣味）
        if Double.random(in: 0...1) < 0.6 {
            newDetails.sealRotationDegrees = Double.random(in: -20...20)
        }
        
        // 随机添加文字戳（如果AestheticDetails支持）
        // 注意：这里假设AestheticDetails可能有其他字段来存储文字戳
        // 如果实际结构不同，需要相应调整
        
        return newDetails
    }
}

// MARK: - 🔥 简洁的心情和天气选择器（美观简洁版）
struct CompactMoodWeatherPicker: View {
    @Binding var selectedMood: Mood
    @Binding var selectedWeather: Weather?
    let theme: LuxuryTheme
    
    var body: some View {
        HStack(spacing: 12) {
            // 心情选择按钮
            Menu {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        HStack {
                            Text(mood.emoji)
                                .font(.system(size: 18))
                            Text(mood.label)
                                .font(.system(size: 15))
                            if selectedMood == mood {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.accentColor)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedMood.emoji)
                        .font(.system(size: 18))
                    Text(selectedMood.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // 天气选择按钮
            Menu {
                ForEach(Weather.allCases, id: \.self) { weather in
                    Button(action: {
                        selectedWeather = weather
                    }) {
                        HStack {
                            Image(systemName: weather.icon)
                                .font(.system(size: 16))
                            Text(weather.label)
                                .font(.system(size: 15))
                            if selectedWeather == weather {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.accentColor)
                            }
                        }
                    }
                }
                Button(role: .destructive, action: {
                    selectedWeather = nil
                }) {
                    Label("清除", systemImage: "xmark.circle")
                }
            } label: {
                HStack(spacing: 6) {
                    if let weather = selectedWeather {
                        Image(systemName: weather.icon)
                            .font(.system(size: 16))
                            .foregroundColor(theme.accentColor)
                        Text(weather.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "cloud.sun")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Text("天气")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedWeather != nil ? theme.accentColor.opacity(0.1) : Color.white.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedWeather != nil ? theme.accentColor.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - 🔥 底部状态栏（天气和心情选择）
struct BottomStatusBar: View {
    @Binding var selectedWeather: Weather?
    @Binding var selectedMood: Mood
    let theme: LuxuryTheme
    
    var body: some View {
        HStack(spacing: 20) {
            // 天气选择按钮
            Menu {
                ForEach(Weather.allCases, id: \.self) { weather in
                    Button(action: {
                        selectedWeather = weather
                    }) {
                        HStack {
                            Image(systemName: weather.icon)
                            Text(weather.label)
                            if selectedWeather == weather {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Button(role: .destructive, action: {
                    selectedWeather = nil
                }) {
                    Label("清除", systemImage: "xmark.circle")
                }
            } label: {
                HStack(spacing: 8) {
                    if let weather = selectedWeather {
                        Image(systemName: weather.icon)
                            .font(.system(size: 18))
                        Text(weather.label)
                            .font(.system(size: 14, weight: .medium))
                    } else {
                        Image(systemName: "cloud.sun")
                            .font(.system(size: 18))
                        Text("天气")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .foregroundColor(selectedWeather != nil ? theme.accentColor : theme.textColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedWeather != nil ? theme.accentColor.opacity(0.2) : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedWeather != nil ? theme.accentColor : Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                )
            }
            
            // 心情选择按钮
            Menu {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        HStack {
                            Text(mood.emoji)
                                .font(.system(size: 20))
                            Text(mood.label)
                            if selectedMood == mood {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedMood.emoji)
                        .font(.system(size: 20))
                    Text(selectedMood.label)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(theme.accentColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.accentColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.accentColor, lineWidth: 1.5)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 🔥 文字编辑弹窗（白色背景，黑色字体）
struct MintTextEditorSheet: View {
    @Binding var content: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // 白色弹窗
            VStack(spacing: 0) {
                // 顶部栏：完成按钮
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("完成")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.white)
                
                // 文字输入区域（确保黑色文字，白色背景）
                ZStack(alignment: .topLeading) {
                    Color.white
                    TextEditor(text: $content)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                        }
                }
            }
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
            .padding(.top, UIScreen.main.bounds.height * 0.5)
        }
    }
}

// MARK: - 信物样式选择栏（显示所有20个信物 + 元数据选择器）
struct ArtifactStylePickerBar: View {
    @Binding var selectedStyleIndex: Int
    let availableStyles: [RitualStyle]
    @Binding var selectedMood: Mood
    @Binding var selectedWeather: Weather?
    @Binding var selectedDate: Date
    @ObservedObject var themeEngine = ThemeEngine.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 信物样式选择
                ForEach(Array(availableStyles.enumerated()), id: \.element) { index, style in
                    Button(action: {
                        selectedStyleIndex = index
                    }) {
                        VStack(spacing: 4) {
                            Text(style.emoji)
                                .font(.system(size: 24))
                            Text(style.label)
                                .font(.system(size: 10, weight: .medium))
                                .lineLimit(1)
                        }
                        .foregroundColor(selectedStyleIndex == index ? .white : Color(hex: "8B7355"))
                        .frame(width: 60, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStyleIndex == index ? Color(hex: "D4AF37") : Color.white.opacity(0.8))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedStyleIndex == index ? Color(hex: "D4AF37") : Color(hex: "E0D5C0"), lineWidth: selectedStyleIndex == index ? 2 : 1)
                        )
                    }
                }
                
                // 分隔线
                Rectangle()
                    .fill(Color(hex: "E0D5C0"))
                    .frame(width: 1, height: 50)
                    .padding(.horizontal, 4)
                
                // 日期选择器
                DatePickerButton(selectedDate: $selectedDate)
                
                // 天气选择器
                WeatherPickerButton(selectedWeather: $selectedWeather, theme: themeEngine.currentTheme)
                
                // 心情选择器
                MoodPickerButton(selectedMood: $selectedMood, theme: themeEngine.currentTheme)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - 日期选择按钮
struct DatePickerButton: View {
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        Button(action: {
            showingDatePicker = true
        }) {
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                Text(formattedDate)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(Color(hex: "8B7355"))
            .frame(width: 60, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "E0D5C0"), lineWidth: 1)
            )
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .navigationTitle("选择日期")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showingDatePicker = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 天气选择按钮
struct WeatherPickerButton: View {
    @Binding var selectedWeather: Weather?
    let theme: LuxuryTheme
    
    var body: some View {
        Menu {
            ForEach(Weather.allCases, id: \.self) { weather in
                Button(action: {
                    selectedWeather = weather
                }) {
                    HStack {
                        Image(systemName: weather.icon)
                        Text(weather.label)
                        if selectedWeather == weather {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            Button(role: .destructive, action: {
                selectedWeather = nil
            }) {
                Label("清除", systemImage: "xmark.circle")
            }
        } label: {
            VStack(spacing: 4) {
                if let weather = selectedWeather {
                    Image(systemName: weather.icon)
                        .font(.system(size: 20))
                        .foregroundColor(theme.accentColor)
                    Text(weather.label)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                } else {
                    Image(systemName: "cloud.sun")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                    Text("天气")
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(selectedWeather != nil ? theme.accentColor : Color(hex: "8B7355"))
            .frame(width: 60, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedWeather != nil ? theme.accentColor.opacity(0.1) : Color.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedWeather != nil ? theme.accentColor : Color(hex: "E0D5C0"), lineWidth: selectedWeather != nil ? 2 : 1)
            )
        }
    }
}

// MARK: - 心情选择按钮
struct MoodPickerButton: View {
    @Binding var selectedMood: Mood
    let theme: LuxuryTheme
    
    var body: some View {
        Menu {
            ForEach(Mood.allCases, id: \.self) { mood in
                Button(action: {
                    selectedMood = mood
                }) {
                    HStack {
                        Text(mood.emoji)
                            .font(.system(size: 18))
                        Text(mood.label)
                        if selectedMood == mood {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            VStack(spacing: 4) {
                Text(selectedMood.emoji)
                    .font(.system(size: 24))
                Text(selectedMood.label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(theme.accentColor)
            .frame(width: 60, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.accentColor.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.accentColor, lineWidth: 2)
            )
        }
    }
}

// MARK: - 扩展底部状态栏（包含更多元数据）
struct ExtendedBottomStatusBar: View {
    @Binding var selectedWeather: Weather?
    @Binding var selectedMood: Mood
    let theme: LuxuryTheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // 天气选择
                Menu {
                    ForEach(Weather.allCases, id: \.self) { weather in
                        Button(action: {
                            selectedWeather = weather
                        }) {
                            HStack {
                                Image(systemName: weather.icon)
                                Text(weather.label)
                                if selectedWeather == weather {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    Button(role: .destructive, action: {
                        selectedWeather = nil
                    }) {
                        Label("清除", systemImage: "xmark.circle")
                    }
                } label: {
                    HStack(spacing: 8) {
                        if let weather = selectedWeather {
                            Image(systemName: weather.icon)
                                .font(.system(size: 18))
                            Text(weather.label)
                                .font(.system(size: 14, weight: .medium))
                        } else {
                            Image(systemName: "cloud.sun")
                                .font(.system(size: 18))
                            Text("天气")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(selectedWeather != nil ? Color(hex: "D4AF37") : Color(hex: "8B7355"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedWeather != nil ? Color(hex: "D4AF37").opacity(0.15) : Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedWeather != nil ? Color(hex: "D4AF37") : Color(hex: "E0D5C0"), lineWidth: 1.5)
                            )
                    )
                }
                
                // 心情选择
                Menu {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                        }) {
                            HStack {
                                Text(mood.emoji)
                                    .font(.system(size: 20))
                                Text(mood.label)
                                if selectedMood == mood {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(selectedMood.emoji)
                            .font(.system(size: 20))
                        Text(selectedMood.label)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "D4AF37"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "D4AF37").opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "D4AF37"), lineWidth: 1.5)
                            )
                    )
                }
                
                // 日期显示
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                        Text(Date().formatted(.dateTime.month().day()))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "8B7355"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "E0D5C0"), lineWidth: 1.5)
                            )
                    )
                }
                .disabled(true)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - 🔥 照片选择弹窗
struct PhotoPickerSheet: View {
    let onPhotoSelected: (UIImage, Data) -> Void
    let onCamera: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("选择照片")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 20)
                
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                        Text("从相册选择")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Button(action: onCamera) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        Text("拍照")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhotos) { _, items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                onPhotoSelected(image, data)
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 铸造后的信物预览视图（提供下载、分享、重做、保存选项）
struct MintedArtifactPreviewView: View {
    let record: DayRecord
    let renderedImage: UIImage
    let onDismiss: () -> Void
    let onSave: () -> Void
    let onRedo: () -> Void
    
    // V5版本：已删除分享和时光胶囊相关状态
    
    var body: some View {
                
        ZStack {
            // 🔥 确保背景始终可见，避免黑屏（使用系统颜色，不依赖hex扩展）
            Color(UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1.0))
                .ignoresSafeArea(.all)
                .zIndex(0) // 确保背景在最底层
            
            VStack(spacing: 0) {
                // 顶部栏：关闭按钮
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "8B7355"))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // 信物预览
                ScrollView {
                    VStack(spacing: 24) {
                                                StyledArtifactView(record: record)
                            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.95)  // iPad 1.0x, iPhone 0.95x (增大)
                            .frame(maxWidth: min(UIScreen.main.bounds.width - 40, UIDevice.current.userInterfaceIdiom == .pad ? 550 : 450)) // iPad 550, iPhone 450 (增大)
                            .shadow(color: Color.black.opacity(0.15), radius: 25, y: 10)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // 操作按钮组 - V5版本：使用十大工坊主题铸造按钮
                        VStack(spacing: 16) {
                            // 铸造按钮（自动保存到相册和时光胶囊）
                            ForgeArtifactButton(record: record) { success, message in
                                if success {
                                    // 自动保存到时光Tab
                                onSave()
                                }
                            }
                            
                            // 重做按钮
                            Button {
                                onRedo()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                    Text("重做")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(Color(hex: "8B7355"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "E0D5C0"), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        // V5版本：已删除分享和时光胶囊按钮，铸造按钮自动处理所有保存
        .onAppear {
            mintLog("MintedArtifactPreviewView onAppear - record ID: \(record.id.uuidString), image size: \(renderedImage.size)")
        }
    }
    
    // V5版本：已删除所有保存相关函数，使用ForgeArtifactButton处理所有保存逻辑
}

// MARK: - 预览容器视图包装器（使用Binding确保实时更新）
struct MintedPreviewContainerViewWrapper: View {
    @Binding var mintedRecord: DayRecord?
    @Binding var mintedImage: UIImage?
    @Binding var isRendering: Bool
    let onDismiss: () -> Void
    let onSave: (DayRecord) -> Void
    let onRedo: () -> Void
    
    var body: some View {
                
        // 🔥 使用ZStack确保背景始终可见
        ZStack {
            // 🔥 第一层：背景色（必须始终存在，避免黑屏）
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            // 🔥 第二层：内容
            if let record = mintedRecord, let image = mintedImage {
                                MintedArtifactPreviewView(
                    record: record,
                    renderedImage: image,
                    onDismiss: onDismiss,
                    onSave: { onSave(record) },
                    onRedo: onRedo
                )
            } else {
                                // 🔥 即使record为nil，也显示背景和加载状态（背景已在ZStack中）
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(hex: "D4AF37"))
                    Text("正在准备预览...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "8B7355"))
                }
            }
        }
        .onAppear {
                    }
    }
}

// MARK: - 全屏预览视图（铸造后使用）
struct MintedFullScreenPreviewView: View {
    let mintedRecord: DayRecord?
    let mintedImage: UIImage?
    let dataManager: DataManager
    let onDismiss: () -> Void
    let onSave: (DayRecord) -> Void
    let onRedo: () -> Void
    
    @State private var localRecord: DayRecord?
    @State private var localImage: UIImage?
    
    var body: some View {
                
        // 🔥 使用最简单的结构，确保背景始终可见
        ZStack {
            // 🔥 第一层：背景色（使用系统颜色确保一定能显示）
            Color(UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1.0))
                .ignoresSafeArea(.all)
            
            // 🔥 第二层：内容
            if let record = localRecord ?? mintedRecord, let image = localImage ?? mintedImage {
                                MintedArtifactPreviewView(
                    record: record,
                    renderedImage: image,
                    onDismiss: onDismiss,
                    onSave: { onSave(record) },
                    onRedo: onRedo
                )
            } else {
                                // 🔥 即使record为nil，也显示加载状态
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.orange)
                    Text("正在准备预览...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
                        // 🔥 在onAppear时更新本地状态，确保视图正确显示
            localRecord = mintedRecord
            localImage = mintedImage
        }
        .onChange(of: mintedRecord) { _, newValue in
            localRecord = newValue
        }
        .onChange(of: mintedImage) { _, newValue in
            localImage = newValue
        }
    }
}

// MARK: - 分享 Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 时光胶囊选择视图（简化版）
struct TimeCapsuleSelectionView: View {
    let record: DayRecord
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("选择封存时间")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 20)
                
                // 预设时间选项
                VStack(spacing: 12) {
                    TimeCapsuleOption(title: "一周后", days: 7)
                    TimeCapsuleOption(title: "一个月后", days: 30)
                    TimeCapsuleOption(title: "一年后", days: 365)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("时光胶囊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        onConfirm()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimeCapsuleOption: View {
    let title: String
    let days: Int
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(hex: "8B7355"))
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - 辅助扩展
// 注意：cornerRadius 和 RoundedCorner 已在 Helpers.swift 中定义

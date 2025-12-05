//
//  NewRecordView.swift
//  时光格 V4.2 - 新建记录（沉浸式画布）
//
//  V4.2 Improvements:
//  - 顶部布局：信物风格选择器置顶
//  - 输入区：高度缩减，增加随机名言按钮
//  - 预览区：核心位置，所见即所得
//  - 元数据：整合显示
//  - 底部：全屏预览 + 保存
//  - 右上角：照片选择入口

import SwiftUI
import PhotosUI
import Combine
import UIKit

// MARK: - 内联 ViewModel (避免编译顺序问题)
class InlineNewRecordViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedMood: Mood = .neutral
    @Published var selectedWeather: Weather?
    @Published var selectedStyle: RitualStyle = .thermal
    @Published var selectedStyleIndex: Int = 0 {
        didSet {
            // 🔥 使用与选择器相同的样式列表，确保索引一致
            let styles = RitualStyle.allCases.filter { $0 != .monoTicket && $0 != .galaInvite }
            if selectedStyleIndex >= 0 && selectedStyleIndex < styles.count {
                selectedStyle = styles[selectedStyleIndex]
                print("🔍 DEBUG: selectedStyleIndex 变化为 \(selectedStyleIndex), selectedStyle 更新为 \(selectedStyle)")
            }
        }
    }
    @Published var selectedPaperColorHex: String = "#FDF8F3"
    @Published var photoData: [Data] = []
    @Published var aestheticDetails: AestheticDetails = AestheticDetails()
    @Published var previewRecord: DayRecord = DayRecord(date: Date(), content: "", mood: .neutral, artifactStyle: .envelope)
    @Published var isCustomizationMode: Bool = false

    // MARK: - 新增元数据字段
    @Published var tags: [String] = []
    @Published var eventType: EventType?
    @Published var location: LocationData?
    @Published var weatherData: WeatherData?
    @Published var timestamp: Date = Date()

    private var cancellables = Set<AnyCancellable>()
    private let recordDate: Date
    private let existingRecord: DayRecord?

    let paperColors: [(name: String, hex: String)] = [
        ("米白", "#FDF8F3"),
        ("复古黄", "#F9F7F1"),
        ("淡蓝", "#E3F2FD"),
        ("浅绿", "#E8F5E9"),
        ("樱粉", "#FCE4EC")
    ]
    
    init(recordDate: Date, existingRecord: DayRecord?, defaultStyle: RitualStyle) {
        self.recordDate = recordDate
        self.existingRecord = existingRecord

        // 初始化逻辑：优先使用已有记录的风格，否则使用传入的默认风格
        self.selectedStyle = existingRecord?.artifactStyle ?? defaultStyle
        let styles = RitualStyle.allCases.filter { $0 != .monoTicket && $0 != .galaInvite }
        if let index = styles.firstIndex(of: selectedStyle) {
            self.selectedStyleIndex = index
        }
        self.selectedMood = existingRecord?.mood ?? .neutral
        self.selectedWeather = existingRecord?.weather
        self.aestheticDetails = existingRecord?.aestheticDetails ?? AestheticDetails.generate(for: selectedStyle, customColorHex: nil)

        if let existing = existingRecord {
            self.content = existing.content
            self.photoData = existing.photos
        }

        // 从已有记录加载元数据
        if let existing = existingRecord {
            self.tags = existing.tags
            self.eventType = existing.eventType
            self.location = existing.location
            self.weatherData = existing.weatherData
            self.timestamp = existing.timestamp ?? Date()
        }

        self.previewRecord = DayRecord(
            date: recordDate,
            content: content,
            mood: selectedMood,
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails,
            timestamp: timestamp,
            location: location,
            weatherData: weatherData,
            tags: tags,
            eventType: eventType
        )
        
        // 监听风格变化，重新生成预览
        setupStyleObserver()
    }
    
    private func setupStyleObserver() {
        $selectedStyle
            .dropFirst() // 跳过初始值
            .sink { [weak self] newStyle in
                guard let self = self else { return }
                // 风格变化时，重新生成美学细节
                self.aestheticDetails = AestheticDetails.generate(for: newStyle, customColorHex: nil)
                self.updatePreview()
            }
            .store(in: &cancellables)
        
        // 监听内容、心情、天气变化
        Publishers.CombineLatest3($content, $selectedMood, $selectedWeather)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreview()
            }
            .store(in: &cancellables)
        
        // 监听照片变化（实时更新预览）
        $photoData
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreview()
            }
            .store(in: &cancellables)
    }

    func createFinalRecord() -> DayRecord {
        return DayRecord(
            date: recordDate,
            content: content,
            mood: selectedMood,
            photos: photoData,
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails,
            timestamp: timestamp,
            location: location,
            weatherData: weatherData,
            tags: tags,
            eventType: eventType
        )
    }

    func updatePreview() {
        previewRecord = DayRecord(
            date: recordDate,
            content: content,
            mood: selectedMood,
            photos: photoData,  // 修复：包含照片数据
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails
        )
    }

    func insertRandomQuote(quotesManager: QuotesManager) {
        let quote = quotesManager.getRandomQuote()
        if content.isEmpty {
            content = quote.text
        } else {
            content += "\n\n" + quote.text
        }
        if let original = quote.originalText {
            content += "\n\n" + original
        }
        updatePreview()
    }

    func updatePhotos(_ photos: [Data]) {
        photoData = photos
        updatePreview()
        }
    }
    
struct NewRecordView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeEngine = ThemeEngine.shared

    let recordDate: Date

    // 内联 ViewModel (避免跨文件引用问题)
    @StateObject private var viewModel: InlineNewRecordViewModel
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingSealAnimation = false
    @State private var recordForAnimation: DayRecord?
    @State private var showingFullScreenPreview = false
    // 🔥 移除：不再需要保存后的预览状态
    @State private var showingCustomCamera = false
    @State private var capturedImage: UIImage?
    @State private var showingImagePicker = false

    @FocusState private var isContentFocused: Bool

    // V4.2: 定制模式状态
    @State private var showingCustomizationPanel = false
    @State private var showingTextEditor = false // 🔥 新增：文本编辑弹窗状态
    
    // 铸造后的预览状态
    @State private var showingMintedPreview = false
    @State private var mintedRecord: DayRecord?
    @State private var mintedImage: UIImage?
    
    // 🔥 清除确认对话框
    @State private var showingClearConfirmation = false
    
    // 初始化
    init(recordDate: Date, initialStyle: RitualStyle? = nil) {
        self.recordDate = recordDate
        // 内联ViewModel初始化
        // 如果提供了初始风格就使用它，否则使用随机选择
        let defaultStyle: RitualStyle
        if let style = initialStyle {
            defaultStyle = style
        } else {
            // 每次进入随机选择一个信物
            defaultStyle = ArtifactPickerManager.shared.getRandomStyle()
        }
        _viewModel = StateObject(wrappedValue: InlineNewRecordViewModel(
            recordDate: recordDate,
            existingRecord: nil as DayRecord?,
            defaultStyle: defaultStyle
        ))
    }
    
    var body: some View {
        ZStack {
            // 1. 背景：米黄色淡色背景（拒绝黑色）
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部栏：退出按钮、清除按钮和文字添加按钮
                HStack {
                    Button(action: { dismiss() }) {
                        Text("退出")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "8B7355"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    // 🔥 一键清除按钮
                    if hasAnyContent {
                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .medium))
                                Text("清除")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "FF6B6B"))
                            .cornerRadius(20)
                        }
                    }
                    
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
                
                // 2. 信物选择器（显示所有20个信物）
                ArtifactStylePickerBar(
                    selectedStyleIndex: $viewModel.selectedStyleIndex,
                    availableStyles: RitualStyle.allCases.filter { $0 != .monoTicket && $0 != .galaInvite },
                    selectedMood: $viewModel.selectedMood,
                    selectedWeather: $viewModel.selectedWeather,
                    selectedDate: $viewModel.timestamp
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // 3. 信物预览区域（左右滑动选择，占50%以上）
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        TabView(selection: $viewModel.selectedStyleIndex) {
                            ForEach(Array(RitualStyle.allCases.filter { $0 != .monoTicket && $0 != .galaInvite }.enumerated()), id: \.element) { index, style in
                                NewRecordArtifactPreviewCard(
                                    style: style,
                                    content: viewModel.content,
                                    photoData: viewModel.photoData, // 🔥 传递所有照片，而不是只传递第一张
                                    mood: viewModel.selectedMood,
                                    weather: viewModel.selectedWeather,
                                    onAddPhoto: {
                                        showingImagePicker = true
                                    },
                                    onAddText: {
                                        showingTextEditor = true
                                    }
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: geo.size.height * 0.7)
                        
                        // 2. 文本框（在信物预览下方）
                        ScrollView {
                            VStack(spacing: 16) {
                                // 文字内容
                        VStack(alignment: .leading, spacing: 8) {
                            Text("文字内容")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "8B7355"))
                            
                            TextEditor(text: $viewModel.content)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .scrollContentBackground(.hidden)
                                .frame(height: 80)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "E0D5C0"), lineWidth: 1)
                                )
                                }
                                
                                // 元数据选择：日期、天气、心情
                                MetadataPickerView(
                                    selectedDate: $viewModel.timestamp,
                                    selectedWeather: $viewModel.selectedWeather,
                                    selectedMood: $viewModel.selectedMood
                                )
                                
                                // 标签输入
                                TagsInputView(tags: $viewModel.tags)
                                
                                // 事件类型选择
                                EventTypePickerView(selectedEventType: $viewModel.eventType)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                            .padding(.bottom, 20)
                        }
                        .frame(height: geo.size.height * 0.3)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // 4. 金色"铸造时光信物"按钮（底部）
                Button(action: { saveRecord() }) {
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
            
            // 4. 文字编辑弹窗（白色背景，黑色字体）
            if showingTextEditor {
                MintTextEditorSheet(
                    content: $viewModel.content,
                    isPresented: $showingTextEditor
                )
            }
        }
        .confirmationDialog("确定要清除所有内容吗？", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
            Button("清除全部", role: .destructive) {
                clearAllContent()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将清除已输入的文字、选择的照片、心情和天气")
        }
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $selectedPhotos,
            maxSelectionCount: 10, // 🔥 允许选择多张照片
            matching: .images
        )
        .fullScreenCover(isPresented: $showingMintedPreview) {
            // 🔥 确保背景始终可见，避免黑屏
            ZStack {
                // 背景色（使用系统颜色确保一定能显示）
                Color(UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1.0))
                    .ignoresSafeArea(.all)
                
                // 内容
                if let record = mintedRecord, let image = mintedImage {
                    let _ = { print("🔍 DEBUG: NewRecordView fullScreenCover - 显示预览内容，record ID: \(record.id.uuidString)") }()
                    MintedArtifactPreviewView(
                        record: record,
                        renderedImage: image,
                        onDismiss: {
                            showingMintedPreview = false
                        },
                        onSave: {
                            // 保存到时光Tab
                            print("🔍 DEBUG: onSave - 保存记录，record ID: \(record.id.uuidString), artifactStyle: \(record.artifactStyle)")
                            if let artifactID = ImageFileManager.shared.saveArtifact(image: image) {
                                let recordWithArtifact = DayRecord(
                                    id: record.id,
                                    date: record.date,
                                    content: record.content,
                                    mood: record.mood,
                                    photos: record.photos,
                                    weather: record.weather,
                                    isSealed: record.isSealed,
                                    sealedAt: record.sealedAt,
                                    hasBeenOpened: record.hasBeenOpened,
                                    openedAt: record.openedAt,
                                    artifactStyle: record.artifactStyle,
                                    aestheticDetails: record.aestheticDetails,
                                    sticker: record.sticker,
                                    renderedArtifactID: artifactID
                                )
                                print("🔍 DEBUG: onSave - 保存 recordWithArtifact, ID: \(recordWithArtifact.id.uuidString), artifactStyle: \(recordWithArtifact.artifactStyle)")
                                dataManager.addOrUpdateRecord(recordWithArtifact)
                            } else {
                                print("🔍 DEBUG: onSave - 保存 record (无artifactID), ID: \(record.id.uuidString), artifactStyle: \(record.artifactStyle)")
                                dataManager.addOrUpdateRecord(record)
                            }
                            SensoryManager.shared.playRitualFeedback(for: record.artifactStyle, phase: .mintingComplete)
                            showingMintedPreview = false
                            // 🔥 重置所有状态，下次打开时是全新的
                            resetToNewState()
                            dismiss()
                        },
                        onRedo: {
                            // 重做：关闭预览，继续编辑
                            showingMintedPreview = false
                        }
                    )
                } else {
                    let _ = { print("🔍 DEBUG: NewRecordView fullScreenCover - 显示加载状态，record: \(mintedRecord != nil), image: \(mintedImage != nil)") }()
                    // 🔥 即使record为nil，也显示加载状态（背景已在ZStack中）
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
                print("🔍 DEBUG: NewRecordView fullScreenCover onAppear - record: \(mintedRecord != nil), image: \(mintedImage != nil)")
            }
        }
        .onChange(of: selectedPhotos) { oldValue, newItems in
            Task {
                var newPhotos: [Data] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        newPhotos.append(data)
                    }
                }
                await MainActor.run {
                    if !newPhotos.isEmpty {
                        // 🔥 追加照片，但不超过当前信物风格的最大数量限制
                        let maxPhotos = viewModel.selectedStyle.maxPhotos
                        var currentPhotos = viewModel.photoData
                        let remainingSlots = max(0, maxPhotos - currentPhotos.count)
                        if remainingSlots > 0 {
                            let photosToAdd = Array(newPhotos.prefix(remainingSlots))
                            currentPhotos.append(contentsOf: photosToAdd)
                        viewModel.updatePhotos(currentPhotos)
                        }
                        // 🔥 清空 selectedPhotos，允许下次再次选择
                        selectedPhotos = []
                    }
                }
            }
        }
        .onAppear {
            // 🔥 如果是从中间tab打开（今天是今天且没有记录），重置为全新状态
            let calendar = Calendar.current
            let isToday = calendar.isDateInToday(recordDate)
            let existingRecord = dataManager.record(for: recordDate)
            
            if isToday && existingRecord == nil {
                // 从铸造tab打开，重置为全新状态并自动采集元数据
                resetToNewState()
                // 自动采集元数据
                collectMetadata()
            } else if let existing = existingRecord {
                // 从日历补记打开，加载已有记录
                viewModel.content = existing.content
                viewModel.selectedMood = existing.mood
                viewModel.selectedWeather = existing.weather
                viewModel.selectedStyle = existing.artifactStyle
                viewModel.photoData = existing.photos
                // 加载元数据
                viewModel.tags = existing.tags
                viewModel.eventType = existing.eventType
                viewModel.location = existing.location
                viewModel.weatherData = existing.weatherData
                viewModel.timestamp = existing.timestamp ?? Date()
                viewModel.updatePreview()
            } else {
                // 补记过去的日期，重置为全新状态
                resetToNewState()
            }
        }
    }
    
    // MARK: - 元数据采集
    
    private func collectMetadata() {
        let metadataCollector = MetadataCollector.shared
        
        // 请求位置权限（如果需要）
        let locationService = LocationService.shared
        if locationService.authorizationStatus == CLAuthorizationStatus.notDetermined {
            locationService.requestPermission()
        }
        
        // 采集所有元数据
        metadataCollector.collectAllMetadata(for: recordDate) { [weak viewModel] (metadata: MetadataCollector.CollectedMetadata) in
            guard let viewModel = viewModel else { return }
            
            viewModel.timestamp = metadata.timestamp
            viewModel.location = metadata.location
            viewModel.weatherData = metadata.weatherData
            
            // 如果有详细天气数据，更新基础天气
            if let weatherData = metadata.weatherData {
                viewModel.selectedWeather = weatherData.condition
            }
            
            viewModel.updatePreview()
        }
    }
    
    // 🔥 重置为全新状态
    private func resetToNewState() {
        viewModel.content = ""
        viewModel.selectedMood = .neutral
        viewModel.selectedWeather = nil
        viewModel.selectedStyleIndex = 0
        viewModel.photoData = []
        viewModel.updatePreview()
        showingMintedPreview = false
        mintedRecord = nil
        mintedImage = nil
        selectedPhotos = []
        showingTextEditor = false
        // 🔥 清除元数据
        viewModel.tags = []
        viewModel.eventType = nil
        viewModel.location = nil
        viewModel.weatherData = nil
    }
    
    // 🔥 一键清除所有内容
    private func clearAllContent() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            viewModel.content = ""
            viewModel.photoData = []
            selectedPhotos = []
            viewModel.selectedMood = .neutral
            viewModel.selectedWeather = nil
            // 保留信物风格选择
            viewModel.updatePreview()
        }
        
        // 触感反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // 🔥 检查是否有任何内容
    private var hasAnyContent: Bool {
        !viewModel.content.isEmpty || 
        !viewModel.photoData.isEmpty || 
        viewModel.selectedMood != .neutral || 
        viewModel.selectedWeather != nil
    }
    
    private func saveRecord() {
        print("🔍 DEBUG: NewRecordView saveRecord() 开始执行")
        print("🔍 DEBUG: 当前 selectedStyleIndex = \(viewModel.selectedStyleIndex)")
        print("🔍 DEBUG: 当前 selectedStyle = \(viewModel.selectedStyle)")
        
        // 🔥 每次创建新记录，使用新的 UUID（允许同一天有多个记录）
        let recordId = UUID()
        print("🔍 DEBUG: 创建新记录 ID: \(recordId.uuidString)")
        
        let record = viewModel.createFinalRecord()
        print("🔍 DEBUG: createFinalRecord 返回的 artifactStyle = \(record.artifactStyle)")
        
        // 创建最终记录（包含所有元数据）
        let finalRecord = DayRecord(
            id: recordId,
            date: record.date,
            content: record.content,
            mood: record.mood,
            photos: record.photos,
            weather: record.weather,
            isSealed: true,
            sealedAt: Date(),
            hasBeenOpened: record.hasBeenOpened,
            openedAt: record.openedAt,
            artifactStyle: record.artifactStyle,
            aestheticDetails: record.aestheticDetails,
            sticker: record.sticker,
            renderedArtifactID: nil,
            timestamp: record.timestamp,
            location: record.location,
            weatherData: record.weatherData,
            tags: record.tags,
            eventType: record.eventType
        )
        print("🔍 DEBUG: finalRecord 创建完成 - ID: \(finalRecord.id.uuidString), artifactStyle: \(finalRecord.artifactStyle)")
        
        // 🔥 记录信物使用（用于"最近使用"功能）
        ArtifactPickerManager.shared.recordUsage(finalRecord.artifactStyle)
        
        // 🔥 立即创建占位图片，避免黑屏
        let placeholderSize = CGSize(width: 800, height: 1200)
        UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0)
        if let color = UIColor(hex: "F5F0E8") {
            color.setFill()
        } else {
            UIColor.systemBackground.setFill()
        }
        UIRectFill(CGRect(origin: .zero, size: placeholderSize))
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 🔥 先设置record和占位图，确保状态完整
        mintedRecord = finalRecord
        mintedImage = placeholderImage ?? UIImage()
        
        print("🔍 DEBUG: NewRecordView saveRecord - mintedRecord set: \(mintedRecord != nil), mintedImage set: \(mintedImage != nil)")
        
        // 🔥 立即显示预览（不等待渲染完成）
        showingMintedPreview = true
        print("🔍 DEBUG: NewRecordView saveRecord - showingMintedPreview 已设置为 true")
        
        // 🔥 使用新的 snapshot 方法渲染
        Task { @MainActor in
            print("🔍 DEBUG: NewRecordView saveRecord - 准备渲染预览图片，photos count: \(finalRecord.photos.count)")

            let artifactView = StyledArtifactView(record: finalRecord)
            
            // 直接渲染视图为图片 (700pt @ 2.0x = 1400px)
            let controller = UIHostingController(rootView: AnyView(artifactView).ignoresSafeArea())
            let uiView = controller.view
            let width: CGFloat = 700
            let scale: CGFloat = 2.0
            
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
            let renderedImage = renderer.image { context in
                uiView?.drawHierarchy(in: uiView!.bounds, afterScreenUpdates: true)
            }

            print("🔍 DEBUG: NewRecordView saveRecord - 渲染完成，更新图片")
            print("🔍 DEBUG: 渲染的 record ID: \(finalRecord.id.uuidString), artifactStyle: \(finalRecord.artifactStyle)")
            print("🔍 DEBUG: 渲染的 record photos count: \(finalRecord.photos.count)")
            print("🔍 DEBUG: 渲染的 record content: \(finalRecord.content.isEmpty ? "空" : "有内容")")
            print("🔍 DEBUG: 渲染的图片尺寸: \(renderedImage.size)")

            mintedImage = renderedImage
        }
    }
}

// MARK: - NewRecordArtifactPreviewCard（与MintArtifactPreviewCard相同逻辑）
struct NewRecordArtifactPreviewCard: View {
    let style: RitualStyle
    let content: String
    let photoData: [Data] // 🔥 改为数组，支持多张照片
    let mood: Mood
    let weather: Weather?
    let onAddPhoto: () -> Void
    let onAddText: () -> Void
    
    @State private var previewRecord: DayRecord
    
    init(style: RitualStyle, content: String, photoData: [Data], mood: Mood, weather: Weather?, onAddPhoto: @escaping () -> Void, onAddText: @escaping () -> Void) {
        self.style = style
        self.content = content
        self.photoData = photoData
        self.mood = mood
        self.weather = weather
        self.onAddPhoto = onAddPhoto
        self.onAddText = onAddText
        
        var details = AestheticDetails.generate(for: style)
        // 添加随机装饰元素
        details = MintArtifactPreviewCard.addRandomDecorations(to: details)
        
        self._previewRecord = State(initialValue: DayRecord(
            date: Date(),
            content: content,
            mood: mood,
            photos: photoData, // 🔥 使用所有照片
            weather: weather,
            artifactStyle: style,
            aestheticDetails: details
        ))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 信物预览（大尺寸，占50%以上，动态大小）
                // 确保至少占屏幕高度的50%以上
                let maxWidth = geo.size.width * 0.9
                let maxHeight = geo.size.height * 0.65 // 至少65%高度
                let artifactSize = min(maxWidth, maxHeight)
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
                                Image(systemName: photoData.isEmpty ? "plus.circle.fill" : "photo.badge.plus")
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
        details = MintArtifactPreviewCard.addRandomDecorations(to: details)
        
        previewRecord = DayRecord(
            date: Date(),
            content: content,
            mood: mood,
            photos: photoData, // 🔥 使用所有照片
            weather: weather,
            artifactStyle: style,
            aestheticDetails: details
        )
    }
}

// MARK: - 辅助组件

// MARK: - 风格选择器项
struct StylePickerItem: View {
    let style: RitualStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 8) {
                Text(style.emoji)
                    .font(.system(size: 28))
                
                Text(style.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color("PrimaryOrange") : Color("TextSecondary"))
                    .lineLimit(1)
                            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color("PrimaryWarm").opacity(0.15) : Color("CardBackground"))
            .cornerRadius(12)
                            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("PrimaryOrange") : Color.clear, lineWidth: 2)
                            )
                        }
        .buttonStyle(PlainButtonStyle()) // 🔥 修复：使用PlainButtonStyle确保点击响应
        }
    }
    
// MARK: - 照片选择按钮组件（INS/TikTok风格）

struct PhotoSelectionButton: View {
    let icon: String
    let label: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("PrimaryOrange").opacity(0.1))
                        .frame(width: 80, height: 80)

                    Circle()
                        .stroke(Color("PrimaryOrange"), lineWidth: 2)
                        .frame(width: 80, height: 80)

                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(Color("PrimaryOrange"))
                }

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToolbarWeatherButton: View {
    let weather: Weather?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("CardBackground"))
                    .frame(width: 50, height: 50)
                                .overlay(
                        Group {
                            if let weather = weather {
                                Image(systemName: weather.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(Color("PrimaryOrange"))
                            } else {
                                Image(systemName: "cloud")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    )
                
                Text(weather?.label ?? "天气")
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToolbarMoodButton: View {
    let mood: Mood
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("CardBackground"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(mood.emoji)
                            .font(.system(size: 28))
                    )
                
                Text(mood.label)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .buttonStyle(PlainButtonStyle())
        }
    }
    
struct ToolbarStickerButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("CardBackground"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "face.smiling")
                            .font(.system(size: 24))
                            .foregroundColor(Color("TextSecondary"))
                    )
                    
                Text("表情")
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToolbarStyleButton: View {
    let style: RitualStyle
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("CardBackground"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(style.emoji)
                            .font(.system(size: 28))
                    )
                
                Text(style.label)
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToolbarTextButton: View {
    let hasContent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("CardBackground"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: hasContent ? "text.cursor.fill" : "text.cursor")
                            .font(.system(size: 24))
                            .foregroundColor(hasContent ? Color("PrimaryOrange") : Color("TextSecondary"))
                    )
                
                Text("文字")
                    .font(.system(size: 11))
                    .foregroundColor(Color("TextSecondary"))
    }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 文本编辑弹窗
struct TextEditorSheet: View {
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeEngine.shared.currentTheme.backgroundView
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .focused($isFocused)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
                }
                .padding(20)
                        }
            .navigationTitle("编辑内容")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        onSave()
                    }
                    .foregroundColor(Color("PrimaryOrange"))
                    }
                }
            .onAppear {
                // 自动聚焦
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = true
                }
            }
            }
        }
    }
    
// MARK: - 全屏预览视图
struct FullScreenPreviewView: View {
    let record: DayRecord
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // 顶部关闭按钮
                HStack {
                    Spacer()
                        Button {
                        onDismiss()
                        } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
            }
                    .padding()
                }
                
                Spacer()
                
                // 信物预览
                StyledArtifactView(record: record)
                    .scaleEffect(1.0)
                    .shadow(color: Color.black.opacity(0.3), radius: 30, y: 15)
                
                Spacer()
            }
        }
    }
            }
            
// MARK: - DIY信物视图（直接在信物上编辑）
struct CustomizationView: View {
    @ObservedObject var viewModel: InlineNewRecordViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedComponent: DIYComponent? = nil
    
    enum DIYComponent {
        case paperColor
        case sealDesign
        case sealRotation
        case qrCode
        case stickers
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部：编辑按钮区域（不遮挡信物）
                    HStack {
                        // 左上角：信纸颜色（仅信封风格）
                        if viewModel.selectedStyle == .envelope {
                            DIYEditButton(
                                icon: "paintbrush.fill",
                                label: "信纸",
                                isActive: selectedComponent == .paperColor
                            ) {
                                withAnimation(.spring()) {
                                    selectedComponent = selectedComponent == .paperColor ? nil : .paperColor
                                }
                            }
                        }
                        
                        Spacer()
            
                        // 右上角：印章设计（仅信封风格）
                        if viewModel.selectedStyle == .envelope {
                            DIYEditButton(
                                icon: "seal.fill",
                                label: "印章",
                                isActive: selectedComponent == .sealDesign
                            ) {
                                withAnimation(.spring()) {
                                    selectedComponent = selectedComponent == .sealDesign ? nil : .sealDesign
                }
            }
        }
    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 中心：信物预览（占据主要空间，实时显示DIY效果）
                    ScrollView {
                        VStack {
                            Spacer(minLength: 20)
                            
                            StyledArtifactView(record: viewModel.previewRecord)
                                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, UIDevice.current.userInterfaceIdiom == .pad ? 500 : 400))
                                .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.85)  // iPad 1.0x, iPhone 0.85x
                                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 40 : 30)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 25, y: 10)
                            
                            Spacer(minLength: 20)
    }
}

                    // 底部：编辑面板（当选中组件时显示）
                    if selectedComponent != nil {
                        editPanel
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("DIY信物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("保存") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryOrange"))
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // 编辑面板（根据选中的组件显示不同选项）
    @ViewBuilder
    private var editPanel: some View {
        VStack(spacing: 0) {
            Divider()
            
            switch selectedComponent {
            case .paperColor:
                paperColorEditPanel
            case .sealDesign:
                sealDesignEditPanel
            default:
                EmptyView()
            }
        }
        .background(Color("CardBackground"))
        .frame(height: 200)
    }
    
    private var paperColorEditPanel: some View {
        VStack(spacing: 16) {
            Text("选择信纸颜色")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
                .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.paperColors, id: \.hex) { color in
                        Button {
                            viewModel.selectedPaperColorHex = color.hex
                            viewModel.aestheticDetails.letterBackgroundColorHex = color.hex
                            viewModel.updatePreview()
                        } label: {
                            VStack(spacing: 8) {
                    Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                        Circle()
                                            .stroke(
                                                viewModel.selectedPaperColorHex == color.hex ?
                                                    Color("PrimaryOrange") : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                        
                                Text(color.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(
                                        viewModel.selectedPaperColorHex == color.hex ?
                                            Color("PrimaryOrange") : Color("TextSecondary")
            )
                            }
        }
        .buttonStyle(.plain)
    }
}
                .padding(.horizontal, 20)
                }
        }
    }
    
    private var sealDesignEditPanel: some View {
        VStack(spacing: 16) {
            Text("选择印章设计")
                .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach([WaxSealDesign.initialY, .heart, .star, .crown, .anchor], id: \.self) { design in
                        Button {
                            viewModel.aestheticDetails.waxSealDesign = design
                            viewModel.updatePreview()
                        } label: {
                            VStack(spacing: 8) {
        ZStack {
                    Circle()
                                        .fill(Color("PrimaryOrange").opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Text(design.rawValue)
                                        .font(.system(size: 24))
                                }
                                .overlay(
                        Circle()
                                        .stroke(
                                            viewModel.aestheticDetails.waxSealDesign == design ?
                                                Color("PrimaryOrange") : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                
                                Text(design.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        viewModel.aestheticDetails.waxSealDesign == design ?
                                            Color("PrimaryOrange") : Color("TextSecondary")
                                    )
                            }
                }
                        .buttonStyle(.plain)
            }
        }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - DIY编辑按钮
struct DIYEditButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .white : Color("PrimaryOrange"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isActive ? Color("PrimaryOrange") : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? Color.clear : Color("PrimaryOrange"), lineWidth: 2)
            )
        }
    }
}

// MARK: - 注意：ArtifactStylePickerBar 和 ExtendedBottomStatusBar 已在 MintFlowView.swift 中定义

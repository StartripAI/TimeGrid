//
//  DayDetailView.swift
//  时光格 V3.1 - 统一日期详情页
//
//  解决 Bug 1: 点击任何日期格子都有返回按钮，不再死胡同
//  包含：空状态哲思、FTUE支持、信物分享功能
//

import SwiftUI
import UIKit

struct DayDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    @Environment(\.dismiss) var dismiss
    
    let date: Date
    
    @State private var record: DayRecord?
    @State private var showingEditor = false
    @State private var renderedImage: UIImage?
    @State private var shareableImage: UIImage?
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(formattedDate)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // V3.1 核心修复：始终有关闭按钮
                    ToolbarItem(placement: .cancellationAction) {
                        Button("关闭") { dismiss() }
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    // V3.3: 分享按钮（封存后即可分享，无需等待拆封）
                    if let _ = record, let img = shareableImage {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(
                                item: Image(uiImage: img),
                                preview: SharePreview("时光格时光信物", image: Image(uiImage: img))
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color("PrimaryWarm"))
                            }
                        }
                    }
                }
                .onAppear(perform: loadData)
                .sheet(isPresented: $showingEditor) {
                    NewRecordView(recordDate: date)
                        .onDisappear(perform: loadData)
                        .presentationDetents([.large]) // 使用大尺寸
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                        .interactiveDismissDisabled(false) // 允许拖拽关闭
                        .presentationBackgroundInteraction(.enabled) // 允许背景交互
                }
        }
        .background(
            // 保底背景：始终使用浅色背景，避免黑屏
            // 如果有记录，主题背景作为装饰层叠加
            ZStack {
                // 保底浅色背景（拒绝黑色）
                Color(hex: "F5F0E8")
                    .ignoresSafeArea()
                
                // 如果有记录，叠加主题背景（半透明）
                if record != nil {
                    ThemeEngine.shared.currentTheme.backgroundView
                        .opacity(0.3) // 降低透明度，避免完全黑屏
                        .ignoresSafeArea()
                }
            }
        )
    }
    
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            // 修复：空日期的"黑洞"问题，使用全局材质
            // Color("BackgroundCream").ignoresSafeArea() // DELETED
            
            if let rec = record {
                // 有记录
                RecordContentView(
                    record: rec,
                    renderedImage: $renderedImage,
                    onOpen: { openRecord(rec) }
                )
            } else {
                // 无记录 - 显示空状态哲思
                EmptyDayPlaceholder(
                    date: date,
                    quote: quotesManager.getContextualQuote(for: date),
                    onAddTapped: { showingEditor = true }
                )
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    private func loadData() {
        self.record = dataManager.record(for: date)
        // V3.3: 预渲染图像用于分享（封存后即可）
        if let rec = self.record {
            renderArtifact(record: rec)
            // V4.2: 加载已渲染的信物图片用于分享
            Task { @MainActor in
                self.shareableImage = await getShareableImage(for: rec)
            }
        }
    }
    // V4.0: 移除封存逻辑，记录始终可见，不需要"打开"
    private func openRecord(_ rec: DayRecord) {
        // V4.0: 记录始终可见，此方法保留用于兼容性，但不执行任何操作
        loadData()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    // V3.3: 获取可分享的图片（优先使用存储的，否则当前渲染的）
    @MainActor
    private func getShareableImage(for record: DayRecord) async -> UIImage? {
        // V4.0: 优先使用保存的信物图片
        if let artifactID = record.renderedArtifactID {
            return await ImageFileManager.shared.loadArtifact(id: artifactID)
        }
        
        // 如果没有保存的图片，则实时渲染
        let artifactView = StyledArtifactView(record: record)
        return renderViewToImageInternal(AnyView(artifactView))
    }
    
    @MainActor
    private func renderArtifact(record: DayRecord) {
        let content = ArtifactRenderContainer(record: record)
        self.renderedImage = renderViewToImageInternal(AnyView(content))
    }
    
    // 本地辅助函数：渲染视图为图片
    @MainActor
    private func renderViewToImageInternal(_ view: AnyView, width: CGFloat = 700, scale: CGFloat = 2.0) -> UIImage? {
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
}

// MARK: - 记录内容视图

struct RecordContentView: View {
    @EnvironmentObject var dataManager: DataManager
    let record: DayRecord
    @Binding var renderedImage: UIImage?
    let onOpen: () -> Void
    
    // V2.0: 移除封存限制 - 所有记录都可以立即查看
    var body: some View {
        // 直接显示完整内容，不再检查封存状态
        OpenedRecordView(record: record)
    }
}

// MARK: - 已打开的记录视图

struct OpenedRecordView: View {
    let record: DayRecord
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 根据风格显示信物
                ArtifactRenderContainer(record: record)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                    .padding(.top, 20)
                
                // V4.0: 移除封存时间戳显示
                // 只显示记录日期
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text("记录于 \(formatTime(record.date))")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                }
                .padding(.top, 10)
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 可拆封提示视图

struct UnsealPromptView: View {
    let record: DayRecord
    let onOpen: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 封存的信封图标
            ZStack {
                Circle()
                    .fill(Color("PrimaryWarm").opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("PrimaryWarm"))
            }
            
            VStack(spacing: 12) {
                Text("这份记忆已准备好")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(record.formattedDate)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextSecondary"))
            }
            
            // 拆封按钮
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onOpen()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.open.fill")
                        .font(.system(size: 18))
                    
                    Text("立即拆开")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 54)
                .background(
                    LinearGradient(
                        colors: [Color("PrimaryWarm"), Color("SealColor")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(27)
                .shadow(color: Color("PrimaryWarm").opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .scaleEffect(isPressed ? 0.95 : 1)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in withAnimation(.spring(response: 0.2)) { isPressed = true } }
                    .onEnded { _ in withAnimation(.spring(response: 0.2)) { isPressed = false } }
            )
            
            Spacer()
        }
    }
}

// V4.0: 移除等待视图
// 记录始终可见，不再需要等待视图

// MARK: - 空状态占位（多语言哲思）

struct EmptyDayPlaceholder: View {
    let date: Date
    let quote: ContextualQuote
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("这一天没有留下记录")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "8B7355"))
                
                // 多语言哲思卡片
                VStack(spacing: 16) {
                    // 中文
                    Text(quote.textZh)
                        .font(.system(size: 18, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: "5A4A3A"))
                        .multilineTextAlignment(.center)
                    
                    // 原文（如有）
                    if let original = quote.textOriginal {
                        Text(original)
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Color(hex: "8B7355"))
                            .multilineTextAlignment(.center)
                    }
                    
                    // 作者
                    HStack(spacing: 4) {
                        Text("——")
                        Text(quote.author)
                    }
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(Color(hex: "8B7355"))
                }
                .padding(25)
                .background(Color.white.opacity(0.9))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            
            // 补记按钮（允许所有日期添加记录，包括未来）- 确保可见和可点击
            Button(action: onAddTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("补记这一天")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "F2D06B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 8, y: 4)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(30)
    }
}

// MARK: - 信物渲染容器（用于分享）

struct ArtifactRenderContainer: View {
    let record: DayRecord
    
    var body: some View {
        // V4.0: 使用 StyledArtifactView 显示信物
        StyledArtifactView(record: record)
            .padding(20)
    }
}

#Preview {
    DayDetailView(date: Date())
        .environmentObject(DataManager())
        .environmentObject(QuotesManager())
}


import SwiftUI
import PhotosUI

struct EditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    
    // 动画控制状态
    @State private var isTriggeringAnimation = false
    @State private var entryForAnimation: ReceiptEntry?
    @State private var imageForAnimation: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 照片选择区域
                    photoSection
                    
                    // 文字输入区域
                    textSection
                    
                    // 预览提示
                    previewHint
                }
                .padding(20)
            }
            .background(Color("PaperBackground").opacity(0.5).ignoresSafeArea())
            .navigationTitle("新建小票")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("打印") {
                        prepareAndPrint()
                    }
                    .fontWeight(.bold)
                    .disabled(content.isEmpty && inputImage == nil)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                loadPhoto(from: newValue)
            }
            // 核心仪式：使用 fullScreenCover 播放沉浸式动画
            .fullScreenCover(isPresented: $isTriggeringAnimation) {
                if let entry = entryForAnimation {
                    PrintingAnimationView(entry: entry, processedImage: imageForAnimation) { renderedImage in
                        // 动画完成后的回调
                        saveEntry(entry: entry, renderedImage: renderedImage)
                        dismiss() // 关闭 EditorView
                    }
                }
            }
        }
    }
    
    // MARK: - 照片选择区域
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("照片")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color("InkColor").opacity(0.6))
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                if let img = inputImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        
                        // 删除按钮
                        Button {
                            inputImage = nil
                            selectedPhotoItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .offset(x: 8, y: -8)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                        Text("选择一张照片")
                            .font(.system(size: 14, design: .monospaced))
                    }
                    .foregroundColor(Color("InkColor").opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundColor(Color("InkColor").opacity(0.3))
                    )
                }
            }
        }
    }
    
    // MARK: - 文字输入区域
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时间消费项")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color("InkColor").opacity(0.6))
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $content)
                    .frame(minHeight: 150)
                    .font(.system(size: 16, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color("PaperBackground"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("InkColor").opacity(0.2), lineWidth: 1)
                    )
                
                if content.isEmpty {
                    Text("记录这一刻...")
                        .foregroundColor(Color("InkColor").opacity(0.4))
                        .font(.system(size: 16, design: .monospaced))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    // MARK: - 预览提示
    private var previewHint: some View {
        VStack(spacing: 8) {
            Image(systemName: "printer.fill")
                .font(.system(size: 20))
            Text("点击「打印」生成时光小票")
                .font(.system(size: 12, design: .monospaced))
        }
        .foregroundColor(Color("InkColor").opacity(0.4))
        .padding(.top, 20)
    }
    
    // MARK: - 功能方法
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.inputImage = uiImage
                }
            }
        }
    }
    
    // 准备数据并触发动画
    private func prepareAndPrint() {
        guard !isTriggeringAnimation else { return }

        // 1. 创建条目实例
        let newEntry = ReceiptEntry(
            content: content,
            imageData: inputImage?.jpegData(compressionQuality: 0.8)
        )
        
        // 2. 处理图片 (异步进行，防止阻塞UI)
        Task.detached(priority: .userInitiated) {
            // 应用热敏打印效果
            let processedImg: UIImage?
            if let image = self.inputImage {
                // 尝试应用随机抖动效果，如果失败则使用简单效果
                processedImg = ImageProcessor.shared.applyThermalEffect(to: image)
                    ?? ImageProcessor.shared.applySimpleThermalEffect(to: image)
            } else {
                processedImg = nil
            }
            
            await MainActor.run {
                // 3. 准备好数据后，触发动画视图
                self.entryForAnimation = newEntry
                self.imageForAnimation = processedImg
                self.isTriggeringAnimation = true
            }
        }
    }
    
    // 保存数据到 SwiftData
    private func saveEntry(entry: ReceiptEntry, renderedImage: UIImage?) {
        // 将最终渲染的小票图片保存起来
        entry.renderedReceiptData = renderedImage?.pngData()
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

#Preview {
    EditorView()
        .modelContainer(for: ReceiptEntry.self, inMemory: true)
}


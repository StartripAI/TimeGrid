import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // 查询所有记录，按时间倒序
    @Query(sort: \ReceiptEntry.timestamp, order: .reverse) private var entries: [ReceiptEntry]
    
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 40) {
                    if entries.isEmpty {
                        emptyState
                    } else {
                        ForEach(entries) { entry in
                            TimelineCard(entry: entry)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            // 使用稍微灰暗的背景区分小票
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            .navigationTitle("MonoLog")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingEditor = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                EditorView()
            }
        }
    }
    
    // MARK: - 空状态视图
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "printer")
                .font(.system(size: 60))
                .foregroundColor(Color("InkColor").opacity(0.3))
            
            VStack(spacing: 8) {
                Text("时光小票")
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                
                Text("点击右上角 + 号")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("打印你的第一张时光小票")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 120)
    }
}

// MARK: - 时间线上的卡片（包含分享功能）
struct TimelineCard: View {
    @Environment(\.modelContext) private var modelContext
    let entry: ReceiptEntry
    
    @State private var showingDeleteAlert = false
    
    // 从SwiftData中读取已渲染的图片
    var renderedImage: Image? {
        // 这里读取的是已经渲染好（无墨迹模糊）的图片数据
        if let data = entry.renderedReceiptData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    var renderedUIImage: UIImage? {
        if let data = entry.renderedReceiptData {
            return UIImage(data: data)
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 15) {
            // 时间标签
            HStack {
                Text(entry.shortDate)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 删除按钮
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 30)
            
            if let image = renderedImage {
                // 显示渲染好的小票图片
                image
                    .resizable()
                    .scaledToFit()
                    // 在UI上再次添加墨迹模糊和阴影，增强视觉效果
                    .blur(radius: 0.3)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                
                // 操作按钮
                HStack(spacing: 20) {
                    // 分享按钮 (使用ShareLink)
                    // ShareLink支持分享到微信、保存到相册等系统级操作
                    if let uiImage = renderedUIImage {
                        ShareLink(
                            item: Image(uiImage: uiImage),
                            preview: SharePreview("时光小票 \(entry.shortDate)", image: Image(uiImage: uiImage))
                        ) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享")
                            }
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color("InkColor").opacity(0.6))
                        }
                    }
                    
                    // 保存到相册按钮
                    Button {
                        saveToPhotoLibrary()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                            Text("保存")
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color("InkColor").opacity(0.6))
                    }
                }
            } else {
                // 加载失败状态
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                    Text("小票数据加载失败")
                        .font(.system(size: 12, design: .monospaced))
                }
                .foregroundColor(.secondary)
                .frame(height: 200)
            }
        }
        .padding(.horizontal, 20)
        .alert("删除小票", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("确定要删除这张时光小票吗？此操作不可撤销。")
        }
    }
    
    private func saveToPhotoLibrary() {
        guard let uiImage = renderedUIImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        
        // 保存成功反馈
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func deleteEntry() {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ReceiptEntry.self, inMemory: true)
}


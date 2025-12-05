//
//  TodayView.swift
//  时光格 V3.0 - 中Tab: 今日（极简首页）
//
//  设计理念：极度聚焦，一键开始今日记录
//  参考 HTML 设计稿优化
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    
    @State private var showingNewRecord = false
    @State private var showingTimeCapsule = false
    @State private var showingPendingList = false
    @State private var selectedRecord: DayRecord?
    @State private var showingCustomCamera = false
    @State private var showingHubStylePicker = false
    // V3.5.1 修改: 存储 UIImage
    @State private var capturedImageForNewRecord: UIImage?

    // V5.0: 使用全局信物风格状态，让三个Tab完全联动
    
    private var todayRecord: DayRecord? {
        dataManager.todayRecord()
    }
    
    // V4.0: 使用固定颜色
    private var hubBackgroundColor: Color {
        todayRecord == nil ? Color("PrimaryWarm").opacity(0.1) : Color("BackgroundCream")
    }
    
    private var dateColor: Color {
        todayRecord == nil ? Color("PrimaryOrange").opacity(0.7) : Color("TextSecondary")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                hubBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    todayMainSection
                    
                    Spacer()
                    
                    if dataManager.settings.dailyQuoteEnabled {
                        dailyQuoteCard
                            .padding(.horizontal, 20)
                    }
                    
                    quickActionsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("时光格")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHubStylePicker = true
                    } label: {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(Color("PrimaryWarm"))
                    }
                }
            }
            .sheet(isPresented: $showingHubStylePicker) {
                HubStylePickerView()
            }
        }
        // V3.5.1 修改: 更新 NewRecordView 调用
        .fullScreenCover(isPresented: $showingNewRecord, onDismiss: {
            capturedImageForNewRecord = nil
        }) {
            NewRecordView(recordDate: Date())
        }
        .sheet(isPresented: $showingTimeCapsule) {
            TimeCapsuleView()
        }
        .sheet(isPresented: $showingPendingList) {
            PendingRecordsView()
        }
        .sheet(item: $selectedRecord) { record in
            RecordDetailView(record: record)
        }
        // V2.0: 移除 MaxSealsReachedView - 取消封存次数限制
        // V3.5.1 修改: 更新 CustomCameraView 调用并添加时序修复
        .fullScreenCover(isPresented: $showingCustomCamera) {
            CustomCameraView { image in
                // 1. 保存图片
                capturedImageForNewRecord = image
                // 2. 关闭相机
                showingCustomCamera = false
                
                // V3.5.1 修复：延迟显示 NewRecordView 确保相机完全关闭，修复联动失败问题
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingNewRecord = true
                }
            } onCancel: {
                showingCustomCamera = false
            }
        }
        // V2.0: 移除封存确认对话框 - 改为可选时光胶囊
    }
    
    // MARK: - 今日主入口
    
    private var todayMainSection: some View {
        VStack(spacing: 22) {
            Text(formattedToday)
                .font(.system(size: 15))
                .foregroundColor(dateColor)
            
            // V4.0: 使用入口风格组件（根据 todayHubStyle 显示不同的入口）
            RitualHubWidgetContainer(
                style: dataManager.settings.todayHubStyle,
                hasRecordToday: todayRecord != nil,
                onTrigger: handlePrimaryAction,
                onShowRecord: handleExistingRecordTap
            )
            .padding(.bottom, 20) // 增加底部间距，防止文字被遮挡
        }
    }
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 · EEEE"
        return formatter.string(from: Date())
    }

    // V2.0: 取消强制封存 - 每天可以无限次打卡
    // V4.0: 统一入口与信物风格，使用推荐逻辑
    private func handlePrimaryAction() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // V4.0: 根据入口风格推荐对应的信物风格
        let recommendedStyle = recommendedArtifactStyle(for: dataManager.settings.todayHubStyle)
        
        // 如果当前默认信物风格与推荐不一致，临时设置为推荐风格
        // 这样中Tab入口和最终信物就完全统一了
        let originalStyle = dataManager.settings.preferredArtifactStyle
        if originalStyle != recommendedStyle {
            dataManager.settings.preferredArtifactStyle = recommendedStyle
        }
        
        // V2.0: 总是允许创建新记录，不限制次数
        triggerNewRecordFlow()
        
        // 可选：记录完成后恢复原风格（如果需要）
        // 或者保持推荐风格，让用户看到入口和信物的一致性
    }
    
    // 辅助方法：根据入口风格推荐信物风格
    private func recommendedArtifactStyle(for hubStyle: TodayHubStyle) -> RitualStyle {
        switch hubStyle {
        // 影像类入口 → 影像类信物
        case .polaroidCamera:
            return .polaroid
        case .leicaCamera:
            return .developedPhoto // 使用冲洗照片替代胶片底片
        
        // 书信类入口 → 书信类信物
        case .waxEnvelope:
            return .envelope
        case .waxStamp:
            return .envelope
        
        // 收藏类入口 → 收藏类信物
        case .jewelryBox:
            return .vinylRecord
        
        // 其他入口的智能推荐
        case .simple:
            return .envelope
        case .vault:
            return .journalPage
        case .typewriter:
            return .journalPage
        case .safari:
            return .postcard
        case .aurora:
            return .developedPhoto
        case .astrolabe:
            return .pressedFlower
        case .omikuji:
            return .bookmark
        case .hourglass:
            return .thermal // 使用热敏小票替代车票
        }
    }
    
    private func handleExistingRecordTap() {
        if let today = todayRecord {
            selectedRecord = today
        } else {
            triggerNewRecordFlow()
        }
    }
    
    private func triggerNewRecordFlow() {
        if requiresCameraShortcut {
            showingCustomCamera = true
        } else {
            showingNewRecord = true
        }
    }
    
    private var requiresCameraShortcut: Bool {
        dataManager.settings.todayHubStyle == .leicaCamera || dataManager.settings.todayHubStyle == .polaroidCamera
    }
    
    // MARK: - 今日一言 - 参考 HTML 设计优化
    
    private var dailyQuoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标签
            HStack {
                Text("📖 今日一言")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("PrimaryWarm"))
                
                Spacer()
                
                // 刷新按钮（可选）
                Button {
                    // V3.5.1 修改：每次点击都更换名言
                    withAnimation(.spring()) {
                        quotesManager.updateTodayQuote(category: dataManager.settings.quoteCategory)
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary").opacity(0.6))
                }
            }
            
            // 引言内容
            Text("「\(quotesManager.todayQuote.text)」")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(6)
                .italic()
            
            // 来源
            Text("— \(quotesManager.todayQuote.source)")
                .font(.system(size: 13, design: .serif))
                .foregroundColor(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 快捷入口 - 参考 HTML 设计
    
    private var quickActionsSection: some View {
        HStack(spacing: 15) {
            // 时光机
            QuickActionButton(
                icon: "clock.arrow.circlepath",
                emoji: "⏳",
                label: "时光机",
                badge: nil
            ) {
                showingTimeCapsule = true
            }
            
            // 待拆封
            let pendingCount = dataManager.pendingToOpenCount
            QuickActionButton(
                icon: "envelope.badge",
                emoji: "📬",
                label: "待拆封",
                badge: pendingCount > 0 ? "\(pendingCount)" : nil
            ) {
                showingPendingList = true
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - 大按钮样式

// MARK: - 快捷按钮 - 参考 HTML 设计优化
struct QuickActionButton: View {
    let icon: String
    let emoji: String
    let label: String
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    // 使用 emoji 更有亲和力
                    Text(emoji)
                        .font(.system(size: 28))
                    
                    // 角标
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Color("SealColor"))
                            .clipShape(Circle())
                            .offset(x: 10, y: -5)
                    }
                }
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color("CardBackground"))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(TodayScaleButtonStyle())
    }
}

// MARK: - 待拆封列表

struct PendingRecordsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedRecord: DayRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()
                
                List {
                    let pending = dataManager.sealedRecordsToOpen()
                    
                    if pending.isEmpty {
                        VStack(spacing: 16) {
                            Text("📭")
                                .font(.system(size: 56))
                            
                            Text("暂无待拆封的记录")
                                .font(.system(size: 16))
                                .foregroundColor(Color("TextSecondary"))
                            
                            Text("所有记录都可以立即查看")
                                .font(.system(size: 13))
                                .foregroundColor(Color("TextSecondary").opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(pending) { record in
                            PendingRecordRow(record: record)
                                .onTapGesture {
                                    selectedRecord = record
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("待拆封")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(Color("PrimaryWarm"))
                }
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
}

struct PendingRecordRow: View {
    let record: DayRecord
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 信封图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("PrimaryWarm").opacity(0.15), Color("SealColor").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color("PrimaryWarm"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.formattedDate)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                HStack(spacing: 6) {
                    Text("可以拆开了")
                        .font(.system(size: 13))
                        .foregroundColor(Color("PrimaryWarm"))
                    
                    Circle()
                        .fill(Color("PrimaryWarm"))
                        .frame(width: 6, height: 6)
                }
            }
            
            Spacer()
            
            Text(record.mood.emoji)
                .font(.system(size: 28))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextSecondary").opacity(0.5))
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            withAnimation(.spring(response: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - 按钮样式

struct TodayScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}



#Preview {
    TodayView()
        .environmentObject(DataManager())
        .environmentObject(QuotesManager())
}

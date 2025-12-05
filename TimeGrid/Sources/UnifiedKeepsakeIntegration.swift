//
//  UnifiedKeepsakeIntegration.swift
//  时光格 - 统一信物系统整合示例
//
//  展示如何在现有项目中使用统一系统
//

import SwiftUI

// MARK: - ============================================
// MARK: - 核心整合：TodayHubView 使用统一入口
// MARK: - ============================================

/// 新版 TodayHubView - 使用统一的信物入口
struct UnifiedTodayHubView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showStylePicker = false
    @State private var showRecordView = false

    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#F5F0E8").ignoresSafeArea()

            VStack(spacing: 30) {
                // 顶部：样式名称 + 切换按钮
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dataManager.selectedKeepsakeStyle.displayName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "#2C2C2C"))

                        Text(dataManager.selectedKeepsakeStyle.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                    }

                    Spacer()

                    // 切换样式按钮
                    Button {
                        showStylePicker = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#D4A574"))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // 核心：统一的信物入口
                KeepsakeHubEntry(style: dataManager.selectedKeepsakeStyle) {
                    showRecordView = true
                }

                Spacer()

                // 底部提示
                Text("点击开始记录")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#B8B8B8"))
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showStylePicker) {
            KeepsakeStylePicker(selectedStyle: $dataManager.selectedKeepsakeStyle)
        }
        .fullScreenCover(isPresented: $showRecordView) {
            // 进入记录流程，传入选中的样式
            UnifiedRecordView(style: selectedStyle)
        }
    }
}

// MARK: - ============================================
// MARK: - 记录流程：保持样式一致
// MARK: - ============================================

/// 记录视图 - 根据选中样式展示对应界面
struct UnifiedRecordView: View {
    let style: UnifiedKeepsakeStyle
    @Environment(\.dismiss) var dismiss

    @State private var content = ""
    @State private var selectedMood: Mood = .peaceful
    @State private var selectedPhoto: UIImage?
    @State private var showPhotoOptions = false
    @State private var showPreview = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色跟随信物主题
                style.primaryColor.opacity(0.1).ignoresSafeArea()

                VStack(spacing: 24) {
                    // 头部：样式标识
                    styleHeader

                    // 内容输入
                    contentEditor

                    // 心情选择
                    moodPicker

                    // 照片（如果该样式支持）
                    if styleSupportsPhoto {
                        photoSection
                    }

                    Spacer()

                    // 预览 & 保存
                    actionButtons
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(Color(hex: "#8B8B8B"))
                }

                ToolbarItem(placement: .principal) {
                    Text(style.displayName)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showPreview) {
                KeepsakePreviewSheet(
                    style: style,
                    content: content,
                    mood: selectedMood,
                    photo: selectedPhoto,
                    onSave: saveRecord
                )
            }
        }
    }

    // MARK: - 子视图

    private var styleHeader: some View {
        HStack(spacing: 12) {
            // 样式图标
            ZStack {
                Circle()
                    .fill(style.primaryColor)
                    .frame(width: 48, height: 48)

                Image(systemName: style.icon)
                    .font(.system(size: 22))
                    .foregroundColor(style.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("正在创建")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8B8B8B"))
                Text(style.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#2C2C2C"))
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private var contentEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("写下此刻的心情")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8B8B8B"))

            TextEditor(text: $content)
                .font(.system(size: 16))
                .frame(minHeight: 120)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    Group {
                        if content.isEmpty {
                            Text(placeholderText)
                                .foregroundColor(Color(hex: "#C0C0C0"))
                                .padding(.leading, 16)
                                .padding(.top, 20)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今天的心情")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8B8B8B"))

            HStack(spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: 28))
                            Text(mood.label)
                                .font(.system(size: 10))
                                .foregroundColor(selectedMood == mood ? style.accentColor : Color(hex: "#8B8B8B"))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedMood == mood ? style.primaryColor.opacity(0.3) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMood == mood ? style.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("添加照片（可选）")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8B8B8B"))

            Button {
                showPhotoOptions = true
            } label: {
                if let photo = selectedPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            // 删除按钮
                            Button {
                                selectedPhoto = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                            .padding(8),
                            alignment: .topTrailing
                        )
                } else {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 24))
                        Text("点击添加照片")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(hex: "#B8B8B8"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                            .foregroundColor(Color(hex: "#D0D0D0"))
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // 预览按钮
            Button {
                showPreview = true
            } label: {
                HStack {
                    Image(systemName: "eye")
                    Text("预览")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(style.accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(style.accentColor, lineWidth: 1)
                )
            }

            // 保存按钮
            Button {
                saveRecord()
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark")
                        Text("保存")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [style.accentColor, style.primaryColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .disabled(content.isEmpty || isSaving)
            .opacity(content.isEmpty ? 0.6 : 1)
        }
    }

    // MARK: - 辅助属性

    private var styleSupportsPhoto: Bool {
        switch style {
        case .polaroid, .leicaFilm, .filmRoll, .postcard:
            return true
        default:
            return false
        }
    }

    private var placeholderText: String {
        switch style {
        case .polaroid: return "记录这个瞬间..."
        case .leicaFilm: return "捕捉光影..."
        case .filmRoll: return "等待显影的故事..."
        case .movieTicket: return "今天看了什么电影..."
        case .trainTicket: return "旅途中的风景..."
        case .concertTicket: return "现场的感动..."
        case .waxEnvelope: return "想说的话..."
        case .postcard: return "寄给远方的问候..."
        case .journalPage: return "亲爱的日记..."
        case .vinylRecord: return "此刻的旋律..."
        case .bookmark: return "书中的感悟..."
        case .pressedFlower: return "自然的馈赠..."
        }
    }

    // MARK: - 方法

    private func saveRecord() {
        isSaving = true

        // TODO: 实际保存逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - ============================================
// MARK: - 预览弹窗：展示最终信物效果
// MARK: - ============================================

struct KeepsakePreviewSheet: View {
    let style: UnifiedKeepsakeStyle
    let content: String
    let mood: Mood
    let photo: UIImage?
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var showSealAnimation = false

    var body: some View {
        ZStack {
            Color(hex: "#F5F0E8").ignoresSafeArea()

            VStack(spacing: 30) {
                Text("预览效果")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#2C2C2C"))

                Spacer()

                // 统一的信物卡片
                UnifiedKeepsakeCard(
                    style: style,
                    content: content,
                    date: Date(),
                    mood: mood,
                    photo: photo
                )
                .scaleEffect(0.85)

                Spacer()

                // 操作按钮
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                    } label: {
                        Text("继续编辑")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                            .frame(width: 120, height: 48)
                            .background(Color.white)
                            .cornerRadius(24)
                    }

                    Button {
                        showSealAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            onSave()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("确认保存")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 140, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#D4A574"), Color(hex: "#C49A6C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(24)
                    }
                }
                .padding(.bottom, 40)
            }

            // 封存动画
            if showSealAnimation {
                SealingAnimation(style: style)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - ============================================
// MARK: - 封存动画（与样式统一）
// MARK: - ============================================

struct SealingAnimation: View {
    let style: UnifiedKeepsakeStyle

    @State private var scale: CGFloat = 2
    @State private var opacity: Double = 0
    @State private var rotation: Double = -30

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                // 样式图标
                ZStack {
                    Circle()
                        .fill(style.primaryColor)
                        .frame(width: 100, height: 100)

                    Image(systemName: style.icon)
                        .font(.system(size: 44))
                        .foregroundColor(style.accentColor)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)

                Text("封存成功")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text(style.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            // 震动反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // 动画
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1
                opacity = 1
                rotation = 0
            }
        }
    }
}

// MARK: - ============================================
// MARK: - 主入口：三Tab整合示例
// MARK: - ============================================

struct UnifiedMainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 1 // 0=左, 1=中, 2=右

    var body: some View {
        TabView(selection: $selectedTab) {
            // 左Tab - 历史记录（使用统一卡片展示）
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("时光")
                }
                .tag(0)

            // 中Tab - 今日入口（统一入口样式）
            UnifiedTodayHubView(selectedStyle: $dataManager.selectedKeepsakeStyle)
                .tabItem {
                    Image(systemName: dataManager.selectedKeepsakeStyle.icon)
                    Text(dataManager.selectedKeepsakeStyle.displayName)
                }
                .tag(1)

            // 右Tab - 设置/样式选择
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("设置")
                }
                .tag(2)
        }
        .tint(Color(hex: "#D4A574"))
    }
}

// MARK: - 占位视图

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 30) {
                    // V5.0: 展示历史记录使用当前选中的信物风格
                    ForEach(0..<5) { i in
                        UnifiedKeepsakeCard(
                            style: dataManager.selectedKeepsakeStyle,
                            content: "这是第\(i+1)条记录的内容...",
                            date: Date().addingTimeInterval(TimeInterval(-i * 86400)),
                            mood: Mood.allCases[i % Mood.allCases.count],
                            photo: nil
                        )
                        .scaleEffect(0.8)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#F5F0E8"))
            .navigationTitle("时光记录")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showStylePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section("信物样式") {
                    Button {
                        showStylePicker = true
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(dataManager.selectedKeepsakeStyle.primaryColor)
                                    .frame(width: 40, height: 40)
                                Image(systemName: dataManager.selectedKeepsakeStyle.icon)
                                    .foregroundColor(dataManager.selectedKeepsakeStyle.accentColor)
                            }

                            VStack(alignment: .leading) {
                                Text(dataManager.selectedKeepsakeStyle.displayName)
                                    .foregroundColor(.primary)
                                Text(dataManager.selectedKeepsakeStyle.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("其他设置") {
                    Text("提醒时间")
                    Text("云同步")
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showStylePicker) {
                KeepsakeStylePicker(selectedStyle: $dataManager.selectedKeepsakeStyle)
            }
        }
    }
}

// MARK: - ============================================
// MARK: - 预览
// MARK: - ============================================

#Preview("主界面") {
    UnifiedMainView()
}

#Preview("TodayHub") {
    UnifiedTodayHubView()
        .environmentObject(DataManager())
}

#Preview("记录流程") {
    UnifiedRecordView(style: .movieTicket)
}

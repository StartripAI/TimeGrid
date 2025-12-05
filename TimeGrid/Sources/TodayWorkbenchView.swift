import SwiftUI

// MARK: - 皇家工坊工作台 (The Atelier Dashboard)
// 核心：今日信物的展示台 + 发片台 + 高定入口

struct TodayWorkbenchView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var themeEngine = ThemeEngine.shared
    @State private var showingThemePicker = false
    @State private var showThemeInfo = false
    @State private var themeInfoOpacity: Double = 0
    @State private var selectedCardIndex: Int = 0
    
    // 获取今天的所有记录（按时间倒序，最新的在前）
    private var todayRecords: [DayRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return dataManager.records.filter { record in
            calendar.isDate(record.date, inSameDayAs: today)
        }.sorted { record1, record2 in
            // 优先按sealedAt排序（如果有），否则按id（UUID按时间生成）排序
            if let sealed1 = record1.sealedAt, let sealed2 = record2.sealedAt {
                return sealed1 > sealed2
            } else if record1.sealedAt != nil {
                return true
            } else if record2.sealedAt != nil {
                return false
            } else {
                // 如果都没有sealedAt，按UUID排序（UUID包含时间戳信息）
                return record1.id.uuidString > record2.id.uuidString
            }
        }
    }
    
    // 获取当前选中的记录
    private var currentRecord: DayRecord? {
        guard !todayRecords.isEmpty, selectedCardIndex < todayRecords.count else {
            return nil
        }
        return todayRecords[selectedCardIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🔥 使用全局主题背景
                themeEngine.currentTheme.backgroundView
                    .ignoresSafeArea()
                
                // 内容层
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 1. 日期显示（在信物上方）
                    Text(Date().formatted(.dateTime.year().month().day().weekday(.wide)))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeEngine.currentTheme.textColor)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    
                    // 2. 当前主题信息（带淡入淡出动画）
                    if showThemeInfo {
                        VStack(spacing: 8) {
                            Text(themeEngine.currentTheme.workshopName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeEngine.currentTheme.textColor)
                            
                            Text(themeEngine.currentTheme.description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(themeEngine.currentTheme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .opacity(themeInfoOpacity)
                        .transition(.opacity)
                        .padding(.bottom, 20)
                    }
                    
                    // 3. 信物展示（叠加显示，类似扑克牌）
                    if !todayRecords.isEmpty {
                        GeometryReader { geo in
                            ZStack {
                                // 叠加的信物卡片（从后往前绘制）
                                ForEach(Array(todayRecords.enumerated().reversed()), id: \.element.id) { index, record in
                                    CardStackItem(
                                        record: record,
                                        index: index,
                                        selectedIndex: selectedCardIndex,
                                        totalCount: todayRecords.count,
                                        maxWidth: min(geo.size.width * 0.85, 400)
                                    )
                                    .offset(
                                        x: index < selectedCardIndex ? CGFloat(selectedCardIndex - index) * 8 : 0,
                                        y: index < selectedCardIndex ? CGFloat(selectedCardIndex - index) * 12 : 0
                                    )
                                    .scaleEffect(index == selectedCardIndex ? 1.0 : 0.95 - CGFloat(abs(selectedCardIndex - index)) * 0.05)
                                    .zIndex(Double(todayRecords.count - index))
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCardIndex = index
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .gesture(
                                DragGesture(minimumDistance: 50)
                                    .onEnded { value in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            if value.translation.width > 50 && selectedCardIndex > 0 {
                                                selectedCardIndex -= 1
                                            } else if value.translation.width < -50 && selectedCardIndex < todayRecords.count - 1 {
                                                selectedCardIndex += 1
                                            }
                                        }
                                    }
                            )
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // 如果没有记录，显示占位提示
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(themeEngine.currentTheme.accentColor.opacity(0.5))
                            Text("还没有今天的信物")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeEngine.currentTheme.secondaryTextColor)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    
                    Spacer()
                    
                    // 4. 主题选择按钮（在信物下方）
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 16))
                            Text("选择工坊主题")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(themeEngine.currentTheme.textColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeEngine.currentTheme.accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeEngine.currentTheme.accentColor.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingThemePicker = true
                    } label: {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(themeEngine.currentTheme.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView(onThemeSelected: {
                // 主题选择后的回调
                showThemeInfo = true
                themeInfoOpacity = 1.0
                
                // 3秒后开始淡出
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        themeInfoOpacity = 0
                    }
                    
                    // 淡出完成后隐藏
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showThemeInfo = false
                    }
                }
            })
        }
        .onChange(of: themeEngine.currentTheme) { oldTheme, newTheme in
            // 主题变化时显示信息
            if oldTheme != newTheme {
                showThemeInfo = true
                themeInfoOpacity = 1.0
                
                // 3秒后开始淡出
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        themeInfoOpacity = 0
                    }
                    
                    // 淡出完成后隐藏
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showThemeInfo = false
                    }
                }
            }
        }
        .onChange(of: todayRecords.count) { oldCount, newCount in
            // 当有新记录添加时，自动选中最新的（索引0）
            if newCount > oldCount {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedCardIndex = 0
                }
            }
        }
    }
}

// MARK: - 主题选择器
struct ThemePickerView: View {
    @ObservedObject var themeEngine = ThemeEngine.shared
    @Environment(\.dismiss) var dismiss
    var onThemeSelected: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("选择工坊主题")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(LuxuryTheme.allCases) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: themeEngine.currentTheme == theme
                            ) {
                                themeEngine.switchTheme(to: theme)
                                onThemeSelected?()
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("工坊主题")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryWarm"))
                }
            }
        }
    }
}

// MARK: - 主题卡片
struct ThemeCard: View {
    let theme: LuxuryTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 预览背景
                theme.backgroundView
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.accentColor)
                                    .background(Circle().fill(.white))
                                    .font(.system(size: 24))
                                    .offset(x: 50, y: -50)
                            }
                        }
                    )
                
                VStack(spacing: 4) {
                    Text(theme.chineseName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(theme.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : Color("CardBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 叠加卡片组件
struct CardStackItem: View {
    let record: DayRecord
    let index: Int
    let selectedIndex: Int
    let totalCount: Int
    let maxWidth: CGFloat
    
    private var isTopCard: Bool {
        index == selectedIndex
    }
    
    private var cardOffset: CGFloat {
        // 计算卡片偏移量（类似扑克牌效果）
        let offset = CGFloat(selectedIndex - index)
        return max(0, offset)
    }
    
    private var cardRotation: Double {
        // 轻微旋转效果
        let offset = CGFloat(selectedIndex - index)
        return offset > 0 ? Double(offset) * 2.0 : 0
    }
    
    var body: some View {
        Group {
            if isTopCard {
                // 顶层卡片：完整显示
                                StyledArtifactView(record: record)
                    .frame(maxWidth: maxWidth)
                    .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.85)  // iPad 1.0x, iPhone 0.85x
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            } else if cardOffset > 0 && cardOffset <= 3 {
                // 下层卡片：只显示顶部（类似扑克牌只看到数字）
                ZStack(alignment: .top) {
                    // 卡片背景（模糊，只显示顶部）
                    StyledArtifactView(record: record)
                        .frame(maxWidth: maxWidth)
                        .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.85)  // iPad 1.0x, iPhone 0.85x
                        .blur(radius: 1)
                        .opacity(0.5)
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // 顶部日期标签（类似扑克牌的数字）
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                // 显示日期和时间（类似扑克牌的数字）
                                Text(record.shortDate)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                // 显示时间（如果有）
                                if let sealedAt = record.sealedAt {
                                    Text(sealedAt.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.75))
                            )
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                }
                .frame(height: 90) // 只显示顶部90点高度
                .cornerRadius(12, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .rotationEffect(.degrees(cardRotation))
            }
        }
        .opacity(cardOffset <= 3 ? 1.0 : 0.0)
    }
}

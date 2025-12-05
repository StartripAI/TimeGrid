//
//  ProfileView.swift
//  一格 V3.0 - 右Tab: 我的时光（统计+设置）
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    @ObservedObject var themeEngine = ThemeEngine.shared // 🔥 观察主题变化
    @State private var showingCustomTemplate = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 统计卡片
                    statsCard
                    
                    // 心情趋势
                    moodTrendCard
                    
                    // 记录样式选择
                    recordStyleSection
                    
                    // 设置区域
                    settingsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(themeEngine.currentTheme.backgroundView.ignoresSafeArea())
            .navigationTitle("我的时光")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCustomTemplate) {
                NavigationStack {
                    CustomTemplateEditorView()
                    }
        }
    }
    }
    
    // MARK: - 统计卡片
    
    private var statsCard: some View {
        StatsCardView(dataManager: dataManager)
    }
    
    // MARK: - 心情趋势
    
    private var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("😊 近7天心情")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            let stats = dataManager.moodStatistics(days: 7)
            
            if stats.recentMoods.isEmpty {
                Text("暂无数据，开始记录吧")
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                // 心情柱状图
                MoodChartView(moods: stats.recentMoods)
                
                // 平均心情
                HStack {
                    Text("平均心情指数")
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", stats.averageScore))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("PrimaryWarm"))
                        
                        Text("/ 5")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - V4.0 信物风格选择（简化：移除重复的横向滚动，统一使用导航链接）
    
    private var recordStyleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    showingCustomTemplate = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 14))
                        Text("自定义模板")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color("PrimaryWarm"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("PrimaryWarm").opacity(0.1))
                    .cornerRadius(16)
                }

                Spacer()
                
                Text("🪄 信物风格")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                NavigationLink {
                    ArtifactStylePickerView()
                } label: {
                    HStack(spacing: 4) {
                        Text(dataManager.settings.preferredArtifactStyle.label)
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
            
            Text("选择您喜欢的时光凭证样式")
                .font(.system(size: 12))
                .foregroundColor(Color("TextSecondary"))
            
            // 🔥 修复：移除重复的横向滚动选择器，统一使用导航链接进入详细选择页面
            // 显示当前选择的样式预览
            HStack {
                Text(dataManager.settings.preferredArtifactStyle.emoji)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataManager.settings.preferredArtifactStyle.label)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("点击右侧箭头查看更多样式")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color("CardBackground").opacity(0.5))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - 设置区域
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            // 今日一言
            SettingToggleRow(
                icon: "📖",
                title: "今日一言",
                subtitle: dataManager.settings.quoteCategory.label,
                isOn: $dataManager.settings.dailyQuoteEnabled
            )
            
            Divider().padding(.leading, 60)
            
            // V4.0: 首页入口风格设置
            NavigationLink {
                HubStylePickerView()
            } label: {
                SettingNavigationRow(
                    icon: "✨",
                    title: "首页交互风格 (入口)",
                    value: dataManager.settings.todayHubStyle.rawValue
                )
            }
            
            Divider().padding(.leading, 60)
            
            // V4.0: 信物默认风格设置
            NavigationLink {
                ArtifactStylePickerView()
            } label: {
                SettingNavigationRow(
                    icon: "🪄",
                    title: "信物默认风格 (输出)",
                    value: dataManager.settings.preferredArtifactStyle.rawValue
                )
            }
            
            Divider().padding(.leading, 60)
            
            // 今日一言类别
            if dataManager.settings.dailyQuoteEnabled {
                SettingPickerRow(
                    icon: "🎭",
                    title: "一言类别",
                    selection: $dataManager.settings.quoteCategory
                )
                
                Divider().padding(.leading, 60)
            }
            
            // 每日提醒
            SettingToggleRow(
                icon: "🔔",
                title: "每日提醒",
                subtitle: formatTime(dataManager.settings.notificationTime),
                isOn: $dataManager.settings.notificationEnabled
            )
            
            Divider().padding(.leading, 60)
            
            // 提醒时间
            if dataManager.settings.notificationEnabled {
                SettingTimeRow(
                    icon: "⏰",
                    title: "提醒时间",
                    time: $dataManager.settings.notificationTime
                )
                
                Divider().padding(.leading, 60)
            }
            
            // 关于
            NavigationLink {
                AboutView()
            } label: {
                SettingNavigationRow(
                    icon: "ℹ️",
                    title: "关于一格",
                    value: "V3.0"
                )
            }
        }
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - 包装器视图（解决类型推断问题）
    
    @ViewBuilder
    private var timelineViewWrapper: some View {
        NavigationStack {
            TimelineView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var customTemplateViewWrapper: some View {
        NavigationStack {
            CustomTemplateEditorView()
        }
    }
}

// MARK: - 统计卡片视图
struct StatsCardView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: Date())
        let recordsThisMonth = dataManager.records(for: Date()).filter { $0.isSealed }.count
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("📈 时光统计")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            HStack(spacing: 0) {
                StatItemView(value: "\(dataManager.totalRecords)", label: "总记录")
                
                Divider()
                    .frame(height: 40)
                
                StatItemView(value: "\(dataManager.streakDays)", label: "连续天数")
                
                Divider()
                    .frame(height: 40)
                
                StatItemView(value: "\(Int(dataManager.thisMonthCompletionRate * 100))%", label: "本月完成")
            }
            
            // 进度条
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("本月记录进度")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                    
                    Text("\(recordsThisMonth)/\(dayOfMonth)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("TextSecondary").opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color("PrimaryWarm"), Color("SealColor")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(dataManager.thisMonthCompletionRate), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    }

// MARK: - 统计项

struct StatItemView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryWarm"))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 心情图表

struct MoodChartView: View {
    let moods: [(date: Date, mood: Mood)]
    
    var body: some View {
        VStack(spacing: 8) {
            // 柱状图
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    if index < moods.count {
                        let item = moods[index]
                        MoodBar(mood: item.mood, height: CGFloat(item.mood.score) / 5.0)
                    } else {
                        MoodBar(mood: .neutral, height: 0, isEmpty: true)
                    }
                }
            }
            .frame(height: 80)
            
            // 日期标签
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    if index < moods.count {
                        Text(dayLabel(for: moods[index].date))
                            .font(.system(size: 10))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("-")
                            .font(.system(size: 10))
                            .foregroundColor(Color("TextSecondary").opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        }
        let weekday = calendar.component(.weekday, from: date)
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return "周\(weekdays[weekday - 1])"
    }
    
    // MARK: - 包装器视图（解决类型推断问题）
    
    @ViewBuilder
    private var timelineViewWrapper: some View {
        NavigationStack {
            TimelineView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var customTemplateViewWrapper: some View {
        NavigationStack {
            CustomTemplateEditorView()
        }
    }
}

struct MoodBar: View {
    let mood: Mood
    let height: CGFloat
    var isEmpty: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if isEmpty {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("TextSecondary").opacity(0.1))
                    .frame(height: 20)
            } else {
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.system(size: 14))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(moodColor)
                        .frame(height: max(20, 60 * height))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var moodColor: Color {
        switch mood {
        case .joyful: return Color.yellow
        case .peaceful: return Color.green
        case .neutral: return Color.gray
        case .tired: return Color.purple
        case .sad: return Color.blue
        }
    }
}

// MARK: - 设置行组件

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color("PrimaryWarm"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

struct SettingPickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: QuoteCategory
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.label).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("PrimaryWarm"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

struct SettingTimeRow: View {
    let icon: String
    let title: String
    @Binding var time: Date
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
            
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

struct SettingNavigationRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - 关于页面

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Logo
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color("PrimaryWarm"), Color("SealColor")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("一")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("一格")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("每日一格，封存时光")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                    
                    Text("V3.0")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color("TextSecondary").opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.top, 40)
                
                // 介绍
                VStack(alignment: .leading, spacing: 16) {
                    Text("关于")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("""
                    一格是一款有仪式感的生活记录应用。

                    像圣诞节的倒数日历一样，每天记录一格，封存当下的心情。过些日子再拆开，回味那些被时光温柔包裹的记忆。

                    • 倒数日历：期待每一个特别的日子
                    • 封存仪式：为今天盖上印章
                    • 延时满足：24小时后才能拆开
                    • 时光洞察：看见情绪的变化

                    不必长篇大论，几句话、一张照片，足矣。
                    """)
                        .font(.system(size: 15))
                        .foregroundColor(Color("TextSecondary"))
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color("BackgroundCream").ignoresSafeArea())
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 信物风格卡片

struct RitualStyleCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // 图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color("PrimaryWarm").opacity(0.15) : Color("TextSecondary").opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextSecondary"))
                }
                
                // 名称
                Text(style.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? Color("PrimaryWarm") : Color("TextPrimary"))
                
                // 描述
                Text(style.description)
                    .font(.system(size: 9))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 95, height: 120)
            .padding(10)
            .background(isSelected ? Color("PrimaryWarm").opacity(0.08) : Color("BackgroundCream"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color("PrimaryWarm") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
}
}

#Preview {
    ProfileView()
        .environmentObject(DataManager())
        .environmentObject(QuotesManager())
}


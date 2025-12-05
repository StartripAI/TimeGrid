//
//  TimelineView.swift
//  时光格 - 时间线视图（类似Instagram/朋友圈）
//
//  功能：分类筛选、时间线展示、分组显示

import SwiftUI
import UIKit

struct TimelineView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var quotesManager: QuotesManager
    @ObservedObject var themeEngine = ThemeEngine.shared // 🔥 观察主题变化
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showingFilters = false
    @State private var showingTimeCapsule = false
    @State private var showingPendingList = false
    
    private var filteredRecords: [DayRecord] {
        viewModel.filteredRecords(from: dataManager.records)
    }
    
    private var timelineSections: [TimelineSection] {
        viewModel.sections(from: dataManager.records)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeEngine.currentTheme.backgroundView
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        if dataManager.settings.dailyQuoteEnabled {
                            dailyQuoteCard
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        }
                        
                        if filteredRecords.isEmpty {
                            emptyStateView
                        } else {
                            categoryFilterBar
                                .padding(.horizontal, 16)
                            
                            timelineList
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("时光")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button { showingTimeCapsule = true } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(Color("PrimaryWarm"))
                        }
                        
                        let pendingCount = dataManager.pendingToOpenCount
                        Button { showingPendingList = true } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "envelope.badge")
                                    .foregroundColor(Color("PrimaryWarm"))
                                
                                if pendingCount > 0 {
                                    Text("\(pendingCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color("PrimaryWarm"))
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingFilters = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundColor(viewModel.hasActiveFilters ? Color("PrimaryWarm") : Color.white.opacity(0.6))
                            
                            if viewModel.hasActiveFilters {
                                Circle()
                                    .fill(Color("PrimaryWarm"))
                                    .frame(width: 6, height: 6)
                                    .offset(x: -8, y: -8)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                TimelineFiltersView(
                    selectedCategory: $viewModel.selectedCategory,
                    selectedMood: $viewModel.selectedMood,
                    selectedStyle: $viewModel.selectedStyle
                )
            }
            .sheet(isPresented: $showingTimeCapsule) {
                TimeCapsuleView()
            }
            .sheet(isPresented: $showingPendingList) {
                PendingRecordsView()
            }
        }
    }
    
    private var timelineList: some View {
        ForEach(timelineSections) { section in
            ForEach(Array(section.records.enumerated()), id: \.element.id) { index, record in
                TimelineDayRow(
                    record: record,
                    dateKey: section.label,
                    showDate: index == 0
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }
    
    // 分类筛选栏（优化：显示当前筛选状态）
    private var categoryFilterBar: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimelineCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.title,
                            icon: category.icon,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedCategory = category
                                if category != .byStyle {
                                    viewModel.selectedStyle = nil
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            if viewModel.hasActiveFilters {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("PrimaryWarm"))
                    
                    Text(viewModel.activeFiltersDescription)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.clearFilters()
                        }
                    } label: {
                        Text("清除")
                            .font(.system(size: 12))
                            .foregroundColor(Color("PrimaryWarm"))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }
    
    // 空状态
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(Color("PrimaryOrange").opacity(0.6))
            
            Text(viewModel.selectedCategory == .all ? "还没有记录呢" : "没有符合条件的记录")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            Text("切换到今日Tab开始记录吧")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 今日一言卡片
    private var dailyQuoteCard: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .blur(radius: 1)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundColor(Color("PrimaryWarm"))
                        Text("今日一言")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        Spacer()
                    }
                    
                    Text("\"\(quotesManager.todayQuote.text)\"")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("—— \(quotesManager.todayQuote.source)")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 缓存

private enum TimelineImageCache {
    static let shared: NSCache<NSData, UIImage> = {
        let cache = NSCache<NSData, UIImage>()
        cache.countLimit = 300
        cache.totalCostLimit = 200 * 1024 * 1024
        return cache
    }()
}

// MARK: - 时间线分类

enum TimelineCategory: String, CaseIterable {
    case all = "全部"
    case withPhotos = "有照片"
    case withMood = "有心情"
    case byStyle = "按风格"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .withPhotos: return "photo"
        case .withMood: return "heart"
        case .byStyle: return "paintpalette"
        }
    }
}

// MARK: - 时光行视图（一行一天，结构化显示）

struct TimelineDayRow: View {
    let record: DayRecord
    let dateKey: String
    let showDate: Bool // 是否显示日期
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                if showDate {
                    Text(dateKey)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 60, alignment: .leading)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 20)
                }
                
                HStack(spacing: 4) {
                    Text(record.mood.emoji)
                        .font(.system(size: 16))
                    if let weather = record.weather {
                        Image(systemName: weather.icon)
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .frame(width: 60, alignment: .leading)
            }
            .frame(width: 80)
            
            VStack(alignment: .leading, spacing: 8) {
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("无文字内容")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                        .italic()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                NavigationLink(destination: DayDetailView(date: record.date)) {
                    StyledArtifactView(record: record)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                
                if !record.photos.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(record.photos.prefix(3).enumerated()), id: \.offset) { _, photoData in
                            if let uiImage = cachedImage(for: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        if record.photos.count > 3 {
                            Text("+\(record.photos.count - 3)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .frame(width: 140, alignment: .trailing)
        }
        .padding(16)
        .background(Color("CardBackground").opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func cachedImage(for data: Data) -> UIImage? {
        let nsData = data as NSData
        if let cached = TimelineImageCache.shared.object(forKey: nsData) {
            return cached
        }
        guard let image = UIImage(data: data) else { return nil }
        TimelineImageCache.shared.setObject(image, forKey: nsData)
        return image
    }
}

// MARK: - 时光信物卡片

struct TimelineArtifactCard: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            StyledArtifactView(record: record)
                .frame(height: 200)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
            
            VStack {
                Spacer()
                HStack {
                    Text(record.formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    Spacer()
                }
                .padding(12)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - 时间线记录卡片 (V4.2 重构：大卡片 Feed 流风格)

struct TimelineRecordCard: View {
    let record: DayRecord
    
    var body: some View {
        NavigationLink(destination: RecordDetailView(record: record)) {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(spacing: 0) {
                        Text(record.shortDate.split(separator: ".")[1])
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                        Text(record.shortDate.split(separator: ".")[0] + "月")
                            .font(.system(size: 10))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .frame(width: 44, height: 44)
                    .background(Color("PrimaryWarm").opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatTime(record.date))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                        
                        HStack(spacing: 6) {
                            if let weather = record.weather {
                                Label(weather.label, systemImage: weather.icon)
                                    .font(.system(size: 11))
                            }
                            Text("•")
                                .font(.system(size: 10))
                            Text(record.mood.label)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Spacer()
                    
                    Text(record.mood.emoji)
                        .font(.system(size: 28))
                }
                .padding(16)
                
                VStack(spacing: 12) {
                    ZStack {
                        Color("BackgroundCream").opacity(0.5)
                        
                        StyledArtifactView(record: record)
                            .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.95)
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 360 : 340)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    if !record.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                                    if let uiImage = cachedImage(for: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextPrimary"))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: record.artifactStyle.icon)
                        Text(record.artifactStyle.rawValue)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Color("PrimaryWarm"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("PrimaryWarm").opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Text("点击查看详情")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary").opacity(0.8))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary").opacity(0.8))
                }
                .padding(16)
            }
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private func formatTime(_ date: Date) -> String {
        TimelineFormatters.sectionTime.string(from: date)
    }
    
    private func cachedImage(for data: Data) -> UIImage? {
        let nsData = data as NSData
        if let cached = TimelineImageCache.shared.object(forKey: nsData) {
            return cached
        }
        guard let image = UIImage(data: data) else { return nil }
        TimelineImageCache.shared.setObject(image, forKey: nsData)
        return image
    }
}

// MARK: - 分类芯片

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color("PrimaryWarm") : Color("CardBackground")
            )
            .cornerRadius(20)
        }
    }
}

// MARK: - 筛选视图

struct TimelineFiltersView: View {
    @Binding var selectedCategory: TimelineCategory
    @Binding var selectedMood: Mood?
    @Binding var selectedStyle: RitualStyle?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("分类筛选") {
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(TimelineCategory.allCases, id: \.self) { category in
                            Label(category.title, systemImage: category.icon).tag(category)
                        }
                    }
                }
                
                Section("心情筛选") {
                    Picker("心情", selection: $selectedMood) {
                        Text("全部").tag(nil as Mood?)
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Label(mood.label, systemImage: mood.emoji).tag(mood as Mood?)
                        }
                    }
                }
                
                if selectedCategory == .byStyle {
                    Section("信物风格") {
                        Picker("风格", selection: $selectedStyle) {
                            Text("全部").tag(nil as RitualStyle?)
                            ForEach(RitualStyle.allCases, id: \.self) { style in
                                Label(style.rawValue, systemImage: style.icon).tag(style as RitualStyle?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel & Helpers

final class TimelineViewModel: ObservableObject {
    @Published var selectedCategory: TimelineCategory = .all
    @Published var selectedMood: Mood?
    @Published var selectedStyle: RitualStyle?
    
    func clearFilters() {
        selectedCategory = .all
        selectedMood = nil
        selectedStyle = nil
    }
    
    var hasActiveFilters: Bool {
        let categoryActive = selectedCategory == .byStyle ? selectedStyle != nil : selectedCategory != .all
        return categoryActive || selectedMood != nil || selectedStyle != nil
    }
    
    var activeFiltersDescription: String {
        var parts: [String] = []
        if selectedCategory != .all, !(selectedCategory == .byStyle && selectedStyle == nil) {
            parts.append(selectedCategory.title)
        }
        if let mood = selectedMood {
            parts.append("心情: \(mood.label)")
        }
        if let style = selectedStyle {
            parts.append("样式: \(style.label)")
        }
        return parts.joined(separator: " · ")
    }
    
    func filteredRecords(from records: [DayRecord]) -> [DayRecord] {
        var result = records.sorted(by: { $0.date > $1.date })
        
        switch selectedCategory {
        case .all:
            break
        case .withPhotos:
            result = result.filter { !$0.photos.isEmpty }
        case .withMood:
            result = result.filter { $0.mood != .neutral }
        case .byStyle:
            if let style = selectedStyle {
                result = result.filter { $0.artifactStyle == style }
            }
        }
        
        if let mood = selectedMood {
            result = result.filter { $0.mood == mood }
        }
        
        return result
    }
    
    func sections(from records: [DayRecord]) -> [TimelineSection] {
        let calendar = Calendar.current
        let filtered = filteredRecords(from: records)
        let grouped = Dictionary(grouping: filtered) { record in
            calendar.startOfDay(for: record.date)
        }
        
        return grouped
            .map { date, records in
                let sorted = records.sorted(by: { $0.date > $1.date })
                let label = sectionLabel(for: date, calendar: calendar)
                return TimelineSection(id: date, date: date, label: label, records: sorted)
            }
            .sorted { $0.date > $1.date }
    }
    
    private func sectionLabel(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) { return "今天" }
        if calendar.isDateInYesterday(date) { return "昨天" }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return TimelineFormatters.weekday.string(from: date)
        }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
            return TimelineFormatters.monthDay.string(from: date)
        }
        return TimelineFormatters.yearMonth.string(from: date)
    }
}

struct TimelineSection: Identifiable {
    let id: Date
    let date: Date
    let label: String
    let records: [DayRecord]
}

enum TimelineFormatters {
    static let weekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "本周 EEEE"
        return formatter
    }()
    
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter
    }()
    
    static let yearMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()
    
    static let sectionTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE HH:mm"
        return formatter
    }()
}

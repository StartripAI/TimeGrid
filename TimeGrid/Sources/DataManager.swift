//
//  DataManager.swift
//  一格 V3.0 - 数据管理
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var records: [DayRecord] = []
    @Published var anniversaries: [Anniversary] = []
    @Published var settings: AppSettings
    @Published var currentMonth: Date
    
    // 注意：已移除 recordsDict，因为同一天可以有多个记录，字典无法处理重复键
    
    // 存储键
    private let recordsKey = "TimeGrid_Records_V3"
    private let anniversariesKey = "TimeGrid_Anniversaries_V3"
    private let settingsKey = "TimeGrid_Settings_V3"
    
    private var cancellables = Set<AnyCancellable>()
    
    // ⚠️ 关键优化：init 中不做任何 IO 操作，只设置默认值
    init() {
        self.currentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        self.settings = AppSettings.defaultSettings()
        
        // 立即设置观察者，不阻塞
        setupObservers()
        
        // ⚠️ 优化：延迟加载数据，在后台异步执行，不阻塞启动
        // 使用低优先级，让 UI 渲染优先
        Task.detached(priority: .utility) {
            await MainActor.run {
                self.loadAll()
                }
                        }
                    }

    // MARK: - 数据加载
    
    private func loadAll() {
        loadRecords()
        loadAnniversaries()
        loadSettings()
                }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([DayRecord].self, from: data) {
            self.records = decoded.sorted { $0.date > $1.date }
            // 注意：已移除 recordsDict，因为同一天可以有多个记录
        }
        }
        
    private func loadAnniversaries() {
        if let data = UserDefaults.standard.data(forKey: anniversariesKey),
           let decoded = try? JSONDecoder().decode([Anniversary].self, from: data) {
            self.anniversaries = decoded
        }
        
        // 确保有内置节日
        let currentYear = Calendar.current.component(.year, from: Date())
        let builtInHolidays = ChineseHolidays.getBuiltInHolidays(for: currentYear)
        
        for holiday in builtInHolidays {
            if !anniversaries.contains(where: { $0.name == holiday.name && $0.isBuiltIn }) {
                anniversaries.append(holiday)
            }
        }
        
        saveAnniversaries()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        }
    }
    
    // MARK: - 数据保存
    
    func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
                UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    func saveAnniversaries() {
        if let encoded = try? JSONEncoder().encode(anniversaries) {
                UserDefaults.standard.set(encoded, forKey: anniversariesKey)
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
        
        // 更新通知
        if settings.notificationEnabled {
            NotificationManager.shared.scheduleDailyReminder(at: settings.notificationTime)
        } else {
            NotificationManager.shared.cancelAllNotifications()
        }
    }
    
    // V4.0: 便捷方法，用于更新设置并保存
    func updateSettings() {
        saveSettings()
    }
    
    private func setupObservers() {
        $settings
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 记录 CRUD
    
    func addOrUpdateRecord(_ record: DayRecord) {
        let normalizedDate = Calendar.current.startOfDay(for: record.date)
        // 🔥 修复：确保包含所有字段，特别是 artifactStyle 和 aestheticDetails
        let updatedRecord = DayRecord(
            id: record.id,
            date: normalizedDate,
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
            renderedArtifactID: record.renderedArtifactID
        )
        
        #if DEBUG
        print("🔍 DEBUG: DataManager.addOrUpdateRecord - record ID: \(updatedRecord.id.uuidString), artifactStyle: \(updatedRecord.artifactStyle), photos: \(updatedRecord.photos.count)")
        #endif
        
        // 🔥 修复：使用 record.id 而不是 date 来查找记录（允许同一天有多个记录）
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = updatedRecord
            #if DEBUG
            print("🔍 DEBUG: DataManager.addOrUpdateRecord - 更新现有记录，索引: \(index)")
            #endif
        } else {
            records.append(updatedRecord)
            records.sort { $0.date > $1.date }
            #if DEBUG
            print("🔍 DEBUG: DataManager.addOrUpdateRecord - 添加新记录，总数: \(records.count)")
            #endif
        }
        
        // 注意：已移除 recordsDict，因为同一天可以有多个记录
        saveRecords()
    }
    
    func deleteRecord(_ record: DayRecord) {
        records.removeAll { $0.id == record.id }
        // 注意：已移除 recordsDict，因为同一天可以有多个记录
        saveRecords()
    }
    
    func sealRecord(_ record: DayRecord) {
        var updated = record
        updated.isSealed = true
        updated.sealedAt = Date()
        addOrUpdateRecord(updated)
            }
    
    func openRecord(_ record: DayRecord) {
        guard record.canBeOpened else { return }
        var updated = record
        updated.hasBeenOpened = true
        updated.openedAt = Date()
        addOrUpdateRecord(updated)
    }
    
    // MARK: - 记录查询
    
    func record(for date: Date) -> DayRecord? {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        // 返回该日期最新的记录（按 sealedAt 或 date 排序）
        return records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) }
            .sorted { ($0.sealedAt ?? $0.date) > ($1.sealedAt ?? $1.date) }
            .first
    }
    
    func todayRecord() -> DayRecord? {
        record(for: Date())
    }
    
    func records(for month: Date) -> [DayRecord] {
        let calendar = Calendar.current
        return records.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }
    
    func sealedRecordsToOpen() -> [DayRecord] {
        records.filter { $0.canBeOpened }.sorted { $0.date > $1.date }
    }
    
    func randomOldRecord() -> DayRecord? {
        let oldRecords = records.filter { $0.daysAgo > 7 && $0.isSealed }
        return oldRecords.randomElement()
    }
    
    // MARK: - 格子状态
    
    func gridState(for date: Date) -> GridState {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        
        if checkDate == today { return .today }
        if checkDate > today { return .future }
        
        if let record = record(for: date) {
            if record.hasBeenOpened { return .opened }
            if record.isSealed { return .sealed }
        }
        
        return .empty
    }
    
    // MARK: - 纪念日管理
    
    func addAnniversary(_ anniversary: Anniversary) {
        anniversaries.append(anniversary)
        saveAnniversaries()
    }
    
    func deleteAnniversary(_ anniversary: Anniversary) {
        anniversaries.removeAll { $0.id == anniversary.id }
        saveAnniversaries()
    }
    
    func nearestAnniversary() -> Anniversary? {
        anniversaries
            .filter { $0.daysUntilNext() >= 0 }
            .min { $0.daysUntilNext() < $1.daysUntilNext() }
    }
    
    func upcomingAnniversaries(limit: Int = 5) -> [Anniversary] {
        anniversaries
            .filter { $0.daysUntilNext() >= 0 }
            .sorted { $0.daysUntilNext() < $1.daysUntilNext() }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - 统计数据
    
    var totalRecords: Int { records.count }
    
    var sealedRecordsCount: Int { records.filter { $0.isSealed }.count }
    
    var pendingToOpenCount: Int { sealedRecordsToOpen().count }
    
    var streakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        
        // 如果今天还没记录，从昨天开始算
        if record(for: checkDate) == nil || record(for: checkDate)?.isSealed != true {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }
        
        while let r = record(for: checkDate), r.isSealed {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    var thisMonthCompletionRate: Double {
        let calendar = Calendar.current
        let today = Date()
        let dayOfMonth = calendar.component(.day, from: today)
        let recordsThisMonth = records(for: today).filter { $0.isSealed }.count
        return dayOfMonth > 0 ? Double(recordsThisMonth) / Double(dayOfMonth) : 0
    }
    
    func moodStatistics(days: Int = 7) -> MoodStatistics {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var moodCounts: [Mood: Int] = [:]
        var recentMoods: [(date: Date, mood: Mood)] = []
        var totalScore = 0
        var count = 0
        
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today),
                  let record = record(for: date), record.isSealed else { continue }
            
            moodCounts[record.mood, default: 0] += 1
            recentMoods.append((date: date, mood: record.mood))
            totalScore += record.mood.score
            count += 1
        }
        
        recentMoods.reverse() // 从旧到新
        
        return MoodStatistics(
            moodCounts: moodCounts,
            recentMoods: recentMoods,
            averageScore: count > 0 ? Double(totalScore) / Double(count) : 0
        )
    }
    
    // MARK: - 日历辅助
    
    func daysInMonth(_ date: Date) -> [Date?] {
        let calendar = Calendar.current
        
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let range = calendar.range(of: .day, in: .month, for: date)
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(dayDate)
            }
        }
        
        return days
    }
    
    // V4.2: 获取记录摘要，用于日历显示优化
    func getRecordsSummary() -> [Date: RecordSummary] {
        var summary: [Date: RecordSummary] = [:]

        for record in records where record.isSealed {
            let recordSummary = RecordSummary(
                emoji: record.mood.emoji,
                sticker: record.sticker
            )
            summary[record.date] = recordSummary
        }

        return summary
    }
}

//
//  NewRecordViewModel.swift
//  时光格 V4.0 - 新建记录ViewModel
//
//  V4.0: 引入ViewModel管理复杂状态和预览逻辑

import Foundation
import SwiftUI
import Combine

// MARK: - V4.0 引入 ViewModel 管理复杂状态和预览逻辑
class NewRecordViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedMood: Mood = .neutral
    @Published var selectedWeather: Weather?
    @Published var selectedStyle: RitualStyle = .envelope
    @Published var selectedPaperColorHex: String = "#FDF8F3"
    @Published var photoData: [Data] = []
    @Published var aestheticDetails: AestheticDetails = AestheticDetails()

    // V4.0 核心：实时预览记录
    @Published var previewRecord: DayRecord = DayRecord(date: Date(), content: "", mood: .neutral, artifactStyle: .envelope)

    // V4.2: 定制模式
    @Published var isCustomizationMode: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let recordDate: Date
    private let existingRecord: DayRecord?

    // 可选的信纸颜色
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
        self.selectedStyle = existingRecord?.artifactStyle ?? defaultStyle
        self.selectedMood = existingRecord?.mood ?? .neutral
        self.selectedWeather = existingRecord?.weather

        // 初始化美学细节
        self.aestheticDetails = existingRecord?.aestheticDetails ?? AestheticDetails.generate(for: selectedStyle, customColorHex: nil)

        // 如果有现有记录，加载内容
        if let existing = existingRecord {
            self.content = existing.content
            self.photoData = existing.photos
        }

        // 初始化预览记录
        self.previewRecord = DayRecord(
            date: recordDate,
            content: content,
            mood: selectedMood,
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails
        )

        setupBindings()
        updatePreview(regenerateDetails: false) // 首次更新
    }

    private func setupBindings() {
        // 监听内容、心情、天气变化 (不重新生成细节)
        Publishers.CombineLatest3($content, $selectedMood, $selectedWeather)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main) // 防抖优化
            .sink { [weak self] _ in 
                self?.updatePreview(regenerateDetails: false) 
            }
            .store(in: &cancellables)
        
        // 监听风格变化 (需要重新生成细节)
        $selectedStyle
            .sink { [weak self] _ in
                // 使用动画平滑切换风格
                withAnimation(.easeInOut(duration: 0.3)) {
                     self?.updatePreview(regenerateDetails: true)
                }
            }
            .store(in: &cancellables)
        
        // 监听信纸颜色变化 (需要重新生成细节)
        $selectedPaperColorHex
            .sink { [weak self] _ in
                self?.updatePreview(regenerateDetails: true)
            }
            .store(in: &cancellables)
    }

    // V4.2: 更新预览，确保包含美学细节
    private func updatePreview(regenerateDetails: Bool) {
        var record = DayRecord(
            date: recordDate,
            content: content.isEmpty ? "（输入内容以预览）" : content,
            mood: selectedMood,
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails
        )

        // 当风格变化时，重新生成美学细节
        if regenerateDetails {
            aestheticDetails = AestheticDetails.generate(for: selectedStyle, customColorHex: selectedPaperColorHex)
            record.aestheticDetails = aestheticDetails
        }

        self.previewRecord = record
    }
    
    // 创建最终记录（用于保存）
    func createFinalRecord() -> DayRecord {
        var record = DayRecord(
            date: recordDate,
            content: content,
            mood: selectedMood,
            photos: photoData,
            weather: selectedWeather,
            artifactStyle: selectedStyle,
            aestheticDetails: aestheticDetails
        )

        return record
    }
    
    // 更新照片数据
    func updatePhotos(_ photos: [Data]) {
        photoData = photos
        updatePreview(regenerateDetails: false)
    }
    
    // V4.1: 插入随机名言
    func insertRandomQuote() {
        // 这里可以使用 QuotesManager，为了简单演示先内置几个
        let quotes = [
            "生活不是等待风暴过去，而是学会在雨中跳舞。",
            "我们记录，是为了再次遇见。",
            "每一个不曾起舞的日子，都是对生命的辜负。",
            "种一棵树最好的时间是十年前，其次是现在。",
            "万物皆有裂痕，那是光照进来的地方。"
        ]
        
        if let randomQuote = quotes.randomElement() {
            if content.isEmpty {
                content = randomQuote
            } else {
                content += "\n\n" + randomQuote
            }
        }
    }
}


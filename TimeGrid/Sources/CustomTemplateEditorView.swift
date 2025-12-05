//
//  CustomTemplateEditorView.swift
//  时光格 - 自定义模板编辑器
//
//  功能：原生模板、可编辑组件、实时预览、保存分享

import SwiftUI
import PhotosUI

struct CustomTemplateEditorView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    // 模板状态
    @State private var selectedTemplate: RitualStyle = .envelope
    @State private var templateContent: String = ""
    @State private var templateMood: Mood = .neutral
    @State private var templateWeather: Weather?
    @State private var templatePhotos: [Data] = []
    @State private var templateDate: Date = Date()
    
    // 自定义属性（根据模板类型）
    @State private var paperColorHex: String = "#FDF8F3"
    @State private var sealDesign: WaxSealDesign = .initialG
    @State private var sealRotation: Double = 0
    @State private var customStickers: [String] = []
    
    // UI状态
    @State private var showingPreview = false
    @State private var showingSavePreview = false
    @State private var savedRenderedImage: UIImage?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    // 可编辑组件列表
    private var editableComponents: [EditableComponent] {
        var components: [EditableComponent] = []
        
        switch selectedTemplate {
        case .envelope:
            components = [.paperColor, .sealDesign, .sealRotation, .text, .date, .mood, .photo, .weather]
        case .polaroid, .developedPhoto:
            components = [.text, .date, .mood, .photo, .weather]
        case .postcard:
            components = [.text, .date, .mood, .photo, .weather, .border]
        case .journalPage:
            components = [.text, .date, .mood, .weather, .font]
        default:
            components = [.text, .date, .mood, .weather]
        }
        
        return components
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部：模板选择器
                    templateSelector
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 预览区域（居中显示）
                            previewSection
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            // ═══════════════════════════════════════
                            // 📷 照片快速添加区域（顶部，更明显）
                            // ═══════════════════════════════════════
                            if editableComponents.contains(.photo) {
                                quickPhotoSection
                                    .padding(.horizontal, 20)
                            }
                            
                            // 编辑面板
                            editingPanel
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("自定义模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveTemplate()
                    } label: {
                        Text("保存信物")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("PrimaryWarm"))
                    }
                }
            }
            .sheet(isPresented: $showingPreview) {
                FullScreenTemplatePreviewView(
                    template: selectedTemplate,
                    content: templateContent,
                    mood: templateMood,
                    weather: templateWeather,
                    photos: templatePhotos,
                    date: templateDate,
                    paperColorHex: paperColorHex,
                    sealDesign: sealDesign,
                    sealRotation: sealRotation
                )
            }
            .fullScreenCover(isPresented: $showingSavePreview) {
                if let image = savedRenderedImage {
                    TemplateSavePreviewView(
                        renderedImage: image,
                        template: selectedTemplate,
                        onDismiss: {
                            showingSavePreview = false
                            dismiss()
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - 模板选择器
    
    private var templateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RitualStyle.allCases, id: \.self) { style in
                    TemplateStyleCard(
                        style: style,
                        isSelected: selectedTemplate == style
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTemplate = style
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - 预览区域
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("实时预览")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Button {
                    showingPreview = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12))
                        Text("全屏预览")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color("PrimaryOrange"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("PrimaryWarm").opacity(0.1))
                    .cornerRadius(16)
                }
            }
            
            // 信物预览
            TemplatePreviewCard(
                template: selectedTemplate,
                content: templateContent.isEmpty ? "点击下方编辑内容..." : templateContent,
                mood: templateMood,
                weather: templateWeather,
                photos: templatePhotos,
                date: templateDate,
                paperColorHex: paperColorHex,
                sealDesign: sealDesign,
                sealRotation: sealRotation
            )
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 15, y: 8)
        }
    }
    
    // MARK: - 编辑面板
    
    private var editingPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("可编辑组件")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
            
            // 过滤掉照片组件（已在顶部单独显示）
            ForEach(editableComponents.filter { $0 != .photo }, id: \.self) { component in
                ComponentEditor(
                    component: component,
                    template: selectedTemplate,
                    content: $templateContent,
                    mood: $templateMood,
                    weather: $templateWeather,
                    photos: $templatePhotos,
                    date: $templateDate,
                    paperColorHex: $paperColorHex,
                    sealDesign: $sealDesign,
                    sealRotation: $sealRotation,
                    selectedPhotos: $selectedPhotos
                )
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - 📷 照片快速添加区域（顶部，更明显）
    
    @ViewBuilder
    private var quickPhotoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("PrimaryWarm"))
                Text("添加照片")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                if !templatePhotos.isEmpty {
                    Text("\(templatePhotos.count) 张")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("PrimaryWarm"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color("PrimaryWarm").opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            // 照片选择器（大按钮）
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 9,
                matching: .images
            ) {
                HStack(spacing: 12) {
                    Image(systemName: templatePhotos.isEmpty ? "plus.circle.fill" : "photo.badge.plus")
                        .font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(templatePhotos.isEmpty ? "点击添加照片" : "添加更多照片")
                            .font(.system(size: 16, weight: .semibold))
                        Text("最多9张，支持多选")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color("PrimaryWarm"), Color("SealColor")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color("PrimaryWarm").opacity(0.3), radius: 8, y: 4)
            }
            .onChange(of: selectedPhotos) { oldValue, newItems in
                Task {
                    var newPhotos: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            newPhotos.append(data)
                        }
                    }
                    templatePhotos = newPhotos
                }
            }
            
            // 已添加的照片预览（网格显示）
            if !templatePhotos.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                    ForEach(0..<templatePhotos.count, id: \.self) { index in
                        if let uiImage = UIImage(data: templatePhotos[index]) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("PrimaryWarm").opacity(0.3), lineWidth: 2)
                                    )
                                
                                Button {
                                    templatePhotos.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("PrimaryWarm").opacity(0.2), lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
    
    // MARK: - 保存逻辑
    
    private func saveTemplate() {
        // 创建预览记录
        let previewRecord = DayRecord(
            date: templateDate,
            content: templateContent,
            mood: templateMood,
            photos: templatePhotos,
            weather: templateWeather,
            artifactStyle: selectedTemplate,
            aestheticDetails: AestheticDetails(
                letterBackgroundColorHex: paperColorHex,
                sealRotationDegrees: sealRotation,
                waxSealDesign: sealDesign,
                customStickers: customStickers.isEmpty ? nil : customStickers
            )
        )
        
        // 渲染为图片
        let artifactView = StyledArtifactView(record: previewRecord)
        let renderer = ImageRenderer(content: artifactView)
        renderer.scale = UIScreen.main.scale * 2.0
        
        if let renderedImage = renderer.uiImage {
            savedRenderedImage = renderedImage
            showingSavePreview = true
        }
    }
}

// MARK: - 可编辑组件枚举

enum EditableComponent: String, CaseIterable {
    case text = "文本内容"
    case date = "日期"
    case mood = "心情"
    case weather = "天气"
    case photo = "照片"
    case paperColor = "信纸颜色"
    case sealDesign = "印章设计"
    case sealRotation = "印章旋转"
    case border = "边框"
    case font = "字体"
    case stickers = "贴纸"
}

// MARK: - 组件编辑器

struct ComponentEditor: View {
    let component: EditableComponent
    let template: RitualStyle
    @Binding var content: String
    @Binding var mood: Mood
    @Binding var weather: Weather?
    @Binding var photos: [Data]
    @Binding var date: Date
    @Binding var paperColorHex: String
    @Binding var sealDesign: WaxSealDesign
    @Binding var sealRotation: Double
    @Binding var selectedPhotos: [PhotosPickerItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(component.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            switch component {
            case .text:
                TextEditor(text: $content)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color("BackgroundCream"))
                    .cornerRadius(8)
                
            case .date:
                DatePicker("选择日期", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .tint(Color("PrimaryWarm"))
                
            case .mood:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Mood.allCases, id: \.self) { m in
                            MoodButton(mood: m, isSelected: mood == m) {
                                mood = m
                            }
                        }
                    }
                }
                
            case .weather:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button {
                            weather = nil
                        } label: {
                            Text("无")
                                .font(.system(size: 14))
                                .foregroundColor(weather == nil ? .white : Color("TextPrimary"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(weather == nil ? Color("PrimaryWarm") : Color("CardBackground"))
                                .cornerRadius(12)
                        }
                        
                        ForEach(Weather.allCases, id: \.self) { w in
                            WeatherButton(weather: w, isSelected: weather == w) {
                                weather = w
                            }
                        }
                    }
                }
                
            case .photo:
                VStack(alignment: .leading, spacing: 12) {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 9,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加照片")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color("PrimaryWarm"))
                        .cornerRadius(12)
                    }
                    .onChange(of: selectedPhotos) { oldValue, newItems in
                        Task {
                            var newPhotos: [Data] = []
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    newPhotos.append(data)
                                }
                            }
                            photos = newPhotos
                        }
                    }
                    
                    if !photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<photos.count, id: \.self) { index in
                                    if let uiImage = UIImage(data: photos[index]) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button {
                                                photos.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            case .paperColor:
                ColorPickerGrid(selectedColor: $paperColorHex)
                
            case .sealDesign:
                SealDesignPicker(selectedDesign: $sealDesign)
                
            case .sealRotation:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("旋转角度: \(Int(sealRotation))°")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                        Spacer()
                    }
                    Slider(value: $sealRotation, in: 0...360)
                        .tint(Color("PrimaryWarm"))
                }
                
            case .border, .font, .stickers:
                Text("此组件暂未实现")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color("BackgroundCream"))
        .cornerRadius(12)
    }
}

// MARK: - 辅助视图

struct TemplateStyleCard: View {
    let style: RitualStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color("PrimaryWarm"))
                
                Text(style.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : Color("TextPrimary"))
                    .lineLimit(1)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color("PrimaryWarm") : Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color("PrimaryWarm").opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct TemplatePreviewCard: View {
    let template: RitualStyle
    let content: String
    let mood: Mood
    let weather: Weather?
    let photos: [Data]
    let date: Date
    let paperColorHex: String
    let sealDesign: WaxSealDesign
    let sealRotation: Double
    
    var body: some View {
        let previewRecord = DayRecord(
            date: date,
            content: content,
            mood: mood,
            photos: photos,
            weather: weather,
            artifactStyle: template,
            aestheticDetails: AestheticDetails(
                letterBackgroundColorHex: paperColorHex,
                sealRotationDegrees: sealRotation,
                waxSealDesign: sealDesign,
                customStickers: []
            )
        )
        
        StyledArtifactView(record: previewRecord)
            .scaleEffect(0.8)
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: 24))
                Text(mood.label)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("PrimaryWarm") : Color("CardBackground"))
            .cornerRadius(12)
        }
    }
}

struct WeatherButton: View {
    let weather: Weather
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: weather.icon)
                    .font(.system(size: 14))
                Text(weather.label)
                    .font(.system(size: 13))
            }
            .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("PrimaryWarm") : Color("CardBackground"))
            .cornerRadius(12)
        }
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: String
    
    let colors: [(name: String, hex: String)] = [
        ("米白", "#FDF8F3"),
        ("复古黄", "#F9F7F1"),
        ("淡蓝", "#E3F2FD"),
        ("浅绿", "#E8F5E9"),
        ("樱粉", "#FCE4EC"),
        ("淡紫", "#F3E5F5"),
        ("米色", "#FAF0E6"),
        ("象牙白", "#FFFFF0")
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(colors, id: \.hex) { color in
                Button {
                    selectedColor = color.hex
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color.hex ? Color("PrimaryWarm") : Color.clear, lineWidth: 3)
                            )
                        
                        if selectedColor == color.hex {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

struct SealDesignPicker: View {
    @Binding var selectedDesign: WaxSealDesign
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WaxSealDesign.allCases, id: \.self) { design in
                    Button {
                        selectedDesign = design
                    } label: {
                        VStack(spacing: 4) {
                            if let systemImage = design.systemImageName {
                                Image(systemName: systemImage)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedDesign == design ? .white : Color("PrimaryWarm"))
                            } else if let text = design.text {
                                Text(text)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(selectedDesign == design ? .white : Color("PrimaryWarm"))
                            } else {
                                Text(design.rawValue)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedDesign == design ? .white : Color("PrimaryWarm"))
                            }
                            
                            Text(design.text ?? design.rawValue)
                                .font(.system(size: 11))
                                .foregroundColor(selectedDesign == design ? .white : Color("TextPrimary"))
                        }
                        .frame(width: 70, height: 70)
                        .background(selectedDesign == design ? Color("PrimaryWarm") : Color("CardBackground"))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - 全屏预览

struct FullScreenTemplatePreviewView: View {
    let template: RitualStyle
    let content: String
    let mood: Mood
    let weather: Weather?
    let photos: [Data]
    let date: Date
    let paperColorHex: String
    let sealDesign: WaxSealDesign
    let sealRotation: Double
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            let previewRecord = DayRecord(
                date: date,
                content: content,
                mood: mood,
                photos: photos,
                weather: weather,
                artifactStyle: template,
                aestheticDetails: AestheticDetails(
                    letterBackgroundColorHex: paperColorHex,
                    sealRotationDegrees: sealRotation,
                    waxSealDesign: sealDesign,
                    customStickers: []
                )
            )
            
            StyledArtifactView(record: previewRecord)
                .scaleEffect(1.2)
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

// MARK: - 保存预览

struct TemplateSavePreviewView: View {
    let renderedImage: UIImage
    let template: RitualStyle
    let onDismiss: () -> Void
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 顶部标题
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(Color("TextPrimary"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("保存成功")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(Color("PrimaryWarm"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 预览图片
                        Image(uiImage: renderedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 25, y: 10)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // 操作按钮
                        VStack(spacing: 16) {
                            Button {
                                UIImageWriteToSavedPhotosAlbum(renderedImage, nil, nil, nil)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("保存到相册")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("PrimaryWarm"))
                                .cornerRadius(12)
                            }
                            
                            Button {
                                onDismiss()
                            } label: {
                                Text("完成")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("CardBackground"))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [renderedImage])
        }
    }
}


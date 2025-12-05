//
//  TimeCapsuleSheet.swift
//  时光格 V2.0 - 时光胶囊选择器
//

import SwiftUI

struct TimeCapsuleSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager = AuthManager.shared
    
    let record: DayRecord
    let onConfirm: (TimeCapsule) -> Void
    
    @State private var selectedPreset: CapsuleTimePreset = .nextWeek
    @State private var customDate = Date().addingTimeInterval(86400 * 7)
    @State private var message = ""
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部说明
                    headerSection
                    
                    // 时间预设
                    timePresetSection
                    
                    // 自定义日期（如果选择了自定义）
                    if selectedPreset == .custom {
                        customDateSection
                    }
                    
                    // 附加留言（可选）
                    messageSection
                    
                    // 预览
                    previewSection
                    
                    Spacer(minLength: 100)
                }
                .padding(20)
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("封入时光胶囊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color("TextSecondary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确认") {
                        confirmCapsule()
                    }
                    .foregroundColor(Color("PrimaryWarm"))
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sub Views
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 胶囊图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("PrimaryWarm").opacity(0.2), Color("SealColor").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 36))
                    .foregroundColor(Color("PrimaryWarm"))
            }
            
            Text("把这一天封存起来")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            Text("在未来的某一天，收到来自过去的自己的信")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var timePresetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择开启时间")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(CapsuleTimePreset.allCases, id: \.self) { preset in
                    TimePresetButton(
                        preset: preset,
                        isSelected: selectedPreset == preset
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPreset = preset
                            if preset == .custom {
                                showDatePicker = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var customDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择日期")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
            
            DatePicker(
                "",
                selection: $customDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .tint(Color("PrimaryWarm"))
            .background(Color("CardBackground"))
            .cornerRadius(16)
        }
    }
    
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("给未来的自己留言")
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                
                Text("（可选）")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary").opacity(0.6))
            }
            
            TextEditor(text: $message)
                .frame(height: 80)
                .padding(12)
                .background(Color("CardBackground"))
                .cornerRadius(12)
                .overlay(
                    Group {
                        if message.isEmpty {
                            Text("未来的我，你好...")
                                .foregroundColor(Color("TextSecondary").opacity(0.5))
                                .padding(.leading, 16)
                                .padding(.top, 20)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预览")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
            
            HStack(spacing: 16) {
                // 胶囊图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("PrimaryWarm"), Color("SealColor")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.formattedDate)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(targetDateDescription)
                        .font(.system(size: 13))
                        .foregroundColor(Color("PrimaryWarm"))
                }
                
                Spacer()
                
                Text(record.mood.emoji)
                    .font(.system(size: 28))
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
    }
    
    // MARK: - Computed Properties
    
    private var targetDate: Date {
        if selectedPreset == .custom {
            return customDate
        }
        return selectedPreset.targetDate()
    }
    
    private var targetDateDescription: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        let dateStr = formatter.string(from: targetDate)
        
        let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        
        return "\(dateStr)（\(days)天后）可开启"
    }
    
    // MARK: - Actions
    
    private func confirmCapsule() {
        // 检查是否需要登录
        if authManager.checkRegistrationRequired(for: .capsuleCreate) {
            authManager.requestRegistration(trigger: .capsuleCreate)
            return
        }
        
        let capsule = TimeCapsule(
            recordId: record.id,
            scheduledOpenAt: targetDate,
            message: message.isEmpty ? nil : message
        )
        
        onConfirm(capsule)
        dismiss()
    }
}

// MARK: - 时间预设按钮

struct TimePresetButton: View {
    let preset: CapsuleTimePreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.system(size: 20))
                
                Text(preset.label)
                    .font(.system(size: 13))
            }
            .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [Color("PrimaryWarm"), Color("SealColor")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color("CardBackground"), Color("CardBackground")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color("TextSecondary").opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


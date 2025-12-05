//
//  MetadataPickerView.swift
//  时光格 - 元数据选择器（日期、天气、心情）
//
//  功能：选择日期、天气、心情，风格与标签和事件类型选择器一致
//

import SwiftUI

struct MetadataPickerView: View {
    @Binding var selectedDate: Date
    @Binding var selectedWeather: Weather?
    @Binding var selectedMood: Mood
    @State private var showingDatePicker = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text("元数据")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
            }
            
            // 三个选择器：日期、天气、心情（横向排列）
            HStack(spacing: 12) {
                // 日期选择器
                Button(action: {
                    showingDatePicker = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundColor(Color("PrimaryWarm"))
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("CardBackground").opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // 天气选择器
                Menu {
                    ForEach(Weather.allCases, id: \.self) { weather in
                        Button(action: {
                            selectedWeather = weather
                        }) {
                            HStack {
                                Image(systemName: weather.icon)
                                Text(weather.label)
                                if selectedWeather == weather {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    Button(role: .destructive, action: {
                        selectedWeather = nil
                    }) {
                        Label("清除", systemImage: "xmark.circle")
                    }
                } label: {
                    VStack(spacing: 6) {
                        if let weather = selectedWeather {
                            Image(systemName: weather.icon)
                                .font(.system(size: 18))
                                .foregroundColor(Color("PrimaryWarm"))
                            Text(weather.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color("TextPrimary"))
                        } else {
                            Image(systemName: "cloud.sun")
                                .font(.system(size: 18))
                                .foregroundColor(Color("TextSecondary"))
                            Text("天气")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedWeather != nil ? Color("PrimaryWarm").opacity(0.1) : Color("CardBackground").opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedWeather != nil ? Color("PrimaryWarm") : Color.white.opacity(0.2), lineWidth: selectedWeather != nil ? 1.5 : 1)
                    )
                }
                
                // 心情选择器
                Menu {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                        }) {
                            HStack {
                                Text(mood.emoji)
                                    .font(.system(size: 16))
                                Text(mood.label)
                                if selectedMood == mood {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(selectedMood.emoji)
                            .font(.system(size: 20))
                        Text(selectedMood.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("PrimaryWarm").opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("PrimaryWarm"), lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(16)
        .background(Color("CardBackground").opacity(0.3))
        .cornerRadius(12)
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .navigationTitle("选择日期")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showingDatePicker = false
                        }
                    }
                }
            }
        }
    }
}


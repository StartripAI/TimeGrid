//
//  EventTypePickerView.swift
//  时光格 - 事件类型选择器
//
//  功能：选择事件类型（日常、事件、灵感等）
//

import SwiftUI

struct EventTypePickerView: View {
    @Binding var selectedEventType: EventType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text("事件类型")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                if selectedEventType != nil {
                    Button {
                        selectedEventType = nil
                    } label: {
                        Text("清除")
                            .font(.system(size: 12))
                            .foregroundColor(Color("PrimaryWarm"))
                    }
                }
            }
            
            // 事件类型选择（网格布局）
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(EventType.allCases, id: \.self) { eventType in
                    EventTypeButton(
                        eventType: eventType,
                        isSelected: selectedEventType == eventType
                    ) {
                        selectedEventType = selectedEventType == eventType ? nil : eventType
                    }
                }
            }
        }
        .padding(16)
        .background(Color("CardBackground").opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - 事件类型按钮

struct EventTypeButton: View {
    let eventType: EventType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: eventType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : Color("PrimaryWarm"))
                
                Text(eventType.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color("PrimaryWarm") : Color("CardBackground").opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color("PrimaryWarm") : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


//
//  NewRecordViewComponents.swift
//  时光格 - 新建记录页面组件
//

import SwiftUI

// MARK: - 风格选择器项
struct StylePickerItem: View {
    let style: RitualStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? Color("PrimaryOrange") : Color("TextSecondary"))
                
                Text(style.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color("PrimaryOrange") : Color("TextSecondary"))
                    .lineLimit(1)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color("PrimaryWarm").opacity(0.15) : Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("PrimaryOrange") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 全屏预览视图
struct FullScreenPreviewView: View {
    let record: DayRecord
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // 顶部关闭按钮
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                Spacer()
                
                // 信物预览
                StyledArtifactView(record: record)
                    .scaleEffect(1.0)
                    .shadow(color: Color.black.opacity(0.3), radius: 30, y: 15)
                
                Spacer()
            }
        }
    }
}


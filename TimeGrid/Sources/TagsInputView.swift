//
//  TagsInputView.swift
//  时光格 - 标签输入组件
//
//  功能：支持添加、删除标签，自动建议常见标签
//

import SwiftUI

struct TagsInputView: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""
    @FocusState private var isTagFieldFocused: Bool
    
    // 常见标签建议
    private let suggestedTags = ["旅行", "美食", "工作", "学习", "运动", "阅读", "电影", "音乐", "朋友", "家人", "灵感", "回忆"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text("标签")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                if !tags.isEmpty {
                    Button {
                        tags.removeAll()
                    } label: {
                        Text("清除")
                            .font(.system(size: 12))
                            .foregroundColor(Color("PrimaryWarm"))
                    }
                }
            }
            
            // 已添加的标签（芯片视图）
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagChip(tag: tag, isRemovable: true) {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // 输入框和建议标签
            VStack(alignment: .leading, spacing: 8) {
                // 输入框
                HStack {
                    TextField("输入标签（按回车添加）", text: $newTag)
                        .font(.system(size: 14))
                        .textFieldStyle(.plain)
                        .focused($isTagFieldFocused)
                        .onSubmit {
                            addTag()
                        }
                    
                    if !newTag.isEmpty {
                        Button {
                            addTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color("PrimaryWarm"))
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(12)
                .background(Color("CardBackground").opacity(0.5))
                .cornerRadius(8)
                
                // 建议标签
                if tags.count < 6 { // 最多6个标签
                    Text("建议标签")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextSecondary"))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestedTags.filter { !tags.contains($0) }, id: \.self) { suggestedTag in
                                TagChip(tag: suggestedTag, isRemovable: false) {
                                    if !tags.contains(suggestedTag) && tags.count < 6 {
                                        tags.append(suggestedTag)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color("CardBackground").opacity(0.3))
        .cornerRadius(12)
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) && tags.count < 6 {
            tags.append(trimmedTag)
            newTag = ""
            isTagFieldFocused = false
        }
    }
}

// MARK: - 标签芯片组件

struct TagChip: View {
    let tag: String
    let isRemovable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if !isRemovable {
                    Text("#")
                        .font(.system(size: 10))
                }
                Text(tag)
                    .font(.system(size: 12, weight: .medium))
                
                if isRemovable {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                }
            }
            .foregroundColor(isRemovable ? Color("TextPrimary") : Color("PrimaryWarm"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isRemovable ? Color("PrimaryWarm").opacity(0.2) : Color("PrimaryWarm").opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isRemovable ? Color("PrimaryWarm") : Color("PrimaryWarm").opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


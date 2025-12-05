//
//  CustomizationView.swift
//  时光格 - 自定义信物界面
//
//  设计理念：直接在信物上添加选项，去掉蒙版，直观看到自定义效果
//

import SwiftUI

struct CustomizationView: View {
    @ObservedObject var viewModel: InlineNewRecordViewModel
    @ObservedObject var themeEngine = ThemeEngine.shared // 🔥 观察主题变化
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeEngine.currentTheme.backgroundView.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 信物预览（核心位置）
                        StyledArtifactView(record: viewModel.previewRecord)
                            .frame(maxWidth: .infinity)
                            .padding(30)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                            .padding(.top, 20)
                        
                        // 自定义选项（在信物下方，不遮挡）
                        VStack(spacing: 20) {
                            // 信纸颜色选择（仅信封风格）
                            if viewModel.selectedStyle == .envelope {
                                paperColorSection
                            }
                            
                            // 其他自定义选项可以根据风格添加
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("自定义信物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryOrange"))
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var paperColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("信纸颜色")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.paperColors, id: \.hex) { color in
                        Button {
                            viewModel.selectedPaperColorHex = color.hex
                            // 更新美学细节
                            viewModel.aestheticDetails.letterBackgroundColorHex = color.hex
                            viewModel.updatePreview()
                        } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                viewModel.selectedPaperColorHex == color.hex ?
                                                    Color("PrimaryOrange") : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                
                                Text(color.name)
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        viewModel.selectedPaperColorHex == color.hex ?
                                            Color("PrimaryOrange") : Color("TextSecondary")
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}


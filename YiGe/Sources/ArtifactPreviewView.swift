//
//  ArtifactPreviewView.swift
//  时光格 - 保存后的信物预览界面
//
//  功能：分享、下载、保存到时光胶囊、拆封

import SwiftUI
import UIKit

struct ArtifactPreviewView: View {
    let record: DayRecord
    let renderedImage: UIImage?
    let onDismiss: () -> Void
    let onSaveToCapsule: () -> Void
    
    @State private var showingShareSheet = false
    @State private var showingSaveToCapsule = false
    @State private var showingUnsealAnimation = false
    @State private var isStyleBadgeVisible = true
    
    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题栏
                HStack(spacing: 12) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // 调色盘按钮 - 横排显示信物风格名称+图标，可以叉掉
                    if isStyleBadgeVisible {
                        HStack(spacing: 8) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color("PrimaryWarm"))
                            
                            Text(record.artifactStyle.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color("TextPrimary"))
                            
                            // 动态信物图标预览（小缩略图）
                            StyledArtifactView(record: record)
                                .frame(width: 32, height: 40)
                                .scaleEffect(0.3)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .allowsHitTesting(false)
                            
                            // 叉掉按钮
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    isStyleBadgeVisible = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // 隐藏后显示一个小的调色盘图标，点击可恢复
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isStyleBadgeVisible = true
                            }
                        } label: {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color("PrimaryWarm"))
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("PrimaryWarm"))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // 信物预览区域
                ScrollView {
                    VStack(spacing: 24) {
                        // 信物卡片
                        StyledArtifactView(record: record)
                            .shadow(color: Color.black.opacity(0.15), radius: 25, y: 10)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // 操作按钮组
                        VStack(spacing: 16) {
                            // 下载按钮
                            if let image = renderedImage {
                                Button {
                                    saveToPhotos(image)
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 20))
                                        Text("保存到相册")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("PrimaryWarm"))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // 保存到时光胶囊按钮
                            Button {
                                showingSaveToCapsule = true
                            } label: {
                                HStack {
                                    Image(systemName: "capsule.fill")
                                        .font(.system(size: 20))
                                    Text("保存到时光胶囊")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("SealColor"))
                                .cornerRadius(12)
                            }
                            
                            // 拆封按钮（如果已封存）
                            if record.isSealed && !record.hasBeenOpened {
                                Button {
                                    showingUnsealAnimation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "seal.fill")
                                            .font(.system(size: 20))
                                        Text("拆封信物")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color("PrimaryOrange"), Color("SealColor")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            
                            // 完成按钮
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
            if let image = renderedImage {
                ShareSheet(activityItems: [image])
            }
        }
        .sheet(isPresented: $showingSaveToCapsule) {
            TimeCapsuleSelectionView(record: record, onConfirm: {
                onSaveToCapsule()
                showingSaveToCapsule = false
            })
        }
        .fullScreenCover(isPresented: $showingUnsealAnimation) {
            UnsealAnimationView(record: record) {
                showingUnsealAnimation = false
                onDismiss()
            }
        }
    }
    
    private func saveToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 显示成功提示
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// 注意：ShareSheet 和 TimeCapsuleSelectionView 已在 MintFlowView.swift 中定义

// MARK: - 拆封动画视图
struct UnsealAnimationView: View {
    let record: DayRecord
    let onComplete: () -> Void
    @EnvironmentObject var dataManager: DataManager
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 拆封动画
                StyledArtifactView(record: record)
                    .scaleEffect(1.0 - animationProgress * 0.3)
                    .opacity(1.0 - animationProgress)
                    .overlay(
                        // 蜡封动画
                        Circle()
                            .fill(Color("SealColor"))
                            .frame(width: 60, height: 60)
                            .scaleEffect(animationProgress > 0.5 ? 2.0 : 1.0)
                            .opacity(animationProgress > 0.5 ? 0 : 1)
                    )
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
            
            // 更新记录状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                var updatedRecord = record
                updatedRecord.hasBeenOpened = true
                updatedRecord.openedAt = Date()
                dataManager.addOrUpdateRecord(updatedRecord)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}


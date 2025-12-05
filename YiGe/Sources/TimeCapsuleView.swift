//
//  TimeCapsuleView.swift
//  时光格 V3.0 - 时光机
//

import SwiftUI

struct TimeCapsuleView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var capsuleRotation: Double = 0
    @State private var isShaking = false
    @State private var selectedRecord: DayRecord?
    @State private var showingRecord = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color("BackgroundCream"), Color("PrimaryWarm").opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // 时光胶囊
                    ZStack {
                        // 光晕效果
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color("PrimaryWarm").opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                        
                        // 胶囊主体
                        CapsuleShape()
                            .fill(
                                LinearGradient(
                                    colors: [Color("PrimaryWarm"), Color("SealColor")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 200)
                            .shadow(color: Color("PrimaryWarm").opacity(0.4), radius: 20, x: 0, y: 10)
                            .rotation3DEffect(
                                .degrees(capsuleRotation),
                                axis: (x: 0.5, y: 1, z: 0.2)
                            )
                            .scaleEffect(isShaking ? 1.05 : 1.0)
                        
                        // 内部图标
                        VStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                            
                            Text("时光机")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .rotation3DEffect(
                            .degrees(capsuleRotation),
                            axis: (x: 0.5, y: 1, z: 0.2)
                        )
                    }
                    .onTapGesture {
                        shakeCapsule()
                    }
                    
                    // 提示文字
                    VStack(spacing: 8) {
                        Text("点击摇动时光机")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("随机穿越到过去的某一天")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    // 统计信息
                    if dataManager.totalRecords > 0 {
                        VStack(spacing: 4) {
                            Text("共有 \(dataManager.totalRecords) 条时光记录")
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextSecondary"))
                            
                            // V4.0: 移除封存检查，所有旧记录都计入统计
                            let oldRecords = dataManager.records.filter { $0.daysAgo > 7 }.count
                            Text("其中 \(oldRecords) 条可供穿越")
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary").opacity(0.7))
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("时光机")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
    
    private func shakeCapsule() {
        // 震动反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 摇动动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
            isShaking = true
        }
        
        // 旋转动画
        withAnimation(.easeInOut(duration: 0.8)) {
            capsuleRotation += 360
        }
        
        // 恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                isShaking = false
            }
        }
        
        // 随机选择记录
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let record = dataManager.randomOldRecord() {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                selectedRecord = record
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }
    }
}

// MARK: - 胶囊形状

struct CapsuleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius = rect.width / 2
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        return path
    }
}

#Preview {
    TimeCapsuleView()
        .environmentObject(DataManager())
}

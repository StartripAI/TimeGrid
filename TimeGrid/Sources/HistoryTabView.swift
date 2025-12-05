//
//  HistoryTabView.swift
//  时光格 - 左Tab：历史记录
//
//  显示所有历史记录，使用当前选中的信物风格
//

import SwiftUI

struct HistoryTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    Text("时光记录")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, 20)

                    // 记录列表
                    if dataManager.records.isEmpty {
                        // 空状态
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(Color("PrimaryOrange"))

                            Text("还没有记录呢")
                                .font(.system(size: 18))
                                .foregroundColor(Color("TextSecondary"))

                            Text("切换到今日Tab开始记录吧")
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextSecondary").opacity(0.7))
                        }
                        .padding(.top, 60)
                    } else {
                        // 显示记录
                        LazyVStack(spacing: 16) {
                            ForEach(dataManager.records.sorted(by: { $0.date > $1.date })) { record in
                                NavigationLink(destination: RecordDetailView(record: record)) {
                                    // V4.0: 使用 StyledArtifactView 显示记录，每条记录使用自己的风格
                                    StyledArtifactView(record: record)
                                        .scaleEffect(0.9)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HistoryTabView()
        .environmentObject(DataManager())
}

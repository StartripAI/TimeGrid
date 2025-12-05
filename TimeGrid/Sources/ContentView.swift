import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var themeEngine = ThemeEngine.shared
    
    @State private var selectedTab = 2 // 默认选中"铸造"
    @State private var showMintFlow = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. 核心视图层
        TabView(selection: $selectedTab) {
                TimelineView()
                    .tag(0)
                    .background(Color.clear) // 确保透明
                
                CountdownView()
                    .tag(1)
                    .background(Color.clear)
                
                ForgeViewV3() // 新的铸造页面 V3（世界级设计）
                    .tag(2)
                    .background(Color.clear)
                
                TodayWorkbenchView()
                    .tag(3)
                    .background(Color.clear)
                
                ProfileView()
                    .tag(4)
                    .background(Color.clear)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, 70) // 为 TabBar 留出空间，适应新的状态栏高度（60 + 10安全区域）
            
            // 2. V7.3 皇家导航栏 (5-Column Grid)
            LuxuryTabBar(selectedTab: $selectedTab, onMintTap: {
                // 铸造功能现在在 ForgeView 中，这里保留以备后用
            })
            .padding(.bottom, 0)
            .zIndex(1000) // 提高 zIndex 确保在最上层
        }
        // 🔥 核心：一键奢华化，注入全局材质
        .background(
            themeEngine.currentTheme.backgroundView
                .ignoresSafeArea(.all) // 确保覆盖所有区域，包括底部
                .allowsHitTesting(false) // 背景不拦截触摸
        )
        .preferredColorScheme(ColorScheme.dark) // 🔥 修复：明确类型
        
        // 3. 创建记录流程（统一使用 NewRecordView）
        .fullScreenCover(isPresented: $showMintFlow) {
            NewRecordView(recordDate: Date())
                .environmentObject(dataManager)
        }
        .onAppear {
            themeEngine.currentHubStyle = dataManager.settings.todayHubStyle
        }
        .onChange(of: dataManager.settings.todayHubStyle) { _, newStyle in
            withAnimation {
                themeEngine.currentHubStyle = newStyle
            }
        }
    }
}

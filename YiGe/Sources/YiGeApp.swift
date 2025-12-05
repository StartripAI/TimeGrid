//
//  YiGeApp.swift
//  时光格 V3.5.1 - 启动优化版
//

import SwiftUI

@main
struct YiGeApp: App {
    // ⚠️ 关键优化1：使用 @StateObject 的懒加载特性
    // 这些只在真正需要时才初始化
    @StateObject private var dataManager = DataManager()
    @StateObject private var quotesManager = QuotesManager()
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var migrationManager = MigrationManager.shared
    
    @AppStorage("hasSeenOnboarding_V3_2") private var hasSeenOnboarding: Bool = false
    
    // 启动状态机
    @State private var launchPhase: LaunchPhase = .splash
    
    enum LaunchPhase {
        case splash          // 阶段1：轻量级启动屏（立即显示）
        case onboarding      // 阶段2a：引导页（首次用户）
        case mainLoading     // 阶段2b：主界面加载中
        case ready           // 阶段3：主界面就绪
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 根据启动阶段显示不同内容
                switch launchPhase {
                case .splash:
                    // 轻量级启动屏 - 不依赖任何数据，立即显示
                    OptimizedLaunchScreen(phase: $launchPhase)
                    
                case .onboarding:
                    // 引导页 - 也很轻量，不依赖数据
                    OnboardingView(onComplete: {
                            hasSeenOnboarding = true
                        // 引导完成后，先显示加载屏，再进入主界面
                        withAnimation(.easeInOut(duration: 0.3)) {
                            launchPhase = .mainLoading
                        }
                        // 等待数据加载完成后再进入主界面
                        Task { @MainActor in
                            // 确保数据已加载
                            await ensureDataLoaded()
                            // 短暂延迟让用户看到进度
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                launchPhase = .ready
                }
            }
                    })
                    .transition(.opacity)
                    
                case .mainLoading:
                    // 加载主界面数据时的过渡屏
                    OptimizedLaunchScreen(phase: $launchPhase, isLoading: true)
                    
                case .ready:
                    // 主界面 - 只在这里才真正需要数据
                    ContentView()
                        .environmentObject(dataManager)
            .environmentObject(quotesManager)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $authManager.showLoginSheet) {
                LoginView()
            }
            .task {
                await optimizedStartup()
            }
        }
    }
    
    // ⚠️ 关键优化2：优化的启动流程
    private func optimizedStartup() async {
        // 阶段1：立即显示轻量级启动屏（用户看到的第一个画面）
        await MainActor.run {
            launchPhase = .splash
        }
        
        // 阶段2：在后台并行执行初始化任务
        async let dataTask: () = loadDataInBackground()
        async let notificationTask: () = setupNotificationsInBackground()
        async let preloadTask: () = preloadHeavyViews()
        
        // 等待最小显示时间（让用户看到启动动画，至少0.8秒）
        async let minDelay: () = {
            try? await Task.sleep(nanoseconds: 800_000_000)
            return
        }()
        
        // 并行等待所有任务
        _ = await (dataTask, notificationTask, preloadTask, minDelay)
        
        // 阶段3：根据是否首次用户决定下一步
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                if hasSeenOnboarding {
                    // 老用户：直接进入主界面
                    launchPhase = .ready
                } else {
                    // 首次用户：显示引导页（引导页很轻量，不依赖数据）
                    launchPhase = .onboarding
                }
            }
        }
    }
    
    // 后台加载数据（不阻塞UI）
    private func loadDataInBackground() async {
        // DataManager 已经在 init 中异步加载，这里只是确保完成
        // 如果 DataManager 还没加载完，等待一小段时间
        await Task.detached(priority: .userInitiated) {
            // 等待数据加载完成（最多等待2秒）
            var waitCount = 0
            let maxWait = 10 // 最多等待2秒（10 * 200ms）
            
            while waitCount < maxWait {
                // 检查数据是否已加载
                await MainActor.run {
                if !dataManager.records.isEmpty || dataManager.settings != AppSettings.defaultSettings() {
                        return
                    }
                }
                try? await Task.sleep(nanoseconds: 200_000_000) // 每次等待200ms
                waitCount += 1
            }
        }.value
        }
        
    // 后台设置通知（低优先级，不阻塞启动）
    private func setupNotificationsInBackground() async {
        await Task.detached(priority: .utility) {
            // 延迟到主界面显示后再请求通知权限
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 延迟1秒
            
            await MainActor.run {
        NotificationManager.shared.requestPermission { granted in
            if granted && dataManager.settings.notificationEnabled {
                NotificationManager.shared.scheduleDailyReminder(at: dataManager.settings.notificationTime)
            }
        }
        NotificationManager.shared.clearBadge()
    }
        }.value
    }
    
    // ⚠️ 关键优化3：预热重型视图
    private func preloadHeavyViews() async {
        await Task.detached(priority: .utility) {
            // 在后台预编译一些重型视图
            await MainActor.run {
                // 预热 ContentView 的一些子视图
                _ = ArtifactTemplateFactory.self
                // 预热颜色扩展
                _ = Color(hex: "8B4513")
                _ = Color(hex: "C41E3A")
            }
        }.value
    }
    
    // 确保数据已加载
    private func ensureDataLoaded() async {
        // 如果数据还没加载完，等待一下
        var waitCount = 0
        let maxWait = 10 // 最多等待2秒
        
        while waitCount < maxWait {
            // 检查数据是否已加载
            if !dataManager.records.isEmpty || dataManager.settings != AppSettings.defaultSettings() {
                return
            }
            try? await Task.sleep(nanoseconds: 200_000_000) // 每次等待200ms
            waitCount += 1
        }
    }
}

// MARK: - 优化版轻量级启动屏

struct OptimizedLaunchScreen: View {
    @Binding var phase: YiGeApp.LaunchPhase
    var isLoading: Bool = false
    
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var showProgress = false
    @State private var progressValue: CGFloat = 0
    @State private var statusText: String = "正在唤醒时光格..."
    
    var body: some View {
        ZStack {
            // 纯色背景 - 极轻量，不加载图片
            Color(hex: "F5F0E8")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo - 纯文字，不加载图片资源
                VStack(spacing: 8) {
                    Text("Time Grid")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    
                    Text("时光格")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(Color(hex: "1A1A1A").opacity(0.7))
                        .tracking(8)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // 加载提示（仅在加载主界面时显示）
                if isLoading || showProgress {
                    VStack(spacing: 12) {
                        // 极简进度条
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.black.opacity(0.1))
                                    .frame(height: 3)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: "8B4513"))
                                    .frame(width: geo.size.width * progressValue, height: 3)
                            }
                        }
                        .frame(width: 120, height: 3)
                        
                        Text(statusText)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "1A1A1A").opacity(0.4))
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Logo淡入
        withAnimation(.easeOut(duration: 0.4)) {
            logoOpacity = 1
            logoScale = 1
        }
        
        // 显示进度（如果正在加载）
        if isLoading {
            withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                showProgress = true
            }
            
            // 进度条动画
            withAnimation(.easeInOut(duration: 0.8).delay(0.4)) {
                progressValue = 1.0
            }
            
            // 更新状态文字
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                statusText = "正在加载你的时光..."
            }
        }
    }
}

// MARK: - 旧版启动画面（保留用于迁移状态显示）

// V5.0: 改进版启动动画 - 使用动态生成的精美信物预览
struct LaunchScreenView: View {
    @ObservedObject var dataManager: DataManager
    @ObservedObject var migrationManager: MigrationManager
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var currentSlideIndex: Int = 0
    @State private var slideOpacity: Double = 1.0
    @State private var slideScale: CGFloat = 1.0
    @State private var slideBlur: CGFloat = 0
    
    // 四张启动画面配置
    // 第一张：米黄色背景 + Logo（保持不变）
    // 后面三张：精选的精美信物预览
    private let launchSlides: [LaunchSlide] = [
        .logoBackground,  // 第一张：Logo背景
        .artifact(.envelope),  // 皇家诏书
        .artifact(.polaroid),  // 宝丽来
        .artifact(.developedPhoto)  // 王家卫风格
    ]
    
    enum LaunchSlide: Identifiable {
        case logoBackground
        case artifact(RitualStyle)
        
        var id: String {
            switch self {
            case .logoBackground: return "logo"
            case .artifact(let style): return style.rawValue
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 背景层
            ForEach(0..<launchSlides.count, id: \.self) { index in
                launchSlideView(for: launchSlides[index])
                    .opacity(index == currentSlideIndex ? slideOpacity : 0)
                    .scaleEffect(index == currentSlideIndex ? slideScale : 0.95)
                    .blur(radius: index == currentSlideIndex ? slideBlur : 10)
                    .animation(.easeInOut(duration: 0.8), value: slideOpacity)
                    .animation(.easeInOut(duration: 0.8), value: slideScale)
                    .animation(.easeInOut(duration: 0.8), value: slideBlur)
            }
            
            // Logo和文字（显示在动画上方）
            VStack(spacing: 20) {
                // Logo - Time Grid 时光格
                VStack(spacing: 8) {
                    Text("Time Grid")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                    
                    Text("时光格")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 3)
                }
                
                // V4.1: 迁移状态提示
                if migrationManager.isMigrating {
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("正在迁移数据...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                }
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
        .onAppear {
            // Logo动画
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // 启动画面轮播动画
            startSlideCarousel()
        }
    }
    
    @ViewBuilder
    private func launchSlideView(for slide: LaunchSlide) -> some View {
        switch slide {
        case .logoBackground:
            // 第一张：米黄色背景（保持原样）
            if let image = UIImage(named: "launch1") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                // 如果没有图片，使用米黄色渐变背景
                LinearGradient(
                    colors: [
                        Color(hex: "F5F0E8"),
                        Color(hex: "E8DCC8")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
        case .artifact(let style):
            // 动态生成精美的信物预览
            LaunchArtifactPreview(style: style)
        }
    }
    
    private func startSlideCarousel() {
        // 第一张显示2秒（Logo背景）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            nextSlide()
        }
    }
    
    private func nextSlide() {
        // 淡出当前画面
        withAnimation(.easeInOut(duration: 0.6)) {
            slideOpacity = 0
            slideScale = 0.95
            slideBlur = 10
            }
            
        // 切换到下一张
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentSlideIndex = (currentSlideIndex + 1) % launchSlides.count
            
            // 淡入新画面（从模糊到清晰）
            slideBlur = 15
            slideScale = 0.9
            
            withAnimation(.easeInOut(duration: 0.8)) {
                slideOpacity = 1.0
                slideScale = 1.0
                slideBlur = 0
            }
            
            // 继续轮播（每张显示1.8秒）
            if currentSlideIndex > 0 { // 跳过第一张，因为已经显示过了
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    nextSlide()
                }
            }
        }
    }
}

// MARK: - 启动画面信物预览组件

struct LaunchArtifactPreview: View {
    let style: RitualStyle
    @State private var content: String = ""
    @State private var photoOpacity: Double = 0
    
    // 为每个信物生成示例内容
    private var sampleContent: String {
        switch style {
        case .envelope:
            return "一封来自时光的信\n记录今日的温暖"
        case .polaroid:
            return "这一刻\n值得珍藏"
        case .developedPhoto:
            return "光影之间\n定格永恒"
        default:
            return "时光格\n记录美好"
        }
    }
    
    var body: some View {
        ZStack {
            // 背景渐变（根据信物风格）
            backgroundGradient
            
            // 信物预览（居中，稍微缩小）
            ArtifactTemplateFactory.makeView(for: sampleRecord)
                .frame(width: 280, height: 420)
                .scaleEffect(0.85)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                .opacity(photoOpacity)
        }
        .ignoresSafeArea()
        .onAppear {
            // 淡入动画
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                photoOpacity = 1.0
            }
        }
    }
    
    private var backgroundGradient: some View {
        switch style {
        case .envelope:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "F5F0E8"),
                        Color(hex: "E8DCC8"),
                        Color(hex: "D4C4B0")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .polaroid:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "2C2C2C"),
                        Color(hex: "1A1A1A"),
                        Color(hex: "0D0D0D")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .developedPhoto:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "1A1A2E"),
                        Color(hex: "0F0F1E"),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "F5F0E8"),
                        Color(hex: "E8DCC8")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    private var sampleRecord: DayRecord {
        DayRecord(
            date: Date(),
            content: sampleContent,
            mood: .joyful,
            weather: .sunny,
            artifactStyle: style,
            aestheticDetails: AestheticDetails.generate(for: style, customColorHex: nil)
        )
    }
}


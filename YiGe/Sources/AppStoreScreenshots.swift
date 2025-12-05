//
//  AppStoreScreenshots.swift
//  时光格 - App Store 截图生成器
//
//  使用方法：
//  1. 打开此文件，点击左侧预览窗口
//  2. 点击 Resume 让预览运行
//  3. 点击每个预览窗口右上角的相机图标导出截图
//  4. 或使用 Command + S 快速导出
//

import SwiftUI

// MARK: - 预览包装器（提供必要的环境对象）

struct ScreenshotWrapper<Content: View>: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var quotesManager = QuotesManager()
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(dataManager)
            .environmentObject(quotesManager)
            // DataManager 会在 init 时自动加载，无需手动调用
    }
}

// MARK: - 主页面截图

struct MainScreenshot: View {
    var body: some View {
        ScreenshotWrapper {
            ContentView()
        }
    }
}

// MARK: - 今日首页截图

struct TodayScreenshot: View {
    var body: some View {
        ScreenshotWrapper {
            TodayView()
        }
    }
}

// MARK: - 倒数日历截图

struct CountdownScreenshot: View {
    var body: some View {
        ScreenshotWrapper {
            CountdownView()
        }
    }
}

// MARK: - 时光洞察截图

struct ProfileScreenshot: View {
    var body: some View {
        ScreenshotWrapper {
            ProfileView()
        }
    }
}

// MARK: - 新建记录截图（带示例数据）

struct NewRecordScreenshot: View {
    var body: some View {
        ScreenshotWrapper {
            NewRecordView(recordDate: Date())
        }
    }
}

// MARK: - 记录详情截图（带示例数据）

struct RecordDetailScreenshot: View {
    let sampleRecord: DayRecord
    
    init() {
        // 创建示例记录
        self.sampleRecord = DayRecord(
            date: Date(),
            content: "今天是一个特别的日子，我记录下了这一刻的美好时光。",
            mood: .happy,
            photos: [],
            weather: .sunny,
            isSealed: true,
            sealedAt: Date().addingTimeInterval(-86400),
            artifactStyle: .envelope
        )
    }
    
    var body: some View {
        ScreenshotWrapper {
            RecordDetailView(record: sampleRecord)
        }
    }
}

// MARK: - 高定信物系列截图（展示升级后的精致效果）

struct HighCoutureArtifactScreenshot: View {
    let style: RitualStyle
    let title: String
    
    init(style: RitualStyle, title: String) {
        self.style = style
        self.title = title
    }
    
    var body: some View {
        ScreenshotWrapper {
            ZStack {
                // 柔光摄影棚背景
                Color(hex: "F5F5F0").ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text(title)
                        .font(.custom("Didot", size: 32))
                        .foregroundColor(Color(hex: "382822"))
                        .padding(.top, 60)
                    
                    // 展示高定信物
                    let sampleRecord = DayRecord(
                        date: Date(),
                        content: "这一刻，被永恒定格。",
                        mood: .happy,
                        photos: [],
                        weather: .sunny,
                        artifactStyle: style,
                        aestheticDetails: AestheticDetails.generate(for: style)
                    )
                    
                    ArtifactTemplateFactory.makeView(for: sampleRecord)
                        .scaleEffect(0.9)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 高定系列预览

struct RoyalDecreeScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .envelope,
            title: "The Royal Decree"
        )
    }
}

struct ClassifiedScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .vault,
            title: "The Classified"
        )
    }
}

struct NolanScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .filmNegative,
            title: "The Nolan"
        )
    }
}

struct WongKarWaiScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .developedPhoto,
            title: "The Wong Kar-wai"
        )
    }
}

struct VogueCoverScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .simple,
            title: "The Vogue Cover"
        )
    }
}

struct PolaroidScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .polaroid,
            title: "The Polaroid SX-70"
        )
    }
}

struct VinylScreenshot: View {
    var body: some View {
        HighCoutureArtifactScreenshot(
            style: .vinylRecord,
            title: "The Vinyl"
        )
    }
}

// MARK: - Preview Provider

struct AppStoreScreenshots: PreviewProvider {
    static var previews: some View {
        Group {
            // ========== 1284 × 2778px（iPhone 17 Pro Max - 竖屏）==========
            // 这是 App Store 要求的最大尺寸
            MainScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - 主页面")
            
            TodayScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - 今日首页")
            
            CountdownScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - 倒数日历")
            
            NewRecordScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - 新建记录")
            
            RecordDetailScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - 记录详情")
            
            // ========== 高定信物系列截图 ==========
            RoyalDecreeScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Royal Decree")
            
            ClassifiedScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Classified")
            
            NolanScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Nolan")
            
            WongKarWaiScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Wong Kar-wai")
            
            VogueCoverScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Vogue Cover")
            
            PolaroidScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Polaroid")
            
            VinylScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewDisplayName("1284×2778 - Vinyl")
            
            // ========== 1242 × 2688px（iPhone 15 Pro Max / 14 Pro Max - 竖屏）==========
            // 如果 17 Pro Max 不可用，使用这个
            MainScreenshot()
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("1242×2688 - 主页面")
            
            TodayScreenshot()
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("1242×2688 - 今日首页")
            
            CountdownScreenshot()
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("1242×2688 - 倒数日历")
            
            // ========== 横屏版本（可选，App Store 也接受横屏截图）==========
            // 2778 × 1284px（横屏）
            MainScreenshot()
                .previewDevice("iPhone 17 Pro Max")
                .previewInterfaceOrientation(.landscape)
                .previewDisplayName("2778×1284 - 主页面(横屏)")
            
            // 2688 × 1242px（横屏）
            MainScreenshot()
                .previewDevice("iPhone 15 Pro Max")
                .previewInterfaceOrientation(.landscape)
                .previewDisplayName("2688×1242 - 主页面(横屏)")
        }
        }
        }

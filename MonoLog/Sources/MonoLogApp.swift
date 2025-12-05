import SwiftUI
import SwiftData

@main
struct MonoLogApp: App {
    // 配置 SwiftData 容器
    let modelContainer: ModelContainer
    
    init() {
        do {
            // 配置模型容器以使用 ReceiptEntry 模型
            modelContainer = try ModelContainer(for: ReceiptEntry.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
        .preferredColorScheme(.light) // 保持浅色风格
    }
}


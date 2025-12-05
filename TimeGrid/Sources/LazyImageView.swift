//
//  LazyImageView.swift
//  时光格 V4.1 - 异步图片加载和缓存
//
//  性能优化：延迟加载图片，使用内存缓存

import SwiftUI
import UIKit

// MARK: - 图片缓存

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    init() {
        // V4.3: 优化缓存限制
        ImageCache.shared.countLimit = 100 // 最多缓存 100 张图片
        ImageCache.shared.totalCostLimit = 200 * 1024 * 1024 // 200MB
        // 设置缓存名称（用于调试）
        ImageCache.shared.name = "TimeGridImageCache"
    }
    
    // V4.3: 预加载图片到缓存（用于优化列表滚动性能）
    static func preloadImages(ids: [String]) {
        Task.detached(priority: .utility) {
            for id in ids {
                // 如果不在缓存中，异步加载
                if ImageCache.shared.object(forKey: id as NSString) == nil {
                    if let image = await ImageFileManager.shared.loadImage(id: id) {
                        ImageCache.shared.setObject(image, forKey: id as NSString)
                    }
                }
            }
        }
    }
}

// MARK: - 异步图片视图

struct LazyImageView: View {
    let imageID: String
    let placeholder: Image?
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadFailed = false
    
    init(
        imageID: String,
        placeholder: Image? = nil,
        contentMode: ContentMode = .fill
    ) {
        self.imageID = imageID
        self.placeholder = placeholder ?? Image(systemName: "photo")
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                // 加载中占位符
                ZStack {
                    Color("BackgroundCream")
                    ProgressView()
                        .tint(Color("PrimaryWarm"))
                }
            } else if loadFailed {
                // 加载失败占位符
                placeholder?
                    .foregroundColor(Color("TextSecondary").opacity(0.3))
            } else {
                // 默认占位符
                placeholder?
                    .foregroundColor(Color("TextSecondary").opacity(0.3))
            }
        }
        .task(id: imageID) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // 1. 检查缓存（NSCache 是线程安全的）
        if let cachedImage = ImageCache.shared.object(forKey: imageID as NSString) {
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
                self.loadFailed = false
            }
            return
        }
        
        // 2. 从文件系统加载（在后台线程）
        await MainActor.run {
            self.isLoading = true
            self.loadFailed = false
        }
        
        let loadedImage = await ImageFileManager.shared.loadImage(id: imageID)
        
        // 3. 更新UI（回到主线程）
        await MainActor.run {
            if let img = loadedImage {
                self.image = img
                self.loadFailed = false
                // 存入缓存
                ImageCache.shared.setObject(img, forKey: imageID as NSString)
            } else {
                self.loadFailed = true
            }
            self.isLoading = false
        }
    }
}

// MARK: - 预览

#Preview {
    LazyImageView(imageID: "test-id")
        .frame(width: 200, height: 200)
}


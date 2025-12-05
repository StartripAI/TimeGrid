//
//  ImageFileManager.swift
//  时光格 V4.2 - 图片文件系统管理
//
//  性能优化：将图片从 UserDefaults 迁移到文件系统
//  V4.2: 添加信物图片管理

import Foundation
import UIKit

// V4.1: 确保类可以被其他文件访问
public class ImageFileManager {
    public static let shared = ImageFileManager()
    
    private let fileManager = FileManager.default
    private let photosDirectoryName = "YiGePhotos_V4_1"
    private let artifactsDirectoryName = "YiGeArtifacts_V4_2" // V4.2: 信物图片目录
    
    private init() {
        createPhotosDirectoryIfNeeded()
        createArtifactsDirectoryIfNeeded() // V4.2: 创建信物目录
    }
    
    // MARK: - 目录管理
    
    private func getPhotosDirectory() -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(photosDirectoryName)
    }
    
    private func createPhotosDirectoryIfNeeded() {
        guard let photosURL = getPhotosDirectory() else { return }
        
        if !fileManager.fileExists(atPath: photosURL.path) {
            try? fileManager.createDirectory(at: photosURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - V4.2 信物目录管理
    
    private func getArtifactsDirectory() -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(artifactsDirectoryName)
    }
    
    private func createArtifactsDirectoryIfNeeded() {
        guard let artifactsURL = getArtifactsDirectory() else { return }
        
        if !fileManager.fileExists(atPath: artifactsURL.path) {
            try? fileManager.createDirectory(at: artifactsURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - 图片保存和加载
    
    /// 保存图片 Data 到文件系统，返回 ID
    public func saveImage(data: Data) -> String? {
        guard let photosURL = getPhotosDirectory() else { return nil }
        let imageID = UUID().uuidString
        let fileURL = photosURL.appendingPathComponent("\(imageID).jpg")
        
        do {
            // V4.1 优化：压缩图片质量 (0.8) 以减少存储空间
            let finalData: Data
            if let image = UIImage(data: data),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                finalData = compressedData
            } else {
                finalData = data
            }
            
            try finalData.write(to: fileURL, options: .atomic)
            return imageID
        } catch {
            print("ImageFileManager: Failed to save image - \(error)")
            return nil
        }
    }
    
    /// 异步加载图片
    public func loadImage(id: String) async -> UIImage? {
        guard let photosURL = getPhotosDirectory() else { return nil }
        let fileURL = photosURL.appendingPathComponent("\(id).jpg")
        
        // 在后台线程执行 I/O 和解码
        return await Task.detached(priority: .userInitiated) {
            return UIImage(contentsOfFile: fileURL.path)
        }.value
    }
    
    /// 同步加载图片（用于需要立即显示的场合）
    public func loadImageSync(id: String) -> UIImage? {
        guard let photosURL = getPhotosDirectory() else { return nil }
        let fileURL = photosURL.appendingPathComponent("\(id).jpg")
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// 删除图片文件
    public func deleteImage(id: String) {
        guard let photosURL = getPhotosDirectory() else { return }
        let fileURL = photosURL.appendingPathComponent("\(id).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// 批量删除图片
    public func deleteImages(ids: [String]) {
        for id in ids {
            deleteImage(id: id)
        }
    }
    
    /// 获取图片文件大小（用于调试）
    func getImageSize(id: String) -> Int64? {
        guard let photosURL = getPhotosDirectory() else { return nil }
        let fileURL = photosURL.appendingPathComponent("\(id).jpg")
        
        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let size = attributes[.size] as? Int64 else {
            return nil
        }
        return size
    }
    
    // MARK: - V4.2 信物图片管理
    
    /// 保存渲染后的信物图片
    public func saveArtifact(image: UIImage) -> String? {
        guard let artifactsURL = getArtifactsDirectory() else { return nil }
        
        // V4.2: 使用高质量压缩（0.9）以保持信物图片的清晰度
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        
        let artifactID = UUID().uuidString
        let fileURL = artifactsURL.appendingPathComponent("\(artifactID).jpg")
        
        do {
            try data.write(to: fileURL, options: Data.WritingOptions.atomic)
            return artifactID
        } catch {
            print("ImageFileManager: Failed to save artifact - \(error)")
            return nil
        }
    }
    
    /// 异步加载信物图片（用于 UI 显示）
    public func loadArtifact(id: String) async -> UIImage? {
        guard let artifactsURL = getArtifactsDirectory() else { return nil }
        let fileURL = artifactsURL.appendingPathComponent("\(id).jpg")
        
        return await Task.detached(priority: .userInitiated) {
            return UIImage(contentsOfFile: fileURL.path)
        }.value
    }
    
    /// 同步加载信物图片（用于渲染时确保图片已加载）
    public func loadArtifactSync(id: String) -> UIImage? {
        guard let artifactsURL = getArtifactsDirectory() else { return nil }
        let fileURL = artifactsURL.appendingPathComponent("\(id).jpg")
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// 删除信物图片文件
    public func deleteArtifact(id: String) {
        guard let artifactsURL = getArtifactsDirectory() else { return }
        let fileURL = artifactsURL.appendingPathComponent("\(id).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
}

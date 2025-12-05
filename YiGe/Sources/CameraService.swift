//
//  CameraService.swift
//  时光格 V3.5.1 - 相机服务（修复版）
//
//  修复：
//  - 添加完善的错误处理
//  - 添加相机可用性检测
//  - 添加模拟器检测
//  - 添加权限状态跟踪
//

import AVFoundation
import UIKit
import Combine

enum CameraError: Error, LocalizedError {
    case notAuthorized
    case notAvailable
    case configurationFailed
    case captureFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "未获得相机权限"
        case .notAvailable:
            return "相机不可用"
        case .configurationFailed:
            return "相机配置失败"
        case .captureFailed:
            return "拍照失败"
        }
    }
}

final class CameraService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var isSessionReady = false
    @Published var isCapturing = false
    @Published var error: CameraError?
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.shiguangge.camera.queue")
    private var isConfigured = false
    
    // MARK: - Computed Properties
    
    /// 检测是否在模拟器上运行
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 相机是否可用
    var isCameraAvailable: Bool {
        // 模拟器没有相机
        if CameraService.isSimulator {
            return false
        }
        // 检查是否有视频设备
        return AVCaptureDevice.default(for: .video) != nil
    }
    
    // MARK: - Public Methods
    
    /// 准备相机会话
    func prepareSession() {
        // 更新当前权限状态
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        // 检查相机可用性
        guard isCameraAvailable else {
            DispatchQueue.main.async {
                self.error = .notAvailable
            }
            return
        }
        
        // 如果已配置，直接启动
        if isConfigured {
            startSession()
            return
        }
        
        // 请求权限并配置
        Task {
            await requestAccessAndSetup()
        }
    }
    
    /// 拍照
    func capturePhoto() {
        guard isSessionReady, !isCapturing else {
            print("⚠️ CameraService: Cannot capture - session not ready or already capturing")
            return
        }
        
        isCapturing = true
        
        let settings = AVCapturePhotoSettings()
        
        // V3.5.1 修复: 使用新的 API 替代已弃用的 isHighResolutionPhotoEnabled
        // iOS 16+ 使用 maxPhotoDimensions 来控制分辨率
        if #available(iOS 16.0, *) {
            // 设置最大照片尺寸为高分辨率（4032×3024 是常见的 12MP 分辨率）
            // maxPhotoDimensions 需要 CMVideoDimensions 类型
            settings.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
        } else {
            // iOS 15 及以下使用旧 API
            if photoOutput.isHighResolutionCaptureEnabled {
                settings.isHighResolutionPhotoEnabled = true
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// 停止会话
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            DispatchQueue.main.async {
                self.isSessionReady = false
            }
        }
    }
    
    /// 重置错误
    func resetError() {
        error = nil
    }
    
    /// 重置拍摄状态（用于重新拍摄）
    func reset() {
        capturedImage = nil
        error = nil
        isCapturing = false
        prepareSession()
    }
    
    // MARK: - Private Methods
    
    private func requestAccessAndSetup() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        await MainActor.run {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorized:
            setupSession()
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            if granted {
                setupSession()
            } else {
                await MainActor.run {
                    self.error = .notAuthorized
                }
            }
            
        case .denied, .restricted:
            await MainActor.run {
                self.error = .notAuthorized
            }
            
        @unknown default:
            await MainActor.run {
                self.error = .notAuthorized
            }
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // 获取相机设备
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.error = .notAvailable
                }
                return
            }
            
            // 添加输入
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                guard self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async {
                        self.error = .configurationFailed
                    }
                    return
                }
                
                self.session.addInput(input)
            } catch {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.error = .configurationFailed
                }
                return
            }
            
            // 添加输出
            guard self.session.canAddOutput(self.photoOutput) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.error = .configurationFailed
                }
                return
            }
            
            self.session.addOutput(self.photoOutput)
            
            // V3.5.1 修复: 使用新的 API 替代已弃用的 isHighResolutionCaptureEnabled
            if #available(iOS 16.0, *) {
                // iOS 16+ 不需要单独设置，在 capturePhoto 时通过 maxPhotoDimensions 控制
            } else {
                // iOS 15 及以下使用旧 API
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            self.session.commitConfiguration()
            self.isConfigured = true
            
            // 启动会话
            self.startSession()
        }
    }
    
    private func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.session.isRunning {
                self.session.startRunning()
            }
            
            DispatchQueue.main.async {
                self.isSessionReady = self.session.isRunning
                if !self.session.isRunning {
                    self.error = .configurationFailed
                }
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isCapturing = false
        }
        
        if let error = error {
            print("❌ CameraService: Capture error - \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.error = .captureFailed
            }
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("❌ CameraService: Failed to get image data")
            DispatchQueue.main.async { [weak self] in
                self?.error = .captureFailed
            }
            return
        }
        
        // 修正图片方向
        let correctedImage = image.fixOrientation()
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = correctedImage
            print("✅ CameraService: Photo captured successfully")
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// 修正图片方向
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}


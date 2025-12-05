//
//  CustomCameraView.swift
//  时光格 V3.5.1 - 自定义相机（修复版）
//
//  修复：
//  - 添加相机不可用时的回退方案（相册选择）
//  - 添加错误提示UI
//  - 添加模拟器检测
//  - 优化状态管理
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CustomCameraView: View {
    @StateObject private var cameraService = CameraService()
    
    let onPhotoTaken: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var shutterOpacity: Double = 0
    @State private var isDeveloping = false
    @State private var developedImage: UIImage?
    @State private var showingPhotosPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 根据状态显示不同内容
            if cameraService.error != nil {
                // 错误状态 - 显示回退选项
                errorView
            } else if !cameraService.isCameraAvailable {
                // 相机不可用（如模拟器）- 显示回退选项
                cameraUnavailableView
            } else if cameraService.isSessionReady {
                // 相机就绪 - 显示预览
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                // 加载中
                loadingView
            }
            
            // 取景器叠加层（仅在相机就绪时显示）
            if cameraService.isSessionReady && !isDeveloping {
                ViewfinderOverlay(
                    onCapture: triggerCapture,
                    onCancel: cancel,
                    onSelectFromLibrary: { showingPhotosPicker = true }
                )
            }
            
            // 快门闪烁效果
            Color.white
                .opacity(shutterOpacity)
                .ignoresSafeArea()
            
            // 显影动画
            if isDeveloping {
                DevelopingOverlay(image: developedImage) { image in
                    onPhotoTaken(image)
                }
            }
        }
        .onAppear {
            cameraService.prepareSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .onChange(of: cameraService.capturedImage) { _, newImage in
            guard let image = newImage else { return }
            handleCapturedImage(image)
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await loadSelectedPhoto(newItem)
            }
        }
        .alert("需要相机权限", isPresented: $showingPermissionAlert) {
            Button("去设置") {
                openSettings()
            }
            Button("从相册选择") {
                showingPhotosPicker = true
            }
            Button("取消", role: .cancel) {
                onCancel()
            }
        } message: {
            Text("请在设置中允许时光格访问您的相机，或者从相册选择照片。")
        }
    }
    
    // MARK: - Sub Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("正在启动相机...")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text(cameraService.error?.localizedDescription ?? "相机出错")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if cameraService.error == .notAuthorized {
                    Button {
                        openSettings()
                    } label: {
                        Text("前往设置")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color("PrimaryWarm"))
                            .cornerRadius(25)
                    }
                }
                
                Button {
                    showingPhotosPicker = true
                } label: {
                    Text("从相册选择")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("PrimaryWarm"))
                        .frame(width: 200, height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                }
                
                Button {
                    onCancel()
                } label: {
                    Text("取消")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 10)
            }
        }
    }
    
    private var cameraUnavailableView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("相机不可用")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                if CameraService.isSimulator {
                    Text("模拟器不支持相机功能")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            VStack(spacing: 12) {
                Button {
                    showingPhotosPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text("从相册选择")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color("PrimaryWarm"))
                    .cornerRadius(25)
                }
                
                Button {
                    onCancel()
                } label: {
                    Text("取消")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Actions
    
    private func triggerCapture() {
        // 快门动画
        withAnimation(.easeInOut(duration: 0.08)) {
            shutterOpacity = 0.8
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        cameraService.capturePhoto()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.15)) {
                shutterOpacity = 0
            }
        }
    }
    
    private func cancel() {
        cameraService.stopSession()
        onCancel()
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        cameraService.stopSession()
        developedImage = image
        withAnimation(.easeInOut(duration: 0.3)) {
            isDeveloping = true
        }
    }
    
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    handleCapturedImage(image)
                }
            }
        } catch {
            print("❌ Failed to load photo: \(error)")
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Camera Preview

private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // 确保 session 正确连接
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
    }
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}

// MARK: - Viewfinder Overlay

private struct ViewfinderOverlay: View {
    let onCapture: () -> Void
    let onCancel: () -> Void
    let onSelectFromLibrary: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("仪式拍摄")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                // 占位，保持对称
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 50)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            )
            
            Spacer()
            
            // 取景框
            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    // 中心十字
                    path.move(to: CGPoint(x: w / 2 - 15, y: h / 2))
                    path.addLine(to: CGPoint(x: w / 2 + 15, y: h / 2))
                    path.move(to: CGPoint(x: w / 2, y: h / 2 - 15))
                    path.addLine(to: CGPoint(x: w / 2, y: h / 2 + 15))
                    
                    let margin: CGFloat = 40
                    let length: CGFloat = 35
                    
                    // 四角
                    // 左上
                    path.move(to: CGPoint(x: margin, y: margin + length))
                    path.addLine(to: CGPoint(x: margin, y: margin))
                    path.addLine(to: CGPoint(x: margin + length, y: margin))
                    
                    // 右上
                    path.move(to: CGPoint(x: w - margin - length, y: margin))
                    path.addLine(to: CGPoint(x: w - margin, y: margin))
                    path.addLine(to: CGPoint(x: w - margin, y: margin + length))
                    
                    // 左下
                    path.move(to: CGPoint(x: margin, y: h - margin - length))
                    path.addLine(to: CGPoint(x: margin, y: h - margin))
                    path.addLine(to: CGPoint(x: margin + length, y: h - margin))
                    
                    // 右下
                    path.move(to: CGPoint(x: w - margin - length, y: h - margin))
                    path.addLine(to: CGPoint(x: w - margin, y: h - margin))
                    path.addLine(to: CGPoint(x: w - margin, y: h - margin - length))
                }
                .stroke(Color("PrimaryWarm"), lineWidth: 1.5)
            }
            
            Spacer()
            
            // 底部控制栏
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                
                HStack(spacing: 60) {
                    // 相册按钮
                    Button(action: onSelectFromLibrary) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                    }
                    
                    // 快门按钮
                    Button(action: onCapture) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(Color("SealColor"))
                                .frame(width: 64, height: 64)
                        }
                    }
                    
                    // 占位
                    Color.clear.frame(width: 50, height: 50)
                }
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Developing Overlay (显影动画)

private struct DevelopingOverlay: View {
    let image: UIImage?
    let onComplete: (UIImage) -> Void
    
    @State private var progress: Double = 0
    @State private var cardOffset: CGFloat = 500
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 🎨 Hermes-Inspired Luxury Background (Parchment + Gold Accents)
                LuxuryDevelopingBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    if let image = image {
                        // 🖼 Enlarged Polaroid Card (70% of screen width)
                        let cardWidth = geo.size.width * 0.75
                        let imageHeight = cardWidth * 1.1 // Slightly taller for polaroid proportion
                        
                        VStack(spacing: 0) {
                            // Photo area with developing effect
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardWidth, height: imageHeight)
                                .clipped()
                                .mask(
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: .black, location: 0),
                                                    .init(color: .black, location: progress),
                                                    .init(color: .clear, location: min(1, progress + 0.01))
                                                ]),
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                )
                            
                            // Bottom white border (Polaroid signature)
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFFEF8"), Color(hex: "FBF8F0")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: cardWidth, height: cardWidth * 0.25)
                                .overlay(
                                    VStack(spacing: 8) {
                                        if progress >= 1 {
                                            // ✨ Completed state
                                            HStack(spacing: 6) {
                                                Text("📸")
                                                    .font(.system(size: 18))
                                                Text("已显影")
                                                    .font(.custom("DINCondensed-Bold", size: 20))
                                                    .tracking(2)
                                            }
                                            .foregroundColor(Color(hex: "D4AF37"))
                                            
                                            Text("DEVELOPED")
                                                .font(.system(size: 11, weight: .medium, design: .serif))
                                                .tracking(1.5)
                                                .foregroundColor(Color(hex: "8B7355").opacity(0.6))
                                        } else {
                                            // ⏳ Developing state
                                            Text("显影中...")
                                                .font(.custom("PingFang SC", size: 17))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(hex: "2F2F2F"))
                                            
                                            Text("\(Int(progress * 100))%")
                                                .font(.system(size: 14, design: .monospaced))
                                                .foregroundColor(Color(hex: "2F2F2F").opacity(0.5))
                                        }
                                    }
                                )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 20)
                        .overlay(
                            // 🌟 Gold foil edge reflection (Hermes detail)
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D4AF37").opacity(0.3),
                                            Color.clear,
                                            Color(hex: "D4AF37").opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .offset(y: cardOffset)
                    }
                    
                    Spacer()
                    
                    // ✅ Enhanced confirmation button
                    if showButton, let image = image {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onComplete(image)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18))
                                Text("使用这张照片")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white)
                            .frame(width: geo.size.width * 0.7, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "D4AF37"), Color(hex: "C19A2E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color(hex: "D4AF37").opacity(0.5), radius: 15, y: 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)).combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer().frame(height: 60)
                }
            }
        }
        .onAppear {
            startDevelopingAnimation()
        }
    }
    
    private func startDevelopingAnimation() {
        // 卡片滑入
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
            cardOffset = 0
        }
        
        // 显影动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.5)) {
                progress = 1
            }
        }
        
        // 显示按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.spring(response: 0.4)) {
                showButton = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

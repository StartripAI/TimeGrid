import SwiftUI

// 负责播放"打印"仪式动画
struct PrintingAnimationView: View {
    let entry: ReceiptEntry
    let processedImage: UIImage?
    let onComplete: (UIImage?) -> Void
    
    @State private var printProgress: CGFloat = 0.0
    @State private var renderedOutput: UIImage?
    @State private var showSkipButton = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.opacity(0.85)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 要打印的小票内容 (使用墨迹效果)
                    let receipt = ReceiptView(entry: entry, processedImage: processedImage, applyInkBleed: true)
                    
                    receipt
                        .frame(width: min(geometry.size.width * 0.9, 320))
                        // 核心动画：使用 mask(alignment: .top) 模拟逐行打印并滑出
                        .mask(alignment: .top) {
                            GeometryReader { receiptGeometry in
                                Rectangle()
                                    // Mask的高度根据进度变化
                                    .frame(height: receiptGeometry.size.height * printProgress)
                            }
                        }
                        .shadow(color: .black.opacity(0.5), radius: 20)

                    // "打印口" UI元素
                    PrinterSlotView()
                }
                
                // 跳过按钮（动画开始后显示）
                if showSkipButton {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                skipAnimation()
                            } label: {
                                Text("跳过")
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(20)
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 60)
                        }
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    @MainActor
    private func renderImage() {
        // 渲染用于保存的图像。关键：渲染时不应用墨迹模糊(applyInkBleed: false)。
        let receiptForRender = ReceiptView(entry: entry, processedImage: processedImage, applyInkBleed: false)
        
        let renderer = ImageRenderer(content: receiptForRender)
        renderer.scale = 3.0 // 高清渲染
        self.renderedOutput = renderer.uiImage
    }

    func startAnimation() {
        renderImage()
        
        // 震动反馈设置
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        let animationDuration = 2.5
        
        // 显示跳过按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                showSkipButton = true
            }
        }
        
        // 使用定时器模拟连续的轻微震动 (仪式感增强)
        var vibrationCount = 0
        let maxVibrations = Int(animationDuration / 0.08)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            vibrationCount += 1
            if vibrationCount <= maxVibrations {
                generator.impactOccurred(intensity: 0.4)
            } else {
                timer.invalidate()
            }
        }
        
        // 开始视觉动画
        withAnimation(.easeOut(duration: animationDuration)) {
            printProgress = 1.0
        }
        
        // 完成
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            timer.invalidate() // 停止震动
            completeAnimation()
        }
    }
    
    private func skipAnimation() {
        // 快速完成动画
        withAnimation(.easeOut(duration: 0.3)) {
            printProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completeAnimation()
        }
    }
    
    private func completeAnimation() {
        // 结束反馈
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // 隐藏跳过按钮
        withAnimation {
            showSkipButton = false
        }
        
        // 延迟一点再回调，让用户看到完整小票
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete(renderedOutput)
        }
    }
}

// MARK: - 模拟打印机的出纸口
struct PrinterSlotView: View {
    var body: some View {
        ZStack {
            // 打印机主体
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.25), Color(white: 0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 70)
            
            // 中间的黑色缝隙
            VStack(spacing: 2) {
                // 上边缘高光
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                
                // 出纸口
                Capsule()
                    .fill(Color.black)
                    .frame(height: 10)
                    .shadow(color: .black, radius: 2, y: 2)
                
                // 下边缘阴影
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 30)
            
            // 装饰性指示灯
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 6, height: 6)
                    .shadow(color: .green.opacity(0.5), radius: 3)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    PrintingAnimationView(
        entry: ReceiptEntry(content: "测试内容", imageData: nil),
        processedImage: nil
    ) { _ in }
}


//
//  RecordStyleViews.swift
//  时光格 V3.3 - 时光信物视觉与封存动画
//
//  三种可选风格：
//  1. 经典信笺 (Classic Letter) - 温暖复古，蜡封盖章仪式
//  2. 时光小票 (Mono Ticket) - 热敏打印风格，逐行打印仪式
//  3. 流光邀约 (Gala Invite) - 电影节邀请函，烫金流光仪式
//

import SwiftUI
import UIKit  // V4.1: ImageFileManager 需要 UIKit
import CoreImage.CIFilterBuiltins  // V3.3: QR 码生成

// MARK: - ============================================
// MARK: - 1. 经典信笺 (Classic Letter) - V3.2 升级
// MARK: - ============================================

// V3.3: 信物内容 - 用户拆封后看到和分享的
struct EnvelopeArtifactView: View {
    let record: DayRecord
    
    // V3.3: 使用存储的随机背景色
    private var backgroundColor: Color {
        if let hex = record.aestheticDetails?.letterBackgroundColorHex {
            return Color(hex: hex)
        }
        return Color("CardBackground")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header（增强版：添加优雅手写日期）
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    ElegantHandwrittenDate(date: record.date)
                    if let location = record.location?.placeName {
                        Text(location)
                            .font(.system(size: 10))
                            .foregroundColor(Color("TextSecondary").opacity(0.6))
                    }
                }
                Spacer()
                Text(record.mood.emoji)
                    .font(.system(size: 32))
            }
            
            // 装饰分隔线
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color("TextSecondary").opacity(0.2))
                    .frame(height: 1)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color("TextSecondary").opacity(0.3))
                
                Rectangle()
                    .fill(Color("TextSecondary").opacity(0.2))
                    .frame(height: 1)
            }
            
            // 照片（如有）
            // V4.0: 使用 photos 数组，多张照片水平排列
            if !record.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                            if let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // 内容
            if !record.content.isEmpty {
                Text(record.content)
                    .font(.system(size: 16, design: .serif))
                    .lineSpacing(8)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Spacer(minLength: 20)
            
            // 签名
            HStack {
                // 天气图标
                if let weather = record.weather {
                    HStack(spacing: 4) {
                        Image(systemName: weather.icon)
                            .font(.system(size: 14))
                        Text(weather.label)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color("TextSecondary").opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Yours,")
                        .font(.custom("Snell Roundhand", size: 22))
                        .foregroundColor(Color("TextPrimary").opacity(0.7))
                    
                    Text(record.formattedElegantTimestamp)
                        .font(.system(size: 10))
                        .foregroundColor(Color("TextSecondary").opacity(0.5))
                }
            }
        }
        .padding(30)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - V3.2 容器：英式蜡封信封（等待期显示）

struct SealedEnvelopeContainer: View {
    let record: DayRecord
    
    // V3.3: 使用存储的美学细节
    private var sealDesign: WaxSealDesign {
        record.aestheticDetails?.waxSealDesign ?? .initialY
    }
    
    private var sealRotation: Double {
        record.aestheticDetails?.sealRotationDegrees ?? 0
    }
    
    private var backgroundColor: Color {
        if let hex = record.aestheticDetails?.letterBackgroundColorHex {
            return Color(hex: hex)
        }
        return Color("TicketPaper")
    }
    
    var body: some View {
        ZStack {
            // 信封主体
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
            
            // 信封线条装饰
            GeometryReader { geo in
                // 下半部折痕
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                }
                .stroke(Color("TextSecondary").opacity(0.2), lineWidth: 1)
                
                // 上半部盖子
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.45))
                    path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                }
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
            }
            
            // V3.3: 使用随机蜡封设计
            WaxSealView(design: sealDesign, rotation: sealRotation)
                .offset(y: -20)
            
            // 花体时间戳
            VStack {
                Spacer()
                Text(record.formattedElegantTimestamp)
                    .font(.custom("Snell Roundhand", size: 14))
                    .foregroundColor(Color("TextPrimary").opacity(0.5))
                    .rotationEffect(.degrees(-3))
                    .padding(.bottom, 25)
            }
            
            // 心情标记
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(record.mood.emoji)
                        .font(.system(size: 24))
                        .padding(15)
                }
            }
        }
        .frame(height: 220)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

// MARK: - V3.3 英式蜡封视觉（支持随机设计）

struct WaxSealView: View {
    var design: WaxSealDesign = .initialY
    var rotation: Double = 0
    
    // 兼容旧版本的初始化
    init(text: String = "Y") {
        self.design = text == "G" ? .initialG : .initialY
        self.rotation = 0
    }
    
    init(design: WaxSealDesign, rotation: Double = 0) {
        self.design = design
        self.rotation = rotation
    }
    
    var body: some View {
        ZStack {
            // 蜡封基底（模拟溢出效果）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("SealColor"), Color(hex: "8B0000")],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 75, height: 75)
                .shadow(color: Color("SealColor").opacity(0.5), radius: 6, x: 2, y: 4)
            
            // 内圈边缘
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                .frame(width: 60, height: 60)
            
            // 内容（根据 design 变化）
            Group {
                if let text = design.text {
                    Text(text)
                        .font(.custom("Snell Roundhand", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.9))
                } else if let imageName = design.systemImageName {
                    Image(systemName: imageName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - ============================================
// MARK: - 2. 时光小票 (Mono Ticket)
// MARK: - ============================================

struct MonoTicketView: View {
    let record: DayRecord
    private let receiptFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    
    // V4.0: 使用存储的随机 TXN ID
    private var transactionID: String {
        record.aestheticDetails?.qrCodeContent ?? "TXN-\(record.id.uuidString.prefix(8).uppercased())"
    }
    
    private var compactDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        // V4.0: 移除封存时间，直接使用记录日期
        return formatter.string(from: record.date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 锯齿边缘（上）
            TicketTornEdge()
                .fill(Color("TicketPaper"))
                .frame(height: 12)
            
            // 主体
            VStack(spacing: 12) {
                // 标题
                VStack(spacing: 4) {
                    Text("时光小票 TIME TICKET")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    
                    Text("--- 为时间开具收据 ---")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                TicketDashedLine()
                
                // 元数据
                VStack(alignment: .leading, spacing: 4) {
                    Text("DATE: \(compactDate)")
                    Text("TXN:  \(transactionID)")
                    Text("MOOD: \(record.mood.emoji) \(record.mood.label.uppercased())")
                    if let weather = record.weather {
                        Text("WEATHER: \(weather.label.uppercased())")
                    }
                }
                .font(receiptFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                TicketDashedLine()
                
                // V4.0: 照片（如有）
                if let photoData = record.photos.first, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 150)
                        // V3.5.1: 移除灰度处理，保持原色
                        .cornerRadius(4)
                }
                
                // 内容
                if !record.content.isEmpty {
                    Text(record.content.prefix(150).uppercased())
                        .font(receiptFont)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                TicketDashedLine()
                
                // V3.3: 动态 QR 码
                HStack(spacing: 20) {
                    // 条形码
                    VStack(spacing: 4) {
                        TicketBarcodeView()
                            .frame(height: 35)
                        
                        Text(transactionID)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    // QR 码
                    if let qrContent = record.aestheticDetails?.qrCodeContent,
                       let qrImage = generateQRCode(from: qrContent) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                }
                
                Text("THANK YOU FOR YOUR TIME")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.top, 8)
            }
            .padding(20)
            .foregroundColor(Color("TextPrimary"))
            .background(Color("TicketPaper"))
            
            // 锯齿边缘（下）
            TicketTornEdge()
                .fill(Color("TicketPaper"))
                .frame(height: 12)
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
        }
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    // V3.3: QR 码生成器
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // 放大以保持清晰度
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

// 锯齿边缘
struct TicketTornEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let toothWidth: CGFloat = 10
        let toothHeight: CGFloat = 8
        
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        
        var x: CGFloat = 0
        while x < rect.width {
            path.addLine(to: CGPoint(x: x + toothWidth/2, y: rect.maxY - toothHeight))
            path.addLine(to: CGPoint(x: x + toothWidth, y: rect.maxY))
            x += toothWidth
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: 0, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

// 虚线
struct TicketDashedLine: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
            .foregroundColor(Color("TextSecondary").opacity(0.5))
        }
        .frame(height: 1)
    }
}

// 条形码
struct TicketBarcodeView: View {
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<35, id: \.self) { _ in
                Rectangle()
                    .fill(Color("TextPrimary"))
                    .frame(width: CGFloat.random(in: 1...3))
            }
        }
    }
}

// MARK: - ============================================
// MARK: - 3. 流光邀约 (Gala Invite)
// MARK: - ============================================

struct GalaInviteView: View {
    let record: DayRecord
    
    var body: some View {
        VStack(spacing: 25) {
            // 标题
            VStack(spacing: 8) {
                Text("时光电影节")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color("InviteGold"))
                
                Text("YIGE FILM FESTIVAL")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .tracking(3)
                    .foregroundColor(Color("InviteGold").opacity(0.7))
            }
            
            // 影片信息
            VStack(spacing: 15) {
                Text("展映影片")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(Color("InviteGold").opacity(0.6))
                
                Text("《\(record.formattedDate)》")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                
                // V4.0: 电影海报（照片）
                if let photoData = record.photos.first, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("InviteGold").opacity(0.3), lineWidth: 1)
                        )
                }
                
                // 剧情简介
                if !record.content.isEmpty {
                    Text(record.content.prefix(120))
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                }
            }
            
            // 底部信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("主演")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(Color("InviteGold").opacity(0.6))
                    Text("你")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("心情指数")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(Color("InviteGold").opacity(0.6))
                    Text(record.mood.emoji)
                        .font(.system(size: 28))
                }
            }
            
            // 底部标语
            Text("每一天都是一部电影")
                .font(.system(size: 11, design: .serif))
                .foregroundColor(Color("InviteGold").opacity(0.5))
        }
        .padding(30)
        .background(Color("InviteDark"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("InviteGold").opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color("InviteGold").opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - ============================================
// MARK: - 封存动画系统
// MARK: - ============================================

struct SealRitualContainerView: View {
    let record: DayRecord
    let style: RitualStyle
    let onComplete: () -> Void
    // V3.3: 可选的渲染回调（用于即时分享）
    var onCompleteWithImage: ((UIImage?) -> Void)?
    
    @State private var renderedImage: UIImage?
    
    var body: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            switch style {
            case .envelope:
                EnvelopeSealingAnimation(record: record, onComplete: handleAnimationComplete)
            case .monoTicket:
                TicketPrintingAnimation(record: record, onComplete: handleAnimationComplete)
            case .galaInvite:
                InvitationStampingAnimation(record: record, onComplete: handleAnimationComplete)
            // 其他风格使用默认动画（信封动画）
            default:
                EnvelopeSealingAnimation(record: record, onComplete: handleAnimationComplete)
            }
        }
        .onAppear(perform: renderArtifact)
    }
    
    // V3.3: 在动画开始时渲染信物图片
    @MainActor
    private func renderArtifact() {
        let content = ArtifactRenderContainer(record: record)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3.0  // 高清渲染
        self.renderedImage = renderer.uiImage
    }
    
    private func handleAnimationComplete() {
        if let callback = onCompleteWithImage {
            callback(renderedImage)
        } else {
            onComplete()
        }
    }
}

// MARK: - 1. 信封盖章动画

struct EnvelopeSealingAnimation: View {
    let record: DayRecord
    let onComplete: () -> Void
    
    @State private var stampScale: CGFloat = 3.0
    @State private var stampOpacity: Double = 0.0
    @State private var isSealed = false
    @State private var envelopeScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 30) {
            // 信封
            EnvelopeArtifactView(record: record)
                .frame(width: 300)
                .scaleEffect(envelopeScale)
                .overlay(
                    // 最终印章
                    ZStack {
                        Circle()
                            .fill(Color("SealColor"))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                    }
                    .opacity(isSealed ? 1.0 : 0.0)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 100, y: 60)
                    .shadow(color: Color("SealColor").opacity(0.5), radius: 10)
                )
                .overlay(
                    // 动画中的印章
                    ZStack {
                        Circle()
                            .fill(Color("SealColor"))
                            .frame(width: 70, height: 70)
                        
                        Text("封")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 100, y: 60)
                )
            
            // 提示文字
            VStack(spacing: 8) {
                Text(isSealed ? "封存成功" : "正在封存...")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                Text("明天之后可以拆开回顾")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(isSealed ? 1 : 0)
            }
        }
        .onAppear {
            // 信封放大
            withAnimation(.spring(response: 0.4)) {
                envelopeScale = 1.0
            }
            
            // 印章出现
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.15)) {
                    stampOpacity = 1.0
                }
                
                // 印章盖下
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    stampScale = 1.0
                }
            }
            
            // 碰撞反馈
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                
                withAnimation(.easeOut(duration: 0.15)) {
                    stampOpacity = 0.0
                }
                isSealed = true
            }
            
            // 完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onComplete()
            }
        }
    }
}

// MARK: - 2. 小票打印动画

struct TicketPrintingAnimation: View {
    let record: DayRecord
    let onComplete: () -> Void
    
    @State private var printProgress: CGFloat = 0.0
    @State private var showComplete = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 小票（使用 Mask 模拟逐行打印）
            MonoTicketView(record: record)
                .frame(width: 300)
                .mask(alignment: .top) {
                    GeometryReader { geo in
                        Rectangle()
                            .frame(height: geo.size.height * printProgress)
                    }
                }
            
            // 打印口
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.25))
                    .frame(height: 50)
                
                Capsule()
                    .fill(Color.black)
                    .frame(height: 8)
                    .padding(.horizontal, 30)
            }
            .frame(width: 320)
            
            Spacer()
            
            // 提示文字
            VStack(spacing: 8) {
                Text(showComplete ? "打印完成" : "正在打印...")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                if showComplete {
                    Text("时光凭证已生成")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            // 逐行打印动画
            withAnimation(.linear(duration: 2.5)) {
                printProgress = 1.0
            }
            
            // 打印完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showComplete = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                onComplete()
            }
        }
    }
}

// MARK: - 3. 邀请函烫金动画

struct InvitationStampingAnimation: View {
    let record: DayRecord
    let onComplete: () -> Void
    
    @State private var shineProgress: CGFloat = -0.5
    @State private var showComplete = false
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0.5
    
    var body: some View {
        VStack(spacing: 30) {
            // 邀请函（带光泽扫过效果）
            GalaInviteView(record: record)
                .frame(width: 320)
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .overlay(
                    // 光泽效果
                    GeometryReader { geo in
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: max(0, shineProgress - 0.2)),
                                .init(color: Color("InviteGold").opacity(0.6), location: shineProgress),
                                .init(color: .clear, location: min(1, shineProgress + 0.2))
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blendMode(.overlay)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                )
            
            // 提示文字
            VStack(spacing: 8) {
                Text(showComplete ? "邀请函已生成" : "正在烫金...")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                if showComplete {
                    Text("每一天都是一部电影")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color("InviteGold").opacity(0.8))
                }
            }
        }
        .onAppear {
            // 卡片出现
            withAnimation(.spring(response: 0.5)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            
            // 光泽扫过
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.8)) {
                    shineProgress = 1.5
                }
            }
            
            // 完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                showComplete = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
        }
    }
}

// MARK: - ============================================
// MARK: - ============================================
// MARK: - V3.3 预览卡片（用于 NewRecordView）
// MARK: - ============================================

struct ArtifactPreviewCard: View {
    let record: DayRecord
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // 根据风格显示对应的预览
                Group {
                    switch record.artifactStyle {
                    case .envelope:
                        EnvelopeArtifactView(record: record)
                            .frame(width: 300)
                    case .monoTicket:
                        MonoTicketView(record: record)
                            .frame(width: 280)
                    case .galaInvite:
                        GalaInviteView(record: record)
                            .frame(width: 300)
                    // 其他风格使用 StyledArtifactView（已支持所有12种）
                    default:
                        StyledArtifactView(record: record)
                            .frame(width: 300)
                    }
                }
                .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 0.95) // iPad 1.0x, iPhone 0.95x (增大)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 380) // iPad 400, iPhone 380 (增大)
    }
}

// MARK: - 风格选择器
// MARK: - ============================================

struct RitualStylePickerView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // 用于预览的示例数据
    // V4.0: 移除封存相关参数
    private let previewRecord = DayRecord(
        date: Date(),
        content: "这是一个预览内容，展示了凭证的视觉效果。今天的阳光很好，适合写代码。",
        mood: .joyful
    )
    
    var body: some View {
        Form {
            Section(header: Text("选择时光信物样式")) {
                ForEach(RitualStyle.allCases, id: \.self) { style in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            dataManager.settings.preferredArtifactStyle = style
                        }
                        dataManager.updateSettings()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: style.icon)
                                .font(.system(size: 22))
                                .foregroundColor(Color("PrimaryWarm"))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(style.label)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("TextPrimary"))
                                
                                Text(style.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("TextSecondary"))
                            }
                            
                            Spacer()
                            
                            if dataManager.settings.preferredArtifactStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("PrimaryWarm"))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            Section(header: Text("样式预览")) {
                VStack(spacing: 20) {
                    switch dataManager.settings.preferredArtifactStyle {
                    case .envelope:
                        EnvelopeArtifactView(record: previewRecord)
                    case .monoTicket:
                        MonoTicketView(record: previewRecord)
                    case .galaInvite:
                        GalaInviteView(record: previewRecord)
                    // 其他风格使用 StyledArtifactView（已支持所有12种）
                    default:
                        StyledArtifactView(record: previewRecord)
                    }
                }
                .padding(.vertical, 15)
                .animation(.easeInOut(duration: 0.3), value: dataManager.settings.preferredArtifactStyle)
            }
        }
        .navigationTitle("信物风格")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 统一信物展示视图（支持所有12种风格）

struct StyledArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        switch record.artifactStyle {
        // 书信类
        case .envelope:
            EnvelopeArtifactView(record: record)
        case .postcard:
            PostcardArtifactView(record: record)
        case .journalPage:
            JournalPageArtifactView(record: record)
        
        // 影像类
        case .polaroid:
            PolaroidArtifactView(record: record)
        case .developedPhoto:
            DevelopedPhotoArtifactView(record: record)
        case .filmNegative:
            ArtifactTemplateFactory.makeView(for: record)
        
        // 票据类 - V3版本（修复文字颜色，增加时间戳、盖章）
        case .receipt:
            StyleReceiptViewV3(record: record)
        case .thermal:
            StyleThermalViewV3(record: record)
        
        // 收藏类 - V5版本
        case .vinylRecord:
            VinylRecordV5(record: record)
        case .bookmark:
            BookmarkV5(record: record)
        case .pressedFlower:
            PressedFlowerV5(record: record)
        
        // 兼容旧版本
        case .monoTicket:
            MonoTicketView(record: record)
        case .galaInvite:
            GalaInviteView(record: record)
            
        // 新增高定风格 (使用工厂渲染)
        case .waxStamp, .typewriter, .safari, .aurora, .astrolabe, .omikuji, .hourglass, .vault, .simple, .waxEnvelope:
            ArtifactTemplateFactory.makeView(for: record)
        
        // ✈️ 航空系列 (使用工厂渲染)
        case .boardingPass, .aircraftType, .flightLog, .luggageTag:
            ArtifactTemplateFactory.makeView(for: record)
        
        // 🎫 票据系列 (使用工厂渲染)
        case .concertTicket:
            ArtifactTemplateFactory.makeView(for: record)
        }
    }
}

// MARK: - 12种信物视图实现（每种都有独特预览）

// 影像类
struct PolaroidArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        VStack(spacing: 0) {
            // 照片区域（黑色边框）- 多张照片水平排列
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 240)
                
                if !record.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                                if let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 240, height: 240)
                                        .clipped()
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                } else {
                    Text(record.mood.emoji)
                        .font(.system(size: 80))
                }
            }
            
            // 白边区域（增强版：添加日期、地点和Polaroid Logo）
            VStack(spacing: 6) {
                Text(record.content)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                
                HStack {
                Text(record.formattedDate)
                        .font(.system(size: 10))
                    .foregroundColor(Color("TextSecondary"))
                    
                    if let location = record.location?.placeName {
                        Text("•")
                            .foregroundColor(Color("TextSecondary"))
                        Text(location)
                            .font(.system(size: 9))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                
                // 增强：Polaroid Logo
                HStack(spacing: 2) {
                    Text("Polaroid")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.gray.opacity(0.6))
                    Image(systemName: "rainbow")
                        .font(.system(size: 6))
                        .foregroundColor(.gray.opacity(0.6))
                }
                    .padding(.bottom, 8)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .frame(width: 280, height: 340)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 15, y: 8)
    }
}

struct DevelopedPhotoArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 复古相纸背景
            LinearGradient(
                colors: [Color(hex: "#FFF8E7"), Color(hex: "#E8DCC8")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 16) {
                if let photoData = record.photos.first,
                   let uiImage = UIImage(data: photoData) {
                    ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                        )
                        
                        // 增强：复古胶片日期戳（右下角）
                        RetroFilmDateStamp(date: record.date)
                            .padding(8)
                    }
                }
                
                Text(record.content)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // 增强：相机型号和曝光参数
                HStack {
                    Text("Contax T2")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color(hex: "#4A4A4A").opacity(0.4))
                
                Spacer()
                
                    Text("f/2.8  1/60")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color(hex: "#4A4A4A").opacity(0.4))
                                }
                    .padding(.horizontal, 20)
                    .padding(.horizontal, 16)
                
                Text("FUJI")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.orange.opacity(0.6))
            }
            .padding(20)
        }
        .frame(width: 280, height: 340)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 15, y: 8)
    }
}

// 书信类（已有envelope，新增postcard和journalPage）
struct PostcardArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧：图片区域
            ZStack {
                Color.cyan.opacity(0.3)
                
                if let photoData = record.photos.first,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 280)
                        .clipped()
                } else {
                    Text(record.mood.emoji)
                        .font(.system(size: 60))
                }
            }
            .frame(width: 140)
            
            // 右侧：文字区域（增强版：添加邮戳）
            VStack(alignment: .leading, spacing: 12) {
                Text(record.content)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // 增强：邮戳风格日期
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 50, height: 50)
                        
                        VStack(spacing: 1) {
                            Text(record.formattedDate.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 7, weight: .bold))
                            if let location = record.location?.placeName {
                                Text(location.prefix(6))
                                    .font(.system(size: 5, weight: .medium))
                            }
                        }
                    }
                    
                    Text("📮")
                        .font(.system(size: 16))
                }
            }
            .padding(16)
            .frame(width: 140)
            .background(Color(hex: "#FFF8E7"))
        }
        .frame(width: 280, height: 340)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 15, y: 8)
    }
}

struct JournalPageArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 横线纸背景
            Color(hex: "#FFF8DC")
            
            // 横线
            VStack(spacing: 20) {
                ForEach(0..<10) { _ in
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // 红色边线
            Rectangle()
                .fill(Color(hex: "#C41E3A").opacity(0.3))
                .frame(width: 2)
                .offset(x: -130)
            
            // 内容
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(record.formattedDate)
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text(record.mood.emoji)
                        .font(.system(size: 18))
                }
                .foregroundColor(Color(hex: "#4A4A4A"))
                
                // 照片区域（如果有照片）- 多张照片水平排列
                if !record.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                                if let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                Text(record.content)
                    .font(.custom("Bradley Hand", size: 14))
                    .foregroundColor(Color(hex: "#2C2C2C"))
                    .lineSpacing(8)
                    .lineLimit(8)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
        }
        .frame(width: 280, height: 340)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 15, y: 8)
    }
}

// 收藏类
struct VinylRecordArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 黑色封套背景
            Color.black
            
            // 唱片（露出一部分）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#1C1C1C"), Color(hex: "#2C2C2C"), Color(hex: "#1C1C1C")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#3C3C3C"), lineWidth: 0.5)
                        .frame(width: 120)
                )
                .overlay(
                    Circle()
                        .fill(Color(hex: "#C41E3A"))
                        .frame(width: 50)
                        .overlay(
                            Text(record.mood.emoji)
                                .font(.system(size: 20))
                        )
                )
                .offset(x: 40)
            
            // 封面信息
            VStack(alignment: .leading, spacing: 8) {
                // 照片区域（如果有照片）- 多张照片水平排列
                if !record.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                                if let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 140, height: 140)
                                        .clipped()
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.bottom, 8)
                }
                
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                
                Spacer()
                
                Text(record.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 280, height: 340)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.5), radius: 20, y: 10)
    }
}

struct BookmarkArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 深红色背景
            Color(hex: "#722F37")
            
            VStack(spacing: 16) {
                // 照片区域（如果有照片）
                if let photoData = record.photos.first,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#FFD700").opacity(0.3), lineWidth: 1)
                        )
                }
                
                Text("\"")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text(record.content)
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .multilineTextAlignment(.center)
                    .italic()
                    .lineLimit(6)
                    .padding(.horizontal, 20)
                
                Text("\"")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text(record.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.7))
            }
            .padding(20)
        }
        .frame(width: 280, height: 340)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#FFD700").opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color(hex: "#722F37").opacity(0.4), radius: 20, y: 10)
    }
}

struct PressedFlowerArtifactView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 标本纸背景
            Color(hex: "#FFF8E7")
            
            // 干花
            Text("🌸")
                .font(.system(size: 100))
                .offset(x: -60, y: -40)
            
            // 胶带
            HStack {
                Rectangle()
                    .fill(Color(hex: "#D3D3D3").opacity(0.6))
                    .frame(width: 60, height: 8)
            }
            .offset(x: 60, y: -60)
            
            // 内容
            VStack(spacing: 12) {
                // 照片区域（如果有照片）- 多张照片水平排列
                if !record.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(record.photos.enumerated()), id: \.offset) { _, photoData in
                                if let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 140, height: 140)
                                        .clipped()
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                Text(record.content)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .padding(.horizontal, 20)
                    .padding(.top, record.photos.isEmpty ? 80 : 12)
                
                Text(record.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#8B7355"))
            }
            .padding(20)
        }
        .frame(width: 280, height: 340)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 15, y: 8)
    }
}

#Preview("信封") {
    // V4.0: 移除封存相关参数
    EnvelopeArtifactView(record: DayRecord(
        content: "今天是美好的一天",
        mood: .joyful
    ))
    .padding(20)
    .background(Color.gray.opacity(0.2))
}

#Preview("小票") {
    // V4.0: 移除封存相关参数
    MonoTicketView(record: DayRecord(
        content: "今天下午在咖啡馆写了两个小时代码",
        mood: .peaceful,
        weather: .sunny
    ))
    .padding(20)
    .background(Color.gray.opacity(0.2))
}

#Preview("邀请函") {
    // V4.0: 移除封存相关参数
    GalaInviteView(record: DayRecord(
        content: "生活就像一场电影，每一天都是独特的一幕",
        mood: .joyful
    ))
    .padding(20)
    .background(Color.gray.opacity(0.2))
}

// MARK: - 新增票据类信物视图

struct ReceiptArtifactView: View {
    let record: DayRecord
    
    // 生成商品列表（基于文字内容）
    private var items: [(name: String, price: Double)] {
        let contentLines = record.content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        if contentLines.isEmpty {
            return [("美好时光", 88.88), ("珍贵回忆", 99.99), ("心情记录", 66.66)]
        }
        return contentLines.prefix(5).enumerated().map { index, line in
            let price = Double.random(in: 19.99...199.99)
            return (name: line.isEmpty ? "商品\(index + 1)" : line, price: price)
        }
    }
    
    private var subtotal: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    private var tax: Double {
        subtotal * 0.1
    }
    
    private var total: Double {
        subtotal + tax
    }
    
    var body: some View {
        ZStack {
            // 白色收据背景
            Color.white
            
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部：商店名称和Logo（增强版）
                    VStack(spacing: 6) {
                        // Logo图标
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                        
                        Text("THE MEMORY BISTRO")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Text("记忆小酒馆")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // 地址：优先显示实际位置，否则显示默认
                        Text(record.location?.address ?? record.location?.placeName ?? "地址：记忆大道2024号")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("电话：400-888-2024")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // 订单号和日期（增强版）
                        VStack(spacing: 4) {
                            let orderNumber = Int.random(in: 1000...9999)
                            Text("ORDER #\(String(format: "%04d", orderNumber))")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // 日期和时间
                            HStack {
                        Text(record.formattedDate)
                                    .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.black)
                        
                                Spacer()
                                
                                if let timestamp = record.timestamp {
                                    Text(timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.gray)
                                } else {
                        Text(Date().formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // 详细天气信息（如果有）
                        if let weatherData = record.weatherData {
                            HStack(spacing: 8) {
                                if let temp = weatherData.temperature {
                                    Text("\(Int(temp))°C")
                            .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.black)
                                }
                                if let aqi = weatherData.airQuality {
                                    Text("AQI: \(aqi)")
                                        .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // 分隔线
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // 照片区域（最多6张，根据数量智能排列）
                    let displayPhotos = Array(record.photos.prefix(record.artifactStyle.maxPhotos))
                    if !displayPhotos.isEmpty {
                        // 根据照片数量决定布局
                        if displayPhotos.count == 1 {
                            // 1张：居中，较大
                            if let uiImage = UIImage(data: displayPhotos[0]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                                    .frame(height: 150)
                            .clipped()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                            }
                        } else if displayPhotos.count == 2 {
                            // 2张：水平排列
                            HStack(spacing: 8) {
                                ForEach(Array(displayPhotos.enumerated()), id: \.offset) { _, photoData in
                                    if let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 100)
                                            .clipped()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        } else {
                            // 3-6张：水平滚动
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(displayPhotos.enumerated()), id: \.offset) { _, photoData in
                                        if let uiImage = UIImage(data: photoData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 12)
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }
                    
                    // 商品列表
                    VStack(spacing: 6) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.name)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(String(format: "¥%.2f", item.price))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    // 分隔线
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    
                    // 小计、税费、总计
                    VStack(spacing: 4) {
                        HStack {
                            Text("小计")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.black)
                            Spacer()
                            Text(String(format: "¥%.2f", subtotal))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text("税费(10%)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "¥%.2f", tax))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text("总计")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                            Spacer()
                            Text(String(format: "¥%.2f", total))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // 支付方式
                    HStack {
                        Text("支付方式：")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("时光币")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.black)
                        Spacer()
                        Text("交易号：\(UUID().uuidString.prefix(8).uppercased())")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // 天气和心情
                    HStack {
                        if let weatherData = record.weatherData {
                            HStack(spacing: 4) {
                                Image(systemName: weatherData.condition.icon)
                                    .font(.system(size: 10))
                                if let temp = weatherData.temperature {
                                    Text("\(Int(temp))°C")
                                        .font(.system(size: 10, design: .monospaced))
                                } else {
                                    Text(weatherData.condition.label)
                                        .font(.system(size: 10))
                                }
                            }
                            .foregroundColor(.gray)
                        } else if let weather = record.weather {
                            HStack(spacing: 4) {
                                Image(systemName: weather.icon)
                                    .font(.system(size: 10))
                                Text(weather.label)
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(record.mood.emoji)
                            .font(.system(size: 18))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // 标签和事件类型（如果有）
                    if !record.tags.isEmpty || record.eventType != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            if !record.tags.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(record.tags.prefix(3), id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            if let eventType = record.eventType {
                                Text("[\(eventType.rawValue)]")
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }
                    
                    // 分隔线
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    
                    // 底部：二维码和感谢语（增强版）
                    VStack(spacing: 6) {
                        // 二维码占位
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "qrcode")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                        
                        Text("SCAN FOR MEMBER REWARDS")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("* * * THANK YOU * * *")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Text("Your memories are our treasure")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                        
                        // 收银员信息
                        HStack {
                            Text("CASHIER: TIME")
                            Spacer()
                            Text("TERMINAL: 01")
                        }
                        .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .frame(width: 200) // V4: 缩小到200pt宽度
        .fixedSize(horizontal: false, vertical: true) // 允许垂直方向自然展开
        .cornerRadius(4)
        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ThermalArtifactView: View {
    let record: DayRecord
    
    // 生成商品列表（基于文字内容）
    private var items: [(name: String, qty: Int, price: Double)] {
        let contentLines = record.content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        if contentLines.isEmpty {
            return [
                ("美好时光", 1, 28.00),
                ("珍贵回忆", 2, 35.50),
                ("心情记录", 1, 19.90),
                ("日常片段", 3, 12.80)
            ]
        }
        return contentLines.prefix(6).enumerated().map { index, line in
            let qty = Int.random(in: 1...3)
            let price = Double.random(in: 8.80...88.80)
            return (name: line.isEmpty ? "商品\(index + 1)" : line, qty: qty, price: price)
        }
    }
    
    private var subtotal: Double {
        items.reduce(0) { $0 + Double($1.qty) * $1.price }
    }
    
    private var total: Double {
        subtotal
    }
    
    var body: some View {
        ZStack {
            // 热敏纸背景（浅灰白色，更窄）
            Color(hex: "#F8F8F8")
            
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部：商店名称和Logo（增强版）
                    VStack(spacing: 3) {
                        Text("⏰")
                            .font(.system(size: 20))
                        
                        Text("时光便利店")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Text("24H MEMORY MART")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("营业时间: 永不打烊")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // 地址：优先显示实际位置
                        Text(record.location?.address ?? record.location?.placeName ?? "地址：记忆街88号")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    // 分隔线（虚线效果）
                    HStack(spacing: 3) {
                        ForEach(0..<25) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 6, height: 1)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 日期和时间（显示精确时间戳）
                    HStack {
                        Text(record.formattedDate)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.black)
                        Spacer()
                        if let timestamp = record.timestamp {
                            Text(timestamp.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.black)
                        } else {
                        Text(Date().formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 详细天气（如果有）
                    if let weatherData = record.weatherData, let temp = weatherData.temperature {
                        HStack {
                            Text("\(Int(temp))°C")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.black)
                            if let aqi = weatherData.airQuality {
                                Text("AQI: \(aqi)")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                    }
                    
                    // 交易号和日期（增强版）
                    VStack(spacing: 3) {
                        let transactionNumber = Int.random(in: 10000000...99999999)
                        HStack {
                            Text("单号")
                            Spacer()
                            Text("\(String(format: "%08d", transactionNumber))")
                        }
                        HStack {
                            Text("日期")
                            Spacer()
                            Text(record.formattedDate)
                        }
                        HStack {
                            Text("时间")
                            Spacer()
                            if let timestamp = record.timestamp {
                                Text(timestamp.formatted(date: .omitted, time: .shortened))
                            } else {
                                Text(Date().formatted(date: .omitted, time: .shortened))
                            }
                        }
                    }
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                    
                    // 分隔线
                    HStack(spacing: 3) {
                        ForEach(0..<25) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 6, height: 1)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 照片区域（最多6张，根据数量智能排列）
                    let displayPhotos = Array(record.photos.prefix(record.artifactStyle.maxPhotos))
                    if !displayPhotos.isEmpty {
                        // 根据照片数量决定布局
                        if displayPhotos.count == 1 {
                            // 1张：居中，较大
                            if let uiImage = UIImage(data: displayPhotos[0]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 6)
                            }
                        } else if displayPhotos.count == 2 {
                            // 2张：水平排列
                            HStack(spacing: 6) {
                                ForEach(Array(displayPhotos.enumerated()), id: \.offset) { _, photoData in
                                    if let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 80)
                                            .clipped()
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 6)
                        } else {
                            // 3-6张：水平滚动
                        ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(Array(displayPhotos.enumerated()), id: \.offset) { _, photoData in
                                    if let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                            .clipped()
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        .padding(.bottom, 6)
                        }
                        
                        HStack(spacing: 3) {
                            ForEach(0..<25) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 6, height: 1)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                    }
                    
                    // 商品列表（热敏小票风格，窄列）
                    VStack(spacing: 3) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            VStack(spacing: 2) {
                                HStack {
                                    Text(item.name)
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("\(item.qty)x")
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.2f", item.price))
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.2f", Double(item.qty) * item.price))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.bottom, 6)
                    
                    // 分隔线
                    HStack(spacing: 3) {
                        ForEach(0..<25) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 6, height: 1)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 小计和总计
                    VStack(spacing: 2) {
                        HStack {
                            Text("小计")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.black)
                            Spacer()
                            Text(String(format: "%.2f", subtotal))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text("总计")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                            Spacer()
                            Text(String(format: "¥%.2f", total))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 支付方式
                    HStack {
                        Text("支付：")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("时光币")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.black)
                        Spacer()
                        Text("找零：0.00")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 天气和心情
                    HStack {
                        if let weatherData = record.weatherData {
                            HStack(spacing: 2) {
                                Image(systemName: weatherData.condition.icon)
                                    .font(.system(size: 7))
                                if let temp = weatherData.temperature {
                                    Text("\(Int(temp))°C")
                                        .font(.system(size: 8, design: .monospaced))
                                } else {
                                    Text(weatherData.condition.label)
                                        .font(.system(size: 8, design: .monospaced))
                                }
                            }
                            .foregroundColor(.gray)
                        } else if let weather = record.weather {
                            Text("\(weather.icon) \(weather.label)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(record.mood.emoji)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 标签和事件类型（如果有）
                    if !record.tags.isEmpty || record.eventType != nil {
                        VStack(alignment: .leading, spacing: 2) {
                            if !record.tags.isEmpty {
                                HStack(spacing: 3) {
                                    ForEach(record.tags.prefix(2), id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 7, design: .monospaced))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            if let eventType = record.eventType {
                                Text("[\(eventType.rawValue)]")
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                    }
                    
                    // 分隔线
                    HStack(spacing: 3) {
                        ForEach(0..<25) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 6, height: 1)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    // 底部：条形码和感谢语（增强版）
                    VStack(spacing: 4) {
                        Text("会员积分: +∞")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        // 条形码占位
                        HStack(spacing: 1) {
                            ForEach(0..<30, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: CGFloat.random(in: 1...3), height: 20)
                            }
                        }
                        .frame(height: 25)
                        
                        Text("谢谢惠顾 欢迎下次光临")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.black)
                        
                        Text("客服热线: 400-TIME-MEMORY")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    // 底部：小票特征（细长条）
                    HStack(spacing: 2) {
                        ForEach(0..<35) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 1.5, height: 6)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(width: 180) // V4: 缩小到180pt宽度
        .fixedSize(horizontal: false, vertical: true) // 允许垂直方向自然展开
        .cornerRadius(2)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
}

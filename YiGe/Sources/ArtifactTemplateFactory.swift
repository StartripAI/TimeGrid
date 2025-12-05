import SwiftUI

// MARK: - 💎 High Couture Artifact Engine (高定信物引擎)
// 这是一个程序化生成的艺术工厂，用于生产 NFT 级别的数字信物。
// 告别静态贴纸，拥抱 Shader、PBR 和动态排版。

// MARK: - 类型引用（确保编译器能找到这些类型）
// 所有 Master 视图定义在以下文件中：
// - MasterArtifacts_Royal.swift: MasterRoyalDecreeView, MasterClassifiedView
// - MasterArtifacts_Nature.swift: MasterPressedFlowerView, MasterJournalPageView, MasterTypewriterManuscriptView
// - MasterArtifacts_Film.swift: MasterDevelopedPhotoView
// - MasterArtifacts_Explorer.swift: MasterSafariJournalView, MasterAuroraView, MasterAstrolabeView, MasterOmikujiView, MasterHourglassView
// - MasterArtifacts_Aviation.swift: MasterBoardingPassView, MasterAircraftTypeRatingView, MasterFlightLogView, MasterLuggageTagView
// - MasterArtifacts_Tickets.swift: MasterMonoTicketView, MasterGalaInviteView, MasterConcertTicketView
//
// 如果遇到编译错误，请确保所有 MasterArtifacts_*.swift 文件都已添加到项目 target 中

private struct ArtifactTemplateDefinition {
    let style: RitualStyle
    let builder: (DayRecord) -> AnyView
}

// MARK: - 1. 核心工厂类
struct ArtifactTemplateFactory {
    
    private static let templates: [RitualStyle: ArtifactTemplateDefinition] = {
        let defs: [ArtifactTemplateDefinition] = [
            // 🏛 Collection I: The Archivist (皇家档案馆)
            .init(style: .envelope, builder: { AnyView(MasterRoyalDecreeView(record: $0)) }),
            .init(style: .vault, builder: { AnyView(MasterClassifiedView(record: $0)) }),
            .init(style: .pressedFlower, builder: { AnyView(MasterPressedFlowerView(record: $0)) }),
            
            // 🎬 Collection II: The Director (电影大师)
            .init(style: .postcard, builder: { AnyView(StyleWesAndersonView(record: $0)) }),
            .init(style: .developedPhoto, builder: { AnyView(MasterDevelopedPhotoView(record: $0)) }),
            .init(style: .filmNegative, builder: { AnyView(MasterFilmNegativeView(record: $0)) }),
            
            // 👠 Collection III: The Vogue (时尚女魔头)
            .init(style: .simple, builder: { AnyView(StyleVogueCoverView(record: $0)) }),
            .init(style: .polaroid, builder: { AnyView(StylePolaroidSX70View(record: $0)) }),
            
            // 💿 Collection V: The Collector (顶级藏家)
            .init(style: .vinylRecord, builder: { AnyView(VinylRecordV5(record: $0)) }),
            .init(style: .receipt, builder: { AnyView(StyleReceiptViewV3(record: $0)) }),
            .init(style: .thermal, builder: { AnyView(StyleThermalViewV3(record: $0)) }),
            
            // 🏛 Collection I 补充风格
            .init(style: .waxEnvelope, builder: { AnyView(MasterRoyalDecreeView(record: $0)) }),
            .init(style: .waxStamp, builder: { AnyView(StyleWaxStampView(record: $0)) }),
            .init(style: .typewriter, builder: { AnyView(MasterTypewriterManuscriptView(record: $0)) }),
            .init(style: .journalPage, builder: { AnyView(MasterJournalPageView(record: $0)) }),
            
            // 💿 Collection V 补充风格
            .init(style: .bookmark, builder: { AnyView(BookmarkV5(record: $0)) }),
            
            // 🌍 Collection VI: The Explorer (探索者系列)
            .init(style: .safari, builder: { AnyView(MasterSafariJournalView(record: $0)) }),
            .init(style: .aurora, builder: { AnyView(MasterAuroraView(record: $0)) }),
            .init(style: .astrolabe, builder: { AnyView(MasterAstrolabeView(record: $0)) }),
            .init(style: .omikuji, builder: { AnyView(MasterOmikujiView(record: $0)) }),
            .init(style: .hourglass, builder: { AnyView(MasterHourglassView(record: $0)) }),
            
            // ✈️ Collection VII: Aviation (航空系列)
            .init(style: .boardingPass, builder: { AnyView(MasterBoardingPassView(record: $0)) }),
            .init(style: .aircraftType, builder: { AnyView(MasterAircraftTypeRatingView(record: $0)) }),
            .init(style: .flightLog, builder: { AnyView(MasterFlightLogView(record: $0)) }),
            .init(style: .luggageTag, builder: { AnyView(MasterLuggageTagView(record: $0)) }),
            
            // 🎫 Collection VIII: Tickets (票据系列)
            .init(style: .monoTicket, builder: { AnyView(MasterMonoTicketView(record: $0)) }),
            .init(style: .galaInvite, builder: { AnyView(MasterGalaInviteView(record: $0)) }),
            .init(style: .concertTicket, builder: { AnyView(MasterConcertTicketView(record: $0)) }),
        ]
        
        return Dictionary(uniqueKeysWithValues: defs.map { ($0.style, $0) })
    }()
    
    @ViewBuilder
    static func makeView(for record: DayRecord) -> some View {
        if let template = templates[record.artifactStyle] {
            template.builder(record)
        } else {
            StyleGenericCoutureView(record: record)
        }
    }
}

// MARK: - 2. 通用高定视图 (Fallback)
struct StyleGenericCoutureView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            Color(hex: "F5F5F0") // Cream Studio
            
            VStack(spacing: 20) {
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 280)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                
                Text(record.content)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(20)
        }
        .frame(width: 300, height: 450)
        .cornerRadius(2)
        .shadow(radius: 5)
    }
}

// MARK: - 3. 程序化组件库 (Procedural Components)

// 3.1 纸张纹理叠加层 (增强版 - 更真实的纤维和污渍)
struct PaperTextureOverlay: View {
    var opacity: Double = 0.15
    
    var body: some View {
        Canvas { context, size in
            // 高频噪点模拟纤维 (增加密度)
            for _ in 0..<8000 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let w = Double.random(in: 0.5...1.5)
                let rect = CGRect(x: x, y: y, width: w, height: w)
                let grain = Double.random(in: 0.1...0.4)
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(grain)))
            }
            // 低频污渍模拟陈旧感 (更真实的边缘羽化)
            for _ in 0..<30 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let s = Double.random(in: 15...80)
                let rect = CGRect(x: x, y: y, width: s, height: s)
                // 使用径向渐变模拟污渍中心到边缘的衰减
                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: "8B4513").opacity(0.03)))
            }
            // 添加细微的划痕
            for _ in 0..<10 {
                let startX = Double.random(in: 0...size.width)
                let startY = Double.random(in: 0...size.height)
                let length = Double.random(in: 20...60)
                let angle = Double.random(in: 0...360)
                let endX = startX + cos(angle * .pi / 180) * length
                let endY = startY + sin(angle * .pi / 180) * length
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))
                context.stroke(path, with: .color(.black.opacity(0.05)), lineWidth: 0.5)
            }
        }
        .blendMode(.multiply)
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

// 3.2 动态胶片颗粒 (增强版 - 24fps真实胶片质感)
struct FilmGrainEffect: View {
    var intensity: Double = 0.2
    
    var body: some View {
        SwiftUI.TimelineView(.periodic(from: Date(), by: 1.0 / 24.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // 使用时间种子确保每帧不同但可重现
                var generator = SeededRandomGenerator(seed: UInt64(time * 1000))
                
                // 增加颗粒密度，模拟真实胶片
                for _ in 0..<4000 {
                    let x = Double.random(in: 0...size.width, using: &generator)
                    let y = Double.random(in: 0...size.height, using: &generator)
                    let w = Double.random(in: 0.8...2.5, using: &generator)
                    let grain = Double.random(in: 0.1...0.8, using: &generator) * intensity
                    let rect = CGRect(x: x, y: y, width: w, height: w)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(grain)))
                }
                
                // 添加随机的大颗粒 (模拟胶片缺陷)
                for _ in 0..<50 {
                    let x = Double.random(in: 0...size.width, using: &generator)
                    let y = Double.random(in: 0...size.height, using: &generator)
                    let w = Double.random(in: 2...4, using: &generator)
                    let rect = CGRect(x: x, y: y, width: w, height: w)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(intensity * 1.5)))
                }
            }
        }
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }
}

// 辅助：可重现的随机数生成器
struct SeededRandomGenerator: RandomNumberGenerator {
    var seed: UInt64
    
    mutating func next() -> UInt64 {
        seed = seed &* 1103515245 &+ 12345
        return seed
    }
}

extension Double {
    static func random(in range: ClosedRange<Double>, using generator: inout SeededRandomGenerator) -> Double {
        let random = UInt64.random(in: 0...UInt64.max, using: &generator)
        return Double(random) / Double(UInt64.max) * (range.upperBound - range.lowerBound) + range.lowerBound
    }
}

// 3.3 程序化火漆印章 (增强版 - PBR材质，3D效果)
struct ProceduralWaxSealView: View {
    let design: WaxSealDesign
    let rotation: Double
    @State private var shimmer: Double = 0
    
    var body: some View {
        ZStack {
            // 外圈不规则边缘 (模拟蜡溢出，更真实)
            ZStack {
                // 底层深红
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "8B0000"), Color(hex: "6B0000")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.4), radius: 5, x: 2, y: 3)
                
                // 边缘高光 (模拟蜡的油润感)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "A00000").opacity(0.6), Color(hex: "600000").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 1)
                
                // 动态高光 (模拟光线反射)
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(shimmer))
            }
            
            // 内部凹陷 (更深的3D效果)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "7B0000"), Color(hex: "5B0000")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 2)
                
                // 内圈高光边 (模拟凹陷边缘的反光)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "900000").opacity(0.8), Color(hex: "500000").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 50, height: 50)
            }
            
            // 图案 (更精致的雕刻效果)
            Group {
                if let sys = design.systemImageName {
                    Image(systemName: sys)
                } else if let txt = design.text {
                    Text(txt)
                }
            }
            .font(.system(size: 24, weight: .bold, design: .serif))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "400000"), Color(hex: "600000")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .white.opacity(0.3), radius: 0.5, x: -0.5, y: -0.5) // 左上高光
            .shadow(color: .black.opacity(0.6), radius: 1, x: 1, y: 1)         // 右下阴影
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                shimmer = 360
            }
        }
    }
}

// 3.4 程序化条形码（重命名以避免与 MasterArtifacts_Aviation.swift 中的 BarcodeView 冲突）
struct SimpleBarcodeView: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<30, id: \.self) { _ in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat.random(in: 1...3), height: 30)
            }
        }
    }
}

// 3.5 3D视差效果修饰符
struct Parallax3DEffect: ViewModifier {
    let strength: CGFloat
    @State private var offset = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    offset = CGSize(width: strength/2, height: strength/2)
                }
            }
    }
}

// MARK: - 🏛 Collection I: The Archivist (皇家档案馆)

// 1. The Royal Decree (诏书风) - Style.envelope (增强版 - 更华贵的皇家质感)
struct StyleRoyalDecreeView: View {
    let record: DayRecord
    @State private var inkProgress: Double = 0
    @State private var inkBleed: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // 羊皮纸基底 (更丰富的渐变)
            LinearGradient(
                colors: [
                    Color(hex: "F5F0E6"),
                    Color(hex: "F8F3E8"),
                    Color(hex: "F2EDE0")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PaperTextureOverlay(opacity: 0.25)
            
            // 边缘烧焦效果 (模拟古老文档)
            VStack {
                HStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "8B4513").opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "8B4513").opacity(0.1)],
                                startPoint: .trailing,
                                endPoint: .leading
                            )
                        )
                        .frame(height: 2)
                }
            }
            .padding(5)
            
            VStack(spacing: 25) {
                // 蚀刻照片 (更精致的边框和阴影)
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    ZStack {
                        // 照片白边 (多层阴影)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white)
                            .frame(width: 260, height: 200)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 3)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 3, y: 5)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240)
                            .grayscale(0.85)
                            .contrast(1.3)
                            .saturation(0.3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(0.6),
                                                Color.black.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .rotationEffect(.degrees(-1.5))
                    .padding(.top, 10)
                }
                
                // 墨水文字 (更真实的洇染效果)
                VStack(alignment: .leading, spacing: 12) {
                    Text(record.content)
                        .font(.custom("Didot", size: 17))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.95),
                                    Color.black.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .lineSpacing(7)
                        .opacity(inkProgress)
                        .mask(
                            Rectangle()
                                .frame(height: 200)
                                .offset(y: -100 + (inkProgress * 200))
                        )
                        .overlay(
                            // 墨水洇染效果
                            Canvas { context, size in
                                for point in inkBleed {
                                    let radius = Double.random(in: 2...5)
                                    let rect = CGRect(
                                        x: point.x - radius,
                                        y: point.y - radius,
                                        width: radius * 2,
                                        height: radius * 2
                                    )
                                    context.fill(
                                        Path(ellipseIn: rect),
                                        with: .color(.black.opacity(0.1))
                                    )
                                }
                            }
                            .opacity(inkProgress)
                        )
                    
                    Text(formatDate(record.date))
                        .font(.custom("Didot-Italic", size: 13))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.7),
                                    Color.black.opacity(0.5)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 12)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 底部火漆 (增强3D效果)
                HStack {
                    Spacer()
                    ProceduralWaxSealView(design: .crown, rotation: 12)
                        .modifier(Parallax3DEffect(strength: 12))
                        .scaleEffect(1.1)
                        .padding(.trailing, 25)
                        .padding(.bottom, 25)
                }
            }
            .padding(.top, 45)
        }
        .frame(width: 320, height: 520)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "8B4513").opacity(0.3),
                            Color(hex: "8B4513").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            // 墨水书写动画
            withAnimation(.easeInOut(duration: 2.5)) {
                inkProgress = 1.0
            }
            // 生成洇染点
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for _ in 0..<15 {
                    inkBleed.append(CGPoint(
                        x: Double.random(in: 50...250),
                        y: Double.random(in: 100...250)
                    ))
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "en_GB")
        return "Recorded on the \(f.string(from: date))"
    }
}

// 2. The Classified (绝密档案) - Style.vault (增强版 - 极致机密质感)
struct StyleClassifiedView: View {
    let record: DayRecord
    @State private var redacted = true
    @State private var typewriterProgress: Double = 0
    
    var body: some View {
        ZStack {
            // 牛皮纸色 (更真实的陈旧感)
            LinearGradient(
                colors: [
                    Color(hex: "D7C9AA"),
                    Color(hex: "D4C5A0"),
                    Color(hex: "D7C9AA")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PaperTextureOverlay(opacity: 0.2)
            
            VStack(alignment: .leading, spacing: 15) {
                // 顶部标记 (更精致的边框)
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.05))
                            .frame(width: 100, height: 22)
                        Text("CONFIDENTIAL")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(4)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    Spacer()
                    Text("COPY 01/01")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                
                // 照片 + 回形针 (更真实的细节)
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 220)
                            .grayscale(1.0)
                            .contrast(1.3)
                            .brightness(-0.1)
                            .rotationEffect(.degrees(1.2))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 3)
                            .overlay(
                                // 照片边缘磨损
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
                            )
                        
                        // 回形针 (更真实的金属质感)
                        ZStack {
                            Image(systemName: "paperclip")
                                .font(.system(size: 26))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.gray.opacity(0.8),
                                            Color.gray.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(-45))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        }
                        .offset(x: -6, y: -12)
                    }
                    .padding(.leading, 20)
                }
                
                // 被涂黑的文字 (更戏剧化的效果)
                VStack(alignment: .leading, spacing: 10) {
                    Text("SUBJECT: MEMORY RETRIEVAL")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .opacity(typewriterProgress)
                    
                    Text(record.content)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.black)
                        .lineSpacing(5)
                        .opacity(typewriterProgress)
                        .overlay(
                            GeometryReader { geo in
                                if redacted {
                                    ZStack {
                                        // 多层黑条 (更真实的涂黑效果)
                                        Color.black
                                        // 添加一些随机白点 (模拟涂改液)
                                        Canvas { context, size in
                                            for _ in 0..<5 {
                                                let x = Double.random(in: 0...size.width)
                                                let y = Double.random(in: 0...size.height)
                                                let rect = CGRect(x: x, y: y, width: 2, height: 2)
                                                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.3)))
                                            }
                                        }
                                    }
                                    .frame(height: geo.size.height)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            }
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                redacted.toggle()
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    
                    Text("// END OF FILE //")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.top, 12)
                        .opacity(typewriterProgress)
                }
                .padding(.horizontal, 25)
                
                Spacer()
                
                // 印章 (更戏剧化的效果)
                HStack {
                    Spacer()
                    ZStack {
                        // 印章背景
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 140, height: 50)
                        
                        Text("TOP SECRET")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.9),
                                        Color.red.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.red.opacity(0.9), lineWidth: 4)
                            )
                    }
                    .rotationEffect(.degrees(-12))
                    .shadow(color: .red.opacity(0.3), radius: 4, x: 2, y: 2)
                    .padding(20)
                }
            }
        }
        .frame(width: 300, height: 480)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 4)
        .onAppear {
            // 打字机效果
            withAnimation(.easeInOut(duration: 1.5)) {
                typewriterProgress = 1.0
            }
        }
    }
}

// 3. The Botanist (植物学家) - Style.pressedFlower
struct StyleBotanistView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            Color(hex: "F2E8D5") // 标本纸色
            PaperTextureOverlay(opacity: 0.1)
            
            // 边框
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color(hex: "556B2F"), lineWidth: 2)
                .padding(10)
            
            VStack {
                // 标本照片
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 240)
                        .clipped()
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        .overlay(
                            // 干花投影
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.black.opacity(0.1))
                                .offset(x: 50, y: 50)
                                .rotationEffect(.degrees(30))
                        )
                }
                
                // 手写学名
                VStack(spacing: 5) {
                    Text("Fig. 1: " + (record.weather?.label ?? "Specimen"))
                        .font(.custom("Snell Roundhand", size: 24))
                        .foregroundColor(Color(hex: "2F4F4F"))
                    
                    Text(record.content)
                        .font(.custom("Snell Roundhand", size: 18))
                        .foregroundColor(Color(hex: "2F4F4F").opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 30)
                
                Spacer()
                
                Text("Herbalium Musei")
                    .font(.system(size: 10, design: .serif))
                    .foregroundColor(Color(hex: "556B2F"))
                    .padding(.bottom, 20)
            }
            .padding(.top, 40)
        }
        .frame(width: 300, height: 460)
        .shadow(radius: 4)
    }
}

// MARK: - 🎬 Collection II: The Director (电影大师)

// 4. The Nolan (IMAX) - Style.filmNegative (增强版 - 极致电影质感)
struct StyleNolanView: View {
    let record: DayRecord
    @State private var frameOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 深黑背景 (模拟胶片暗盒)
            LinearGradient(
                colors: [Color.black, Color(hex: "0A0A0A")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 0) {
                // 上齿孔 (更精致的细节)
                FilmStrip()
                    .overlay(
                        // 齿孔边缘高光
                        HStack(spacing: 12) {
                            ForEach(0..<8) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 12, height: 18)
                            }
                        }
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                    )
                
                // 画面 (IMAX 70mm 质感)
                ZStack {
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contrast(1.15)
                            .saturation(1.1)
                            .brightness(-0.05)
                            .overlay(FilmGrainEffect(intensity: 0.35)) // 增强颗粒
                            .overlay(
                                // 边缘渐隐 (模拟胶片边缘)
                                VStack {
                                    LinearGradient(
                                        colors: [.black.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                    .frame(height: 20)
                                    Spacer()
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.3)],
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 20)
                                }
                            )
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(1.78, contentMode: .fit)
                    }
                }
                .offset(x: frameOffset)
                
                // 下齿孔
                FilmStrip()
                    .overlay(
                        HStack(spacing: 12) {
                            ForEach(0..<8) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 12, height: 18)
                            }
                        }
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                    )
            }
            
            // 侧边编码 (更精致的排版)
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    Text("KODAK 5219")
                        .font(.system(size: 5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "DAA520"))
                    Text("IMAX 70MM")
                        .font(.system(size: 5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "FFD700"))
                    Text(formatDate(record.date))
                        .font(.system(size: 5, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "DAA520").opacity(0.8))
                }
                .rotationEffect(.degrees(90))
                .offset(x: 135)
            }
            
            // 边缘光晕 (模拟放映机光线)
            VStack {
                LinearGradient(
                    colors: [.clear, Color(hex: "DAA520").opacity(0.1), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 450)
            }
        }
        .frame(width: 300, height: 450)
        .clipped()
        .onAppear {
            // 微妙的画面抖动 (模拟胶片放映)
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                frameOffset = 0.5
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
}

struct FilmStrip: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<8) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 12, height: 18)
            }
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
}

// 5. The Wes Anderson (韦斯·安德森) - Style.postcard (增强版 - 极致对称美学)
struct StyleWesAndersonView: View {
    let record: DayRecord
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 糖果粉背景 (更丰富的渐变)
            LinearGradient(
                colors: [
                    Color(hex: "FFC0CB"),
                    Color(hex: "FFB6C1"),
                    Color(hex: "FFC0CB")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 0) {
                Spacer()
                
                // 对称构图 (完美居中)
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 240)
                        .clipShape(Circle())
                        .overlay(
                            // 多层边框 (更精致的细节)
                            ZStack {
                                Circle()
                                    .stroke(Color(hex: "FFFACD"), lineWidth: 6)
                                Circle()
                                    .stroke(Color(hex: "FFE4B5"), lineWidth: 3)
                                    .padding(3)
                            }
                        )
                        .shadow(color: Color(hex: "4169E1").opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(scale)
                }
                
                Spacer()
                
                // 标题 (更精致的排版)
                Text("THE GRAND MEMORY")
                    .font(.custom("Futura-Bold", size: 17))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "4169E1"),
                                Color(hex: "1E90FF")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(3)
                    .padding(.top, 25)
                
                Text(record.content.uppercased())
                    .font(.custom("Futura-Medium", size: 13))
                    .foregroundColor(Color(hex: "4169E1"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                
                Spacer()
                
                // 钥匙图标 (更精致的金色)
                Image(systemName: "key.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700"),
                                Color(hex: "FFA500")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 4)
                    .padding(.bottom, 25)
                
                Spacer()
            }
        }
        .frame(width: 300, height: 450)
        .overlay(
            // 白色边框 (更精致的多层效果)
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.white, lineWidth: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "F0F0F0"), lineWidth: 8)
                        .padding(2)
                )
        )
        .shadow(color: Color(hex: "4169E1").opacity(0.2), radius: 12, x: 0, y: 6)
        .onAppear {
            // 微妙的缩放动画 (模拟镜头推进)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                scale = 1.02
            }
        }
    }
}

// 6. The Wong Kar-wai (王家卫) - Style.developedPhoto (增强版 - 极致霓虹美学)
struct StyleWongKarWaiView: View {
    let record: DayRecord
    @State private var neonFlicker: Double = 1.0
    @State private var scanlineOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if let data = record.photos.first, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 450)
                    .blur(radius: 1.5) // 更柔和的朦胧感
                    .overlay(
                        // 王家卫标志性绿色滤镜 (更丰富的层次)
                        LinearGradient(
                            colors: [
                                Color(hex: "006400").opacity(0.35),
                                Color(hex: "228B22").opacity(0.25),
                                Color(hex: "006400").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // 霓虹光晕
                        RadialGradient(
                            colors: [
                                Color(hex: "00FF00").opacity(0.1 * neonFlicker),
                                .clear
                            ],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
            } else {
                Color.black
            }
            
            VStack {
                Spacer()
                
                // 台词字幕 (更精致的排版)
                Text(record.content)
                    .font(.custom("PingFangSC-Semibold", size: 17))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFFF00"),
                                Color(hex: "FFD700")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 1, y: 1)
                    .shadow(color: Color(hex: "FFFF00").opacity(0.5 * neonFlicker), radius: 5, x: 0, y: 0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 65)
                    .opacity(neonFlicker)
                
                // 电子表时间 (更真实的LED效果)
                HStack {
                    Spacer()
                    ZStack {
                        // LED背景光
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "00FF00").opacity(0.2 * neonFlicker))
                            .blur(radius: 8)
                            .frame(width: 120, height: 35)
                        
                        Text(formatTime(record.date))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "00FF00"))
                            .shadow(color: Color(hex: "00FF00").opacity(0.8 * neonFlicker), radius: 8)
                    }
                    .padding(20)
                }
            }
            
            // 动态扫描线 (更真实的CRT效果)
            VStack(spacing: 0) {
                ForEach(0..<225) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.black.opacity(0.05),
                                    Color.black.opacity(0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .offset(x: sin(Double(i) * 0.1 + scanlineOffset) * 2)
                }
            }
            .blendMode(.overlay)
        }
        .frame(width: 300, height: 450)
        .clipped()
        .onAppear {
            // 霓虹闪烁动画
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                neonFlicker = Double.random(in: 0.85...1.0)
            }
            // 扫描线移动
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                scanlineOffset += .pi * 2
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}

// MARK: - 👠 Collection III: The Vogue (时尚女魔头)

// 8. The Cover (九月刊) - Style.simple (增强版 - 极致时尚杂志质感)
struct StyleVogueCoverView: View {
    let record: DayRecord
    @State private var titleGlow: Double = 1.0
    
    var body: some View {
        ZStack {
            if let data = record.photos.first, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 450)
                    .overlay(
                        // 杂志封面光晕 (模拟印刷反光)
                        LinearGradient(
                            colors: [
                                .white.opacity(0.05),
                                .clear,
                                .white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                LinearGradient(
                    colors: [Color.gray, Color(hex: "2C2C2C")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            
            // 巨大的标题遮挡 (更精致的排版)
            VStack {
                ZStack {
                    // 标题背景光晕
                    Text("TIME\nGRID")
                        .font(.custom("Didot", size: 62))
                        .fontWeight(.black)
                        .foregroundColor(.white.opacity(0.3))
                        .blur(radius: 8)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-10)
                    
                    // 主标题
                    Text("TIME\nGRID")
                        .font(.custom("Didot", size: 60))
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    Color.white.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineSpacing(-10)
                        .shadow(color: .black.opacity(0.6), radius: 8, x: 2, y: 3)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 1, y: 2)
                        .opacity(titleGlow)
                }
                .padding(.top, 25)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // 标签 (更精致的边框)
                        Text("THE MEMORY ISSUE")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                ZStack {
                                    Color.black.opacity(0.8)
                                    Rectangle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                }
                            )
                        
                        Text(record.content)
                            .font(.custom("Didot", size: 19))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color.white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineLimit(3)
                            .shadow(color: .black.opacity(0.7), radius: 4, x: 1, y: 2)
                    }
                    .padding(.leading, 18)
                    .padding(.bottom, 85)
                    
                    Spacer()
                }
            }
            
            // 底部条形码 (更精致的细节)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 85, height: 32)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                            
                            SimpleBarcodeView()
                                .frame(width: 80, height: 30)
                        }
                        
                        Text("$12.00 US")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                ZStack {
                                    Color.black.opacity(0.85)
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                }
                            )
                    }
                    .padding(18)
                }
            }
        }
        .frame(width: 300, height: 450)
        .clipped()
        .onAppear {
            // 标题呼吸光效
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                titleGlow = 0.92
            }
        }
    }
}

// 10. The Polaroid SX-70 (宝丽来) - Style.polaroid (增强版 - 极致复古显影质感)
struct StylePolaroidSX70View: View {
    let record: DayRecord
    @State private var developed: Double = 0
    @State private var chemicalStain: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // 宝丽来白色边框 (更真实的质感)
            LinearGradient(
                colors: [
                    Color.white,
                    Color(hex: "F8F8F8"),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // 边框阴影 (模拟照片厚度)
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
            )
            
            VStack(spacing: 0) {
                ZStack {
                    // 照片区域 (黑色边框)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.black)
                        .frame(width: 260, height: 260)
                        .padding(.top, 20)
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 260, height: 260)
                            .clipped()
                            .saturation(developed * 0.85) // 宝丽来特有的低饱和度
                            .contrast(0.7 + developed * 0.4)
                            .brightness(-0.1 + developed * 0.1)
                            .overlay(
                                // 显影过程中的化学污渍
                                Canvas { context, size in
                                    for point in chemicalStain {
                                        let radius = Double.random(in: 3...8)
                                        let rect = CGRect(
                                            x: point.x - radius,
                                            y: point.y - radius,
                                            width: radius * 2,
                                            height: radius * 2
                                        )
                                        context.fill(
                                            Path(ellipseIn: rect),
                                            with: .color(Color(hex: "FFD700").opacity(0.15 * (1 - developed)))
                                        )
                                    }
                                }
                                .opacity(1 - developed)
                            )
                            .overlay(
                                // 显影过程中的渐变遮罩
                                LinearGradient(
                                    colors: [
                                        .black.opacity(1 - developed),
                                        .black.opacity((1 - developed) * 0.5),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                
                Spacer()
                
                // 手写标题区域 (更真实的宝丽来风格)
                HStack {
                    Text(record.content.isEmpty ? "Untitled" : record.content)
                        .font(.custom("MarkerFelt-Thin", size: 19))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.9),
                                    Color.black.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)
            }
        }
        .frame(width: 300, height: 400) // 宝丽来比例
        .shadow(color: .black.opacity(0.15), radius: 8, x: 3, y: 4)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 1, y: 2)
        .onAppear {
            // 显影动画 (更真实的渐进过程)
            withAnimation(.easeIn(duration: 4.0)) {
                developed = 1.0
            }
            // 生成化学污渍
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                for _ in 0..<8 {
                    chemicalStain.append(CGPoint(
                        x: Double.random(in: 20...240),
                        y: Double.random(in: 20...240)
                    ))
                }
            }
        }
    }
}

// MARK: - 🎫 Collection IV: The Voyager (环球旅行家)

// 11. The Boarding Pass (登机牌) - Style.trainTicket
struct StyleBoardingPassView: View {
    let record: DayRecord
    @State private var isTorn = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 主券
            ZStack {
                Color.white
                // 蓝色条纹
                VStack(spacing: 4) {
                    ForEach(0..<15) { _ in
                        Rectangle()
                            .fill(Color(hex: "003366").opacity(0.05))
                            .frame(height: 1)
                        Spacer().frame(height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "airplane")
                        Text("PAN AM FIRST CLASS")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "003366"))
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .grayscale(1.0)
                            .overlay(Color(hex: "003366").opacity(0.2)) // 蓝色单色调
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("FROM").font(.caption2).foregroundColor(.gray)
                            Text("MEMORY").font(.system(size: 16, weight: .bold))
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("TO").font(.caption2).foregroundColor(.gray)
                            Text("ETERNITY").font(.system(size: 16, weight: .bold))
                        }
                    }
                }
                .padding(15)
            }
            .frame(width: 200, height: 450)
            
            // 虚线
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(width: 1)
                .foregroundColor(.gray)
            
            // 副券
            ZStack {
                Color.white
                VStack {
                    Text("SEAT")
                        .font(.caption)
                    Text("1A")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    SimpleBarcodeView()
                        .rotationEffect(.degrees(-90))
                    Spacer()
                }
                .padding(5)
            }
            .frame(width: 60, height: 450)
            .offset(x: isTorn ? 30 : 0, y: isTorn ? 30 : 0)
            .rotationEffect(.degrees(isTorn ? 10 : 0))
            .opacity(isTorn ? 0 : 1)
            .onTapGesture {
                withAnimation { isTorn = true }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

// MARK: - 💿 Collection V: The Collector (顶级藏家)

// 14. The Vinyl (黑胶) - Style.vinylRecord (增强版 - 极致黑胶质感)
struct StyleVinylView: View {
    let record: DayRecord
    @State private var spinning: Double = 0
    @State private var recordShine: Double = 0
    
    var body: some View {
        ZStack {
            // 封套 (左移，更精致的细节)
            ZStack {
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 280)
                        .clipped()
                        .overlay(
                            // 封套光晕
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    .clear,
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    LinearGradient(
                        colors: [Color(hex: "1A1A1A"), Color(hex: "0F0F0F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 280, height: 280)
                }
                
                VStack {
                    HStack {
                        // STEREO标签 (更精致的边框)
                        Text("STEREO")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                ZStack {
                                    Color.black.opacity(0.6)
                                    Rectangle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                }
                            )
                        Spacer()
                    }
                    .padding(12)
                    Spacer()
                    Text(record.content)
                        .font(.system(size: 19, weight: .heavy, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 2)
                        .padding()
                }
            }
            .frame(width: 280, height: 280)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 4)
            .offset(x: -40)
            
            // 唱片 (右移，旋转，更真实的黑胶质感)
            ZStack {
                // 外层黑胶
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black,
                                Color(hex: "1A1A1A"),
                                Color.black
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .overlay(
                        // 动态高光 (模拟光线反射)
                        Circle()
                            .trim(from: 0, to: 0.4)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3 * recordShine),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 60, lineCap: .round)
                            )
                            .frame(width: 260, height: 260)
                            .rotationEffect(.degrees(spinning + 45))
                    )
                
                // 沟壑 (更真实的螺旋纹理)
                ForEach(0..<5) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.15),
                                    Color.gray.opacity(0.25),
                                    Color.gray.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 15
                        )
                        .frame(width: 180 - CGFloat(i * 20), height: 180 - CGFloat(i * 20))
                }
                
                // 盘标 (更精致的金色标签)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFA500"),
                                    Color(hex: "FFD700")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 4)
                    
                    Text("SIDE A")
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            .offset(x: 60)
            .zIndex(-1)
            .rotationEffect(.degrees(spinning))
            .onAppear {
                // 旋转动画 (33.3 RPM)
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    spinning = 360
                }
                // 高光闪烁
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    recordShine = 1.0
                }
            }
        }
        .frame(width: 350, height: 300)
    }
}

// 16. The Receipt (小票) - Style.movieTicket
struct StyleReceiptView: View {
    let record: DayRecord
    
    var body: some View {
        VStack(spacing: 0) {
            // 锯齿边缘
            JaggedEdge()
                .fill(Color.white)
                .frame(height: 10)
            
            ZStack {
                Color.white
                VStack(spacing: 15) {
                    Text("THE MEMORY BISTRO")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    
                    Divider()
                    
                    // 伪造的消费项
                    VStack(alignment: .leading, spacing: 5) {
                        itemRow(name: "1x MOMENT", price: "$0.00")
                        itemRow(name: "1x EMOTION: \(record.mood.label)", price: "Priceless")
                        if let w = record.weather?.label {
                            itemRow(name: "1x ATMOSPHERE: \(w)", price: "$0.00")
                        }
                    }
                    
                    Divider()
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .grayscale(1.0)
                            .contrast(1.5) // 高对比度模拟热敏打印
                            .overlay(
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .blendMode(.multiply) // 颗粒感
                            )
                    }
                    
                    Text(record.content)
                        .font(.system(size: 12, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    
                    Text(Date().formatted())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
            
            // 底部锯齿
            JaggedEdge()
                .fill(Color.white)
                .frame(height: 10)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 260)
        .shadow(radius: 2)
    }
    
    func itemRow(name: String, price: String) -> some View {
        HStack {
            Text(name).font(.system(size: 12, design: .monospaced))
            Spacer()
            Text(price).font(.system(size: 12, design: .monospaced))
        }
    }
}

struct JaggedEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        let step = 10.0
        for x in stride(from: 0, to: rect.width, by: step) {
            path.addLine(to: CGPoint(x: x + step/2, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: rect.height))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - 🏛 Collection I 补充风格

// 皇家御玺 - Style.waxStamp
struct StyleWaxStampView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 金色羊皮纸
            LinearGradient(
                colors: [Color(hex: "F5E6D3"), Color(hex: "E8D5B7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PaperTextureOverlay(opacity: 0.2)
            
            VStack(spacing: 20) {
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240)
                        .grayscale(0.3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "D4AF37"), lineWidth: 3)
                        )
                }
                
                Text(record.content)
                    .font(.custom("Didot", size: 16))
                    .foregroundColor(Color(hex: "8B4513"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // 巨大的御玺
                ProceduralWaxSealView(design: .crown, rotation: 0)
                    .scaleEffect(1.5)
                    .padding(.bottom, 40)
            }
            .padding(.top, 50)
        }
        .frame(width: 300, height: 450)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "D4AF37"), lineWidth: 2)
        )
    }
}

// 作家手稿 - Style.typewriter
struct StyleTypewriterView: View {
    let record: DayRecord
    @State private var typingProgress: Double = 0
    
    var body: some View {
        ZStack {
            // 打字机纸张色
            Color(hex: "F9F9F6")
            PaperTextureOverlay(opacity: 0.15)
            
            VStack(alignment: .leading, spacing: 15) {
                // 打字机行号
                HStack {
                    ForEach(1..<6) { n in
                        Text("\(n)")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .grayscale(0.8)
                        .contrast(1.2)
                        .padding(.leading, 40)
                }
                
                Text(record.content)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.black)
                    .lineSpacing(8)
                    .opacity(typingProgress)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // 打字机按键效果
                HStack {
                    Spacer()
                    Text("///")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.bottom, 30)
                        .padding(.trailing, 30)
                }
            }
        }
        .frame(width: 300, height: 450)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                typingProgress = 1.0
            }
        }
    }
}

// 日记内页 - Style.journalPage
struct StyleJournalPageView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 日记本纸张
            Color(hex: "FFFEF7")
            PaperTextureOverlay(opacity: 0.1)
            
            // 横线
            VStack(spacing: 20) {
                ForEach(0..<20) { _ in
                    Rectangle()
                        .fill(Color(hex: "E8E8E0"))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 50)
            
            VStack(alignment: .leading, spacing: 15) {
                // 日期
                Text(record.formattedDate)
                    .font(.custom("Snell Roundhand", size: 18))
                    .foregroundColor(Color(hex: "8B4513"))
                    .padding(.horizontal, 30)
                    .padding(.top, 40)
                
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding(.leading, 30)
                }
                
                Text(record.content)
                    .font(.custom("Snell Roundhand", size: 16))
                    .foregroundColor(Color(hex: "2F2F2F"))
                    .lineSpacing(8)
                    .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .frame(width: 300, height: 450)
        .overlay(
            Rectangle()
                .stroke(Color(hex: "D4AF37"), lineWidth: 2)
        )
    }
}

// MARK: - 🎫 Collection IV 补充风格

// 演出票 - Style.concertTicket
struct StyleConcertTicketView: View {
    let record: DayRecord
    
    var body: some View {
        VStack(spacing: 0) {
            // 票头
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack {
                    Text("CONCERT")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .foregroundColor(.white)
                    Text("MEMORY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                }
            }
            .frame(height: 80)
            
            // 照片区域
            if let data = record.photos.first, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            }
            
            // 信息区域
            VStack(alignment: .leading, spacing: 10) {
                Text(record.content)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                HStack {
                    Text("DATE:")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(record.formattedDate)
                        .font(.system(size: 10, design: .monospaced))
                }
                
                SimpleBarcodeView()
                    .frame(height: 40)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 280, height: 450)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}

// MARK: - 💿 Collection V 补充风格

// 书签 - Style.bookmark
struct StyleBookmarkView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 书签形状
            VStack(spacing: 0) {
                // 顶部圆角
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B0000"), Color(hex: "A52A2A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 350)
                
                // 底部尖角
                Triangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "A52A2A"), Color(hex: "8B0000")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 100)
            }
            
            VStack(spacing: 15) {
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
                
                Text(record.content)
                    .font(.custom("Didot", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            .padding(.top, 30)
        }
        .frame(width: 200, height: 450)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// 注意：Triangle 已在 UnifiedKeepsakeSystem.swift 和 MasterForgeWidgets_Complete.swift 中定义
// 这里不再重复定义

// MARK: - 🌍 Collection VI: The Explorer (探索者系列)

// 探险日志 - Style.safari
struct StyleSafariView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 沙漠色背景
            LinearGradient(
                colors: [Color(hex: "F4A460"), Color(hex: "DEB887")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PaperTextureOverlay(opacity: 0.2)
            
            VStack(spacing: 20) {
                // 标题
                Text("SAFARI LOG")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "8B4513"))
                    .padding(.top, 30)
                
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                }
                
                Text(record.content)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(Color(hex: "654321"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
                
                // 印章
                Text("EXPEDITION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "8B4513"))
                    .padding(8)
                    .overlay(
                        Rectangle()
                            .stroke(Color(hex: "8B4513"), lineWidth: 2)
                    )
                    .padding(.bottom, 30)
            }
        }
        .frame(width: 300, height: 450)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "8B4513"), lineWidth: 3)
        )
    }
}

// 极光幻境 - Style.aurora
struct StyleAuroraView: View {
    let record: DayRecord
    @State private var auroraOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 深蓝夜空
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 极光效果
            VStack {
                LinearGradient(
                    colors: [
                        Color(hex: "00FF88").opacity(0.6),
                        Color(hex: "00D4FF").opacity(0.4),
                        Color(hex: "FF00FF").opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 150)
                .offset(x: auroraOffset)
                .blur(radius: 20)
            }
            
            VStack(spacing: 20) {
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "00FF88"), Color(hex: "00D4FF")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                }
                
                Text(record.content)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                    .shadow(color: Color(hex: "00FF88").opacity(0.5), radius: 5)
            }
            .padding(.top, 50)
        }
        .frame(width: 300, height: 450)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                auroraOffset = 50
            }
        }
    }
}

// 星象仪 - Style.astrolabe
struct StyleAstrolabeView: View {
    let record: DayRecord
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 深蓝星空
            LinearGradient(
                colors: [Color(hex: "000428"), Color(hex: "004e92")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 星星
            Canvas { context, size in
                for _ in 0..<50 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let radius = Double.random(in: 0.5...2)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                        with: .color(.white.opacity(0.8))
                    )
                }
            }
            
            VStack(spacing: 20) {
                // 星象仪圆环
                ZStack {
                    Circle()
                        .stroke(Color(hex: "FFD700"), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.5), lineWidth: 1)
                        .frame(width: 150, height: 150)
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    }
                }
                .rotationEffect(.degrees(rotation))
                
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
            }
            .padding(.top, 50)
        }
        .frame(width: 300, height: 450)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// 神社绘马 - Style.omikuji
struct StyleOmikujiView: View {
    let record: DayRecord
    
    var body: some View {
        ZStack {
            // 木色背景
            LinearGradient(
                colors: [Color(hex: "DEB887"), Color(hex: "CD853F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PaperTextureOverlay(opacity: 0.25)
            
            VStack(spacing: 15) {
                // 顶部装饰
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(hex: "8B4513"))
                    Spacer()
                    Text("⛩️")
                        .font(.system(size: 30))
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(hex: "8B4513"))
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                }
                
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "654321"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
                
                // 底部签名
                Text("願い事")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "8B4513"))
                    .padding(.bottom, 30)
            }
        }
        .frame(width: 280, height: 450)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "8B4513"), lineWidth: 3)
        )
    }
}

// 流沙时光 - Style.hourglass
struct StyleHourglassView: View {
    let record: DayRecord
    @State private var sandProgress: Double = 0
    
    var body: some View {
        ZStack {
            // 沙色背景
            LinearGradient(
                colors: [Color(hex: "F5DEB3"), Color(hex: "DEB887")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // 沙漏图标
                ZStack {
                    Image(systemName: "hourglass")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "8B4513"))
                        .opacity(0.3)
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "8B4513"), lineWidth: 3)
                            )
                    }
                }
                .padding(.top, 50)
                
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "654321"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
                
                // 流沙效果
                VStack {
                    Rectangle()
                        .fill(Color(hex: "8B4513").opacity(0.3))
                        .frame(height: CGFloat(sandProgress * 60))
                }
                .frame(width: 20, height: 60)
                .padding(.bottom, 40)
            }
        }
        .frame(width: 300, height: 450)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "8B4513"), lineWidth: 2)
        )
        .onAppear {
            withAnimation(.linear(duration: 3)) {
                sandProgress = 1.0
            }
        }
    }
}

// MARK: - 兼容旧版本

// 时光小票 - Style.monoTicket
struct StyleMonoTicketView: View {
    let record: DayRecord
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white
                
                VStack(spacing: 10) {
                    Text("时光格")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .grayscale(1.0)
                            .contrast(1.5)
                    }
                    
                    Text(record.content)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text(record.formattedDate)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
        }
        .frame(width: 260, height: 450)
        .shadow(radius: 3)
    }
}

// 流光邀约 - Style.galaInvite
struct StyleGalaInviteView: View {
    let record: DayRecord
    @State private var shimmer: Double = 0
    
    var body: some View {
        ZStack {
            // 深色背景
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 流光效果
            VStack {
                LinearGradient(
                    colors: [
                        .clear,
                        Color(hex: "FFD700").opacity(0.3 * shimmer),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 450)
                .offset(x: CGFloat(shimmer * 100 - 50))
            }
            
            VStack(spacing: 20) {
                Text("GALA INVITATION")
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.top, 40)
                
                if let data = record.photos.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "FFD700"), lineWidth: 2)
                        )
                }
                
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
            }
        }
        .frame(width: 300, height: 450)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                shimmer = 1.0
            }
        }
    }
}

// MARK: - ⚠️ 重要提示
// 如果遇到 "Cannot find 'MasterXXXView' in scope" 错误，
// 请确保以下文件已添加到 Xcode 项目的 target 中：
// - MasterArtifacts_Nature.swift (包含 MasterPressedFlowerView, MasterJournalPageView, MasterTypewriterManuscriptView)
// - MasterArtifacts_Film.swift (包含 MasterDevelopedPhotoView)
// - MasterArtifacts_Explorer.swift (包含 MasterSafariJournalView, MasterAuroraView, MasterAstrolabeView, MasterOmikujiView, MasterHourglassView)
// - MasterArtifacts_Aviation.swift (包含 MasterBoardingPassView, MasterAircraftTypeRatingView, MasterFlightLogView, MasterLuggageTagView)
// - MasterArtifacts_Tickets.swift (包含 MasterMonoTicketView, MasterGalaInviteView, MasterConcertTicketView)
//
// 添加方法：
// 1. 在 Xcode 项目导航器中，右键点击 'Sources' 文件夹
// 2. 选择 'Add Files to "YiGe"...'
// 3. 选择上述文件
// 4. 确保 'Add to targets: YiGe' 被选中
// 5. 点击 'Add'

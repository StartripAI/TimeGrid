import SwiftUI

struct ReceiptView: View {
    let entry: ReceiptEntry
    let processedImage: UIImage?
    var applyInkBleed: Bool = true // 控制是否应用墨迹模拟
    
    // 使用系统等宽字体
    let receiptFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    let titleFont = Font.system(size: 18, weight: .bold, design: .monospaced)
    let smallFont = Font.system(size: 10, weight: .regular, design: .monospaced)

    var body: some View {
        VStack(spacing: 10) {
            // Header
            VStack(spacing: 4) {
                Text("时光小票 MONOLOG")
                    .font(titleFont)
                    .tracking(2)
                Text("--- 为时间开具收据 ---")
                    .font(receiptFont)
            }
            
            DividerLine()
            
            // Metadata
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DATE:")
                    Spacer()
                    Text(entry.displayDate)
                }
                HStack {
                    Text("TXN:")
                    Spacer()
                    Text(entry.transactionID)
                }
            }
            .font(receiptFont)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            DividerLine()
            
            // Content Section
            VStack(alignment: .leading, spacing: 12) {
                // 照片
                if let img = processedImage {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none) // 关键：保持像素感
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
                
                // 文字内容
                if !entry.content.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MEMO:")
                            .font(smallFont)
                            .opacity(0.6)
                        Text(entry.content.uppercased())
                            .font(receiptFont)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            DividerLine()
            
            // Item Line (模拟收据项目)
            HStack {
                Text("TIME SPENT")
                Spacer()
                Text("1 MOMENT")
            }
            .font(receiptFont)
            
            HStack {
                Text("VALUE")
                Spacer()
                Text("PRICELESS")
            }
            .font(receiptFont)
            
            DividerLine()
            
            // Footer & Barcode
            VStack(spacing: 12) {
                // 条形码
                if let barcode = ImageProcessor.shared.generateBarcode(from: entry.barcodeString) {
                    Image(uiImage: barcode)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }
                
                // 条形码数字
                Text(entry.barcodeString)
                    .font(smallFont)
                    .tracking(4)
                
                // Footer 消息
                Text(entry.footerMessage)
                    .font(receiptFont)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                // 时间戳装饰
                Text("*  *  *")
                    .font(receiptFont)
                    .opacity(0.5)
            }
        }
        .font(receiptFont)
        .foregroundColor(Color("InkColor"))
        .padding(20)
        .background(Color("PaperBackground"))
        // 应用墨迹模拟 (轻微模糊)
        .blur(radius: applyInkBleed ? 0.3 : 0)
        // 应用撕裂边缘效果
        .clipShape(TornEdgeShape(tearHeight: 5, tearCount: 35))
    }
}

// MARK: - 辅助视图：虚线分隔符
struct DividerLine: View {
    var body: some View {
        Text(String(repeating: "-", count: 40))
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(Color("InkColor"))
            .opacity(0.7)
            .lineLimit(1)
    }
}

// MARK: - 辅助形状：模拟真实的撕纸边缘
struct TornEdgeShape: Shape {
    var tearHeight: CGFloat = 5
    var tearCount: Int = 30

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let step = rect.width / CGFloat(tearCount)
        
        // 顶部撕裂边缘
        path.move(to: CGPoint(x: 0, y: tearHeight))
        
        for i in 0...tearCount {
            let x = CGFloat(i) * step
            let randomOffset = CGFloat.random(in: -tearHeight * 0.3...tearHeight * 0.3)
            let baseHeight = (i % 2 == 0) ? 0 : tearHeight
            let y = baseHeight + randomOffset
            path.addLine(to: CGPoint(x: x, y: max(0, min(tearHeight * 2, y))))
        }
        
        // 右边
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - tearHeight))
        
        // 底部撕裂边缘
        for i in stride(from: tearCount, through: 0, by: -1) {
            let x = CGFloat(i) * step
            let randomOffset = CGFloat.random(in: -tearHeight * 0.3...tearHeight * 0.3)
            let baseHeight = (i % 2 == 0) ? 0 : tearHeight
            let y = rect.height - baseHeight - randomOffset
            path.addLine(to: CGPoint(x: x, y: max(rect.height - tearHeight * 2, min(rect.height, y))))
        }
        
        // 左边
        path.addLine(to: CGPoint(x: 0, y: tearHeight))
        
        path.closeSubpath()
        return path
    }
}

// MARK: - 预览
#Preview {
    ReceiptView(
        entry: ReceiptEntry(content: "今天阳光很好，在咖啡店度过了一个美好的下午。", imageData: nil),
        processedImage: nil
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}


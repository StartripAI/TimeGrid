//
//  ThermalReceiptV9.swift
//  时光格 - 支持1-6张照片的热敏小票和收据 V9.0
//
//  ⚠️ 核心保证：
//  - 照片100%彩色，绝不变黑白
//  - 1-6张照片全部同时可见，绝不重叠
//  - 智能布局，每种数量都有最佳排列
//

import SwiftUI

// MARK: - 🏪 热敏小票 V9

struct ThermalReceiptV9: View {
    let record: DayRecord
    
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    private let terminal: String
    
    init(record: DayRecord) {
        self.record = record
        
        let stores = [
            ("时光便利店", "TIME MART 24H"),
            ("记忆小酒馆", "MEMORY BISTRO"),
            ("回忆咖啡屋", "NOSTALGIA CAFE")
        ]
        self.storeName = stores.randomElement()!
        
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        self.orderNo = prefix + String(format: "%06d", Int.random(in: 1...999999))
        self.cashier = ["TIME", "MEMO", "STAR"].randomElement()!
        self.terminal = String(format: "%02d", Int.random(in: 1...12))
    }
    
    // 获取有效照片（最多6张）- 确保返回数组
    private var photos: [UIImage] {
        let images = record.photos.compactMap { UIImage(data: $0) }
        return Array(images.prefix(6))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            JaggedEdgeV9()
                .fill(Color.white)
                .frame(height: 8)
            
            // 主体
            ZStack {
                Color.white
                PaperNoiseV9()
                
                VStack(spacing: 5) {
                    // 店铺头部
                    VStack(spacing: 2) {
                        Text("🏪")
                            .font(.system(size: 18))
                        Text(storeName.cn)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                        Text(storeName.en)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 6)
                    
                    // 分隔
                    Text(String(repeating: "·", count: 26))
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.4))
                    
                    // 订单信息
                    HStack {
                        Text("单号: \(orderNo)")
                        Spacer()
                        Text(dateString)
                    }
                    .font(.system(size: 5, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    
                    DashedLineV9()
                    
                    // ═══════════════════════════════════════════
                    // 📷 照片区域 - 1-6张全部可见
                    // ═══════════════════════════════════════════
                    if !photos.isEmpty {
                        VStack(spacing: 4) {
                            Text("📷 今日快照 ×\(photos.count)")
                                .font(.system(size: 6, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // 照片网格 - 确保所有照片都显示
                            ThermalPhotoGridV9(photos: photos)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    DashedLineV9()
                    
                    // 商品列表
                    VStack(alignment: .leading, spacing: 2) {
                        itemRow("回忆存储 ×\(max(1, photos.count))", "¥0.00")
                        itemRow("心情: \(record.mood.label)", "∞")
                        if let w = record.weather {
                            itemRow("天气: \(w.label)", "¥0.00")
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // 内容
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 6, design: .monospaced))
                            .lineLimit(2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                    }
                    
                    // 分隔
                    Text(String(repeating: "═", count: 20))
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    // 合计
                    HStack {
                        Text("合计")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("¥∞")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 8)
                    
                    // 条形码
                    BarcodeV9()
                        .frame(height: 16)
                        .padding(.horizontal, 15)
                    
                    // 底部
                    Text("★ 谢谢惠顾 ★")
                        .font(.system(size: 6, weight: .medium, design: .monospaced))
                    
                    Text(fullTimestamp)
                        .font(.system(size: 4, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 6)
                }
                .padding(.horizontal, 6)
            }
            
            // 底部锯齿
            JaggedEdgeV9()
                .fill(Color.white)
                .frame(height: 8)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 170, height: photoAreaHeight + 280)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
    
    // 根据照片数量计算高度
    private var photoAreaHeight: CGFloat {
        switch photos.count {
        case 0: return 0
        case 1: return 110
        case 2: return 65
        case 3: return 50
        case 4: return 120
        case 5: return 105
        case 6: return 95
        default: return 95
        }
    }
    
    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f.string(from: record.date)
    }
    
    private var fullTimestamp: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return f.string(from: record.date)
    }
    
    private func itemRow(_ name: String, _ price: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(price)
        }
        .font(.system(size: 6, design: .monospaced))
    }
}

// MARK: - 🎫 热敏小票照片网格

struct ThermalPhotoGridV9: View {
    let photos: [UIImage]
    
    var body: some View {
        Group {
            switch photos.count {
            case 1:
                // 1张：大图居中 (130×100pt)
                PhotoCellV9(image: photos[0], width: 130, height: 100)
                
            case 2:
                // 2张：左右并排 (各 68×55pt)
                HStack(spacing: 4) {
                    PhotoCellV9(image: photos[0], width: 68, height: 55)
                    PhotoCellV9(image: photos[1], width: 68, height: 55)
                }
                
            case 3:
                // 3张：一行三张 (各 46×42pt)
                HStack(spacing: 3) {
                    PhotoCellV9(image: photos[0], width: 46, height: 42)
                    PhotoCellV9(image: photos[1], width: 46, height: 42)
                    PhotoCellV9(image: photos[2], width: 46, height: 42)
                }
                
            case 4:
                // 4张：2×2网格 (各 68×52pt)
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[0], width: 68, height: 52)
                        PhotoCellV9(image: photos[1], width: 68, height: 52)
                    }
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[2], width: 68, height: 52)
                        PhotoCellV9(image: photos[3], width: 68, height: 52)
                    }
                }
                
            case 5:
                // 5张：上2下3 (上 68×48pt, 下 46×38pt)
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[0], width: 68, height: 48)
                        PhotoCellV9(image: photos[1], width: 68, height: 48)
                    }
                    HStack(spacing: 3) {
                        PhotoCellV9(image: photos[2], width: 46, height: 38)
                        PhotoCellV9(image: photos[3], width: 46, height: 38)
                        PhotoCellV9(image: photos[4], width: 46, height: 38)
                    }
                }
                
            case 6:
                // 6张：2×3网格 (各 46×38pt) - 两行，每行3张
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        PhotoCellV9(image: photos[0], width: 46, height: 38)
                        PhotoCellV9(image: photos[1], width: 46, height: 38)
                        PhotoCellV9(image: photos[2], width: 46, height: 38)
                    }
                    HStack(spacing: 3) {
                        PhotoCellV9(image: photos[3], width: 46, height: 38)
                        PhotoCellV9(image: photos[4], width: 46, height: 38)
                        PhotoCellV9(image: photos[5], width: 46, height: 38)
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - 🍽️ 收据 V9

struct ReceiptV9: View {
    let record: DayRecord
    
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    
    init(record: DayRecord) {
        self.record = record
        
        let stores = [
            ("记忆小酒馆", "MEMORY BISTRO"),
            ("回忆咖啡屋", "NOSTALGIA CAFE"),
            ("时光茶室", "TIME TEA HOUSE")
        ]
        self.storeName = stores.randomElement()!
        
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        self.orderNo = prefix + String(format: "%06d", Int.random(in: 1...999999))
        self.cashier = ["TIME", "LUNA", "NOVA"].randomElement()!
    }
    
    // 获取有效照片（最多6张）- 确保返回数组
    private var photos: [UIImage] {
        let images = record.photos.compactMap { UIImage(data: $0) }
        return Array(images.prefix(6))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            JaggedEdgeV9()
                .fill(Color.white)
                .frame(height: 10)
            
            // 主体
            ZStack {
                Color.white
                PaperNoiseV9()
                
                VStack(spacing: 6) {
                    // 店铺头部
                    VStack(spacing: 2) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        Text(storeName.en)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                        Text(storeName.cn)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                    
                    DashedLineV9()
                    
                    // 订单信息
                    HStack {
                        Text("ORDER #\(orderNo)")
                        Spacer()
                        Text(dateString)
                    }
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    
                    DashedLineV9()
                    
                    // ═══════════════════════════════════════════
                    // 📷 照片区域 - 1-6张全部可见
                    // ═══════════════════════════════════════════
                    if !photos.isEmpty {
                        VStack(spacing: 4) {
                            Text("📸 TODAY'S SPECIAL ×\(photos.count)")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // 照片网格 - 确保所有照片都显示
                            ReceiptPhotoGridV9(photos: photos)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    DashedLineV9()
                    
                    // 商品列表
                    VStack(alignment: .leading, spacing: 3) {
                        receiptItem("\(max(1, photos.count))x", "MOMENTS CAPTURED", "$0.00")
                        receiptItem("1x", "EMOTION: \(record.mood.label.uppercased())", "PRICELESS")
                        if let w = record.weather {
                            receiptItem("1x", "WEATHER: \(w.label.uppercased())", "$0.00")
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    // 内容
                    if !record.content.isEmpty {
                        VStack(spacing: 1) {
                            Text("NOTES")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.gray)
                            Text(record.content)
                                .font(.system(size: 7, design: .monospaced))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                    }
                    
                    DashedLineV9()
                    
                    // 总计
                    VStack(spacing: 2) {
                        HStack {
                            Text("SUBTOTAL")
                            Spacer()
                            Text("PRICELESS")
                        }
                        .font(.system(size: 7, design: .monospaced))
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 0.5)
                        
                        HStack {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("∞")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    // 条形码
                    BarcodeV9()
                        .frame(height: 18)
                        .padding(.horizontal, 18)
                    
                    // 底部
                    VStack(spacing: 1) {
                        Text("★ ★ ★ THANK YOU ★ ★ ★")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                        Text("Your memories are priceless")
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 8)
            }
            
            // 底部锯齿
            JaggedEdgeV9()
                .fill(Color.white)
                .frame(height: 10)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 190, height: photoAreaHeight + 300)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
    
    private var photoAreaHeight: CGFloat {
        switch photos.count {
        case 0: return 0
        case 1: return 125
        case 2: return 75
        case 3: return 60
        case 4: return 140
        case 5: return 120
        case 6: return 110
        default: return 110
        }
    }
    
    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy HH:mm"
        return f.string(from: record.date)
    }
    
    private func receiptItem(_ qty: String, _ name: String, _ price: String) -> some View {
        HStack {
            Text(qty)
                .frame(width: 20, alignment: .leading)
            Text(name)
                .lineLimit(1)
            Spacer()
            Text(price)
        }
        .font(.system(size: 6, design: .monospaced))
    }
}

// MARK: - 🎫 收据照片网格

struct ReceiptPhotoGridV9: View {
    let photos: [UIImage]
    
    var body: some View {
        Group {
            switch photos.count {
            case 1:
                // 1张：大图居中 (150×115pt)
                PhotoCellV9(image: photos[0], width: 150, height: 115)
                
            case 2:
                // 2张：左右并排 (各 78×62pt)
                HStack(spacing: 5) {
                    PhotoCellV9(image: photos[0], width: 78, height: 62)
                    PhotoCellV9(image: photos[1], width: 78, height: 62)
                }
                
            case 3:
                // 3张：一行三张 (各 52×48pt)
                HStack(spacing: 4) {
                    PhotoCellV9(image: photos[0], width: 52, height: 48)
                    PhotoCellV9(image: photos[1], width: 52, height: 48)
                    PhotoCellV9(image: photos[2], width: 52, height: 48)
                }
                
            case 4:
                // 4张：2×2网格 (各 78×60pt)
                VStack(spacing: 4) {
                    HStack(spacing: 5) {
                        PhotoCellV9(image: photos[0], width: 78, height: 60)
                        PhotoCellV9(image: photos[1], width: 78, height: 60)
                    }
                    HStack(spacing: 5) {
                        PhotoCellV9(image: photos[2], width: 78, height: 60)
                        PhotoCellV9(image: photos[3], width: 78, height: 60)
                    }
                }
                
            case 5:
                // 5张：上2下3 (上 78×55pt, 下 52×42pt)
                VStack(spacing: 4) {
                    HStack(spacing: 5) {
                        PhotoCellV9(image: photos[0], width: 78, height: 55)
                        PhotoCellV9(image: photos[1], width: 78, height: 55)
                    }
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[2], width: 52, height: 42)
                        PhotoCellV9(image: photos[3], width: 52, height: 42)
                        PhotoCellV9(image: photos[4], width: 52, height: 42)
                    }
                }
                
            case 6:
                // 6张：2×3网格 (各 52×44pt) - 两行，每行3张
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[0], width: 52, height: 44)
                        PhotoCellV9(image: photos[1], width: 52, height: 44)
                        PhotoCellV9(image: photos[2], width: 52, height: 44)
                    }
                    HStack(spacing: 4) {
                        PhotoCellV9(image: photos[3], width: 52, height: 44)
                        PhotoCellV9(image: photos[4], width: 52, height: 44)
                        PhotoCellV9(image: photos[5], width: 52, height: 44)
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - 📷 单个照片单元格

struct PhotoCellV9: View {
    let image: UIImage
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 0.5)
            )
    }
}

// MARK: - 辅助组件

struct JaggedEdgeV9: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        let step: CGFloat = 6.0
        for x in stride(from: CGFloat(0), to: rect.width, by: step) {
            path.addLine(to: CGPoint(x: x + step/2, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: rect.height))
        }
        path.closeSubpath()
        return path
    }
}

struct PaperNoiseV9: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<80 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.gray.opacity(Double.random(in: 0.02...0.04))))
            }
        }
        .allowsHitTesting(false)
    }
}

struct DashedLineV9: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
            .foregroundColor(.gray.opacity(0.4))
        }
        .frame(height: 1)
        .padding(.horizontal, 8)
    }
}

struct BarcodeV9: View {
    var body: some View {
        HStack(spacing: 0.8) {
            ForEach(0..<40, id: \.self) { _ in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat.random(in: 0.8...2.2))
            }
        }
    }
}


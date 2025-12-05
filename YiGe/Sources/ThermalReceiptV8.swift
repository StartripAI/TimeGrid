//
//  ThermalReceiptV8.swift
//  时光格 - 支持1-6张照片的热敏小票和收据 V8.0
//
//  照片布局规则：
//  - 1张：大图居中
//  - 2张：左右并排
//  - 3张：一行三张
//  - 4张：2×2网格
//  - 5张：上2下3
//  - 6张：2×3网格（两行，每行3张）
//

import SwiftUI

// MARK: - 🏪 热敏小票 V8 (支持多照片)

struct ThermalReceiptV8: View {
    let record: DayRecord
    
    // 随机元素
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    private let terminal: String
    private let showBarcode: Bool
    private let showQR: Bool
    
    init(record: DayRecord) {
        self.record = record
        
        let stores = [
            ("时光便利店", "TIME MART 24H"),
            ("记忆小酒馆", "MEMORY BISTRO"),
            ("回忆咖啡屋", "NOSTALGIA CAFE"),
            ("光阴杂货铺", "MOMENT GROCERY"),
            ("岁月面包房", "YEARS BAKERY")
        ]
        self.storeName = stores.randomElement()!
        
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        self.orderNo = prefix + String(format: "%06d", Int.random(in: 1...999999))
        
        self.cashier = ["TIME", "MEMO", "PAST", "YEAR", "STAR"].randomElement()!
        self.terminal = String(format: "%02d", Int.random(in: 1...12))
        self.showBarcode = Double.random(in: 0...1) > 0.4
        self.showQR = Bool.random()
    }
    
    // 获取有效照片（最多6张）
    private var validPhotos: [UIImage] {
        record.photos.compactMap { UIImage(data: $0) }.prefix(6).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            ThermalJaggedEdgeV8()
                .fill(Color.white)
                .frame(height: 8)
            
            // 主体
            ZStack {
                Color.white
                ThermalNoiseV8()
                
                VStack(spacing: 5) {
                    // ══════════════════════════════════════
                    // 店铺头部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Text("🏪")
                            .font(.system(size: 20))
                        
                        Text(storeName.cn)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                        
                        Text(storeName.en)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 5)
                    
                    // 分隔符
                    Text(String(repeating: "·", count: 28))
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    // ══════════════════════════════════════
                    // 订单信息
                    // ══════════════════════════════════════
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("单号: \(orderNo)")
                            Text("日期: \(dateString)")
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("收银: \(cashier)")
                            Text("机号: \(terminal)")
                        }
                    }
                    .font(.system(size: 5, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    
                    // 虚线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 🎨 照片区域 - 智能布局 1-6张
                    // ══════════════════════════════════════
                    if !validPhotos.isEmpty {
                        VStack(spacing: 3) {
                            Text("📷 今日快照 (\(validPhotos.count))")
                                .font(.system(size: 6, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // 智能照片网格
                            ThermalPhotoGridV8(photos: validPhotos, containerWidth: 150)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 虚线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 商品列表
                    // ══════════════════════════════════════
                    VStack(alignment: .leading, spacing: 2) {
                        thermalItem("回忆存储 x\(validPhotos.count)", "¥0.00")
                        thermalItem("心情: \(record.mood.label)", "∞")
                        if let w = record.weather {
                            thermalItem("天气: \(w.label)", "¥0.00")
                        }
                    }
                    .padding(.horizontal, 6)
                    
                    // ══════════════════════════════════════
                    // 内容（如有）
                    // ══════════════════════════════════════
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 6, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                    }
                    
                    // 分隔
                    Text(String(repeating: "═", count: 22))
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    // ══════════════════════════════════════
                    // 合计
                    // ══════════════════════════════════════
                    HStack {
                        Text("合计")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("¥∞")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 6)
                    
                    // ══════════════════════════════════════
                    // 条形码
                    // ══════════════════════════════════════
                    if showBarcode {
                        ThermalBarcodeV8()
                            .frame(height: 18)
                            .padding(.horizontal, 12)
                    }
                    
                    // ══════════════════════════════════════
                    // 底部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Text("★ 谢谢惠顾 ★")
                            .font(.system(size: 6, weight: .medium, design: .monospaced))
                        
                        Text(fullTimestamp)
                            .font(.system(size: 4, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.bottom, 5)
                }
                .padding(.horizontal, 6)
            }
            
            // 底部锯齿
            ThermalJaggedEdgeV8()
                .fill(Color.white)
                .frame(height: 8)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 170, height: dynamicHeight)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
    
    // 根据照片数量动态调整高度
    private var dynamicHeight: CGFloat {
        let baseHeight: CGFloat = 280
        let photoCount = validPhotos.count
        
        switch photoCount {
        case 0: return baseHeight
        case 1: return baseHeight + 100
        case 2: return baseHeight + 60
        case 3: return baseHeight + 45
        case 4: return baseHeight + 110
        case 5: return baseHeight + 95
        case 6: return baseHeight + 85
        default: return baseHeight + 85
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
    
    private func thermalItem(_ name: String, _ price: String) -> some View {
        HStack {
            Text(name).lineLimit(1)
            Spacer()
            Text(price)
        }
        .font(.system(size: 6, design: .monospaced))
    }
}

// MARK: - 🍽️ 收据 V8 (支持多照片)

struct ReceiptV8: View {
    let record: DayRecord
    
    // 随机元素
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    private let showBarcode: Bool
    private let showSignature: Bool
    
    init(record: DayRecord) {
        self.record = record
        
        let stores = [
            ("记忆小酒馆", "MEMORY BISTRO"),
            ("回忆咖啡屋", "NOSTALGIA CAFE"),
            ("时光茶室", "TIME TEA HOUSE"),
            ("往事餐厅", "PAST RESTAURANT"),
            ("岁月厨房", "YEARS KITCHEN")
        ]
        self.storeName = stores.randomElement()!
        
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        self.orderNo = prefix + String(format: "%06d", Int.random(in: 1...999999))
        
        self.cashier = ["TIME", "MEMO", "PAST", "LUNA", "NOVA"].randomElement()!
        self.showBarcode = Bool.random()
        self.showSignature = Double.random(in: 0...1) > 0.6
    }
    
    // 获取有效照片（最多6张）
    private var validPhotos: [UIImage] {
        record.photos.compactMap { UIImage(data: $0) }.prefix(6).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            ThermalJaggedEdgeV8()
                .fill(Color.white)
                .frame(height: 10)
            
            // 主体
            ZStack {
                Color.white
                ThermalNoiseV8()
                
                VStack(spacing: 6) {
                    // ══════════════════════════════════════
                    // 店铺头部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        Text(storeName.en)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        
                        Text(storeName.cn)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 6)
                    
                    // 分隔线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 订单信息
                    // ══════════════════════════════════════
                    HStack {
                        Text("ORDER #\(orderNo)")
                            .font(.system(size: 6, weight: .medium, design: .monospaced))
                        Spacer()
                        Text(dateTimeString)
                            .font(.system(size: 6, design: .monospaced))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    
                    // 分隔线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 🎨 照片区域 - 智能布局 1-6张
                    // ══════════════════════════════════════
                    if !validPhotos.isEmpty {
                        VStack(spacing: 4) {
                            Text("📸 TODAY'S SPECIAL (\(validPhotos.count))")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // 智能照片网格
                            ReceiptPhotoGridV8(photos: validPhotos, containerWidth: 170)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // 分隔线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 商品列表
                    // ══════════════════════════════════════
                    VStack(alignment: .leading, spacing: 3) {
                        receiptItem(validPhotos.count, "MOMENTS CAPTURED", "$0.00")
                        receiptItem(1, "EMOTION: \(record.mood.label.uppercased())", "PRICELESS")
                        if let w = record.weather {
                            receiptItem(1, "WEATHER: \(w.label.uppercased())", "$0.00")
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // ══════════════════════════════════════
                    // 内容（如有）
                    // ══════════════════════════════════════
                    if !record.content.isEmpty {
                        VStack(spacing: 1) {
                            Text("NOTES")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.gray)
                            Text(record.content)
                                .font(.system(size: 7, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 10)
                        }
                    }
                    
                    // 分隔线
                    ThermalDashedLineV8()
                    
                    // ══════════════════════════════════════
                    // 总计
                    // ══════════════════════════════════════
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
                    .padding(.horizontal, 8)
                    
                    // ══════════════════════════════════════
                    // 签名栏（随机）
                    // ══════════════════════════════════════
                    if showSignature {
                        VStack(spacing: 1) {
                            Text("X________________________")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // ══════════════════════════════════════
                    // 条形码
                    // ══════════════════════════════════════
                    if showBarcode {
                        ThermalBarcodeV8()
                            .frame(height: 20)
                            .padding(.horizontal, 15)
                    }
                    
                    // ══════════════════════════════════════
                    // 底部
                    // ══════════════════════════════════════
                    VStack(spacing: 1) {
                        Text("★ ★ ★ THANK YOU ★ ★ ★")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                        
                        Text("Your memories are priceless")
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 8)
            }
            
            // 底部锯齿
            ThermalJaggedEdgeV8()
                .fill(Color.white)
                .frame(height: 10)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 190, height: dynamicHeight)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
    
    // 根据照片数量动态调整高度
    private var dynamicHeight: CGFloat {
        let baseHeight: CGFloat = 300
        let photoCount = validPhotos.count
        
        switch photoCount {
        case 0: return baseHeight
        case 1: return baseHeight + 120
        case 2: return baseHeight + 70
        case 3: return baseHeight + 55
        case 4: return baseHeight + 130
        case 5: return baseHeight + 115
        case 6: return baseHeight + 105
        default: return baseHeight + 105
        }
    }
    
    private var dateTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy HH:mm"
        return f.string(from: record.date)
    }
    
    private func receiptItem(_ qty: Int, _ name: String, _ price: String) -> some View {
        HStack(alignment: .top) {
            Text("\(qty)x")
                .frame(width: 18, alignment: .leading)
            Text(name)
                .lineLimit(1)
            Spacer()
            Text(price)
        }
        .font(.system(size: 6, design: .monospaced))
    }
}

// MARK: - 📷 热敏小票照片网格 (150pt宽)

struct ThermalPhotoGridV8: View {
    let photos: [UIImage]
    let containerWidth: CGFloat
    
    var body: some View {
        Group {
            switch photos.count {
            case 1:
                // 1张：大图居中 (130×100pt)
                singlePhoto(photos[0], width: 130, height: 100)
                
            case 2:
                // 2张：左右并排 (各 70×55pt)
                HStack(spacing: 4) {
                    photoCell(photos[0], width: 70, height: 55)
                    photoCell(photos[1], width: 70, height: 55)
                }
                
            case 3:
                // 3张：一行三张 (各 46×36pt)
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        photoCell(photos[i], width: 46, height: 36)
                    }
                }
                
            case 4:
                // 4张：2×2网格 (各 70×52pt)
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        photoCell(photos[0], width: 70, height: 52)
                        photoCell(photos[1], width: 70, height: 52)
                    }
                    HStack(spacing: 4) {
                        photoCell(photos[2], width: 70, height: 52)
                        photoCell(photos[3], width: 70, height: 52)
                    }
                }
                
            case 5:
                // 5张：上2下3 (上 70×48pt, 下 46×34pt)
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        photoCell(photos[0], width: 70, height: 48)
                        photoCell(photos[1], width: 70, height: 48)
                    }
                    HStack(spacing: 3) {
                        ForEach(2..<5, id: \.self) { i in
                            photoCell(photos[i], width: 46, height: 34)
                        }
                    }
                }
                
            case 6:
                // 6张：2×3网格 (各 46×34pt) - 两行，每行3张
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            photoCell(photos[i], width: 46, height: 34)
                        }
                    }
                    HStack(spacing: 3) {
                        ForEach(3..<6, id: \.self) { i in
                            photoCell(photos[i], width: 46, height: 34)
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    private func singlePhoto(_ image: UIImage, width: CGFloat, height: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
    
    private func photoCell(_ image: UIImage, width: CGFloat, height: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 0.5)
            )
    }
}

// MARK: - 📷 收据照片网格 (170pt宽)

struct ReceiptPhotoGridV8: View {
    let photos: [UIImage]
    let containerWidth: CGFloat
    
    var body: some View {
        Group {
            switch photos.count {
            case 1:
                // 1张：大图居中 (150×110pt)
                singlePhoto(photos[0], width: 150, height: 110)
                
            case 2:
                // 2张：左右并排 (各 80×60pt)
                HStack(spacing: 5) {
                    photoCell(photos[0], width: 80, height: 60)
                    photoCell(photos[1], width: 80, height: 60)
                }
                
            case 3:
                // 3张：一行三张 (各 52×40pt)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        photoCell(photos[i], width: 52, height: 40)
                    }
                }
                
            case 4:
                // 4张：2×2网格 (各 80×58pt)
                VStack(spacing: 4) {
                    HStack(spacing: 5) {
                        photoCell(photos[0], width: 80, height: 58)
                        photoCell(photos[1], width: 80, height: 58)
                    }
                    HStack(spacing: 5) {
                        photoCell(photos[2], width: 80, height: 58)
                        photoCell(photos[3], width: 80, height: 58)
                    }
                }
                
            case 5:
                // 5张：上2下3 (上 80×55pt, 下 52×38pt)
                VStack(spacing: 4) {
                    HStack(spacing: 5) {
                        photoCell(photos[0], width: 80, height: 55)
                        photoCell(photos[1], width: 80, height: 55)
                    }
                    HStack(spacing: 4) {
                        ForEach(2..<5, id: \.self) { i in
                            photoCell(photos[i], width: 52, height: 38)
                        }
                    }
                }
                
            case 6:
                // 6张：2×3网格 (各 52×38pt) - 两行，每行3张
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            photoCell(photos[i], width: 52, height: 38)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(3..<6, id: \.self) { i in
                            photoCell(photos[i], width: 52, height: 38)
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    private func singlePhoto(_ image: UIImage, width: CGFloat, height: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
    
    private func photoCell(_ image: UIImage, width: CGFloat, height: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - 辅助组件

struct ThermalJaggedEdgeV8: Shape {
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

struct ThermalNoiseV8: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<100 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.gray.opacity(Double.random(in: 0.02...0.04))))
            }
        }
        .allowsHitTesting(false)
    }
}

struct ThermalDashedLineV8: View {
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
        .padding(.horizontal, 6)
    }
}

struct ThermalBarcodeV8: View {
    var body: some View {
        HStack(spacing: 0.8) {
            ForEach(0..<45, id: \.self) { _ in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat.random(in: 0.8...2.2))
            }
        }
    }
}


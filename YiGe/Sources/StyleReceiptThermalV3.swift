//
//  StyleReceiptThermalV3.swift
//  时光格 - Receipt 和 Thermal 信物修复版
//
//  修复内容：
//  1. 文字颜色改为深色（可见）
//  2. 增加时间戳、订单号、盖章
//  3. 支持1-6张彩色照片
//  4. 更丰富的排版细节
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🧾 收据信物 V3
// MARK: - ═══════════════════════════════════════════════════════════

struct StyleReceiptViewV3: View {
    let record: DayRecord
    
    // 随机生成的订单号
    private var orderNumber: String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        let numbers = String(format: "%06d", Int.random(in: 100000...999999))
        return "\(prefix)-\(numbers)"
    }
    
    // 随机店铺名
    private var shopName: String {
        let names = ["THE MEMORY BISTRO", "MOMENT CAFÉ", "TIME CAPSULE", "NOSTALGIA DINER"]
        return names.randomElement() ?? names[0]
    }
    
    // 时间格式化
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: record.date)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: record.date)
    }
    
    // 照片
    private var photos: [UIImage] {
        record.photos.prefix(6).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ═══ 顶部锯齿 ═══
            ReceiptJaggedEdgeV3()
                .fill(Color(hex: "FFFEF9"))
                .frame(height: 12)
            
            // ═══ 主体 ═══
            ZStack {
                // 纸张背景
                Color(hex: "FFFEF9")
                
                // 纸张纹理
                ReceiptPaperTexture()
                
                VStack(spacing: 0) {
                    // ═══ 店铺头部 ═══
                    VStack(spacing: 8) {
                        Text(shopName)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "1A1A1A"))  // ✅ 深色文字
                        
                        Text("━━━━━━━━━━━━━━━━━━")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "CCCCCC"))
                    }
                    .padding(.top, 20)
                    
                    // ═══ 订单信息 ═══
                    VStack(spacing: 4) {
                        HStack {
                            Text("订单号:")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                            Spacer()
                            Text(orderNumber)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "1A1A1A"))  // ✅ 深色文字
                        }
                        
                        HStack {
                            Text("日期:")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                            Spacer()
                            Text(formattedDate)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(hex: "1A1A1A"))  // ✅ 深色文字
                        }
                        
                        HStack {
                            Text("时间:")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                            Spacer()
                            Text(formattedTime)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color(hex: "1A1A1A"))  // ✅ 深色文字
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    // ═══ 分隔线 ═══
                    ReceiptDashedLineV3()
                        .padding(.vertical, 12)
                    
                    // ═══ 消费项目 ═══
                    VStack(spacing: 6) {
                        ReceiptItemRow(name: "1x MOMENT", price: "¥0.00")
                        ReceiptItemRow(name: "1x EMOTION: \(record.mood.label)", price: "无价")
                        if let weather = record.weather {
                            ReceiptItemRow(name: "1x WEATHER: \(weather.label)", price: "¥0.00")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // ═══ 分隔线 ═══
                    ReceiptDashedLineV3()
                        .padding(.vertical, 12)
                    
                    // ═══ 照片区域 ═══
                    if !photos.isEmpty {
                        ReceiptPhotoGridV3(photos: photos)
                            .padding(.horizontal, 15)
                        
                        ReceiptDashedLineV3()
                            .padding(.vertical, 12)
                    }
                    
                    // ═══ 内容区域 ═══
                    Text(record.content)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                    
                    // ═══ 心情表情 ═══
                    Text(record.mood.emoji)
                        .font(.system(size: 28))
                        .padding(.top, 15)
                    
                    // ═══ 盖章区域 ═══
                    ZStack {
                        // 主印章
                        Circle()
                            .stroke(Color(hex: "C41E3A").opacity(0.7), lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        VStack(spacing: 1) {
                            Text("已")
                                .font(.system(size: 10, weight: .bold))
                            Text("记录")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "C41E3A").opacity(0.7))
                    }
                    .rotationEffect(.degrees(-15))
                    .padding(.top, 15)
                    
                    // ═══ 底部信息 ═══
                    VStack(spacing: 6) {
                        Text("━━━━━━━━━━━━━━━━━━")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "CCCCCC"))
                        
                        Text("THANK YOU FOR YOUR MEMORY")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                        
                        Text("※ 本小票是您珍贵的回忆凭证 ※")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color(hex: "999999"))  // ✅ 深色文字
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    
                    // ═══ 条形码 ═══
                    ReceiptBarcodeV3()
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                }
            }
            
            // ═══ 底部锯齿 ═══
            ReceiptJaggedEdgeV3()
                .fill(Color(hex: "FFFEF9"))
                .frame(height: 12)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 220)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: - 收据项目行

struct ReceiptItemRow: View {
    let name: String
    let price: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
            Spacer()
            Text(price)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
        }
    }
}

// MARK: - 照片网格

struct ReceiptPhotoGridV3: View {
    let photos: [UIImage]
    
    var body: some View {
        switch photos.count {
        case 1:
            PhotoCellV3(image: photos[0], width: 170, height: 130)
        case 2:
            HStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { i in
                    PhotoCellV3(image: photos[i], width: 90, height: 72)
                }
            }
        case 3:
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    PhotoCellV3(image: photos[i], width: 58, height: 55)
                }
            }
        case 4:
            VStack(spacing: 5) {
                HStack(spacing: 6) {
                    ForEach(0..<2, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 90, height: 65)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(2..<4, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 90, height: 65)
                    }
                }
            }
        case 5:
            VStack(spacing: 5) {
                HStack(spacing: 6) {
                    ForEach(0..<2, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 90, height: 62)
                    }
                }
                HStack(spacing: 5) {
                    ForEach(2..<5, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 58, height: 48)
                    }
                }
            }
        case 6:
            VStack(spacing: 5) {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 58, height: 50)
                    }
                }
                HStack(spacing: 5) {
                    ForEach(3..<6, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 58, height: 50)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 照片单元格（彩色！）

struct PhotoCellV3: View {
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
                    .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
            )
        // ⚠️ 不使用 grayscale！保持照片彩色！
    }
}

// MARK: - 锯齿边缘

struct ReceiptJaggedEdgeV3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        let step: CGFloat = 8
        var x: CGFloat = 0
        
        while x < rect.width {
            path.addLine(to: CGPoint(x: x + step / 2, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: rect.height))
            x += step
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - 虚线分隔

struct ReceiptDashedLineV3: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 15, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width - 15, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .foregroundColor(Color(hex: "CCCCCC"))
        }
        .frame(height: 1)
    }
}

// MARK: - 纸张纹理

struct ReceiptPaperTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<400 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(ellipseIn: rect), with: .color(Color.black.opacity(0.02)))
            }
        }
    }
}

// MARK: - 条形码

struct ReceiptBarcodeV3: View {
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<30, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: "1A1A1A"))
                    .frame(width: CGFloat.random(in: 1...3), height: 30)
            }
        }
        .frame(width: 150)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🧾 热敏小票信物 V3
// MARK: - ═══════════════════════════════════════════════════════════

struct StyleThermalViewV3: View {
    let record: DayRecord
    
    private var shopName: String {
        let names = ["时光便利店", "记忆杂货铺", "回忆小站"]
        return names.randomElement() ?? names[0]
    }
    
    private var receiptNumber: String {
        String(format: "%04d", Int.random(in: 1000...9999))
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: record.date)
    }
    
    private var photos: [UIImage] {
        record.photos.prefix(6).compactMap { UIImage(data: $0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            ThermalJaggedEdgeV3()
                .fill(Color(hex: "F8F6F0"))
                .frame(height: 10)
            
            // 主体
            ZStack {
                Color(hex: "F8F6F0")
                ThermalPaperTextureV3()
                
                VStack(spacing: 0) {
                    // 店名
                    VStack(spacing: 4) {
                        Text(shopName)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "2A2A2A"))  // ✅ 深色文字
                        
                        Text("══════════════════")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color(hex: "AAAAAA"))
                    }
                    .padding(.top, 18)
                    
                    // 小票信息
                    HStack {
                        Text("NO.\(receiptNumber)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                        Spacer()
                        Text(formattedDateTime)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    
                    // 分隔
                    ThermalDashedLineV3()
                        .padding(.vertical, 10)
                    
                    // 项目
                    VStack(spacing: 4) {
                        ThermalItemRow(name: "时光片段", qty: "x1", price: "0.00")
                        ThermalItemRow(name: "心情·\(record.mood.label)", qty: "x1", price: "珍贵")
                    }
                    .padding(.horizontal, 15)
                    
                    // 分隔
                    ThermalDashedLineV3()
                        .padding(.vertical, 10)
                    
                    // 照片
                    if !photos.isEmpty {
                        ThermalPhotoGridV3(photos: photos)
                            .padding(.horizontal, 12)
                        
                        ThermalDashedLineV3()
                            .padding(.vertical, 10)
                    }
                    
                    // 内容
                    Text(record.content)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 15)
                    
                    // 表情
                    Text(record.mood.emoji)
                        .font(.system(size: 26))
                        .padding(.top, 12)
                    
                    // 印章
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: "1E90FF").opacity(0.6), lineWidth: 2)
                            .frame(width: 55, height: 25)
                        
                        Text("已存档")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "1E90FF").opacity(0.6))
                    }
                    .rotationEffect(.degrees(-10))
                    .padding(.top, 12)
                    
                    // 底部
                    VStack(spacing: 4) {
                        Text("══════════════════")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color(hex: "AAAAAA"))
                        
                        Text("谢谢惠顾")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
                    }
                    .padding(.top, 12)
                    
                    // 条形码
                    ThermalBarcodeV3()
                        .padding(.top, 8)
                        .padding(.bottom, 18)
                }
            }
            
            // 底部锯齿
            ThermalJaggedEdgeV3()
                .fill(Color(hex: "F8F6F0"))
                .frame(height: 10)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 200)
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

// MARK: - 热敏项目行

struct ThermalItemRow: View {
    let name: String
    let qty: String
    let price: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
            
            Text(qty)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(hex: "666666"))  // ✅ 深色文字
            
            Spacer()
            
            Text(price)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(hex: "333333"))  // ✅ 深色文字
        }
    }
}

// MARK: - 热敏照片网格

struct ThermalPhotoGridV3: View {
    let photos: [UIImage]
    
    var body: some View {
        switch photos.count {
        case 1:
            PhotoCellV3(image: photos[0], width: 150, height: 110)
        case 2:
            HStack(spacing: 5) {
                ForEach(0..<2, id: \.self) { i in
                    PhotoCellV3(image: photos[i], width: 78, height: 62)
                }
            }
        case 3:
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    PhotoCellV3(image: photos[i], width: 52, height: 48)
                }
            }
        case 4:
            VStack(spacing: 4) {
                HStack(spacing: 5) {
                    ForEach(0..<2, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 78, height: 56)
                    }
                }
                HStack(spacing: 5) {
                    ForEach(2..<4, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 78, height: 56)
                    }
                }
            }
        case 5:
            VStack(spacing: 4) {
                HStack(spacing: 5) {
                    ForEach(0..<2, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 78, height: 54)
                    }
                }
                HStack(spacing: 4) {
                    ForEach(2..<5, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 52, height: 42)
                    }
                }
            }
        case 6:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 52, height: 45)
                    }
                }
                HStack(spacing: 4) {
                    ForEach(3..<6, id: \.self) { i in
                        PhotoCellV3(image: photos[i], width: 52, height: 45)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 热敏组件

struct ThermalJaggedEdgeV3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        let step: CGFloat = 6
        var x: CGFloat = 0
        
        while x < rect.width {
            path.addLine(to: CGPoint(x: x + step / 2, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: rect.height))
            x += step
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct ThermalPaperTextureV3: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<300 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(ellipseIn: rect), with: .color(Color.black.opacity(0.015)))
            }
        }
    }
}

struct ThermalDashedLineV3: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 12, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width - 12, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
            .foregroundColor(Color(hex: "BBBBBB"))
        }
        .frame(height: 1)
    }
}

struct ThermalBarcodeV3: View {
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<25, id: \.self) { _ in
                Rectangle()
                    .fill(Color(hex: "2A2A2A"))
                    .frame(width: CGFloat.random(in: 1...2.5), height: 25)
            }
        }
        .frame(width: 130)
    }
}


//
//  ThermalReceiptV7.swift
//  时光格 - 热敏小票和收据 V7.0 完美修复版
//
//  ⚠️ 核心承诺：照片永远保持彩色，绝不变黑白！
//  ✅ 照片超大尺寸 - 确保清晰可见
//

import SwiftUI

// MARK: - 🏪 热敏小票 V7 (便利店风格 - 彩色照片)

struct ThermalReceiptV7: View {
    let record: DayRecord
    
    // 随机元素
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    private let terminal: String
    private let showBarcode: Bool
    private let showQR: Bool
    private let showPoints: Bool
    
    init(record: DayRecord) {
        self.record = record
        
        // 初始化随机元素
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
        self.showBarcode = Double.random(in: 0...1) > 0.3
        self.showQR = Bool.random()
        self.showPoints = Bool.random()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            ThermalJaggedEdgeV7()
                .fill(Color.white)
                .frame(height: 8)
            
            // 主体
            ZStack {
                Color.white
                
                // 纸张纹理
                ThermalNoiseV7()
                
                VStack(spacing: 6) {
                    // ══════════════════════════════════════
                    // 店铺头部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Text("🏪")
                            .font(.system(size: 22))
                        
                        Text(storeName.cn)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        
                        Text(storeName.en)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("营业时间: 永不打烊")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 6)
                    
                    // 分隔符
                    Text(String(repeating: "·", count: 28))
                        .font(.system(size: 6, design: .monospaced))
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
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    
                    // 虚线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 🎨 照片区域 - 超大！彩色！
                    // ══════════════════════════════════════
                    if let photoData = record.photos.first,
                       let uiImage = UIImage(data: photoData) {
                        
                        VStack(spacing: 4) {
                            Text("📷 今日快照")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // ⚠️ 照片 - 100% 彩色，绝不变黑白！
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 110) // 超大尺寸！
                                .clipped()
                                .cornerRadius(4)
                                // ✅ 只加一点点暖调，保持彩色
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 虚线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 商品列表
                    // ══════════════════════════════════════
                    VStack(alignment: .leading, spacing: 3) {
                        thermalItem("回忆存储 x1", "¥0.00")
                        thermalItem("心情: \(record.mood.label)", "∞")
                        if let w = record.weather {
                            thermalItem("天气: \(w.label)", "¥0.00")
                        }
                        thermalItem("时光封存", "FREE")
                    }
                    .padding(.horizontal, 6)
                    
                    // ══════════════════════════════════════
                    // 内容（如有）
                    // ══════════════════════════════════════
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 7, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                    }
                    
                    // 分隔
                    Text(String(repeating: "═", count: 22))
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    // ══════════════════════════════════════
                    // 合计
                    // ══════════════════════════════════════
                    HStack {
                        Text("合计")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("¥∞")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 6)
                    
                    // ══════════════════════════════════════
                    // 积分（随机）
                    // ══════════════════════════════════════
                    if showPoints {
                        Text("本次积分: +\(Int.random(in: 10...99))  累计: ∞")
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    // ══════════════════════════════════════
                    // 条形码（随机）
                    // ══════════════════════════════════════
                    if showBarcode {
                        ThermalBarcodeV7()
                            .frame(height: 22)
                            .padding(.horizontal, 10)
                    }
                    
                    // ══════════════════════════════════════
                    // 二维码（随机）
                    // ══════════════════════════════════════
                    if showQR {
                        HStack(spacing: 8) {
                            ThermalQRCodeV7()
                                .frame(width: 35, height: 35)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("扫码关注")
                                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                                Text("领专属优惠")
                                    .font(.system(size: 5, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // ══════════════════════════════════════
                    // 底部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Text("★ 谢谢惠顾 欢迎再来 ★")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                        
                        Text(fullTimestamp)
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 8)
            }
            
            // 底部锯齿
            ThermalJaggedEdgeV7()
                .fill(Color.white)
                .frame(height: 8)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 170, height: 400) // 固定尺寸
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
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
        .font(.system(size: 7, design: .monospaced))
    }
}

// MARK: - 🍽️ 收据 V7 (餐厅/咖啡馆风格 - 彩色照片)

struct ReceiptV7: View {
    let record: DayRecord
    
    // 随机元素
    private let storeName: (cn: String, en: String)
    private let orderNo: String
    private let cashier: String
    private let terminal: String
    private let showBarcode: Bool
    private let showQR: Bool
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
        self.terminal = String(format: "%02d", Int.random(in: 1...12))
        self.showBarcode = Bool.random()
        self.showQR = Bool.random()
        self.showSignature = Double.random(in: 0...1) > 0.5
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿
            ThermalJaggedEdgeV7()
                .fill(Color.white)
                .frame(height: 10)
            
            // 主体
            ZStack {
                Color.white
                ThermalNoiseV7()
                
                VStack(spacing: 8) {
                    // ══════════════════════════════════════
                    // 店铺头部
                    // ══════════════════════════════════════
                    VStack(spacing: 3) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.black)
                        
                        Text(storeName.en)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                        
                        Text(storeName.cn)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("123 Memory Lane · Tel: 400-TIME-001")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                    
                    // 分隔线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 订单信息
                    // ══════════════════════════════════════
                    HStack {
                        Text("ORDER #\(orderNo)")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                        Spacer()
                        Text(dateTimeString)
                            .font(.system(size: 7, design: .monospaced))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    
                    // 分隔线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 🎨 照片区域 - 超大！彩色！
                    // ══════════════════════════════════════
                    if let photoData = record.photos.first,
                       let uiImage = UIImage(data: photoData) {
                        
                        VStack(spacing: 4) {
                            Text("📸 TODAY'S SPECIAL")
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // ⚠️ 照片 - 100% 彩色，绝不变黑白！
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 120) // 超大尺寸！
                                .clipped()
                                .cornerRadius(6)
                                // ✅ 保持彩色，只加细边框
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                        }
                        .padding(.vertical, 6)
                    }
                    
                    // 分隔线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 商品列表
                    // ══════════════════════════════════════
                    VStack(alignment: .leading, spacing: 4) {
                        receiptItem(1, "MOMENT CAPTURED", "$0.00")
                        receiptItem(1, "EMOTION: \(record.mood.label.uppercased())", "PRICELESS")
                        if let w = record.weather {
                            receiptItem(1, "WEATHER: \(w.label.uppercased())", "$0.00")
                        }
                        receiptItem(1, "MEMORY STORAGE", "FREE")
                    }
                    .padding(.horizontal, 8)
                    
                    // ══════════════════════════════════════
                    // 内容（如有）
                    // ══════════════════════════════════════
                    if !record.content.isEmpty {
                        VStack(spacing: 2) {
                            Text("NOTES")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.gray)
                            Text(record.content)
                                .font(.system(size: 8, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 10)
                        }
                    }
                    
                    // 分隔线
                    ThermalDashedLineV7()
                    
                    // ══════════════════════════════════════
                    // 总计
                    // ══════════════════════════════════════
                    VStack(spacing: 3) {
                        HStack {
                            Text("SUBTOTAL")
                            Spacer()
                            Text("PRICELESS")
                        }
                        .font(.system(size: 8, design: .monospaced))
                        
                        HStack {
                            Text("TAX")
                            Spacer()
                            Text("$0.00")
                        }
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                        HStack {
                            Text("TOTAL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("∞")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // ══════════════════════════════════════
                    // 签名栏（随机）
                    // ══════════════════════════════════════
                    if showSignature {
                        VStack(spacing: 2) {
                            Text("SIGNATURE")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.gray)
                            Text("X________________________")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // ══════════════════════════════════════
                    // 条形码（随机）
                    // ══════════════════════════════════════
                    if showBarcode {
                        ThermalBarcodeV7()
                            .frame(height: 25)
                            .padding(.horizontal, 12)
                    }
                    
                    // ══════════════════════════════════════
                    // 二维码（随机）
                    // ══════════════════════════════════════
                    if showQR {
                        VStack(spacing: 3) {
                            ThermalQRCodeV7()
                                .frame(width: 40, height: 40)
                            Text("SCAN FOR REWARDS")
                                .font(.system(size: 5, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // ══════════════════════════════════════
                    // 底部
                    // ══════════════════════════════════════
                    VStack(spacing: 2) {
                        Text("★ ★ ★ THANK YOU ★ ★ ★")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                        
                        Text("Your memories are priceless")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                        
                        HStack {
                            Text("CASHIER: \(cashier)")
                            Spacer()
                            Text("TERMINAL: \(terminal)")
                        }
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 8)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 10)
            }
            
            // 底部锯齿
            ThermalJaggedEdgeV7()
                .fill(Color.white)
                .frame(height: 10)
                .rotationEffect(.degrees(180))
        }
        .frame(width: 190, height: 450) // 固定尺寸
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
    
    private var dateTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy HH:mm"
        return f.string(from: record.date)
    }
    
    private func receiptItem(_ qty: Int, _ name: String, _ price: String) -> some View {
        HStack(alignment: .top) {
            Text("\(qty)x")
                .frame(width: 20, alignment: .leading)
            Text(name)
                .lineLimit(1)
            Spacer()
            Text(price)
        }
        .font(.system(size: 7, design: .monospaced))
    }
}

// MARK: - 辅助组件

// 锯齿边
struct ThermalJaggedEdgeV7: Shape {
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

// 纸张噪点
struct ThermalNoiseV7: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<120 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.gray.opacity(Double.random(in: 0.02...0.05))))
            }
        }
        .allowsHitTesting(false)
    }
}

// 虚线
struct ThermalDashedLineV7: View {
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

// 条形码
struct ThermalBarcodeV7: View {
    var body: some View {
        HStack(spacing: 0.8) {
            ForEach(0..<50, id: \.self) { _ in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat.random(in: 0.8...2.5))
            }
        }
    }
}

// 二维码
struct ThermalQRCodeV7: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            
            VStack(spacing: 1) {
                ForEach(0..<8, id: \.self) { _ in
                    HStack(spacing: 1) {
                        ForEach(0..<8, id: \.self) { _ in
                            Rectangle()
                                .fill(Bool.random() ? Color.black : Color.white)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
    }
}


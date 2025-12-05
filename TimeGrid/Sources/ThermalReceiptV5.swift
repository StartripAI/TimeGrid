//
//  ThermalReceiptV5.swift
//  热敏小票和收据 V5.0 完全重设计
//
//  核心原则：
//  1. 固定高度，绝不超出
//  2. 高分辨率渲染
//  3. 丰富的随机元素
//  4. 真实的小票质感
//

import SwiftUI

// MARK: - 随机元素生成器
struct ReceiptRandomizer {
    
    // 随机店铺名（中英双语）
    static var randomStoreName: (chinese: String, english: String) {
        let stores = [
            ("时光便利店", "TIME MART 24H"),
            ("记忆小酒馆", "MEMORY BISTRO"),
            ("回忆咖啡屋", "NOSTALGIA CAFE"),
            ("光阴杂货铺", "MOMENT GROCERY"),
            ("岁月面包房", "YEARS BAKERY"),
            ("往事书店", "PAST BOOKSTORE"),
            ("流年茶室", "FLEETING TEA"),
            ("旧时光超市", "OLD TIMES MART")
        ]
        return stores.randomElement()!
    }
    
    // 随机地址
    static var randomAddress: String {
        let streets = ["记忆大道", "时光路", "回忆街", "岁月巷", "往事胡同"]
        let numbers = [1, 7, 12, 24, 88, 101, 168, 520]
        let districts = ["怀旧区", "光阴区", "流年区", "往昔区"]
        return "\(districts.randomElement()!) \(streets.randomElement()!) \(numbers.randomElement()!)号"
    }
    
    // 随机电话
    static var randomPhone: String {
        let prefixes = ["400-TIME-", "400-MEMO-", "010-8888-", "021-6666-"]
        let suffixes = ["0001", "1234", "5678", "8888", "9999"]
        return prefixes.randomElement()! + suffixes.randomElement()!
    }
    
    // 随机订单号
    static var randomOrderNumber: String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let prefix = String((0..<2).map { _ in letters.randomElement()! })
        let number = String(format: "%06d", Int.random(in: 1...999999))
        return prefix + number
    }
    
    // 随机收银员
    static var randomCashier: String {
        let names = ["TIME", "MEMO", "PAST", "YEAR", "DAYS", "WISH", "HOPE", "STAR"]
        return names.randomElement()!
    }
    
    // 随机终端号
    static var randomTerminal: String {
        return String(format: "%02d", Int.random(in: 1...12))
    }
    
    // 随机会员积分
    static var randomPoints: Int {
        return Int.random(in: 10...999)
    }
    
    // 随机感谢语
    static var randomThankYou: String {
        let messages = [
            "谢谢惠顾 欢迎再来",
            "感谢光临 下次再见",
            "珍藏每一刻美好",
            "愿时光温柔以待",
            "每一天都值得记录",
            "保存这份小确幸"
        ]
        return messages.randomElement()!
    }
    
    // 随机小贴士
    static var randomTip: String {
        let tips = [
            "小贴士: 每日签到可获双倍积分",
            "温馨提示: 会员日全场9折",
            "提示: 扫码关注获10元优惠券",
            "通知: 集满10个章换礼品",
            "活动: 分享朋友圈返现5元"
        ]
        return tips.randomElement()!
    }
}

// MARK: - 🏪 热敏小票 V5 (便利店风格)
struct ThermalReceiptV5: View {
    let record: DayRecord
    
    // 随机生成的元素（创建时固定）
    private let storeName = ReceiptRandomizer.randomStoreName
    private let address = ReceiptRandomizer.randomAddress
    private let phone = ReceiptRandomizer.randomPhone
    private let orderNumber = ReceiptRandomizer.randomOrderNumber
    private let cashier = ReceiptRandomizer.randomCashier
    private let terminal = ReceiptRandomizer.randomTerminal
    private let points = ReceiptRandomizer.randomPoints
    private let thankYou = ReceiptRandomizer.randomThankYou
    
    // 是否显示各种随机元素
    private let showQRCode = Bool.random()
    private let showBarcode = Bool.random()
    private let showTip = Bool.random()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿边
            ThermalJaggedEdge()
                .fill(Color.white)
                .frame(height: 6)
            
            // 主体内容
            ZStack {
                // 热敏纸背景 + 轻微噪点
                Color.white
                ThermalPaperTexture()
                
                VStack(spacing: 6) {
                    // ═══════════ 店铺头部 ═══════════
                    VStack(spacing: 2) {
                        // Logo图标
                        Text("🏪")
                            .font(.system(size: 18))
                        
                        Text(storeName.chinese)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                        
                        Text(storeName.english)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text(address)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("TEL: \(phone)")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                    
                    // 星号分隔
                    Text(String(repeating: "*", count: 24))
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    // ═══════════ 小票信息 ═══════════
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("单号: \(orderNumber)")
                            Text("日期: \(formattedDate)")
                            Text("时间: \(formattedTime)")
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("收银: \(cashier)")
                            Text("机号: \(terminal)")
                        }
                    }
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.gray)
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 商品列表 ═══════════
                    VStack(alignment: .leading, spacing: 3) {
                        thermalItemRow(name: "回忆存储 x1", price: "0.00")
                        thermalItemRow(name: "心情记录(\(record.mood.label))", price: "∞")
                        if let weather = record.weather {
                            thermalItemRow(name: "天气: \(weather.label)", price: "0.00")
                        }
                        thermalItemRow(name: "时光封存服务", price: "FREE")
                    }
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 照片区域 (如果有) - V7修复：彩色照片，超大尺寸 ═══════════
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        VStack(spacing: 4) {
                            Text("📷 今日快照")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // ⚠️ 照片 - 100% 彩色，绝不变黑白！超大尺寸确保清晰可见！
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 110) // 超大尺寸！占信物宽度的82%
                                .clipped()
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // ═══════════ 内容 (限制行数) ═══════════
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 7, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 4)
                    }
                    
                    // 分隔线
                    Text(String(repeating: "=", count: 26))
                        .font(.system(size: 6, design: .monospaced))
                    
                    // ═══════════ 合计 ═══════════
                    HStack {
                        Text("合计")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("¥∞")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    
                    // ═══════════ 积分信息 ═══════════
                    Text("本次获得积分: +\(points)  累计: ∞")
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    // ═══════════ 条形码 (随机显示) ═══════════
                    if showBarcode {
                        ReceiptBarcodeView()
                            .frame(height: 20)
                    }
                    
                    // ═══════════ 二维码 (随机显示) ═══════════
                    if showQRCode {
                        HStack(spacing: 8) {
                            ReceiptQRCodePlaceholder()
                                .frame(width: 35, height: 35)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("扫码关注")
                                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                                Text("领取专属优惠")
                                    .font(.system(size: 5, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // ═══════════ 小贴士 (随机显示) ═══════════
                    if showTip {
                        Text(ReceiptRandomizer.randomTip)
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                    
                    // ═══════════ 感谢语 ═══════════
                    Text(thankYou)
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                    
                    // 时间戳
                    Text(fullTimestamp)
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            
            // 底部锯齿边
            ThermalJaggedEdge()
                .fill(Color.white)
                .frame(height: 6)
                .rotationEffect(.degrees(180))
        }
        // ⚠️ 关键：固定尺寸，不允许内容撑开 - V7: 增大高度以容纳大照片
        .frame(width: 170, height: 400)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }
    
    // 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: record.date)
    }
    
    // 格式化时间
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: record.date)
    }
    
    // 完整时间戳
    private var fullTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: record.date)
    }
    
    // 商品行
    private func thermalItemRow(name: String, price: String) -> some View {
        HStack {
            Text(name)
                .lineLimit(1)
            Spacer()
            Text(price)
        }
        .font(.system(size: 7, design: .monospaced))
    }
}

// MARK: - 🍽️ 收据 V5 (餐厅/咖啡馆风格)
struct ReceiptV5: View {
    let record: DayRecord
    
    // 随机生成的元素
    private let storeName = ReceiptRandomizer.randomStoreName
    private let address = ReceiptRandomizer.randomAddress
    private let phone = ReceiptRandomizer.randomPhone
    private let orderNumber = ReceiptRandomizer.randomOrderNumber
    private let cashier = ReceiptRandomizer.randomCashier
    private let terminal = ReceiptRandomizer.randomTerminal
    private let thankYou = ReceiptRandomizer.randomThankYou
    
    private let showQRCode = Bool.random()
    private let showSignatureLine = Bool.random()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部锯齿边
            ThermalJaggedEdge()
                .fill(Color.white)
                .frame(height: 8)
            
            // 主体内容
            ZStack {
                Color.white
                ThermalPaperTexture()
                
                VStack(spacing: 8) {
                    // ═══════════ 店铺头部 ═══════════
                    VStack(spacing: 3) {
                        // Logo
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        Text(storeName.english)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        
                        Text(storeName.chinese)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text(address)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text(phone)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 6)
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 订单信息 ═══════════
                    HStack {
                        Text("ORDER #\(orderNumber)")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                        Spacer()
                        Text(formattedDateTime)
                            .font(.system(size: 7, design: .monospaced))
                    }
                    .foregroundColor(.gray)
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 商品列表 ═══════════
                    VStack(alignment: .leading, spacing: 4) {
                        receiptItemRow(qty: 1, name: "MOMENT CAPTURED", price: "$0.00")
                        receiptItemRow(qty: 1, name: "EMOTION: \(record.mood.label.uppercased())", price: "PRICELESS")
                        if let weather = record.weather {
                            receiptItemRow(qty: 1, name: "WEATHER: \(weather.label.uppercased())", price: "$0.00")
                        }
                        receiptItemRow(qty: 1, name: "MEMORY PRESERVATION", price: "FREE")
                    }
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 照片 - V7修复：彩色照片，超大尺寸 ═══════════
                    if let data = record.photos.first, let uiImage = UIImage(data: data) {
                        VStack(spacing: 4) {
                            Text("📸 TODAY'S SPECIAL")
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            // ⚠️ 照片 - 100% 彩色，绝不变黑白！超大尺寸确保清晰可见！
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 120) // 超大尺寸！占信物宽度的84%
                                .clipped()
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                        }
                        .padding(.vertical, 6)
                    }
                    
                    // ═══════════ 内容 ═══════════
                    if !record.content.isEmpty {
                        Text(record.content)
                            .font(.system(size: 8, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 6)
                    }
                    
                    // 分隔线
                    ReceiptDashedDivider()
                    
                    // ═══════════ 总计 ═══════════
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
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("∞")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                    }
                    
                    // ═══════════ 签名栏 (随机显示) ═══════════
                    if showSignatureLine {
                        VStack(spacing: 2) {
                            Text("SIGNATURE")
                                .font(.system(size: 6, design: .monospaced))
                                .foregroundColor(.gray)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                            Text("X_____________________")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // ═══════════ 二维码 (随机显示) ═══════════
                    if showQRCode {
                        ReceiptQRCodePlaceholder()
                            .frame(width: 40, height: 40)
                        Text("SCAN FOR MEMBER REWARDS")
                            .font(.system(size: 5, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    // ═══════════ 底部信息 ═══════════
                    VStack(spacing: 2) {
                        Text("* * * \(thankYou.uppercased()) * * *")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                        
                        Text("Your memories are our treasure")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                        
                        HStack {
                            Text("CASHIER: \(cashier)")
                            Spacer()
                            Text("TERMINAL: \(terminal)")
                        }
                        .font(.system(size: 5, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.6))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            // 底部锯齿边
            ThermalJaggedEdge()
                .fill(Color.white)
                .frame(height: 8)
                .rotationEffect(.degrees(180))
        }
        // ⚠️ 关键：固定尺寸 - V7: 增大高度以容纳大照片
        .frame(width: 190, height: 450)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        return formatter.string(from: record.date)
    }
    
    private func receiptItemRow(qty: Int, name: String, price: String) -> some View {
        HStack(alignment: .top) {
            Text("\(qty)x")
                .frame(width: 18, alignment: .leading)
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
struct ThermalJaggedEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        let step: CGFloat = 5.0
        for x in stride(from: CGFloat(0), to: rect.width, by: step) {
            path.addLine(to: CGPoint(x: x + step/2, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: rect.height))
        }
        path.closeSubpath()
        return path
    }
}

// 热敏纸纹理
struct ThermalPaperTexture: View {
    var body: some View {
        Canvas { context, size in
            // 轻微的纸张纹理
            for _ in 0..<100 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.gray.opacity(Double.random(in: 0.02...0.05))))
            }
        }
        .allowsHitTesting(false)
    }
}

// 热敏打印点阵效果
struct ThermalPrintDots: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<150 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(Double.random(in: 0.03...0.08))))
            }
        }
        .blendMode(.multiply)
        .allowsHitTesting(false)
    }
}

// 虚线分隔（V5版本）
struct ReceiptDashedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [2, 1]))
            .foregroundColor(.gray.opacity(0.5))
        }
        .frame(height: 1)
    }
}

// 条形码（V5版本，避免与现有组件冲突）
struct ReceiptBarcodeView: View {
    var body: some View {
        HStack(spacing: 0.5) {
            ForEach(0..<40, id: \.self) { _ in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat.random(in: 1...2.5))
            }
        }
        .padding(.horizontal, 10)
    }
}

// 二维码占位（V5版本）
struct ReceiptQRCodePlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.gray, lineWidth: 0.5)
            
            // 简化的二维码图案
            VStack(spacing: 1) {
                ForEach(0..<7, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { col in
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


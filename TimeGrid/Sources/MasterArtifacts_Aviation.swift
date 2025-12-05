//
//  MasterArtifacts_Aviation.swift
//  时光格 - 世界级信物模板：航空系列 ✈️
//
//  全新设计系列，包含：
//  1. 登机牌 (BoardingPass) - 复古航空黄金年代风格
//  2. 飞机机型证 (AircraftTypeRating) - 飞行员机型签注
//  3. 航空日志 (FlightLog) - 飞行员日志本
//  4. 行李牌 (LuggageTag) - 复古航空行李标签
//
//  设计参考：
//  - Pan Am 泛美航空黄金年代
//  - 波音/空客官方文档风格
//  - 民航飞行员执照
//  - 复古航空旅行美学
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎫 登机牌 (BoardingPass)
// MARK: - 参考：Pan Am黄金年代、复古航空美学
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterBoardingPassView: View {
    let record: DayRecord
    
    @State private var shimmerOffset: CGFloat = -150
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机航班信息
    private var flightInfo: FlightData {
        FlightData.random(from: record.date)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // ═══ 主票区 ═══
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1E3A5F"),
                                Color(hex: "0F2540"),
                                Color(hex: "081828")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 流光效果
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.08), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60)
                    .offset(x: shimmerOffset)
                    .mask(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 0) {
                    // ═══ 头部：航空公司 ═══
                    HStack {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(Color(hex: "D4AF37"))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "airplane")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "1E3A5F"))
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("MEMORY AIRLINES")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(Color(hex: "D4AF37"))
                                .tracking(2)
                            
                            Text("时光航空")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // 舱位等级
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("FIRST CLASS")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(hex: "D4AF37"))
                            
                            Text("头等舱")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 12)
                    
                    // ═══ 航线信息 ═══
                    HStack(spacing: 8) {
                        // 出发
                        VStack(spacing: 2) {
                            Text(flightInfo.departure)
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text(flightInfo.departureCity)
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // 飞机图标和航线
                        VStack(spacing: 4) {
                            Image(systemName: "airplane")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "D4AF37"))
                            
                            // 航线虚线
                            HStack(spacing: 2) {
                                ForEach(0..<8, id: \.self) { _ in
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 2, height: 2)
                                }
                            }
                            
                            Text(flightInfo.duration)
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // 到达
                        VStack(spacing: 2) {
                            Text(flightInfo.arrival)
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text(flightInfo.arrivalCity)
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.top, 15)
                    
                    // ═══ 照片区域（如有）═══
                    if let photo = photos.first {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "D4AF37").opacity(0.5), lineWidth: 1)
                            )
                            .padding(.top, 12)
                    }
                    
                    // ═══ 详细信息 ═══
                    HStack(spacing: 0) {
                        BoardingInfoCell(title: "FLIGHT", value: flightInfo.flightNumber)
                        BoardingInfoCell(title: "DATE", value: flightInfo.date)
                        BoardingInfoCell(title: "TIME", value: flightInfo.time)
                        BoardingInfoCell(title: "GATE", value: flightInfo.gate)
                    }
                    .padding(.top, 12)
                    
                    // ═══ 旅客信息 ═══
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PASSENGER")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("TIME TRAVELER")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("SEAT")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(flightInfo.seat)
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "D4AF37"))
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // ═══ 条形码 ═══
                    BarcodeView(width: 170, height: 35)
                        .padding(.bottom, 12)
                }
            }
            .frame(width: 200, height: 340)
            
            // ═══ 撕裂线 ═══
            PerforationLine()
                .frame(width: 2, height: 340)
            
            // ═══ 存根区 ═══
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1E3A5F"))
                
                VStack(spacing: 8) {
                    // 航班号
                    Text(flightInfo.flightNumber)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    // 座位
                    Text(flightInfo.seat)
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    // 登机口
                    VStack(spacing: 2) {
                        Text("GATE")
                            .font(.system(size: 7))
                            .foregroundColor(.white.opacity(0.5))
                        Text(flightInfo.gate)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // 心情
                    Text(record.mood.emoji)
                        .font(.system(size: 28))
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // 小条形码
                    BarcodeView(width: 50, height: 25)
                        .padding(.bottom, 15)
                }
                .padding(.top, 20)
            }
            .frame(width: 70, height: 340)
        }
        .clipShape(BoardingPassShape())
        .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - 登机牌形状（带撕裂口）
struct BoardingPassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 10
        let notchX: CGFloat = 200 // 撕裂线位置
        
        path.move(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: rect.width - 8, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 8), control: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 8))
        path.addQuadCurve(to: CGPoint(x: rect.width - 8, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: notchX + notchRadius, y: rect.height))
        
        // 底部撕裂口
        path.addArc(center: CGPoint(x: notchX, y: rect.height),
                   radius: notchRadius,
                   startAngle: .degrees(0),
                   endAngle: .degrees(180),
                   clockwise: true)
        
        path.addLine(to: CGPoint(x: 8, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - 8), control: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 0, y: 0))
        
        // 顶部撕裂口
        path.move(to: CGPoint(x: notchX - notchRadius, y: 0))
        path.addArc(center: CGPoint(x: notchX, y: 0),
                   radius: notchRadius,
                   startAngle: .degrees(180),
                   endAngle: .degrees(0),
                   clockwise: true)
        
        return path
    }
}

// MARK: - 撕裂线
struct PerforationLine: View {
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<40, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 2, height: 2)
            }
        }
    }
}

// MARK: - 登机信息单元格
struct BoardingInfoCell: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 6))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 条形码
struct BarcodeView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Canvas { context, size in
            var x: CGFloat = 0
            while x < size.width {
                let barWidth = CGFloat.random(in: 1...3)
                let rect = CGRect(x: x, y: 0, width: barWidth, height: size.height)
                context.fill(Path(rect), with: .color(.white.opacity(Bool.random() ? 0.9 : 0.3)))
                x += barWidth + CGFloat.random(in: 0.5...2)
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - 航班数据模型
struct FlightData {
    let departure: String
    let departureCity: String
    let arrival: String
    let arrivalCity: String
    let flightNumber: String
    let date: String
    let time: String
    let gate: String
    let seat: String
    let duration: String
    
    static func random(from date: Date) -> FlightData {
        let airports = [
            ("PEK", "北京"), ("SHA", "上海"), ("CAN", "广州"), ("SZX", "深圳"),
            ("HKG", "香港"), ("NRT", "东京"), ("ICN", "首尔"), ("SIN", "新加坡"),
            ("LAX", "洛杉矶"), ("JFK", "纽约"), ("LHR", "伦敦"), ("CDG", "巴黎")
        ]
        
        let dep = airports.randomElement()!
        var arr = airports.randomElement()!
        while arr.0 == dep.0 { arr = airports.randomElement()! }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMM"
        let dateStr = formatter.string(from: date).uppercased()
        
        let hour = Int.random(in: 6...22)
        let minute = [0, 15, 30, 45].randomElement()!
        let timeStr = String(format: "%02d:%02d", hour, minute)
        
        let flightNum = "MA\(Int.random(in: 100...999))"
        let gate = "\(["A", "B", "C", "D"].randomElement()!)\(Int.random(in: 1...30))"
        let seat = "\(Int.random(in: 1...12))\(["A", "B", "C", "D", "E", "F"].randomElement()!)"
        let duration = "\(Int.random(in: 1...12))H\(Int.random(in: 0...5) * 10)M"
        
        return FlightData(
            departure: dep.0,
            departureCity: dep.1,
            arrival: arr.0,
            arrivalCity: arr.1,
            flightNumber: flightNum,
            date: dateStr,
            time: timeStr,
            gate: gate,
            seat: seat,
            duration: duration
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📋 飞机机型证 (AircraftTypeRating)
// MARK: - 参考：FAA/CAAC机型签注、飞行员执照
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterAircraftTypeRatingView: View {
    let record: DayRecord
    
    @State private var hologramAngle: Double = 0
    @State private var securityShimmer: CGFloat = -200
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    // 随机机型信息
    private var aircraftInfo: AircraftTypeData {
        AircraftTypeData.random()
    }
    
    var body: some View {
        ZStack {
            // ═══ 证件背景 ═══
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5F5F0"),
                            Color(hex: "E8E8E0"),
                            Color(hex: "F0F0E8")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 安全底纹
            SecurityPatternView()
                .opacity(0.03)
            
            // 流光安全线
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color(hex: "D4AF37").opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 30, height: 400)
                .offset(x: securityShimmer)
                .mask(RoundedRectangle(cornerRadius: 12))
            
            VStack(spacing: 0) {
                // ═══ 头部 ═══
                HStack {
                    // 国徽/Logo
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1E3A5F"))
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "D4AF37"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AIRCRAFT TYPE RATING")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color(hex: "1E3A5F"))
                            .tracking(1)
                        
                        Text("飞机机型等级签注")
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: "5D4037"))
                        
                        Text("CIVIL AVIATION AUTHORITY")
                            .font(.system(size: 7))
                            .foregroundColor(Color(hex: "8B8B8B"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                
                // ═══ 分隔线 ═══
                Rectangle()
                    .fill(Color(hex: "1E3A5F"))
                    .frame(height: 2)
                    .padding(.horizontal, 15)
                    .padding(.top, 12)
                
                HStack(alignment: .top, spacing: 15) {
                    // ═══ 左侧：照片 ═══
                    VStack(spacing: 8) {
                        // 飞行员照片
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "E0E0E0"))
                                .frame(width: 80, height: 100)
                            
                            if let photo = photos.first {
                                Image(uiImage: photo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 76, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            } else {
                                VStack(spacing: 4) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color(hex: "B0B0B0"))
                                    
                                    Text(record.mood.emoji)
                                        .font(.system(size: 20))
                                }
                            }
                            
                            // 照片边框
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "1E3A5F"), lineWidth: 1.5)
                                .frame(width: 80, height: 100)
                        }
                        
                        // 证件号
                        Text("NO. \(generateLicenseNumber())")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "5D4037"))
                    }
                    .padding(.top, 15)
                    
                    // ═══ 右侧：机型信息 ═══
                    VStack(alignment: .leading, spacing: 10) {
                        // 机型
                        TypeRatingField(label: "AIRCRAFT TYPE", value: aircraftInfo.type)
                        
                        // 制造商
                        TypeRatingField(label: "MANUFACTURER", value: aircraftInfo.manufacturer)
                        
                        // 等级
                        TypeRatingField(label: "RATING CLASS", value: aircraftInfo.ratingClass)
                        
                        // 签发日期
                        TypeRatingField(label: "DATE OF ISSUE", value: formattedDate)
                        
                        // 有效期
                        TypeRatingField(label: "VALID UNTIL", value: validUntil)
                    }
                    .padding(.top, 15)
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                
                Spacer()
                
                // ═══ 机型剪影 ═══
                AircraftSilhouetteView(type: aircraftInfo.silhouetteType)
                    .frame(height: 60)
                    .opacity(0.08)
                    .padding(.horizontal, 20)
                
                // ═══ 底部：全息标签和签名 ═══
                HStack(alignment: .bottom) {
                    // 全息标签
                    HologramBadge(angle: hologramAngle)
                        .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    // 签名区
                    VStack(alignment: .trailing, spacing: 4) {
                        Rectangle()
                            .fill(Color(hex: "1E3A5F").opacity(0.3))
                            .frame(width: 100, height: 1)
                        
                        Text("AUTHORIZED SIGNATURE")
                            .font(.system(size: 6))
                            .foregroundColor(Color(hex: "8B8B8B"))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "1E3A5F"), Color(hex: "3A5A8F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        }
        .frame(width: 300, height: 420)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                hologramAngle = 360
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                securityShimmer = 350
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: record.date).uppercased()
    }
    
    private var validUntil: String {
        let calendar = Calendar.current
        if let futureDate = calendar.date(byAdding: .year, value: 5, to: record.date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: futureDate).uppercased()
        }
        return "PERPETUAL"
    }
    
    private func generateLicenseNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let prefix = String((0..<3).map { _ in letters.randomElement()! })
        let numbers = String(format: "%06d", Int.random(in: 100000...999999))
        return "\(prefix)-\(numbers)"
    }
}

// MARK: - 机型数据
struct AircraftTypeData {
    let type: String
    let manufacturer: String
    let ratingClass: String
    let silhouetteType: AircraftSilhouetteType
    
    static func random() -> AircraftTypeData {
        let types: [(String, String, String, AircraftSilhouetteType)] = [
            ("BOEING 737-800", "BOEING", "ME-LAND", .narrowBody),
            ("BOEING 777-300ER", "BOEING", "ME-LAND", .wideBody),
            ("BOEING 787-9", "BOEING", "ME-LAND", .wideBody),
            ("AIRBUS A320neo", "AIRBUS", "ME-LAND", .narrowBody),
            ("AIRBUS A350-900", "AIRBUS", "ME-LAND", .wideBody),
            ("AIRBUS A380-800", "AIRBUS", "ME-LAND", .superJumbo),
            ("COMAC C919", "COMAC", "ME-LAND", .narrowBody),
            ("EMBRAER E190", "EMBRAER", "ME-LAND", .regional),
        ]
        
        let selected = types.randomElement()!
        return AircraftTypeData(
            type: selected.0,
            manufacturer: selected.1,
            ratingClass: selected.2,
            silhouetteType: selected.3
        )
    }
}

enum AircraftSilhouetteType {
    case narrowBody, wideBody, superJumbo, regional
}

// MARK: - 机型签注字段
struct TypeRatingField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 7))
                .foregroundColor(Color(hex: "8B8B8B"))
            
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "1A1A1A"))
        }
    }
}

// MARK: - 安全底纹
struct SecurityPatternView: View {
    var body: some View {
        Canvas { context, size in
            // 波浪线底纹
            for y in stride(from: 0, to: size.height, by: 8) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                
                for x in stride(from: 0, to: size.width, by: 20) {
                    path.addQuadCurve(
                        to: CGPoint(x: x + 20, y: y),
                        control: CGPoint(x: x + 10, y: y + 4)
                    )
                }
                
                context.stroke(path, with: .color(Color(hex: "1E3A5F")), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - 全息标签
struct HologramBadge: View {
    let angle: Double
    
    var body: some View {
        ZStack {
            // 基底
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.red.opacity(0.6),
                            Color.yellow.opacity(0.6),
                            Color.green.opacity(0.6),
                            Color.cyan.opacity(0.6),
                            Color.blue.opacity(0.6),
                            Color.purple.opacity(0.6),
                            Color.red.opacity(0.6)
                        ],
                        center: .center,
                        startAngle: .degrees(angle),
                        endAngle: .degrees(angle + 360)
                    )
                )
            
            // 图案
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            // 光泽
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(
                    Circle()
                        .frame(width: 25, height: 25)
                        .offset(x: -10, y: -10)
                )
        }
    }
}

// MARK: - 飞机剪影
struct AircraftSilhouetteView: View {
    let type: AircraftSilhouetteType
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                
                // 简化的飞机剪影
                // 机身
                path.move(to: CGPoint(x: w * 0.1, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5))
                path.addQuadCurve(
                    to: CGPoint(x: w * 0.95, y: h * 0.5),
                    control: CGPoint(x: w * 0.92, y: h * 0.45)
                )
                
                // 机翼
                path.move(to: CGPoint(x: w * 0.35, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.2))
                path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.2))
                path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
                
                path.move(to: CGPoint(x: w * 0.35, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
                
                // 尾翼
                path.move(to: CGPoint(x: w * 0.85, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5))
            }
            .fill(Color(hex: "1E3A5F"))
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🏷 复古行李牌 (LuggageTag)
// MARK: - 参考：Pan Am黄金年代行李标签
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterLuggageTagView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(1).compactMap { UIImage(data: $0) }
    }
    
    private var destination: (code: String, city: String) {
        let destinations = [
            ("PEK", "北京"), ("SHA", "上海"), ("HKG", "香港"),
            ("TYO", "东京"), ("SEL", "首尔"), ("SIN", "新加坡"),
            ("NYC", "纽约"), ("LAX", "洛杉矶"), ("LDN", "伦敦"),
            ("PAR", "巴黎"), ("ROM", "罗马"), ("SYD", "悉尼")
        ]
        return destinations.randomElement()!
    }
    
    var body: some View {
        ZStack {
            // ═══ 行李牌主体 ═══
            LuggageTagShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F5E6D3"),
                            Color(hex: "E8D5C4"),
                            Color(hex: "DCC8B5")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // 纸张纹理
            LuggageTagShape()
                .fill(Color.clear)
                .overlay(
                    Canvas { context, size in
                        for _ in 0..<500 {
                            let x = Double.random(in: 0...size.width)
                            let y = Double.random(in: 0...size.height)
                            let rect = CGRect(x: x, y: y, width: 1, height: 1)
                            context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.04)))
                        }
                    }
                    .clipShape(LuggageTagShape())
                )
            
            VStack(spacing: 0) {
                // ═══ 挂绳孔 ═══
                ZStack {
                    Circle()
                        .fill(Color(hex: "8B7355"))
                        .frame(width: 18, height: 18)
                    
                    Circle()
                        .fill(Color(hex: "5D4037"))
                        .frame(width: 12, height: 12)
                }
                .padding(.top, 12)
                
                // ═══ 航空公司标志 ═══
                HStack(spacing: 6) {
                    Image(systemName: "airplane")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "1E3A5F"))
                    
                    Text("MEMORY AIRLINES")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(Color(hex: "1E3A5F"))
                        .tracking(1)
                }
                .padding(.top, 15)
                
                // ═══ 目的地大字 ═══
                Text(destination.code)
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "1E3A5F"))
                    .padding(.top, 8)
                
                Text(destination.city)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "5D4037"))
                
                // ═══ 照片（如有）═══
                if let photo = photos.first {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8B7355"), lineWidth: 1)
                        )
                        .padding(.top, 12)
                } else {
                    // 心情
                    Text(record.mood.emoji)
                        .font(.system(size: 32))
                        .padding(.top, 12)
                }
                
                // ═══ 日期 ═══
                Text(formattedDate)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "5D4037"))
                    .padding(.top, 10)
                
                Spacer()
                
                // ═══ 条形码 ═══
                BarcodeView(width: 90, height: 30)
                    .padding(.bottom, 20)
            }
            .frame(width: 120)
            
            // ═══ 边框 ═══
            LuggageTagShape()
                .stroke(Color(hex: "8B7355"), lineWidth: 2)
            
            // ═══ 复古磨损效果 ═══
            LuggageTagShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "8B7355").opacity(0.1), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
        }
        .frame(width: 120, height: 260)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        return formatter.string(from: record.date).uppercased()
    }
}

// MARK: - 行李牌形状
struct LuggageTagShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 15
        let topCurve: CGFloat = 30
        
        // 从左下角开始
        path.move(to: CGPoint(x: cornerRadius, y: rect.height))
        
        // 底边和右下角
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height - cornerRadius),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        
        // 右边
        path.addLine(to: CGPoint(x: rect.width, y: topCurve + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: topCurve),
            control: CGPoint(x: rect.width, y: topCurve)
        )
        
        // 顶部（带挂绳孔的弧形）
        path.addLine(to: CGPoint(x: rect.width / 2 + 15, y: topCurve))
        path.addQuadCurve(
            to: CGPoint(x: rect.width / 2 - 15, y: topCurve),
            control: CGPoint(x: rect.width / 2, y: 0)
        )
        
        // 左边
        path.addLine(to: CGPoint(x: cornerRadius, y: topCurve))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: topCurve + cornerRadius),
            control: CGPoint(x: 0, y: topCurve)
        )
        path.addLine(to: CGPoint(x: 0, y: rect.height - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: rect.height),
            control: CGPoint(x: 0, y: rect.height)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 📒 航空日志 (FlightLog)
// MARK: - 参考：飞行员航行日志本
// MARK: - ═══════════════════════════════════════════════════════════

struct MasterFlightLogView: View {
    let record: DayRecord
    
    private var photos: [UIImage] {
        record.photos.prefix(2).compactMap { UIImage(data: $0) }
    }
    
    private var flightEntry: FlightLogEntry {
        FlightLogEntry.random(from: record.date)
    }
    
    var body: some View {
        ZStack {
            // ═══ 日志本页面 ═══
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "FFFEF5"))
            
            // 格线
            Canvas { context, size in
                // 横线
                for y in stride(from: 30, to: size.height - 10, by: 20) {
                    var path = Path()
                    path.move(to: CGPoint(x: 15, y: y))
                    path.addLine(to: CGPoint(x: size.width - 15, y: y))
                    context.stroke(path, with: .color(Color(hex: "D0E8F0").opacity(0.5)), lineWidth: 0.5)
                }
                
                // 竖线（表格分隔）
                let columns: [CGFloat] = [60, 100, 140, 200, 240]
                for x in columns {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 50))
                    path.addLine(to: CGPoint(x: x, y: size.height - 50))
                    context.stroke(path, with: .color(Color(hex: "D0E8F0").opacity(0.3)), lineWidth: 0.5)
                }
            }
            
            VStack(spacing: 0) {
                // ═══ 页眉 ═══
                HStack {
                    Text("PILOT'S FLIGHT LOG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "1E3A5F"))
                    
                    Spacer()
                    
                    Text("PAGE \(Int.random(in: 1...99))")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color(hex: "8B8B8B"))
                }
                .padding(.horizontal, 18)
                .padding(.top, 15)
                
                // ═══ 表头 ═══
                HStack(spacing: 0) {
                    LogHeaderCell(text: "DATE", width: 45)
                    LogHeaderCell(text: "A/C", width: 40)
                    LogHeaderCell(text: "FROM", width: 40)
                    LogHeaderCell(text: "TO", width: 60)
                    LogHeaderCell(text: "TIME", width: 40)
                    LogHeaderCell(text: "REMARKS", width: 55)
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
                
                // ═══ 飞行记录条目 ═══
                HStack(spacing: 0) {
                    LogDataCell(text: flightEntry.date, width: 45)
                    LogDataCell(text: flightEntry.aircraft, width: 40)
                    LogDataCell(text: flightEntry.from, width: 40)
                    LogDataCell(text: flightEntry.to, width: 60)
                    LogDataCell(text: flightEntry.time, width: 40)
                    LogDataCell(text: record.mood.emoji, width: 55)
                }
                .padding(.horizontal, 15)
                .padding(.top, 5)
                
                // ═══ 照片区域 ═══
                if !photos.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(0..<photos.count, id: \.self) { i in
                            Image(uiImage: photos[i])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: photos.count == 1 ? 180 : 90, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    .padding(.top, 15)
                }
                
                // ═══ 备注区 ═══
                VStack(alignment: .leading, spacing: 4) {
                    Text("REMARKS:")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "1E3A5F"))
                    
                    Text(record.content)
                        .font(.custom("Bradley Hand", size: 12))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 18)
                .padding(.top, 15)
                
                Spacer()
                
                // ═══ 签名 ═══
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Rectangle()
                            .fill(Color(hex: "1E3A5F").opacity(0.3))
                            .frame(width: 100, height: 1)
                        
                        Text("PILOT IN COMMAND")
                            .font(.system(size: 6))
                            .foregroundColor(Color(hex: "8B8B8B"))
                    }
                    
                    Spacer()
                    
                    // 天气
                    if let weather = record.weather {
                        HStack(spacing: 4) {
                            Image(systemName: weather.icon)
                                .font(.system(size: 12))
                            Text(weather.label)
                                .font(.system(size: 9))
                        }
                        .foregroundColor(Color(hex: "5D4037"))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
            
            // ═══ 装订孔 ═══
            VStack(spacing: 0) {
                Spacer()
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "E0E0E0"))
                        .frame(width: 8, height: 8)
                    Spacer()
                }
            }
            .frame(width: 8)
            .offset(x: -135)
            
            // ═══ 边框 ═══
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: "D0D0D0"), lineWidth: 1)
        }
        .frame(width: 280, height: 380)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

// MARK: - 日志表头单元格
struct LogHeaderCell: View {
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text)
            .font(.system(size: 7, weight: .bold))
            .foregroundColor(Color(hex: "1E3A5F"))
            .frame(width: width)
    }
}

// MARK: - 日志数据单元格
struct LogDataCell: View {
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text)
            .font(.system(size: 9, design: .monospaced))
            .foregroundColor(Color(hex: "1A1A1A"))
            .frame(width: width)
    }
}

// MARK: - 飞行日志条目
struct FlightLogEntry {
    let date: String
    let aircraft: String
    let from: String
    let to: String
    let time: String
    
    static func random(from date: Date) -> FlightLogEntry {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        let dateStr = formatter.string(from: date)
        
        let aircrafts = ["B738", "B77W", "B789", "A320", "A359", "A388", "C919"]
        let airports = ["PEK", "SHA", "CAN", "HKG", "NRT", "SIN", "LAX", "JFK"]
        
        let from = airports.randomElement()!
        var to = airports.randomElement()!
        while to == from { to = airports.randomElement()! }
        
        let hours = Int.random(in: 1...12)
        let mins = Int.random(in: 0...5) * 10
        let time = String(format: "%d:%02d", hours, mins)
        
        return FlightLogEntry(
            date: dateStr,
            aircraft: aircrafts.randomElement()!,
            from: from,
            to: to,
            time: time
        )
    }
}


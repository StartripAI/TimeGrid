//
//  ArtifactEnhancements.swift
//  信物增强元素设计
//
//  参考：Instagram Story、复古胶片相机、日记App
//  目标：让每个信物更加精致、更适合分享
//

import SwiftUI

// MARK: - 1. 复古胶片日期戳 (90年代相机风格)
struct RetroFilmDateStamp: View {
    let date: Date
    var color: Color = Color(hex: "FF6B35") // 橙红色LED
    
    private var dateString: String {
        let year = Calendar.current.component(.year, from: date) % 100
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return String(format: "'%02d %02d %02d", year, month, day)
    }
    
    var body: some View {
        Text(dateString)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.8), radius: 2, x: 0, y: 0) // LED发光效果
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
    }
}

// MARK: - 2. 优雅手写日期
struct ElegantHandwrittenDate: View {
    let date: Date
    var color: Color = Color(hex: "8B4513") // 棕色墨水
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    var body: some View {
        Text(dateString)
            .font(.system(size: 14, design: .serif))
            .foregroundColor(color)
            .italic()
    }
}

// MARK: - 3. 打字机日期戳
struct TypewriterDateStamp: View {
    let date: Date
    var color: Color = .black
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("DATE:")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
            Text(dateString)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
        }
        .foregroundColor(color)
        .opacity(0.7)
    }
}

// MARK: - 4. GPS坐标标签
struct GPSCoordinateLabel: View {
    var latitude: Double = 31.2304
    var longitude: Double = 121.4737
    var color: Color = .white.opacity(0.7)
    
    private var latString: String {
        let dir = latitude >= 0 ? "N" : "S"
        return String(format: "%@ %.4f°", dir, abs(latitude))
    }
    
    private var lonString: String {
        let dir = longitude >= 0 ? "E" : "W"
        return String(format: "%@ %.4f°", dir, abs(longitude))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(latString)
            Text(lonString)
        }
        .font(.system(size: 8, weight: .medium, design: .monospaced))
        .foregroundColor(color)
    }
}

// MARK: - 5. 城市名标签
struct CityNameLabel: View {
    var city: String = "SHANGHAI"
    var country: String = "CHINA"
    var style: CityLabelStyle = .modern
    
    enum CityLabelStyle {
        case modern     // 现代简洁
        case vintage    // 复古邮戳风
        case minimal    // 极简
    }
    
    var body: some View {
        switch style {
        case .modern:
            VStack(alignment: .leading, spacing: 0) {
                Text(city)
                    .font(.system(size: 10, weight: .bold, design: .default))
                    .tracking(2)
                Text(country)
                    .font(.system(size: 7, weight: .medium, design: .default))
                    .tracking(1)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
            
        case .vintage:
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 1) {
                    Text(city)
                        .font(.system(size: 7, weight: .bold))
                    Text(country)
                        .font(.system(size: 5, weight: .medium))
                }
            }
            
        case .minimal:
            Text("\(city), \(country)")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 6. 温度标签
struct TemperatureLabel: View {
    var temperature: Int = 23
    var unit: String = "°C"
    var color: Color = .white.opacity(0.8)
    
    var body: some View {
        Text("\(temperature)\(unit)")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(color)
    }
}

// MARK: - 7. 序号标签
struct SerialNumberLabel: View {
    var number: Int = 1
    var prefix: String = "No."
    var style: SerialStyle = .elegant
    
    enum SerialStyle {
        case elegant    // 优雅衬线
        case technical  // 技术等宽
        case minimal    // 极简
    }
    
    var body: some View {
        switch style {
        case .elegant:
            Text("\(prefix) \(String(format: "%03d", number))")
                .font(.system(size: 10, design: .serif))
                .foregroundColor(.secondary)
                
        case .technical:
            Text("#\(String(format: "%04d", number))")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                
        case .minimal:
            Text("\(number)")
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(4)
        }
    }
}

// MARK: - 8. 时光格品牌水印
struct YiGeWatermark: View {
    var style: WatermarkStyle = .subtle
    
    enum WatermarkStyle {
        case subtle     // 微妙
        case elegant    // 优雅
        case minimal    // 极简
    }
    
    var body: some View {
        switch style {
        case .subtle:
            HStack(spacing: 4) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 8))
                Text("一格")
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.primary.opacity(0.3))
            
        case .elegant:
            VStack(spacing: 2) {
                Text("一格")
                    .font(.system(size: 10))
                Text("YIGE")
                    .font(.system(size: 6, weight: .medium, design: .default))
                    .tracking(2)
            }
            .foregroundColor(.primary.opacity(0.4))
            
        case .minimal:
            Text("一格")
                .font(.system(size: 8))
                .foregroundColor(.primary.opacity(0.2))
        }
    }
}

// MARK: - 辅助组件：锯齿边缘
struct JaggedEdgeV2: Shape {
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

// MARK: - 辅助组件：虚线
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// MARK: - 辅助组件：热敏打印噪点效果
struct ThermalPrintNoise: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<200 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(Double.random(in: 0.02...0.08))))
            }
        }
        .blendMode(.multiply)
    }
}


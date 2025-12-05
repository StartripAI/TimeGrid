//
//  CountdownView.swift
//  时光格 V3.0 - 左Tab: 倒数日历
//
//  设计理念：圣诞日历盒式的期待感体验
//  参考 HTML 设计稿优化 - 5列网格、脉动动画、强调今天
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var calendarManager = CalendarManager.shared
    @ObservedObject var themeEngine = ThemeEngine.shared // 🔥 观察主题变化
    
    @State private var showingAddAnniversary = false
    @State private var selectedRecord: DayRecord?
    @State private var selectedDate: Date?
    @State private var showingNewRecord = false
    @State private var showingDayDetail = false  // V3.1: 统一详情页
    @State private var displayedMonth: Date = Date()  // V3.3: 当前显示的月份
    @State private var systemEventsPresence: Set<Date> = []  // V3.3: 有事件的日期
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 应用工坊主题背景
                themeEngine.currentTheme.backgroundView
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 主倒数卡片
                        mainCountdownCard
                        
                        // 本月日历盒
                        adventCalendarSection
                        
                        // 系统日历事件
                        if calendarManager.authorizationStatus == .fullAccess {
                            systemEventsSection
                        } else {
                            calendarPermissionCard
                        }
                        
                        // 其他倒数
                        upcomingSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("倒数日历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAnniversary = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "D4AF37"))
                    }
                }
            }
            .sheet(isPresented: $showingAddAnniversary) {
                AddAnniversaryView()
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
            .fullScreenCover(isPresented: $showingNewRecord) {
                if let date = selectedDate {
                    NewRecordView(recordDate: date)
                }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailView(date: date)
                }
            }
            .onAppear {
                loadSystemEvents()
            }
        }
    }
    
    // MARK: - 主倒数卡片
    
    private var mainCountdownCard: some View {
        Group {
            if let nearest = dataManager.nearestAnniversary() {
                let daysLeft = nearest.daysUntilNext()
                
                ZStack {
                    // 背景渐变
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "F2D06B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(20)
                    
                    // 装饰圆点
                    GeometryReader { geo in
                        ForEach(0..<6, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: CGFloat.random(in: 30...80))
                                .position(
                                    x: CGFloat.random(in: 0...geo.size.width),
                                    y: CGFloat.random(in: 0...geo.size.height)
                                )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // 内容
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text(nearest.emoji)
                                .font(.system(size: 24))
                            Text("距离\(nearest.name)")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("\(daysLeft)")
                            .font(.system(size: 72, weight: .ultraLight, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("天")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formatDate(nearest.nextOccurrence()))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 30)
                }
                .frame(height: 200)
                .shadow(color: Color(hex: "D4AF37").opacity(0.3), radius: 20, x: 0, y: 12)
            } else {
                // 空状态
                VStack(spacing: 12) {
                    Text("🎯")
                        .font(.system(size: 40))
                    Text("添加一个纪念日开始倒数")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Button {
                        showingAddAnniversary = true
                    } label: {
                        Text("添加纪念日")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "D4AF37"))
                            .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.05)) // 玻璃质感
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - 本月日历盒
    
    private var adventCalendarSection: some View {
        VStack(spacing: 16) {
            // 月份导航
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        loadSystemEvents()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(displayedMonthTitle)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(.white) // 白色标题
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        loadSystemEvents()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            
            // 星期标题
            weekdayHeader
            
            // 日历网格
            CalendarGridView(
                month: displayedMonth,
                systemEventsPresence: systemEventsPresence,
                recordsSummary: dataManager.getRecordsSummary(),
                onDayTap: handleDayTap
            )
        }
        .padding(20)
        .background(Color.white.opacity(0.05)) // 半透明玻璃背景
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        .onAppear {
            loadSystemEvents()
        }
        .onChange(of: displayedMonth) {
            loadSystemEvents()
        }
    }
    
    private var displayedMonthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5)) // 浅色文字
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func loadSystemEvents() {
        Task {
            let events = calendarManager.fetchEventPresence(for: displayedMonth)
            await MainActor.run {
                self.systemEventsPresence = events
            }
        }
    }
    
    // MARK: - 系统日历事件
    
    private var systemEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Color(hex: "D4AF37"))
                Text("日历日程")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            let upcoming = calendarManager.upcomingEvents(limit: 3)
            
            if upcoming.isEmpty {
                Text("近期没有日程安排")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                ForEach(upcoming) { event in
                    SystemEventRow(event: event)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 日历权限卡片
    
    private var calendarPermissionCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 36))
                .foregroundColor(Color(hex: "D4AF37"))
            
            Text("连接系统日历")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            Text("同步日历中的节日和日程")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
            
            Button {
                calendarManager.requestAccess()
            } label: {
                Text("授权访问")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "D4AF37"))
                    .cornerRadius(20)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 其他倒数
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("即将到来")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            let upcoming = dataManager.upcomingAnniversaries(limit: 5)
            
            if upcoming.isEmpty {
                Text("暂无其他即将到来的纪念日")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 16)
            } else {
                ForEach(upcoming) { anniversary in
                    CountdownRow(anniversary: anniversary)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    private func handleDayTap(_ date: Date) {
        // 🔥 修复：限制只能选择今天及之前的日期
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        
        // 如果选择的日期是未来，不允许补记
        if selectedDay > today {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        selectedDate = date
        showingDayDetail = true
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - 网格与单元格组件

struct CalendarGridView: View, Equatable {
    @EnvironmentObject var dataManager: DataManager
    
    let month: Date
    let systemEventsPresence: Set<Date>
    let recordsSummary: [Date: RecordSummary]
    let onDayTap: (Date) -> Void
    
    static func == (lhs: CalendarGridView, rhs: CalendarGridView) -> Bool {
        lhs.month == rhs.month &&
        lhs.systemEventsPresence == rhs.systemEventsPresence &&
        lhs.recordsSummary.count == rhs.recordsSummary.count
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.range(of: .day, in: .month, for: month),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        var dates: [Date?] = []
        let offset = weekdayOfFirstDay - 1
        for _ in 0..<offset { dates.append(nil) }
        
        for day in monthInterval {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        return dates
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    let summary = recordsSummary[date]
                    let hasEvent = systemEventsPresence.contains(date)
                    
                    CalendarDayCell(date: date, summary: summary, hasSystemEvent: hasEvent)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onDayTap(date)
                        }
                } else {
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }
}

struct CalendarDayCell: View, Equatable {
    let date: Date
    let summary: RecordSummary?
    let hasSystemEvent: Bool
    
    static func == (lhs: CalendarDayCell, rhs: CalendarDayCell) -> Bool {
        lhs.date == rhs.date &&
        lhs.summary?.emoji == rhs.summary?.emoji &&
        lhs.hasSystemEvent == rhs.hasSystemEvent
    }
    
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var dayNumber: Int { Calendar.current.component(.day, from: date) }
    
    var body: some View {
        ZStack {
            // 背景 (半透明/磨砂)
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .shadow(color: isToday ? Color(hex: "D4AF37").opacity(0.3) : .clear, radius: 4)
            
            // 内容
            VStack(spacing: 2) {
                if let summary = summary {
                    Text(summary.sticker ?? summary.emoji)
                        .font(.system(size: 20))
                } else if isToday {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                } else {
                    // 普通日期
                    Text("\(dayNumber)")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.8)) // 白色文字
                }
            }
            
            // 系统事件蓝点
            if hasSystemEvent && summary == nil && !isToday {
                VStack {
                    Spacer()
                    Circle()
                        .fill(Color(hex: "4169E1").opacity(0.8)) // 皇家蓝
                        .frame(width: 4, height: 4)
                        .padding(.bottom, 4)
                }
            }
            
            // 边框
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: isToday ? 1.5 : 0.5)
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isToday ? 1.05 : 1.0)
    }
    
    private var backgroundColor: Color {
        if summary != nil {
            return Color(hex: "D4AF37").opacity(0.15) // 已记录：淡金色
        } else if isToday {
            return Color.white.opacity(0.1) // 今天：稍微亮一点
        } else {
            return Color.white.opacity(0.03) // 默认：微透明
        }
    }
    
    private var borderColor: Color {
        if isToday {
            return Color(hex: "D4AF37")
        } else if summary != nil {
            return Color(hex: "D4AF37").opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }
}

// MARK: - 子组件定义 (SystemEventRow, CountdownRow, AddAnniversaryView...)

struct SystemEventRow: View {
    let event: SystemCalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: event.startDate))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "D4AF37"))
                
                Text(monthAbbr)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(event.daysUntil == 0 ? "今天" : "\(event.daysUntil)天后")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var monthAbbr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: event.startDate)
    }
}

struct CountdownRow: View {
    let anniversary: Anniversary
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Text(anniversary.emoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(anniversary.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(formatDate(anniversary.nextOccurrence()))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(anniversary.daysUntilNext())天")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "D4AF37"))
        }
        .padding(.vertical, 10)
        .scaleEffect(isPressed ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            withAnimation(.spring(response: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

struct AddAnniversaryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var emoji = "🎂"
    @State private var date = Date()
    @State private var isYearly = true
    @State private var syncToSystem = false
    
    private let emojis = ["🎂", "💕", "🎉", "✈️", "🏠", "👶", "💍", "🎓", "🏆", "⭐️", "🌟", "🎁", "🎄", "🌸", "🍀", "🎊", "💒", "🏖️", "🎵", "📚"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("纪念日名称")) {
                    TextField("例如：妈妈生日", text: $name)
                }
                
                Section(header: Text("选择图标")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(emojis, id: \.self) { e in
                            Text(e)
                                .font(.system(size: 28))
                                .padding(8)
                                .background(emoji == e ? Color(hex: "D4AF37").opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .scaleEffect(emoji == e ? 1.1 : 1)
                                .animation(.spring(response: 0.3), value: emoji)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    emoji = e
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("日期")) {
                    DatePicker("选择日期", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(Color(hex: "D4AF37"))
                    
                    Toggle("每年重复", isOn: $isYearly)
                        .tint(Color(hex: "D4AF37"))
                }
                
                if CalendarManager.shared.authorizationStatus == .fullAccess {
                    Section(header: Text("同步")) {
                        Toggle("同步到系统日历", isOn: $syncToSystem)
                            .tint(Color(hex: "D4AF37"))
                    }
                }
            }
            .navigationTitle("添加纪念日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveAnniversary()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : Color(hex: "D4AF37"))
                }
            }
        }
    }
    
    private func saveAnniversary() {
        let anniversary = Anniversary(
            name: name,
            emoji: emoji,
            date: date,
            isYearly: isYearly,
            isBuiltIn: false
        )
        dataManager.addAnniversary(anniversary)
        
        if syncToSystem {
            CalendarManager.shared.addEventToSystemCalendar(
                title: "\(emoji) \(name)",
                date: anniversary.nextOccurrence(),
                notes: "由「时光格」添加"
            )
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

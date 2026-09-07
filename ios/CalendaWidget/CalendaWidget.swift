import WidgetKit
import SwiftUI

// MARK: - Models

struct WidgetEvent: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String?
    let dayOfWeek: Int?
    let startHour: Int?
    let startMinute: Int?
    let endHour: Int?
    let endMinute: Int?
    let colorHex: String?
    let isNotificationEnabled: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, dayOfWeek, startHour, startMinute, endHour, endMinute, colorHex, isNotificationEnabled
    }
    
    var timeFormatted: String {
        guard let sh = startHour, let sm = startMinute else { return "" }
        let shStr = String(format: "%02d", sh)
        let smStr = String(format: "%02d", sm)
        
        if let eh = endHour, let em = endMinute, !(eh == 0 && em == 0) {
            let ehStr = String(format: "%02d", eh)
            let emStr = String(format: "%02d", em)
            return "\(shStr):\(smStr) - \(ehStr):\(emStr)"
        }
        return "\(shStr):\(smStr)"
    }
    
    var miniTimeFormatted: String {
        guard let sh = startHour, let sm = startMinute else { return "" }
        return String(format: "%02d:%02d", sh, sm)
    }
}

struct WidgetThemeConfig: Decodable {
    let titleText: String?
    let textColorHex: String?
    let backgroundColorHex: String?
    let backgroundOpacity: Double?
}

// MARK: - Color Extension

extension Color {
    init(hex: String, defaultColor: Color = .primary) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&int) else {
            self = defaultColor
            return
        }
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 200, 200, 200)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared Data Reader & Helpers

struct CalendaDataManager {
    static let appGroupId = "group.com.calenda.app"
    
    static func loadTodayEvents() -> [WidgetEvent] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "today_events_json"),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([WidgetEvent].self, from: data)) ?? []
    }
    
    static func loadWeeklyEvents() -> [String: [WidgetEvent]] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "weekly_events_json"),
              let data = jsonString.data(using: .utf8) else {
            return [:]
        }
        return (try? JSONDecoder().decode([String: [WidgetEvent]].self, from: data)) ?? [:]
    }
    
    static func loadThemeConfig() -> WidgetThemeConfig? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "theme_config_json"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetThemeConfig.self, from: data)
    }
    
    /// Calenda Haftanin Gunu (1: Pazartesi ... 7: Pazar)
    static func calendaDayOfWeek(for date: Date) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Pazartesi
        let weekday = cal.component(.weekday, from: date)
        return weekday == 1 ? 7 : weekday - 1
    }
    
    /// Verilen tarihin haftasindaki 7 gunun ayin kaci oldugunu hesaplar
    static func calculateDayNumbers(for date: Date) -> [Int] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Pazartesi
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1 ? 7 : weekday - 1) - 1
        let startOfDay = cal.startOfDay(for: date)
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: startOfDay) else {
            return [1, 2, 3, 4, 5, 6, 7]
        }
        return (0..<7).compactMap { offset in
            cal.date(byAdding: .day, value: offset, to: monday).map { cal.component(.day, from: $0) }
        }
    }
    
    /// Hafta basligini verilen tarihe gore dinamik uretir
    static func formatWeekLabel(for date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1 ? 7 : weekday - 1) - 1
        let startOfDay = cal.startOfDay(for: date)
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: startOfDay),
              let sunday = cal.date(byAdding: .day, value: 6, to: monday) else {
            return "Bu Hafta"
        }
        let monDay = cal.component(.day, from: monday)
        let sunDay = cal.component(.day, from: sunday)
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "LLLL"
        let monthName = f.string(from: sunday)
        
        return "Bu Hafta (\(monDay) - \(sunDay) \(monthName.capitalized))"
    }
}

// MARK: - Timeline Entries

struct DailyEntry: TimelineEntry {
    let date: Date
    let events: [WidgetEvent]
    let theme: WidgetThemeConfig?
}

struct WeeklyEntry: TimelineEntry {
    let date: Date
    let weekLabel: String
    let weeklyMap: [String: [WidgetEvent]]
    let dayNumbers: [Int]
    let theme: WidgetThemeConfig?
}

// MARK: - Daily Widget Provider

struct DailyProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyEntry {
        let sample = [
            WidgetEvent(id: "1", title: "Ders Calisma", subtitle: "Matematik", dayOfWeek: 1, startHour: 10, startMinute: 0, endHour: 11, endMinute: 30, colorHex: "#A2D2FF", isNotificationEnabled: true),
            WidgetEvent(id: "2", title: "Kitap Okuma", subtitle: nil, dayOfWeek: 1, startHour: 14, startMinute: 0, endHour: nil, endMinute: nil, colorHex: "#FCF4DD", isNotificationEnabled: false)
        ]
        return DailyEntry(date: Date(), events: sample, theme: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> ()) {
        let now = Date()
        let weeklyMap = CalendaDataManager.loadWeeklyEvents()
        let todayEvents = CalendaDataManager.loadTodayEvents()
        let theme = CalendaDataManager.loadThemeConfig()
        let calDay = CalendaDataManager.calendaDayOfWeek(for: now)
        let events = todayEvents.isEmpty ? (weeklyMap[String(calDay)] ?? []) : todayEvents
        completion(DailyEntry(date: now, events: events, theme: theme))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> ()) {
        let weeklyMap = CalendaDataManager.loadWeeklyEvents()
        let todayEvents = CalendaDataManager.loadTodayEvents()
        let theme = CalendaDataManager.loadThemeConfig()
        
        var entries: [DailyEntry] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let now = Date()
        
        // 1. Simdiki an (Bugun)
        let currentCalDay = CalendaDataManager.calendaDayOfWeek(for: now)
        let currentEvents = todayEvents.isEmpty ? (weeklyMap[String(currentCalDay)] ?? []) : todayEvents
        entries.append(DailyEntry(date: now, events: currentEvents, theme: theme))
        
        // 2. Gelecek 7 gunun her bir gece yarisi (00:00:01) icin otomatik timeline girdisi olustur
        for dayOffset in 1...7 {
            if let nextDay = calendar.date(byAdding: .day, value: dayOffset, to: now) {
                let startOfDay = calendar.startOfDay(for: nextDay)
                let midnight = calendar.date(byAdding: .second, value: 1, to: startOfDay) ?? startOfDay
                let calDay = CalendaDataManager.calendaDayOfWeek(for: nextDay)
                let dayEvents = weeklyMap[String(calDay)] ?? []
                entries.append(DailyEntry(date: midnight, events: dayEvents, theme: theme))
            }
        }
        
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? calendar.date(byAdding: .hour, value: 2, to: now)!
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: - Weekly Widget Provider

struct WeeklyProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyEntry {
        WeeklyEntry(
            date: Date(),
            weekLabel: "Bu Hafta",
            weeklyMap: [:],
            dayNumbers: [7, 8, 9, 10, 11, 12, 13],
            theme: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklyEntry) -> ()) {
        let now = Date()
        let entry = WeeklyEntry(
            date: now,
            weekLabel: CalendaDataManager.formatWeekLabel(for: now),
            weeklyMap: CalendaDataManager.loadWeeklyEvents(),
            dayNumbers: CalendaDataManager.calculateDayNumbers(for: now),
            theme: CalendaDataManager.loadThemeConfig()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyEntry>) -> ()) {
        let weeklyMap = CalendaDataManager.loadWeeklyEvents()
        let theme = CalendaDataManager.loadThemeConfig()
        
        var entries: [WeeklyEntry] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let now = Date()
        
        // 1. Simdiki an (Bugun)
        entries.append(WeeklyEntry(
            date: now,
            weekLabel: CalendaDataManager.formatWeekLabel(for: now),
            weeklyMap: weeklyMap,
            dayNumbers: CalendaDataManager.calculateDayNumbers(for: now),
            theme: theme
        ))
        
        // 2. Gelecek 7 gunun her bir gece yarisi (00:00:01) icin otomatik timeline girdisi olustur
        for dayOffset in 1...7 {
            if let nextDay = calendar.date(byAdding: .day, value: dayOffset, to: now) {
                let startOfDay = calendar.startOfDay(for: nextDay)
                let midnight = calendar.date(byAdding: .second, value: 1, to: startOfDay) ?? startOfDay
                entries.append(WeeklyEntry(
                    date: midnight,
                    weekLabel: CalendaDataManager.formatWeekLabel(for: nextDay),
                    weeklyMap: weeklyMap,
                    dayNumbers: CalendaDataManager.calculateDayNumbers(for: nextDay),
                    theme: theme
                ))
            }
        }
        
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? calendar.date(byAdding: .hour, value: 2, to: now)!
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: - Views: Aesthetic Daily Widget

struct DailyWidgetEntryView: View {
    var entry: DailyEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var effectiveBgColor: Color {
        if let opacity = entry.theme?.backgroundOpacity {
            if opacity <= 0.05 {
                return Color.clear
            }
            if let hex = entry.theme?.backgroundColorHex, !hex.isEmpty, hex != "#FFFFFF" {
                return Color(hex: hex).opacity(opacity)
            }
            return (colorScheme == .dark ? Color(hex: "#14241B") : Color(hex: "#F7FAF4")).opacity(opacity)
        }
        return Color.clear
    }

    var effectiveTextColor: Color {
        if let hex = entry.theme?.textColorHex, !hex.isEmpty {
            return Color(hex: hex)
        }
        return colorScheme == .dark ? Color(hex: "#F8FAF5") : Color(hex: "#0F172A")
    }

    var displayTitle: String {
        if let t = entry.theme?.titleText, !t.trimmingCharacters(in: .whitespaces).isEmpty {
            return t.trimmingCharacters(in: .whitespaces)
        }
        return "Bugünün Planı"
    }

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(formattedDate(entry.date, format: "d MMMM EEEE"))
                        .font(.system(size: 8.5, weight: .bold, design: .rounded))
                        .foregroundColor(effectiveTextColor.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(displayTitle)
                        .font(.system(size: 13.5, weight: .heavy, design: .rounded))
                        .foregroundColor(effectiveTextColor)
                        .lineLimit(1)
                }
                
                Divider().background(effectiveTextColor.opacity(0.12))
                
                if entry.events.isEmpty {
                    Spacer()
                    Text("Bugün için plan yok 🌿")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(effectiveTextColor.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(entry.events.prefix(3)) { event in
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: event.colorHex ?? "#60A5FA"))
                                    .frame(width: 3, height: 18)
                                
                                VStack(alignment: .leading, spacing: 0.5) {
                                    Text(event.title)
                                        .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                        .foregroundColor(effectiveTextColor)
                                        .lineLimit(1)
                                    
                                    if !event.miniTimeFormatted.isEmpty {
                                        Text(event.miniTimeFormatted)
                                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                                            .foregroundColor(effectiveTextColor.opacity(0.65))
                                    }
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(12)
            .containerBackground(for: .widget) {
                effectiveBgColor
            }

        case .systemMedium:
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(displayTitle)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(effectiveTextColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text({
                        let s = formattedDate(entry.date, format: "d MMMM EEEE")
                        return s.prefix(1).uppercased() + s.dropFirst()
                    }())
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(effectiveTextColor.opacity(0.7))
                    
                    if !entry.events.isEmpty {
                        Text("\(entry.events.count) Plan")
                            .font(.system(size: 9.5, weight: .bold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(effectiveTextColor.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(effectiveTextColor)
                    }
                }
                
                Divider().background(effectiveTextColor.opacity(0.12))
                
                if entry.events.isEmpty {
                    Spacer()
                    Text("Bugün için plan bulunmuyor 🌿")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(effectiveTextColor.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(entry.events.prefix(3)) { event in
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: event.colorHex ?? "#60A5FA"))
                                    .frame(width: 3.2, height: 22)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(event.title)
                                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                        .foregroundColor(effectiveTextColor)
                                        .lineLimit(1)
                                    
                                    if let sub = event.subtitle, !sub.isEmpty {
                                        Text(sub)
                                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                            .foregroundColor(effectiveTextColor.opacity(0.65))
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                if !event.timeFormatted.isEmpty {
                                    Text(event.timeFormatted)
                                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                        .foregroundColor(effectiveTextColor.opacity(0.75))
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(14)
            .containerBackground(for: .widget) {
                effectiveBgColor
            }

        default:
            Text(displayTitle)
                .containerBackground(for: .widget) {
                    effectiveBgColor
                }
        }
    }

    private func formattedDate(_ date: Date, format: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = format
        return f.string(from: date)
    }
}

// MARK: - Views: Aesthetic Weekly Widget

struct WeeklyWidgetEntryView: View {
    var entry: WeeklyEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    private let dayHeaders = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    var effectiveBgColor: Color {
        if let opacity = entry.theme?.backgroundOpacity {
            if opacity <= 0.05 {
                return Color.clear
            }
            if let hex = entry.theme?.backgroundColorHex, !hex.isEmpty, hex != "#FFFFFF" {
                return Color(hex: hex).opacity(opacity)
            }
            return (colorScheme == .dark ? Color(hex: "#14241B") : Color(hex: "#F7FAF4")).opacity(opacity)
        }
        return Color.clear
    }

    var effectiveTextColor: Color {
        if let hex = entry.theme?.textColorHex, !hex.isEmpty {
            return Color(hex: hex)
        }
        return colorScheme == .dark ? Color(hex: "#F8FAF5") : Color(hex: "#0F172A")
    }

    var body: some View {
        let cal = Calendar(identifier: .gregorian)
        let weekday = cal.component(.weekday, from: entry.date)
        let currentDayIndex = weekday == 1 ? 6 : weekday - 2

        switch family {
        case .systemLarge:
            VStack(spacing: 8) {
                headerView
                
                weeklyGridView(currentDayIndex: currentDayIndex, maxEventsPerDay: 2)
                
                Divider().background(effectiveTextColor.opacity(0.12))
                
                let todayKey = String(currentDayIndex + 1)
                let todayEvents = entry.weeklyMap[todayKey] ?? []
                
                if todayEvents.isEmpty {
                    Spacer()
                    Text("Bugün için plan bulunmuyor 🌿")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                        .foregroundColor(effectiveTextColor.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(todayEvents.prefix(3)) { event in
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: event.colorHex ?? "#60A5FA"))
                                    .frame(width: 3.2, height: 22)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(event.title)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(effectiveTextColor)
                                        .lineLimit(1)
                                    if let sub = event.subtitle, !sub.isEmpty {
                                        Text(sub)
                                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                                            .foregroundColor(effectiveTextColor.opacity(0.65))
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                if !event.timeFormatted.isEmpty {
                                    Text(event.timeFormatted)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(effectiveTextColor.opacity(0.75))
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(12)
            .containerBackground(for: .widget) {
                effectiveBgColor
            }

        default: // .systemMedium
            VStack(spacing: 6) {
                headerView
                weeklyGridView(currentDayIndex: currentDayIndex, maxEventsPerDay: 3)
            }
            .padding(10)
            .containerBackground(for: .widget) {
                effectiveBgColor
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text(entry.weekLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(effectiveTextColor)
            Spacer()
            Text("Calenda")
                .font(.system(size: 9.5, weight: .heavy, design: .rounded))
                .foregroundColor(effectiveTextColor.opacity(0.4))
        }
    }

    private func weeklyGridView(currentDayIndex: Int, maxEventsPerDay: Int) -> some View {
        HStack(alignment: .top, spacing: 3) {
            ForEach(0..<7, id: \.self) { idx in
                let isToday = idx == currentDayIndex
                let dayKey = String(idx + 1)
                let dayEvents = entry.weeklyMap[dayKey] ?? []
                let dayNum = entry.dayNumbers.count > idx ? "\(entry.dayNumbers[idx])" : ""
                
                VStack(spacing: 2) {
                    Text(dayHeaders[idx])
                        .font(.system(size: 9, weight: isToday ? .heavy : .bold, design: .rounded))
                        .foregroundColor(isToday ? effectiveTextColor : effectiveTextColor.opacity(0.55))
                    
                    if !dayNum.isEmpty {
                        Text(dayNum)
                            .font(.system(size: 9.5, weight: isToday ? .heavy : .semibold, design: .rounded))
                            .foregroundColor(isToday ? .white : effectiveTextColor.opacity(0.85))
                            .frame(width: 17, height: 17)
                            .background(isToday ? (colorScheme == .dark ? Color(hex: "#2E6B43") : Color(hex: "#0E260A")) : Color.clear)
                            .clipShape(Circle())
                    }
                    
                    if dayEvents.isEmpty {
                        Spacer(minLength: 0)
                    } else {
                        VStack(spacing: 2) {
                            ForEach(dayEvents.prefix(maxEventsPerDay)) { event in
                                let evColor = Color(hex: event.colorHex ?? "#60A5FA")
                                
                                VStack(alignment: .leading, spacing: 0.5) {
                                    if !event.miniTimeFormatted.isEmpty {
                                        Text(event.miniTimeFormatted)
                                            .font(.system(size: 5.2, weight: .bold, design: .monospaced))
                                            .foregroundColor(Color(hex: "#334155"))
                                            .lineLimit(1)
                                    }
                                    Text(event.title)
                                        .font(.system(size: 6.2, weight: .heavy, design: .rounded))
                                        .foregroundColor(Color(hex: "#0F172A"))
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 1.5)
                                .background(evColor.opacity(0.35))
                                .cornerRadius(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(evColor.opacity(0.75), lineWidth: 0.6)
                                )
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 3)
                .background(isToday ? effectiveTextColor.opacity(0.08) : Color.clear)
                .cornerRadius(6)
            }
        }
    }
}

// MARK: - Widget Configurations

struct AestheticPlannerWidget: Widget {
    let kind: String = "AestheticPlannerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyProvider()) { entry in
            DailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calenda Günlük Plan")
        .description("Günün etkinliklerini ve ajandanı zarif bir görünümde takip et.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AestheticWeeklyWidget: Widget {
    let kind: String = "AestheticWeeklyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklyProvider()) { entry in
            WeeklyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calenda Haftalık Akış")
        .description("Haftanın 7 gününü ve ritmini tek ekranda izle.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct CalendaWidgetBundle: WidgetBundle {
    var body: some Widget {
        AestheticPlannerWidget()
        AestheticWeeklyWidget()
    }
}

// MARK: - iOS 17 containerBackground polyfill for earlier iOS versions
extension View {
    func containerBackground(for family: WidgetFamily, @ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 17.0, *) {
            return AnyView(self.containerBackground(for: .widget) { content() })
        } else {
            return AnyView(self.background(content()))
        }
    }
}

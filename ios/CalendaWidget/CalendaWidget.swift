import WidgetKit
import SwiftUI

// MARK: - Models

struct WidgetEvent: Identifiable, Decodable {
    let id: String
    let title: String
    let startTime: String?
    let endTime: String?
    let colorHex: String?
    let isCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, startTime, endTime, colorHex, isCompleted
    }
}

struct WidgetThemeConfig: Decodable {
    let title: String?
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

// MARK: - Shared Data Reader

struct CalendaDataManager {
    static let appGroupId = "group.com.calenda.app"
    
    static func loadTodayEvents() -> [WidgetEvent] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "today_events_json"),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        do {
            return try JSONDecoder().decode([WidgetEvent].self, from: data)
        } catch {
            return []
        }
    }
    
    static func loadWeeklyEvents() -> [String: [WidgetEvent]] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "weekly_events_json"),
              let data = jsonString.data(using: .utf8) else {
            return [:]
        }
        do {
            return try JSONDecoder().decode([String: [WidgetEvent]].self, from: data)
        } catch {
            return [:]
        }
    }
    
    static func loadThemeConfig() -> WidgetThemeConfig? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "theme_config_json"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetThemeConfig.self, from: data)
    }
    
    static func loadWeekLabel() -> String {
        let sharedDefaults = UserDefaults(suiteName: appGroupId)
        return sharedDefaults?.string(forKey: "week_label") ?? "Haftalık Plan"
    }
    
    static func loadWeekDayNumbers() -> [Int] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = sharedDefaults.string(forKey: "week_day_numbers_json"),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
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
        DailyEntry(
            date: Date(),
            events: [
                WidgetEvent(id: "1", title: "Ders Çalışma", startTime: "10:00", endTime: "11:30", colorHex: "#A2D2FF", isCompleted: false),
                WidgetEvent(id: "2", title: "Kitap Okuma", startTime: "14:00", endTime: nil, colorHex: "#FCF4DD", isCompleted: true)
            ],
            theme: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> ()) {
        let events = CalendaDataManager.loadTodayEvents()
        let theme = CalendaDataManager.loadThemeConfig()
        let entry = DailyEntry(date: Date(), events: events, theme: theme)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> ()) {
        let events = CalendaDataManager.loadTodayEvents()
        let theme = CalendaDataManager.loadThemeConfig()
        let entry = DailyEntry(date: Date(), events: events, theme: theme)
        
        // Gece yarısı veya 30 dakikada bir yenile
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Weekly Widget Provider

struct WeeklyProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyEntry {
        WeeklyEntry(
            date: Date(),
            weekLabel: "Haftalık Akış",
            weeklyMap: [:],
            dayNumbers: [7, 8, 9, 10, 11, 12, 13],
            theme: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklyEntry) -> ()) {
        let entry = WeeklyEntry(
            date: Date(),
            weekLabel: CalendaDataManager.loadWeekLabel(),
            weeklyMap: CalendaDataManager.loadWeeklyEvents(),
            dayNumbers: CalendaDataManager.loadWeekDayNumbers(),
            theme: CalendaDataManager.loadThemeConfig()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyEntry>) -> ()) {
        let entry = WeeklyEntry(
            date: Date(),
            weekLabel: CalendaDataManager.loadWeekLabel(),
            weeklyMap: CalendaDataManager.loadWeeklyEvents(),
            dayNumbers: CalendaDataManager.loadWeekDayNumbers(),
            theme: CalendaDataManager.loadThemeConfig()
        )
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Views: Aesthetic Daily Widget

struct DailyWidgetEntryView: View {
    var entry: DailyEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let titleColor = Color(hex: entry.theme?.textColorHex ?? "#4A2B33")
        let bgHex = entry.theme?.backgroundColorHex ?? "#FAF7F2"
        let bgOpacity = entry.theme?.backgroundOpacity ?? 1.0
        let displayTitle = entry.theme?.title?.isEmpty == false ? entry.theme!.title! : "Bugünün Planı"

        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(displayTitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(titleColor)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(titleColor.opacity(0.7))
                }
                
                Divider().background(titleColor.opacity(0.15))
                
                if entry.events.isEmpty {
                    Spacer()
                    Text("Bugün için plan yok")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(titleColor.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(entry.events.prefix(3)) { event in
                            HStack(spacing: 5) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: event.colorHex ?? "#A2D2FF"))
                                    .frame(width: 3, height: 16)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(event.title)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(titleColor)
                                        .lineLimit(1)
                                    if let start = event.startTime, !start.isEmpty {
                                        Text(start)
                                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                                            .foregroundColor(titleColor.opacity(0.6))
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
                Color(hex: bgHex).opacity(bgOpacity)
            }

        case .systemMedium:
            HStack(spacing: 14) {
                // Sol Bölüm: Tarih & Başlık
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedTodayDate())
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(titleColor.opacity(0.7))
                        .textCase(.uppercase)
                    
                    Text(displayTitle)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(titleColor)
                    
                    Spacer()
                    
                    Text("\(entry.events.count) Plan")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(titleColor.opacity(0.08))
                        .cornerRadius(8)
                        .foregroundColor(titleColor)
                }
                .frame(width: 105, alignment: .leading)
                
                Divider().background(titleColor.opacity(0.15))
                
                // Sağ Bölüm: Etkinlik Listesi
                if entry.events.isEmpty {
                    VStack {
                        Spacer()
                        Text("Bugün huzurlu ve serbest 🌿")
                            .font(.system(size: 12.5, weight: .medium, design: .rounded))
                            .foregroundColor(titleColor.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(entry.events.prefix(3)) { event in
                            HStack(spacing: 8) {
                                if let start = event.startTime, !start.isEmpty {
                                    Text(start)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(titleColor.opacity(0.85))
                                        .frame(width: 38, alignment: .leading)
                                }
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: event.colorHex ?? "#A2D2FF"))
                                    .frame(width: 4, height: 24)
                                
                                Text(event.title)
                                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(titleColor)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(14)
            .containerBackground(for: .widget) {
                Color(hex: bgHex).opacity(bgOpacity)
            }

        default:
            Text(displayTitle)
                .containerBackground(for: .widget) {
                    Color(hex: bgHex).opacity(bgOpacity)
                }
        }
    }
    
    private func formattedTodayDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM EEEE"
        return f.string(from: entry.date)
    }
}

// MARK: - Views: Aesthetic Weekly Widget

struct WeeklyWidgetEntryView: View {
    var entry: WeeklyEntry
    @Environment(\.widgetFamily) var family

    private let dayHeaders = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    var body: some View {
        let titleColor = Color(hex: entry.theme?.textColorHex ?? "#4A2B33")
        let bgHex = entry.theme?.backgroundColorHex ?? "#FAF7F2"
        let bgOpacity = entry.theme?.backgroundOpacity ?? 1.0
        
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: entry.date)
        let currentDayIndex = weekday == 1 ? 6 : weekday - 2 // Pzt = 0 .. Paz = 6

        VStack(spacing: 8) {
            // Başlık Çubuğu
            HStack {
                Text(entry.weekLabel)
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(titleColor)
                Spacer()
                Text("Calenda")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(titleColor.opacity(0.4))
            }
            
            // 7 Günlük Tablo
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { idx in
                    let isToday = idx == currentDayIndex
                    let dayKey = String(idx + 1)
                    let dayEvents = entry.weeklyMap[dayKey] ?? []
                    let dayNum = entry.dayNumbers.count > idx ? "\(entry.dayNumbers[idx])" : ""
                    
                    VStack(spacing: 3) {
                        Text(dayHeaders[idx])
                            .font(.system(size: 9.5, weight: isToday ? .bold : .medium, design: .rounded))
                            .foregroundColor(isToday ? titleColor : titleColor.opacity(0.55))
                        
                        if !dayNum.isEmpty {
                            Text(dayNum)
                                .font(.system(size: 10, weight: isToday ? .heavy : .semibold, design: .rounded))
                                .foregroundColor(isToday ? .white : titleColor.opacity(0.8))
                                .frame(width: 18, height: 18)
                                .background(isToday ? titleColor : Color.clear)
                                .clipShape(Circle())
                        }
                        
                        // Etkinlik barları / noktaları
                        VStack(spacing: 2) {
                            ForEach(dayEvents.prefix(3)) { ev in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: ev.colorHex ?? "#A2D2FF"))
                                    .frame(height: 3)
                            }
                        }
                        .frame(maxHeight: 12)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                    .background(isToday ? titleColor.opacity(0.06) : Color.clear)
                    .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(hex: bgHex).opacity(bgOpacity)
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

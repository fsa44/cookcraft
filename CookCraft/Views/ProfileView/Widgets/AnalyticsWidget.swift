

import SwiftUI
import Charts
import Supabase

struct AnalyticsWidget: View {
    // MARK: - Types
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
        var days: Int { self == .week ? 7 : (self == .month ? 30 : 365) }
    }

    enum Metric: String, CaseIterable, Identifiable {
        case calories = "Calories"
        case protein  = "Protein"
        case water    = "Water"
        var id: String { rawValue }
        var unit: String { self == .calories ? "kcal" : (self == .protein ? "g" : "L") }
        var goal: Double {
            switch self { case .calories: 2200; case .protein: 75; case .water: 2.0 }
        }
    }

    struct AnalyticsPoint: Identifiable, Hashable {
        let id = UUID()
        let date: Date
        let calories: Double
        let protein: Double
        let water: Double
        let carbsPct: Double
        let proteinPct: Double
        let fatPct: Double
        func value(for m: Metric) -> Double { m == .calories ? calories : (m == .protein ? protein : water) }
    }

    // MARK: - State
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: Metric = .calories
    @State private var showMovingAverage: Bool = true

    @State private var isLoading: Bool = false
    @State private var serverPoints: [AnalyticsPoint] = []

    // MARK: - Data source
    private var points: [AnalyticsPoint] {
        if !serverPoints.isEmpty { return serverPoints }
        // Fallback to deterministic sample for empty DB or preview
        return Self.sampleData(for: selectedTimeRange)
    }

    private var values: [Double] { points.map { $0.value(for: selectedMetric) } }

    // MARK: - Aggregates
    private var total: Double { values.reduce(0, +) }
    private var average: Double { values.isEmpty ? 0 : total / Double(values.count) }
    private var adherencePct: Int {
        guard !values.isEmpty else { return 0 }
        let g = selectedMetric.goal
        let hits = values.filter { $0 >= g * 0.95 && $0 <= g * 1.05 }.count
        return Int((Double(hits) / Double(values.count) * 100).rounded())
    }
    private var movingAverageSeries: [MovingAveragePoint] {
        let w = selectedTimeRange == .year ? 14 : 7
        return movingAverage(dataPoints: points.map { ($0.date, $0.value(for: selectedMetric)) }, window: w)
    }

    // MARK: - Body (layout preserved)
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Analytics")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding(.top)

            // Controls
            VStack(spacing: 8) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                HStack {
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(Metric.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)

                    Spacer()

                    Toggle("Moving Avg", isOn: $showMovingAverage)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.bottom, 2)

            if points.isEmpty && isLoading {
                loadingState
            } else if points.isEmpty {
                emptyState
            } else {
                // Line Chart + goal + optional MA
                Chart {
                    ForEach(points) { p in
                        LineMark(
                            x: .value("Date", p.date),
                            y: .value(selectedMetric.rawValue, p.value(for: selectedMetric))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green.gradient)

                        if selectedTimeRange == .week {
                            PointMark(
                                x: .value("Date", p.date),
                                y: .value(selectedMetric.rawValue, p.value(for: selectedMetric))
                            )
                            .symbol(Circle())
                            .foregroundStyle(.green)
                        }
                    }

                    if showMovingAverage {
                        ForEach(movingAverageSeries) { p in
                            LineMark(
                                x: .value("Date", p.date),
                                y: .value("MA", p.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(.init(lineWidth: 2, dash: [6, 6]))
                            .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    RuleMark(y: .value("Goal", selectedMetric.goal))
                        .lineStyle(.init(lineWidth: 1.5, dash: [4, 6]))
                        .foregroundStyle(.white.opacity(0.75))
                        .annotation(position: .topLeading, alignment: .leading) {
                            Text("Goal: \(formatValue(selectedMetric.goal)) \(selectedMetric.unit)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                }
                .chartXAxis { xAxisMarks }
                .chartYAxis { yAxisMarks }
                .frame(height: 200)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Summary
                HStack(spacing: 20) {
                    SummaryBox(title: "Total", value: "\(formatTotal(total)) \(selectedMetric.unit)")
                    SummaryBox(title: "Average", value: "\(formatAvg(average)) \(selectedMetric.unit)")
                    SummaryBox(title: "Adherence", value: "\(adherencePct)%")
                }

                // Bars
                if selectedMetric == .calories {
                    Chart {
                        ForEach(points) { p in
                            let carbsVal = p.calories * p.carbsPct / 100.0
                            let protVal  = p.calories * p.proteinPct / 100.0
                            let fatVal   = p.calories * p.fatPct / 100.0

                            BarMark(x: .value("Day", p.date), y: .value("Carbs", carbsVal))
                                .foregroundStyle(.blue.opacity(0.9))
                            BarMark(x: .value("Day", p.date), y: .value("Protein", protVal))
                                .foregroundStyle(.green.opacity(0.9))
                            BarMark(x: .value("Day", p.date), y: .value("Fat", fatVal))
                                .foregroundStyle(.orange.opacity(0.9))
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .chartXAxis { xAxisMarks }
                    .chartYAxis {
                        AxisMarks(position: .leading) { v in
                            AxisGridLine().foregroundStyle(.white.opacity(0.08))
                            AxisTick().foregroundStyle(.white.opacity(0.4))
                            AxisValueLabel {
                                if let n = v.as(Double.self) {
                                    Text("\(Int(n)) kcal").foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                    .frame(height: 150)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Chart {
                        ForEach(points) { p in
                            BarMark(
                                x: .value("Day", p.date),
                                y: .value(selectedMetric.rawValue, p.value(for: selectedMetric))
                            )
                            .foregroundStyle(.teal)
                        }
                        RuleMark(y: .value("Goal", selectedMetric.goal))
                            .lineStyle(.init(lineWidth: 1, dash: [4, 6]))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .chartXAxis { xAxisMarks }
                    .chartYAxis { yAxisMarks }
                    .frame(height: 150)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer()
        }
        .offset(y: -25)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .task { await loadPoints() }
        .onChange(of: selectedTimeRange) { _, _ in Task { await loadPoints() } }
    }
       

    // MARK: - Axes
    private var xAxisMarks: some AxisContent {
        AxisMarks(values: .automatic(desiredCount: selectedTimeRange == .year ? 6 : 7)) { v in
            AxisGridLine().foregroundStyle(.white.opacity(0.08))
            AxisTick().foregroundStyle(.white.opacity(0.4))
            AxisValueLabel {
                if let d = v.as(Date.self) {
                    Text(shortDate(d, range: selectedTimeRange)).foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    private var yAxisMarks: some AxisContent {
        AxisMarks(position: .leading) { v in
            AxisGridLine().foregroundStyle(.white.opacity(0.08))
            AxisTick().foregroundStyle(.white.opacity(0.4))
            AxisValueLabel {
                if let n = v.as(Double.self) {
                    Text(yLabel(n)).foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    // MARK: - States
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            Text("No data yet").foregroundColor(.white).font(.headline)
            Text("Log meals and water to see trends here.")
                .foregroundColor(.white.opacity(0.8)).font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var loadingState: some View {
        HStack(spacing: 10) {
            ProgressView().tint(.white)
            Text("Loading…").foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Live fetch
    private func loadPoints() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let cal = Calendar.current
            let tz = TimeZone.current
            let todayStart = cal.startOfDay(for: Date())
            let start = cal.date(byAdding: .day, value: -(selectedTimeRange.days - 1), to: todayStart) ?? todayStart
            let end = cal.date(byAdding: .day, value: 1, to: todayStart)!  // exclusive bound

            // Encode timestamps as ISO8601 for PostgREST
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let pStart = iso.string(from: start)
            let pEnd   = iso.string(from: end)
            let pTZ    = tz.identifier

            // RPC row payload
            struct DBRow: Decodable {
                let day_local: String       // "YYYY-MM-DD"
                let calories: Double?
                let protein: Double?
                let water: Double?
                let carbs_pct: Double?
                let protein_pct: Double?
                let fat_pct: Double?
            }

            // Call RPC
            let rows: [DBRow] = try await supabase
                .rpc("get_my_nutrition_timeseries", params: [
                    "p_start": pStart,
                    "p_end":   pEnd,
                    "p_tz":    pTZ
                ])
                .execute()
                .value   // this accessor is not throwing

            // Convert "YYYY-MM-DD" to Date at local startOfDay
            var converted: [AnalyticsPoint] = []
            let dayFormatter = DateFormatter()
            dayFormatter.calendar = cal
            dayFormatter.timeZone = tz
            dayFormatter.dateFormat = "yyyy-MM-dd"

            for r in rows {
                guard let day = dayFormatter.date(from: r.day_local) else { continue }
                converted.append(.init(
                    date: day,
                    calories: r.calories ?? 0,
                    protein: r.protein ?? 0,
                    water: r.water ?? 0,
                    carbsPct: r.carbs_pct ?? 50,
                    proteinPct: r.protein_pct ?? 20,
                    fatPct: r.fat_pct ?? 30
                ))
            }

            // Ensure continuous daily series
            serverPoints = fillMissingDays(from: start, toExclusive: end, using: converted)
        } catch {
            print("❌ Analytics fetch failed:", error.localizedDescription)
            serverPoints = []
        }
    }

    // Ensure we have a point for each day in range (for smooth charts)
    private func fillMissingDays(from start: Date, toExclusive end: Date, using rows: [AnalyticsPoint]) -> [AnalyticsPoint] {
        let cal = Calendar.current
        var cursor = start
        let byDate: [Date: AnalyticsPoint] = Dictionary(uniqueKeysWithValues: rows.map { ($0.date, $0) })
        var out: [AnalyticsPoint] = []
        while cursor < end {
            if let p = byDate[cursor] {
                out.append(p)
            } else {
                out.append(.init(
                    date: cursor, calories: 0, protein: 0, water: 0,
                    carbsPct: 0, proteinPct: 0, fatPct: 0
                ))
            }
            cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
        }
        return out.sorted { $0.date < $1.date }
    }

    // MARK: - Formatting / Helpers
    private func formatTotal(_ n: Double) -> String {
        selectedMetric == .water ? NumberFormats.oneDecimal(n) : NumberFormats.compactNoDecimals(n)
    }

    private func formatAvg(_ n: Double) -> String {
        (selectedMetric == .water || selectedMetric == .protein)
        ? NumberFormats.oneDecimal(n)
        : NumberFormats.compactNoDecimals(n)
    }

    private func formatValue(_ n: Double) -> String {
        switch selectedMetric {
        case .calories: return NumberFormats.compactNoDecimals(n)
        case .protein, .water: return NumberFormats.oneDecimal(n)
        }
    }

    private func yLabel(_ n: Double) -> String {
        switch selectedMetric {
        case .calories: return "\(Int(n)) \(selectedMetric.unit)"
        case .protein, .water: return "\(NumberFormats.oneDecimal(n)) \(selectedMetric.unit)"
        }
    }

    private func shortDate(_ d: Date, range: TimeRange) -> String {
        let f = DateFormatter()
        switch range {
        case .week:  f.setLocalizedDateFormatFromTemplate("EE")
        case .month: f.setLocalizedDateFormatFromTemplate("d MMM")
        case .year:  f.setLocalizedDateFormatFromTemplate("MMM")
        }
        return f.string(from: d)
    }

    struct MovingAveragePoint: Identifiable { let id = UUID(); let date: Date; let value: Double }

    /// Simple, efficient moving average that compiles quickly.
    private func movingAverage(dataPoints: [(Date, Double)], window: Int) -> [MovingAveragePoint] {
        guard window > 1, dataPoints.count >= window else { return [] }
        var result: [MovingAveragePoint] = []
        var running: Double = 0
        var queue: [Double] = []
        queue.reserveCapacity(window)

        for (i, item) in dataPoints.enumerated() {
            running += item.1
            queue.append(item.1)
            if queue.count > window {
                running -= queue.removeFirst()
            }
            if i >= window - 1 {
                result.append(.init(date: item.0, value: running / Double(window)))
            }
        }
        return result
    }
}

// MARK: - Sample Data fallback (deterministic; replace with real store later)
extension AnalyticsWidget {
    static func sampleData(for range: TimeRange) -> [AnalyticsWidget.AnalyticsPoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let count = range.days
        var rng = SeededGenerator(seed: UInt64(today.timeIntervalSince1970) ^ UInt64(count))

        return (0..<count).compactMap { i in
            guard let day = cal.date(byAdding: .day, value: -i, to: today) else { return nil }
            let isWeekend = cal.isDateInWeekend(day)

            // Calories: 1800–2600 with weekend bumps + noise
            let baseCal = Double(Int.random(in: isWeekend ? 2100...2600 : 1800...2400, using: &rng))
            let calories = max(1200, baseCal + Double(Int.random(in: -150...150, using: &rng))).rounded()

            // Protein: approx calories/30 ± jitter
            let protein = max(30, (calories / 30.0) + Double(Int.random(in: -10...10, using: &rng))).rounded()

            // Water: 1.2–3.0 L with soft seasonality/noise
            let seasonal = sin(Double(i) / 6.0) * 0.3
            let water = max(0.8, 1.8 + seasonal + Double.random(in: -0.4...0.5, using: &rng))
            let waterRounded = (water * 10).rounded() / 10.0

            // Macro split ~100%
            let carbs = Double.random(in: 45...60, using: &rng)
            let proteinPct = Double.random(in: 15...25, using: &rng)
            let fat = max(20, 100 - carbs - proteinPct)

            return AnalyticsWidget.AnalyticsPoint(
                date: day,
                calories: calories,
                protein: protein,
                water: waterRounded,
                carbsPct: carbs,
                proteinPct: proteinPct,
                fatPct: fat
            )
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - Summary Box
struct SummaryBox: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.white.opacity(0.7))
            Text(value).font(.title2.bold()).foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Utilities
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
enum NumberFormats {
    static func oneDecimal(_ value: Double) -> String {
        let f = NumberFormatter(); f.minimumFractionDigits = 1; f.maximumFractionDigits = 1
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }
    static func compactNoDecimals(_ value: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0; f.usesGroupingSeparator = true
        return f.string(from: NSNumber(value: value)) ?? String(Int(value.rounded()))
    }
}

// MARK: - Preview
#Preview {
    AnalyticsWidget()
        .preferredColorScheme(.dark)
}

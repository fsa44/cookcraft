//
//  AnalyticsWidget.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 20/10/2025.
//

import SwiftUI
import Charts

struct AnalyticsWidget: View {
    // MARK: - Types
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var id: String { self.rawValue }
        var days: Int {
            switch self {
            case .week: 7
            case .month: 30
            case .year: 365
            }
        }
    }

    enum Metric: String, CaseIterable, Identifiable {
        case calories = "Calories"
        case protein  = "Protein"
        case water    = "Water"

        var id: String { rawValue }
        var unit: String {
            switch self {
            case .calories: return "kcal"
            case .protein:  return "g"
            case .water:    return "L"
            }
        }
        /// Default goals (inject user-specific goals from your store later)
        var goal: Double {
            switch self {
            case .calories: return 2200
            case .protein:  return 75
            case .water:    return 2.0
            }
        }
    }

    struct AnalyticsPoint: Identifiable {
        let id = UUID()
        let date: Date
        let calories: Double
        let protein: Double
        let water: Double
        // For stacked macro bars (percentages ~100)
        let carbsPct: Double
        let proteinPct: Double
        let fatPct: Double

        func value(for metric: Metric) -> Double {
            switch metric {
            case .calories: return calories
            case .protein:  return protein
            case .water:    return water
            }
        }
    }

    // MARK: - State
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: Metric = .calories
    @State private var showMovingAverage: Bool = true

    // MARK: - Data Source (deterministic, crash-safe)
    private var points: [AnalyticsPoint] {
        AnalyticsWidget.sampleData(for: selectedTimeRange)
    }

    private var values: [Double] { points.map { $0.value(for: selectedMetric) } }

    // MARK: - Aggregates
    private var total: Double { values.reduce(0, +) }

    private var average: Double {
        guard !values.isEmpty else { return 0 }
        return total / Double(values.count)
    }

    /// % of days within ±5% of goal
    private var adherencePct: Int {
        guard !values.isEmpty else { return 0 }
        let g = selectedMetric.goal
        let count = values.filter { $0 >= g * 0.95 && $0 <= g * 1.05 }.count
        return Int(round(100 * Double(count) / Double(values.count)))
    }

    private var movingAverageSeries: [MovingAveragePoint] {
        let window = (selectedTimeRange == .year) ? 14 : 7
        return movingAverage(dataPoints: points.map { ($0.date, $0.value(for: selectedMetric)) }, window: window)
    }

    // MARK: - Body (layout preserved)
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Analytics")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding(.top)

            // Controls (kept near picker; minimal UI change)
            VStack(spacing: 8) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(Metric.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)

                    Spacer()

                    Toggle("Moving Avg", isOn: $showMovingAverage)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .foregroundColor(.white.opacity(0.9))
                        .accessibilityLabel("Toggle moving average")
                }
            }
            .padding(.bottom, 2)

            if points.isEmpty {
                emptyState
            } else {
                // Line Chart with goal rule & optional MA
                Chart {
                    ForEach(points) { p in
                        LineMark(
                            x: .value("Date", p.date),
                            y: .value(selectedMetric.rawValue, p.value(for: selectedMetric))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.green.gradient)

                        // Show points only for week to reduce clutter
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
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: selectedTimeRange == .year ? 6 : 7)) { v in
                        AxisGridLine().foregroundStyle(.white.opacity(0.08))
                        AxisTick().foregroundStyle(.white.opacity(0.4))
                        AxisValueLabel {
                            if let d = v.as(Date.self) {
                                Text(shortDate(d, range: selectedTimeRange))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { v in
                        AxisGridLine().foregroundStyle(.white.opacity(0.08))
                        AxisTick().foregroundStyle(.white.opacity(0.4))
                        AxisValueLabel {
                            if let n = v.as(Double.self) {
                                Text(yLabel(n))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                    }
                }
                .frame(height: 200)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Summary Stats (cleaner)
                HStack(spacing: 20) {
                    SummaryBox(
                        title: "Total",
                        value: "\(formatTotal(total)) \(selectedMetric.unit)"
                    )
                    SummaryBox(
                        title: "Average",
                        value: "\(formatAvg(average)) \(selectedMetric.unit)"
                    )
                    SummaryBox(
                        title: "Adherence",
                        value: "\(adherencePct)%"
                    )
                }

                // Bar Chart
                if selectedMetric == .calories {
                    // Stacked macro bars when viewing calories
                    Chart {
                        ForEach(points) { p in
                            BarMark(
                                x: .value("Day", p.date),
                                y: .value("Carbs", p.calories * p.carbsPct / 100.0)
                            )
                            .foregroundStyle(.blue.opacity(0.9))

                            BarMark(
                                x: .value("Day", p.date),
                                y: .value("Protein", p.calories * p.proteinPct / 100.0)
                            )
                            .foregroundStyle(.green.opacity(0.9))

                            BarMark(
                                x: .value("Day", p.date),
                                y: .value("Fat", p.calories * p.fatPct / 100.0)
                            )
                            .foregroundStyle(.orange.opacity(0.9))
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: selectedTimeRange == .year ? 6 : 7)) { v in
                            AxisGridLine().foregroundStyle(.white.opacity(0.08))
                            AxisTick().foregroundStyle(.white.opacity(0.4))
                            AxisValueLabel {
                                if let d = v.as(Date.self) {
                                    Text(shortDate(d, range: selectedTimeRange))
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { v in
                            AxisGridLine().foregroundStyle(.white.opacity(0.08))
                            AxisTick().foregroundStyle(.white.opacity(0.4))
                            AxisValueLabel {
                                if let n = v.as(Double.self) {
                                    Text("\(Int(n)) kcal")
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                    .frame(height: 150)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Simple bar when Protein/Water
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
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: selectedTimeRange == .year ? 6 : 7)) { v in
                            AxisGridLine().foregroundStyle(.white.opacity(0.08))
                            AxisTick().foregroundStyle(.white.opacity(0.4))
                            AxisValueLabel {
                                if let d = v.as(Date.self) {
                                    Text(shortDate(d, range: selectedTimeRange))
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { v in
                            AxisGridLine().foregroundStyle(.white.opacity(0.08))
                            AxisTick().foregroundStyle(.white.opacity(0.4))
                            AxisValueLabel {
                                if let n = v.as(Double.self) {
                                    Text(yLabel(n))
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                    .frame(height: 150)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            Text("No data yet")
                .foregroundColor(.white)
                .font(.headline)
            Text("Log meals and water to see trends here.")
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Formatting / Helpers
    private func formatTotal(_ n: Double) -> String {
        if selectedMetric == .calories { return NumberFormats.compactNoDecimals(n) }
        if selectedMetric == .water { return NumberFormats.oneDecimal(n) }
        return NumberFormats.compactNoDecimals(n)
    }

    private func formatAvg(_ n: Double) -> String {
        if selectedMetric == .water { return NumberFormats.oneDecimal(n) }
        if selectedMetric == .protein { return NumberFormats.oneDecimal(n) }
        return NumberFormats.compactNoDecimals(n)
    }

    private func yLabel(_ n: Double) -> String {
        switch selectedMetric {
        case .calories: return "\(Int(n)) \(selectedMetric.unit)"
        case .protein:  return "\(NumberFormats.oneDecimal(n)) \(selectedMetric.unit)"
        case .water:    return "\(NumberFormats.oneDecimal(n)) \(selectedMetric.unit)"
        }
    }

    private func formatValue(_ n: Double) -> String {
        switch selectedMetric {
        case .calories: return NumberFormats.compactNoDecimals(n)
        case .protein:  return NumberFormats.oneDecimal(n)
        case .water:    return NumberFormats.oneDecimal(n)
        }
    }

    private func shortDate(_ d: Date, range: TimeRange) -> String {
        let f = DateFormatter()
        switch range {
        case .week:  f.setLocalizedDateFormatFromTemplate("EE")     // Mon
        case .month: f.setLocalizedDateFormatFromTemplate("d MMM")  // 5 Oct
        case .year:  f.setLocalizedDateFormatFromTemplate("MMM")    // Oct
        }
        return f.string(from: d)
    }

    struct MovingAveragePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    private func movingAverage(dataPoints: [(Date, Double)], window: Int) -> [MovingAveragePoint] {
        guard window > 1, dataPoints.count >= window else { return [] }
        var result: [MovingAveragePoint] = []
        var sum: Double = 0
        var q: [Double] = []

        for (i, item) in dataPoints.enumerated() {
            sum += item.1
            q.append(item.1)
            if i >= window { sum -= q.removeFirst() }
            if i >= window - 1 {
                result.append(.init(date: item.0, value: sum / Double(window)))
            }
        }
        return result
    }
}

// MARK: - Sample Data (deterministic; replace with real store later)
extension AnalyticsWidget {
    static func sampleData(for range: TimeRange) -> [AnalyticsWidget.AnalyticsPoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let count = range.days
        var rng = SeededGenerator(seed: UInt64(today.timeIntervalSince1970) ^ UInt64(count))

        return (0..<count).compactMap { i -> AnalyticsWidget.AnalyticsPoint? in
            guard let day = cal.date(byAdding: .day, value: -i, to: today) else { return nil }
            let isWeekend = cal.isDateInWeekend(day)

            // Calories: 1800-2600 with weekend bumps + noise
            let baseCal = Double(Int.random(in: isWeekend ? 2100...2600 : 1800...2400, using: &rng))
            let calories = max(1200, baseCal + Double(Int.random(in: -150...150, using: &rng))).rounded()

            // Protein: correlated to calories (approx calories/30) ± jitter
            let protein = max(30, (calories / 30.0) + Double(Int.random(in: -10...10, using: &rng))).rounded()

            // Water: 1.2L–3.0L with soft seasonality
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

// MARK: - Summary Box (unchanged look)
struct SummaryBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}



struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed &* 0x9E3779B97F4A7C15 }
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
        let f = NumberFormatter()
        f.minimumFractionDigits = 1
        f.maximumFractionDigits = 1
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }
    static func compactNoDecimals(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.usesGroupingSeparator = true
        return f.string(from: NSNumber(value: value)) ?? String(Int(value.rounded()))
    }
}

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

// MARK: - Preview
#Preview {
    AnalyticsWidget()
        .preferredColorScheme(.dark)
}

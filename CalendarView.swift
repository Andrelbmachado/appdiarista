//
//  CalendarView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedRange: ClosedRange<Date>?
    @State private var anchorDate: Date?
    @State private var monthOffset: Int
    private let calendar = Calendar.current
    private let today: Date
    private let baseMonth: Date
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let maxFutureOffset = 12
    var onSelectionComplete: ((ClosedRange<Date>) -> Void)? = nil

    init(selectedRange: Binding<ClosedRange<Date>?>, onSelectionComplete: ((ClosedRange<Date>) -> Void)? = nil) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self._selectedRange = selectedRange
        self._anchorDate = State(initialValue: nil)
        self.today = today
        self.baseMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        if let lower = selectedRange.wrappedValue?.lowerBound {
            let monthsBetween = calendar.dateComponents([.month], from: self.baseMonth, to: lower).month ?? 0
            self._monthOffset = State(initialValue: min(max(monthsBetween, 0), maxFutureOffset))
        } else {
            self._monthOffset = State(initialValue: 0)
        }
        self.onSelectionComplete = onSelectionComplete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            weekdayRow
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(daysInCurrentMonth.enumerated()), id: \.offset) { _, date in
                    dayCell(for: date)
                        .frame(height: 44)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(20)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selecione o período")
                    .font(.headline)
                Spacer()
                if selectedRange != nil {
                    Button("Limpar datas") {
                        selectedRange = nil
                        anchorDate = nil
                    }
                    .font(.footnote)
                }
            }
            HStack(spacing: 16) {
                Button {
                    withAnimation { monthOffset = max(monthOffset - 1, 0) }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.semibold))
                }
                .disabled(monthOffset == 0)
                Text(monthTitle(for: currentMonthStart))
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                Button {
                    withAnimation { monthOffset = min(monthOffset + 1, maxFutureOffset) }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2.weight(.semibold))
                }
                .disabled(monthOffset == maxFutureOffset)
            }
            Text(selectionDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var weekdayRow: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for date: Date?) -> some View {
        Group {
            if let date {
                let disabled = date < today
                Button {
                    guard !disabled else { return }
                    handleSelection(for: date)
                } label: {
                    ZStack {
                        rangeBackground(for: date)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.body.weight(.semibold))
                            .foregroundColor(foreground(for: date, disabled: disabled))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .buttonStyle(.plain)
                .disabled(disabled)
            } else {
                Color.clear
            }
        }
    }

    private func handleSelection(for date: Date) {
        let day = calendar.startOfDay(for: date)
        if let anchor = anchorDate {
            let lower = min(anchor, day)
            let upper = max(anchor, day)
            let range = lower...upper
            selectedRange = range
            anchorDate = nil
            onSelectionComplete?(range)
        } else {
            selectedRange = day...day
            anchorDate = day
        }
    }

    private func selectionState(for date: Date) -> SelectionState {
        guard let range = selectedRange else { return .none }
        let lower = calendar.startOfDay(for: range.lowerBound)
        let upper = calendar.startOfDay(for: range.upperBound)
        if date < lower || date > upper { return .none }
        if lower == upper { return .single }
        if date == lower { return .start }
        if date == upper { return .end }
        return .middle
    }

    @ViewBuilder
    private func rangeBackground(for date: Date) -> some View {
        let state = selectionState(for: date)
        let highlight = Color.blue
        switch state {
        case .none:
            Color.clear
        case .middle:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(highlight.opacity(0.15))
        case .start, .end, .single:
            Circle()
                .fill(highlight)
                .padding(4)
        }
    }

    private func foreground(for date: Date, disabled: Bool) -> Color {
        if disabled {
            return .secondary
        }
        switch selectionState(for: date) {
        case .start, .end, .single:
            return .white
        default:
            return .primary
        }
    }

    private var selectionDescription: String {
        guard let range = selectedRange else {
            return "Escolha o dia de início e o dia final da faxina."
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Período: \(formatter.string(from: range.lowerBound)) – \(formatter.string(from: range.upperBound))"
    }

    private var weekdaySymbols: [String] {
        var symbols = calendar.shortStandaloneWeekdaySymbols
        if let first = symbols.first {
            symbols.removeFirst()
            symbols.append(first)
        }
        return symbols
    }

    private var daysInCurrentMonth: [Date?] {
        let monthStart = currentMonthStart
        let daysRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<1
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingSpaces = (firstWeekday + 5) % 7
        var cells: [Date?] = Array(repeating: nil, count: leadingSpaces)
        for day in daysRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                cells.append(date)
            }
        }
        return cells
    }

    private var currentMonthStart: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: baseMonth) ?? baseMonth
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.12) : UIColor.systemGray6
        })
        #endif
    }
}

private enum SelectionState {
    case none
    case single
    case start
    case end
    case middle
}

#Preview {
    CalendarView(selectedRange: .constant(Date()...Date().addingTimeInterval(86400 * 4)))
}

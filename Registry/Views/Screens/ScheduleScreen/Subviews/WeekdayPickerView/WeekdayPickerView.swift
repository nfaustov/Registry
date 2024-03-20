//
//  WeekdayPickerView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct WeekdayPickerView: View {
    // MARK: - Dependencies

    @Binding var currentDate: Date

    // MARK: - State

    @State private var weekSlider: [[WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false

    // MARK: -

    var body: some View {
        VStack(spacing: 0) {
            DateText(currentDate, format: .month)
                .font(.title)
                .fontWeight(.medium)

            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    weekView(weekSlider[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 52)
            .onAppear {
                if weekSlider.isEmpty {
                    let previousWeek = week(for: currentDate.addingTimeInterval(-604_800))
                    weekSlider.append(previousWeek)
                    let currentWeek = week(for: currentDate)
                    weekSlider.append(currentWeek)
                    let nextWeek = week(for: currentDate.addingTimeInterval(604_800))
                    weekSlider.append(nextWeek)
                }
            }
            .onChange(of: currentWeekIndex) { _, newValue in
                if newValue == 0 || newValue == weekSlider.count - 1 {
                    createWeek = true
                }
            }
        }
    }
}

#Preview {
    WeekdayPickerView(currentDate: .constant(.now))
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension WeekdayPickerView {
    func weekView(_ week: [WeekDay]) -> some View {
        HStack {
            ForEach(week) { day in
                Text(day.label)
                    .fontWeight(.medium)
                    .padding()
                    .foregroundColor(
                        day.isToday ? .orange : day.isSameDayAs(currentDate) ? .white : .primary
                    )
                    .background(
                        day.isSameDayAs(currentDate) ? Color("appBlack") : .clear,
                        in: Capsule(style: .continuous)
                    )
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.12)) {
                            currentDate = day.date
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX

                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        if value.rounded() == 0 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
}

// MARK: - Calculations

private extension WeekdayPickerView {
    func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if currentWeekIndex == 0 {
                guard let firstDay = weekSlider[currentWeekIndex].first?.date else { return }
                let previousWeek = week(for: firstDay.addingTimeInterval(-86_400))
                weekSlider.insert(previousWeek, at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
                withAnimation(.linear(duration: 0.15)) {
                    currentDate.addTimeInterval(-604_800)
                }
                
            }
            if currentWeekIndex == weekSlider.count - 1 {
                guard let lastDay = weekSlider[currentWeekIndex].last?.date else { return }
                let nextWeek = week(for: lastDay.addingTimeInterval(86_400))
                weekSlider.append(nextWeek)
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
                withAnimation(.linear(duration: 0.15)) {
                    currentDate.addTimeInterval(604_800)
                }
            }
        }
    }

    func week(for date: Date) -> [WeekDay] {
        let calendar = Calendar(identifier: .iso8601)

        var week = [WeekDay]()

        guard let firstWeekDay = calendar.dateInterval(of: .weekOfMonth, for: date)?.start else {
            return []
        }

        for index in 0..<7 {
            if let weekDay = calendar.date(byAdding: .day, value: index, to: firstWeekDay) {
                week.append(WeekDay(date: weekDay))
            }
        }

        return week
    }
}

// MARK: - WeekDay

private extension WeekdayPickerView {
    struct WeekDay: Identifiable {
        var id: UUID = UUID()
        var date: Date

        var label: String {
            DateFormatter.shared.dateFormat = "EE, dd"
            return DateFormatter.shared.string(from: date)
        }

        var isToday: Bool {
            Calendar.current.isDate(date, inSameDayAs: .now)
        }

        func isSameDayAs(_ date: Date) -> Bool {
            Calendar.current.isDate(self.date, inSameDayAs: date)
        }
    }
}


//
//  ScheduleView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//

// Make Adjustments
//  ScheduleView.swift


import SwiftUI

struct ScheduleView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    ForEach(scheduleSections, id: \.title) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 4)

                            ForEach(section.items, id: \.self) { item in
                                GlassTileView(
                                    icon: item.icon,
                                    title: item.title,
                                    subtitle: item.time
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack (spacing: 10){
                    Spacer(minLength: 50) // Space above "Account"
                    Text("Schedule")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 40) // Space below "Account"
                }
            }
        }
    }
}

// MARK: - Schedule Data Model

struct ScheduleItem: Hashable {
    let icon: String
    let title: String
    let time: String
}

struct ScheduleSection: Hashable {
    let title: String
    let items: [ScheduleItem]
}

// MARK: - Sample Data

let scheduleSections: [ScheduleSection] = [
    ScheduleSection(title: "Today", items: [
        ScheduleItem(icon: "sun.max.fill", title: "Morning Workout", time: "8:00 AM"),
        ScheduleItem(icon: "video.fill", title: "Team Stand-up", time: "10:00 AM"),
        ScheduleItem(icon: "leaf.fill", title: "Lunch Break", time: "12:30 PM")
    ]),
    ScheduleSection(title: "Tomorrow", items: [
        ScheduleItem(icon: "calendar", title: "Project Review", time: "9:00 AM"),
        ScheduleItem(icon: "dumbbell.fill", title: "Yoga Class", time: "6:00 PM")
    ])
]

// MARK: - Preview

#Preview {
    NavigationStack {
        ScheduleView()
    }
}

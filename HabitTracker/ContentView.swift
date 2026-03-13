import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "checkmark.circle")
            }

            NavigationStack {
                HabitsView()
            }
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(AppColors.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore())
}

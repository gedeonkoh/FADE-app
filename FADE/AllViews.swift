// AllViews.swift - Remaining views for FADE
import SwiftUI

// MARK: - TasksView
struct TasksView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddTask = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tasks")
                    .font(FadeFont.display(30))
                    .foregroundColor(FadeColors.textPrimary)
                    .padding(.top, 60)
                ForEach(store.tasks) { task in
                    HStack {
                        Button { store.toggleTask(task) } {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? FadeColors.success : FadeColors.textTertiary)
                        }
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                        Spacer()
                    }
                    .padding()
                    .glassCard()
                }
                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - JournalView
struct JournalView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack {
                Text("Journal")
                    .font(FadeFont.display(30))
                    .padding(.top, 60)
                Text("Reflect on your day")
                    .font(FadeFont.body())
                    .foregroundColor(FadeColors.textSecondary)
                Spacer(minLength: 120)
            }
        }
    }
}

// MARK: - StatsView
struct StatsView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack {
                Text("Stats")
                    .font(FadeFont.display(30))
                    .padding(.top, 60)
                Text("\(Int(store.totalFocusHours))h focus")
                Spacer(minLength: 120)
            }
        }
    }
}

// MARK: - OnboardingView
struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var name = ""
    var body: some View {
        ZStack {
            FadeBackground()
            VStack(spacing: 30) {
                Text("FΛDE")
                    .font(FadeFont.display(48))
                    .foregroundColor(FadeColors.accent)
                Text("Focus. Achieve. Dominate. Excel.")
                    .font(FadeFont.headline())
                TextField("Your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                AccentButton(title: "Let's Go", icon: "arrow.right") {
                    store.completeOnboarding(name: name)
                }
            }
        }
    }
}

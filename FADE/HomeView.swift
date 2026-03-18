// HomeView.swift
// FADE — Dashboard home screen

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var appear = false
    @State private var greetingIndex = 0
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = store.userName.isEmpty ? "" : ", \(store.userName)"
        switch hour {
        case 5..<12: return "Good morning\(name)."
        case 12..<17: return "Good afternoon\(name)."
        case 17..<21: return "Good evening\(name)."
        default: return "Burning the midnight oil\(name)."
        }
    }
    
    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                HeaderSection(greeting: greeting, dateString: dateString)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                
                // Today's score card
                TodayScoreCard()
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appear)
                
                // Quick stats row
                QuickStatsRow()
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: appear)
                
                // Upcoming tasks
                UpcomingTasksSection()
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appear)
                
                // Daily quote
                QuoteCard()
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: appear)
                
                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

// MARK: - Header
struct HeaderSection: View {
    let greeting: String
    let dateString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FΛDE")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(FadeColors.accent)
                        .kerning(4)
                    Text(greeting)
                        .font(FadeFont.display(30))
                        .foregroundColor(FadeColors.textPrimary)
                        .lineLimit(2)
                }
                Spacer()
                // Streak badge
                StreakBadge()
            }
            Text(dateString)
                .font(FadeFont.caption())
                .foregroundColor(FadeColors.textTertiary)
        }
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    @EnvironmentObject var store: AppStore
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text("🔥")
                .font(.system(size: 22))
                .scaleEffect(pulse ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            Text("\(store.currentStreak)d")
                .font(FadeFont.mono(14))
                .foregroundColor(FadeColors.warning)
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
        .onAppear { pulse = true }
    }
}

// MARK: - Today Score Card
struct TodayScoreCard: View {
    @EnvironmentObject var store: AppStore
    
    private var todayScore: DailyScore {
        let today = Calendar.current.startOfDay(for: Date())
        return store.dailyScores.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        } ?? DailyScore()
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Score ring
            ZStack {
                ProgressRing(
                    progress: Double(todayScore.score) / 100,
                    size: 90,
                    lineWidth: 8,
                    color: FadeColors.accent
                )
                VStack(spacing: 0) {
                    Text(todayScore.grade)
                        .font(FadeFont.display(30))
                        .foregroundColor(FadeColors.textPrimary)
                    Text("\(todayScore.score)")
                        .font(FadeFont.caption(11))
                        .foregroundColor(FadeColors.textTertiary)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Score")
                    .font(FadeFont.headline())
                    .foregroundColor(FadeColors.textPrimary)
                
                VStack(alignment: .leading, spacing: 6) {
                    MiniStat(icon: "timer", label: "\(store.totalFocusMinutesToday)m focus", color: FadeColors.accent)
                    MiniStat(icon: "checkmark.circle.fill", label: "\(store.completedTasksToday) tasks", color: FadeColors.success)
                    MiniStat(
                        icon: "book.closed.fill",
                        label: store.todayEntry != nil ? "Journal done" : "No entry yet",
                        color: store.todayEntry != nil ? FadeColors.accentTertiary : FadeColors.textTertiary
                    )
                }
            }
            Spacer()
        }
        .padding(20)
        .glassCard(cornerRadius: 22)
    }
}

struct MiniStat: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(FadeFont.caption())
                .foregroundColor(FadeColors.textSecondary)
        }
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                value: String(format: "%.1f", store.totalFocusHours),
                label: "Focus hrs",
                icon: "bolt.fill",
                color: FadeColors.accent
            )
            QuickStatCard(
                value: "\(store.totalTasksCompleted)",
                label: "Completed",
                icon: "checkmark.seal.fill",
                color: FadeColors.success
            )
            QuickStatCard(
                value: "\(store.currentStreak)",
                label: "Day streak",
                icon: "flame.fill",
                color: FadeColors.warning
            )
        }
    }
}

struct QuickStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(FadeFont.display(22))
                    .foregroundColor(FadeColors.textPrimary)
                Text(label)
                    .font(FadeFont.caption(10))
                    .foregroundColor(FadeColors.textTertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 16)
    }
}

// MARK: - Upcoming Tasks
struct UpcomingTasksSection: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Up next", subtitle: "\(store.pendingTasks.count) pending")
            
            if store.pendingTasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(FadeColors.success)
                        Text("All clear. You crushed it.")
                            .font(FadeFont.body())
                            .foregroundColor(FadeColors.textSecondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .glassCard(cornerRadius: 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.pendingTasks.prefix(3)) { task in
                        HomeTaskRow(task: task)
                    }
                }
            }
        }
    }
}

struct HomeTaskRow: View {
    @EnvironmentObject var store: AppStore
    let task: FadeTask
    
    var body: some View {
        HStack(spacing: 14) {
            // Priority indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(task.priority.color)
                .frame(width: 4, height: 36)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(FadeFont.headline(15))
                    .foregroundColor(FadeColors.textPrimary)
                    .lineLimit(1)
                PillTag(text: task.category.rawValue, color: task.category.color)
            }
            Spacer()
            Button(action: { store.toggleTask(task) }) {
                Image(systemName: "circle")
                    .font(.system(size: 22))
                    .foregroundColor(FadeColors.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14)
    }
}

// MARK: - Quote Card
struct QuoteCard: View {
    private let quotes = [
        ("The secret of getting ahead is getting started.", "Mark Twain"),
        ("Do one thing every day that scares you.", "Eleanor Roosevelt"),
        ("It's not about ideas. It's about making ideas happen.", "Scott Belsky"),
        ("Don't watch the clock. Do what it does. Keep going.", "Sam Levenson"),
        ("The harder you work, the luckier you get.", "Gary Player"),
        ("Focus on being productive instead of busy.", "Tim Ferriss"),
    ]
    
    private var todayQuote: (String, String) {
        let index = Calendar.current.component(.day, from: Date()) % quotes.count
        return quotes[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(FadeColors.accent.opacity(0.6))
            
            Text(todayQuote.0)
                .font(FadeFont.title(17))
                .foregroundColor(FadeColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("— " + todayQuote.1)
                .font(FadeFont.caption())
                .foregroundColor(FadeColors.textTertiary)
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
        .overlay(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [FadeColors.accent.opacity(0.25), FadeColors.accentSecondary.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 80, height: 80)
            .blur(radius: 30)
            .offset(x: 10, y: 10)
        }
    }
}

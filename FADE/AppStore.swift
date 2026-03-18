// AppStore.swift
// FADE — Central state management

import SwiftUI
import Combine

class AppStore: ObservableObject {
    
    // MARK: - Persistence Keys
    private let tasksKey = "fade_tasks"
    private let sessionsKey = "fade_sessions"
    private let journalKey = "fade_journal"
    private let scoresKey = "fade_scores"
    private let onboardingKey = "fade_onboarding_done"
    private let streakKey = "fade_streak"
    private let lastOpenKey = "fade_last_open"
    
    // MARK: - Published State
    @Published var tasks: [FadeTask] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var dailyScores: [DailyScore] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentStreak: Int = 0
    @Published var userName: String = ""
    
    // Focus timer state
    @Published var isFocusing: Bool = false
    @Published var focusTimeRemaining: TimeInterval = 25 * 60
    @Published var focusTotalTime: TimeInterval = 25 * 60
    @Published var selectedFocusMode: FocusMode = .deep
    @Published var focusSessionsToday: Int = 0
    
    private var timer: AnyCancellable?
    private var focusStartTime: Date?
    
    init() {
        loadAll()
        updateStreak()
    }
    
    // MARK: - Persistence
    private func loadAll() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        userName = UserDefaults.standard.string(forKey: "fade_username") ?? ""
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([FadeTask].self, from: data) {
            tasks = decoded
        } else {
            tasks = sampleTasks()
        }
        
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            focusSessions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: journalKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: scoresKey),
           let decoded = try? JSONDecoder().decode([DailyScore].self, from: data) {
            dailyScores = decoded
        }
        
        focusSessionsToday = focusSessions.filter {
            Calendar.current.isDateInToday($0.completedAt)
        }.count
    }
    
    private func saveAll() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
        if let data = try? JSONEncoder().encode(focusSessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: journalKey)
        }
        if let data = try? JSONEncoder().encode(dailyScores) {
            UserDefaults.standard.set(data, forKey: scoresKey)
        }
    }
    
    // MARK: - Onboarding
    func completeOnboarding(name: String) {
        userName = name
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        UserDefaults.standard.set(name, forKey: "fade_username")
    }
    
    // MARK: - Tasks
    func addTask(_ task: FadeTask) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            tasks.insert(task, at: 0)
        }
        saveAll()
        updateDailyScore()
    }
    
    func toggleTask(_ task: FadeTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                tasks[index].completedAt = nil
            }
            saveAll()
            updateDailyScore()
        }
    }
    
    func deleteTask(_ task: FadeTask) {
        withAnimation {
            tasks.removeAll { $0.id == task.id }
        }
        saveAll()
    }
    
    var pendingTasks: [FadeTask] {
        tasks.filter { !$0.isCompleted }.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    var completedTasksToday: Int {
        tasks.filter { $0.isCompleted && $0.completedAt.map { Calendar.current.isDateInToday($0) } ?? false }.count
    }
    
    // MARK: - Focus Timer
    func startFocus() {
        isFocusing = true
        focusTotalTime = selectedFocusMode.defaultDuration
        focusTimeRemaining = focusTotalTime
        focusStartTime = Date()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.focusTimeRemaining > 0 {
                    self.focusTimeRemaining -= 1
                } else {
                    self.completeFocus()
                }
            }
    }
    
    func pauseFocus() {
        timer?.cancel()
        isFocusing = false
    }
    
    func completeFocus() {
        timer?.cancel()
        isFocusing = false
        
        let duration = focusTotalTime - focusTimeRemaining
        let session = FocusSession(
            duration: max(duration, 60),
            mode: selectedFocusMode
        )
        focusSessions.append(session)
        focusSessionsToday += 1
        focusTimeRemaining = selectedFocusMode.defaultDuration
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        saveAll()
        updateDailyScore()
    }
    
    var focusProgress: Double {
        guard focusTotalTime > 0 else { return 0 }
        return 1 - (focusTimeRemaining / focusTotalTime)
    }
    
    var focusTimeString: String {
        let mins = Int(focusTimeRemaining) / 60
        let secs = Int(focusTimeRemaining) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var totalFocusMinutesToday: Int {
        let sessions = focusSessions.filter { Calendar.current.isDateInToday($0.completedAt) }
        return Int(sessions.reduce(0) { $0 + $1.duration }) / 60
    }
    
    // MARK: - Journal
    var todayEntry: JournalEntry? {
        journalEntries.first { $0.isToday }
    }
    
    func saveJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.isToday }) {
            journalEntries[index] = entry
        } else {
            journalEntries.insert(entry, at: 0)
        }
        saveAll()
        updateDailyScore()
    }
    
    // MARK: - Streak & Scoring
    func updateStreak() {
        let lastOpen = UserDefaults.standard.object(forKey: lastOpenKey) as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        if let last = lastOpen {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                currentStreak += 1
            } else if diff > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        UserDefaults.standard.set(Date(), forKey: lastOpenKey)
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
    }
    
    private func updateDailyScore() {
        let today = Calendar.current.startOfDay(for: Date())
        let score = DailyScore(
            date: today,
            focusMinutes: totalFocusMinutesToday,
            tasksCompleted: completedTasksToday,
            journalWritten: todayEntry != nil
        )
        if let index = dailyScores.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            dailyScores[index] = score
        } else {
            dailyScores.append(score)
        }
        saveAll()
    }
    
    var weeklyScores: [DailyScore] {
        let cal = Calendar.current
        return (0..<7).compactMap { offset -> DailyScore? in
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let day = cal.startOfDay(for: date)
            return dailyScores.first { cal.isDate($0.date, inSameDayAs: day) }
                ?? DailyScore(date: day)
        }.reversed()
    }
    
    var totalFocusHours: Double {
        Double(focusSessions.reduce(0) { $0 + Int($1.duration) }) / 3600
    }
    
    var totalTasksCompleted: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var longestStreak: Int {
        max(currentStreak, UserDefaults.standard.integer(forKey: "fade_longest_streak"))
    }
    
    // MARK: - Sample Data
    private func sampleTasks() -> [FadeTask] {
        [
            FadeTask(title: "Review electronics project notes", priority: .high, category: .study),
            FadeTask(title: "Complete triboelectric tile write-up", priority: .urgent, category: .work),
            FadeTask(title: "Prep 3D modeling workshop slides", priority: .medium, category: .creative),
            FadeTask(title: "Morning run — 5km", priority: .low, category: .health),
            FadeTask(title: "Read chapter 4: Signal Processing", priority: .medium, category: .study),
        ]
    }
}

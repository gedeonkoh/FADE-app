// Models.swift
// FADE — Data models

import SwiftUI
import Foundation

// MARK: - Task Model
struct FadeTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        category: TaskCategory = .personal,
        dueDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.completedAt = nil
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low: return FadeColors.accentTertiary
        case .medium: return FadeColors.accent
        case .high: return FadeColors.warning
        case .urgent: return FadeColors.danger
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "arrow.up"
        case .urgent: return "exclamationmark.2"
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case personal = "Personal"
    case work = "Work"
    case study = "Study"
    case health = "Health"
    case creative = "Creative"
    
    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .health: return "heart.fill"
        case .creative: return "paintbrush.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .personal: return FadeColors.accent
        case .work: return FadeColors.accentSecondary
        case .study: return FadeColors.accentTertiary
        case .health: return FadeColors.success
        case .creative: return FadeColors.warning
        }
    }
}

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var duration: TimeInterval   // seconds
    var completedAt: Date
    var mode: FocusMode
    var taskTitle: String?
    
    init(
        id: UUID = UUID(),
        duration: TimeInterval,
        completedAt: Date = Date(),
        mode: FocusMode = .deep,
        taskTitle: String? = nil
    ) {
        self.id = id
        self.duration = duration
        self.completedAt = completedAt
        self.mode = mode
        self.taskTitle = taskTitle
    }
    
    var durationFormatted: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

enum FocusMode: String, Codable, CaseIterable {
    case deep = "Deep Work"
    case flow = "Flow State"
    case sprint = "Sprint"
    case meditation = "Mindful"
    
    var icon: String {
        switch self {
        case .deep: return "brain.head.profile"
        case .flow: return "waveform"
        case .sprint: return "bolt.fill"
        case .meditation: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .deep: return FadeColors.accent
        case .flow: return FadeColors.accentTertiary
        case .sprint: return FadeColors.warning
        case .meditation: return FadeColors.success
        }
    }
    
    var defaultDuration: TimeInterval {
        switch self {
        case .deep: return 25 * 60
        case .flow: return 50 * 60
        case .sprint: return 15 * 60
        case .meditation: return 10 * 60
        }
    }
    
    var ambientLabel: String {
        switch self {
        case .deep: return "Enter the zone."
        case .flow: return "Let it flow."
        case .sprint: return "Go all out."
        case .meditation: return "Breathe."
        }
    }
}

// MARK: - Journal Entry
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mood: Mood
    var body: String
    var gratitude: [String]
    var intention: String
    var energyLevel: Int  // 1-5
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood = .neutral,
        body: String = "",
        gratitude: [String] = ["", "", ""],
        intention: String = "",
        energyLevel: Int = 3
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.body = body
        self.gratitude = gratitude
        self.intention = intention
        self.energyLevel = energyLevel
    }
    
    var dateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

enum Mood: String, Codable, CaseIterable {
    case amazing = "Amazing"
    case good = "Good"
    case neutral = "Neutral"
    case low = "Low"
    case rough = "Rough"
    
    var emoji: String {
        switch self {
        case .amazing: return "⚡️"
        case .good: return "✨"
        case .neutral: return "🌚"
        case .low: return "🌧️"
        case .rough: return "🌌"
        }
    }
    
    var color: Color {
        switch self {
        case .amazing: return FadeColors.warning
        case .good: return FadeColors.success
        case .neutral: return FadeColors.accentTertiary
        case .low: return FadeColors.accent
        case .rough: return FadeColors.danger
        }
    }
}

// MARK: - Productivity Score
struct DailyScore: Identifiable, Codable {
    let id: UUID
    var date: Date
    var focusMinutes: Int
    var tasksCompleted: Int
    var journalWritten: Bool
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        focusMinutes: Int = 0,
        tasksCompleted: Int = 0,
        journalWritten: Bool = false
    ) {
        self.id = id
        self.date = date
        self.focusMinutes = focusMinutes
        self.tasksCompleted = tasksCompleted
        self.journalWritten = journalWritten
    }
    
    var score: Int {
        let focusScore = min(focusMinutes / 5, 40)  // max 40pts
        let taskScore = min(tasksCompleted * 8, 40)  // max 40pts
        let journalScore = journalWritten ? 20 : 0  // 20pts
        return focusScore + taskScore + journalScore
    }
    
    var grade: String {
        switch score {
        case 85...: return "S"
        case 70...: return "A"
        case 55...: return "B"
        case 40...: return "C"
        default: return "D"
        }
    }
}

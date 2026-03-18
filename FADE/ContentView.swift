// ContentView.swift
// FADE — Premium iOS Productivity

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab: Int = 0
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            FadeBackground()
                .ignoresSafeArea()
            
            // Tab content
            TabContent(selectedTab: $selectedTab)
            
            // Custom floating tab bar
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .onAppear {
            if !store.hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
                .environmentObject(store)
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            HomeView()
                .opacity(selectedTab == 0 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            FocusView()
                .opacity(selectedTab == 1 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            TasksView()
                .opacity(selectedTab == 2 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            JournalView()
                .opacity(selectedTab == 3 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
            StatsView()
                .opacity(selectedTab == 4 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("timer", "Focus"),
        ("checkmark.circle.fill", "Tasks"),
        ("book.closed.fill", "Journal"),
        ("chart.bar.fill", "Stats")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [FadeColors.accent, FadeColors.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 32)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                        .frame(width: 44, height: 32)
                }
                
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? FadeColors.accent : .white.opacity(0.35))
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .buttonStyle(PlainButtonStyle())
    }
}

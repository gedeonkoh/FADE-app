// FocusView.swift
// FADE — Immersive focus timer screen

import SwiftUI

struct FocusView: View {
    @EnvironmentObject var store: AppStore
    @State private var appear = false
    @State private var showModeSelector = false
    @State private var breatheScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Animated ambient background
            FocusAmbientBackground(mode: store.selectedFocusMode, isActive: store.isFocusing)
            
            VStack(spacing: 0) {
                // Top bar
                FocusTopBar(showModeSelector: $showModeSelector)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                
                Spacer()
                
                // Main timer ring
                FocusTimerRing(breatheScale: $breatheScale, ringRotation: $ringRotation)
                    .opacity(appear ? 1 : 0)
                    .scaleEffect(appear ? 1 : 0.8)
                
                Spacer()
                
                // Bottom controls
                FocusControls()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 130)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)
            }
        }
        .sheet(isPresented: $showModeSelector) {
            FocusModeSelectorSheet()
                .environmentObject(store)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appear = true
            }
            startBreatheAnimation()
        }
        .onChange(of: store.isFocusing) { focusing in
            if focusing {
                withAnimation(.linear(duration: store.focusTotalTime).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
            } else {
                withAnimation { ringRotation = 0 }
            }
        }
    }
    
    private func startBreatheAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breatheScale = 1.06
        }
    }
}

// MARK: - Ambient Background
struct FocusAmbientBackground: View {
    let mode: FocusMode
    let isActive: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            FadeColors.surface0
            
            // Pulsing ambient orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [mode.color.opacity(isActive ? 0.3 : 0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 500)
                .scaleEffect(animate ? 1.15 : 0.85)
                .animation(
                    .easeInOut(duration: isActive ? 2 : 5).repeatForever(autoreverses: true),
                    value: animate
                )
                .blur(radius: 40)
            
            // Secondary orb
            Circle()
                .fill(FadeColors.accentSecondary.opacity(0.08))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: animate ? 60 : -60, y: animate ? -80 : 80)
                .animation(
                    .easeInOut(duration: 7).repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
        .onChange(of: mode) { _ in animate.toggle() }
    }
}

// MARK: - Top Bar
struct FocusTopBar: View {
    @EnvironmentObject var store: AppStore
    @Binding var showModeSelector: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Focus")
                    .font(FadeFont.title(26))
                    .foregroundColor(FadeColors.textPrimary)
                Text("\(store.focusSessionsToday) sessions today")
                    .font(FadeFont.caption())
                    .foregroundColor(FadeColors.textTertiary)
            }
            Spacer()
            Button(action: { showModeSelector = true }) {
                HStack(spacing: 6) {
                    Image(systemName: store.selectedFocusMode.icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(store.selectedFocusMode.rawValue)
                        .font(FadeFont.caption())
                }
                .foregroundColor(store.selectedFocusMode.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glassCard(cornerRadius: 12)
            }
        }
    }
}

// MARK: - Timer Ring
struct FocusTimerRing: View {
    @EnvironmentObject var store: AppStore
    @Binding var breatheScale: CGFloat
    @Binding var ringRotation: Double
    
    var body: some View {
        ZStack {
            // Outer decorative ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            store.selectedFocusMode.color.opacity(0.08),
                            store.selectedFocusMode.color.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: 300)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(store.focusProgress))
                .stroke(
                    AngularGradient(
                        colors: [
                            store.selectedFocusMode.color,
                            store.selectedFocusMode.color.opacity(0.4),
                            store.selectedFocusMode.color
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 270)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: store.focusProgress)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            store.selectedFocusMode.color.opacity(store.isFocusing ? 0.12 : 0.06),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 110
                    )
                )
                .frame(width: 240)
                .scaleEffect(breatheScale)
            
            // Center content
            VStack(spacing: 10) {
                if store.isFocusing {
                    Text(store.focusTimeString)
                        .font(FadeFont.mono(58))
                        .foregroundColor(FadeColors.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 1), value: store.focusTimeString)
                } else {
                    Text(store.focusTimeString)
                        .font(FadeFont.mono(58))
                        .foregroundColor(FadeColors.textPrimary)
                }
                Text(store.selectedFocusMode.ambientLabel)
                    .font(FadeFont.caption())
                    .foregroundColor(store.selectedFocusMode.color.opacity(0.7))
                    .kerning(2)
            }
        }
        .scaleEffect(breatheScale * (store.isFocusing ? 1.0 : 0.98))
    }
}

// MARK: - Focus Controls
struct FocusControls: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(spacing: 20) {
            // Sessions indicator
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < store.focusSessionsToday % 4
                              ? store.selectedFocusMode.color
                              : FadeColors.textTertiary.opacity(0.3))
                        .frame(width: 28, height: 4)
                }
            }
            
            // Main button
            Button(action: {
                if store.isFocusing {
                    store.pauseFocus()
                } else {
                    store.startFocus()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    store.selectedFocusMode.color,
                                    store.selectedFocusMode.color.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: store.selectedFocusMode.color.opacity(0.5), radius: 20, y: 8)
                    
                    Image(systemName: store.isFocusing ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: store.isFocusing ? 0 : 2)
                }
            }
            .scaleEffect(store.isFocusing ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: store.isFocusing)
            
            // Quick mode time label
            Text("\(Int(store.selectedFocusMode.defaultDuration / 60)) min session")
                .font(FadeFont.caption())
                .foregroundColor(FadeColors.textTertiary)
        }
    }
}

// MARK: - Mode Selector Sheet
struct FocusModeSelectorSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            FadeColors.surface0.ignoresSafeArea()
            
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(FadeColors.textTertiary)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                
                Text("Focus Mode")
                    .font(FadeFont.title(22))
                    .foregroundColor(FadeColors.textPrimary)
                
                VStack(spacing: 12) {
                    ForEach(FocusMode.allCases, id: \.self) { mode in
                        FocusModeRow(mode: mode, isSelected: store.selectedFocusMode == mode) {
                            store.selectedFocusMode = mode
                            store.focusTimeRemaining = mode.defaultDuration
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.hidden)
    }
}

struct FocusModeRow: View {
    let mode: FocusMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(mode.color)
                    .frame(width: 44, height: 44)
                    .background(mode.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.rawValue)
                        .font(FadeFont.headline())
                        .foregroundColor(FadeColors.textPrimary)
                    Text("\(Int(mode.defaultDuration / 60)) minutes")
                        .font(FadeFont.caption())
                        .foregroundColor(FadeColors.textTertiary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(mode.color)
                        .font(.system(size: 20))
                }
            }
            .padding(16)
            .glassCard(cornerRadius: 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

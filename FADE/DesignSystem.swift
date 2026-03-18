// DesignSystem.swift
// FADE — Design tokens, colors, glassmorphism, reusable components

import SwiftUI

// MARK: - Color Palette
enum FadeColors {
    // Primary accent: electric violet-indigo
    static let accent = Color(red: 0.45, green: 0.35, blue: 1.0)
    static let accentSecondary = Color(red: 0.75, green: 0.35, blue: 1.0)
    static let accentTertiary = Color(red: 0.35, green: 0.85, blue: 1.0)
    
    // Surfaces
    static let surface0 = Color(red: 0.05, green: 0.05, blue: 0.08)    // deepest bg
    static let surface1 = Color(red: 0.09, green: 0.09, blue: 0.13)    // card bg
    static let surface2 = Color(red: 0.13, green: 0.13, blue: 0.18)    // elevated card
    static let surface3 = Color(red: 0.18, green: 0.18, blue: 0.25)    // pressed/active
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.35)
    
    // Semantic
    static let success = Color(red: 0.2, green: 0.9, blue: 0.6)
    static let warning = Color(red: 1.0, green: 0.75, blue: 0.2)
    static let danger = Color(red: 1.0, green: 0.35, blue: 0.5)
    
    // Gradients
    static let gradientAccent = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let gradientAmbient = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.35, blue: 1.0).opacity(0.3),
            Color(red: 0.75, green: 0.35, blue: 1.0).opacity(0.15),
            Color(red: 0.35, green: 0.85, blue: 1.0).opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
enum FadeFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
            )
            .opacity(opacity)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 1.0) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Fade Background
struct FadeBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base dark
            FadeColors.surface0
            
            // Ambient orb top-left (violet)
            Circle()
                .fill(FadeColors.accent.opacity(0.18))
                .frame(width: 380)
                .blur(radius: 80)
                .offset(x: -80, y: animateGradient ? -150 : -120)
                .animation(
                    .easeInOut(duration: 8).repeatForever(autoreverses: true),
                    value: animateGradient
                )
            
            // Ambient orb bottom-right (purple)
            Circle()
                .fill(FadeColors.accentSecondary.opacity(0.13))
                .frame(width: 340)
                .blur(radius: 90)
                .offset(x: 100, y: animateGradient ? 280 : 320)
                .animation(
                    .easeInOut(duration: 10).repeatForever(autoreverses: true),
                    value: animateGradient
                )
            
            // Accent orb center-right (cyan)
            Circle()
                .fill(FadeColors.accentTertiary.opacity(0.07))
                .frame(width: 260)
                .blur(radius: 70)
                .offset(x: 120, y: animateGradient ? 60 : 80)
                .animation(
                    .easeInOut(duration: 12).repeatForever(autoreverses: true),
                    value: animateGradient
                )
        }
        .onAppear { animateGradient = true }
    }
}

// MARK: - Pill Tag
struct PillTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(FadeFont.caption(11))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
                    .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
            )
    }
}

// MARK: - Accent Button
struct AccentButton: View {
    let title: String
    let icon: String?
    var isDestructive: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(FadeFont.headline(15))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isDestructive
                        ? LinearGradient(colors: [FadeColors.danger, FadeColors.danger.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [FadeColors.accent, FadeColors.accentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: (isDestructive ? FadeColors.danger : FadeColors.accent).opacity(0.45), radius: 12, y: 6)
            )
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    var action: (() -> Void)? = nil
    var actionLabel: String = "See all"
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FadeFont.title(20))
                    .foregroundColor(FadeColors.textPrimary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(FadeFont.caption())
                        .foregroundColor(FadeColors.textTertiary)
                }
            }
            Spacer()
            if let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(FadeFont.caption())
                        .foregroundColor(FadeColors.accent)
                }
            }
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double  // 0...1
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            // Fill
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.6)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(FadeFont.display(28))
                    .foregroundColor(FadeColors.textPrimary)
                Text(title)
                    .font(FadeFont.caption())
                    .foregroundColor(FadeColors.textTertiary)
            }
            Text(subtitle)
                .font(FadeFont.caption(11))
                .foregroundColor(color.opacity(0.8))
        }
        .padding(16)
        .glassCard(cornerRadius: 18)
    }
}

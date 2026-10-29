import SwiftUI

/// Cinematic launch intro: light beams, letters rise in, glow, zoom-through into the app.
struct SplashView: View {
    var onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showMark = false
    @State private var beams = false
    @State private var expand = false
    @State private var glow = false
    @State private var showTagline = false
    @State private var fadeOut = false
    @State private var haptic = false

    private let letters = Array("FINLEY")

    var body: some View {
        ZStack {
            Color.black
                .opacity(fadeOut ? 0 : 1)
                .ignoresSafeArea()

            lightBeams

            VStack(spacing: 14) {
                wordmark
                Text("Your money, made clear.")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 8)
            }
            .scaleEffect(fadeOut ? 6 : (expand ? 1 : 1.5))
            .opacity(fadeOut ? 0 : 1)
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: haptic)
        .task { await run() }
    }

    // MARK: - Pieces

    private var wordmark: some View {
        HStack(spacing: expand ? 6 : -16) {
            ForEach(letters.indices, id: \.self) { i in
                Text(String(letters[i]))
                    .font(.system(size: 54, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.heroGradient)
                    .shadow(color: Theme.accentSoft.opacity(glow ? 0.9 : 0), radius: glow ? 22 : 0)
                    .opacity(showMark ? 1 : 0)
                    .offset(y: showMark ? 0 : 36)
                    .blur(radius: showMark ? 0 : 14)
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.72).delay(Double(i) * 0.08),
                        value: showMark
                    )
            }
        }
    }

    private var lightBeams: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<9, id: \.self) { i in
                    let k = Double(i - 4)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0), Theme.accentSoft.opacity(0.95), Theme.accent.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 5, height: geo.size.height * 1.3)
                        .rotationEffect(.degrees(k * 8))
                        .offset(x: beams ? CGFloat(k) * 40 : 0)
                        .opacity(beams ? (fadeOut ? 0 : 0.55) : 0)
                        .blur(radius: 5)
                        .animation(.easeOut(duration: 1.0).delay(abs(k) * 0.04), value: beams)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Timeline

    private func run() async {
        if reduceMotion {
            try? await Task.sleep(for: .milliseconds(400))
            onFinish()
            return
        }

        try? await Task.sleep(for: .milliseconds(250))
        showMark = true
        beams = true

        try? await Task.sleep(for: .milliseconds(800))
        haptic.toggle()
        withAnimation(.easeInOut(duration: 0.8)) {
            expand = true
            glow = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) { showTagline = true }

        try? await Task.sleep(for: .milliseconds(1400))
        withAnimation(.easeIn(duration: 0.55)) { fadeOut = true }

        try? await Task.sleep(for: .milliseconds(500))
        onFinish()
    }
}

#Preview {
    SplashView(onFinish: {})
}

import SwiftUI

// MARK: - Hex → Color helper
extension Color {
    /// Supports "#RGB", "#RRGGBB", or "#RRGGBBAA"
    static func colorFromHexString(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "#", with: "")
        if s.count == 3 { // e.g., F0A → FF 00 AA
            s = s.map { "\($0)\($0)" }.joined()
        }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)

        let r, g, b, a: Double
        switch s.count {
        case 8: // RRGGBBAA
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8)  & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        default: // 6: RRGGBB (fallback)
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8)  & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1.0
        }
        return Color(red: r, green: g, blue: b).opacity(a)
    }
}

// MARK: - Splash
struct SplashView: View {
    let onFinish: () -> Void                    // call when splash is done
    @State private var opacity = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var bounceOffset: CGFloat = 0
    @State private var bounceOffsetSecondO: CGFloat = 0
    @State private var emojiOffset: CGFloat = -20
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Your background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.colorFromHex("#58B361"),
                    Color.colorFromHex("#264D2A")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // App name animation
                HStack(spacing: 4) {
                    Text("C")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Animated first "o"
                    Text("o")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(y: bounceOffset)
                        .animation(
                            isAnimating ?
                            .interpolatingSpring(stiffness: 100, damping: 5).delay(0.1) :
                            .default, value: bounceOffset
                        )

                    Text("🍲")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(y: bounceOffsetSecondO)
                        .animation(
                            isAnimating ?
                            .interpolatingSpring(stiffness: 100, damping: 5).delay(0.2) :
                            .default, value: bounceOffsetSecondO
                        )

                    Text("k")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("c")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("r")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("a")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("f")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("t")
                        .font(.custom("Avenir", size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)


                }
                .opacity(opacity)
                .scaleEffect(scale)
                .accessibilityLabel("Cookcraft")
            }
        }
        .onAppear {
            // Start the animation for emoji and text
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    emojiOffset = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
                bounceOAnimation()
            }

            // Dismiss after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                onFinish() // Directly call onFinish without animation
            }
        }
    }

    private func bounceOAnimation() {
        // Bounce first "o"
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.5)) {
            bounceOffset = -60
        }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.5).delay(0.3)) {
            bounceOffset = 0
        }

        // Bounce second "o"
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.5).delay(0.6)) {
            bounceOffsetSecondO = -80
        }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.5).delay(0.9)) {
            bounceOffsetSecondO = 0
        }
    }
}

extension Color {
    static func colorFromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

#Preview {
    SplashView {
        print("Splash screen finished!")
    }
}

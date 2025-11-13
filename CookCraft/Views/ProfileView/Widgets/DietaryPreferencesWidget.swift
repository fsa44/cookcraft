


import SwiftUI
import Supabase
import Network

struct DietaryPreferencesWidget: View {
    // Toggles
    @State private var isVegetarianOnly = false
    @State private var isVeganOnly = false
    @State private var isPeanutFree = false
    @State private var isTreeNutFree = false
    @State private var isMeatFree = false
    @State private var isDairyFree = false
    @State private var isEggFree = false
    @State private var isGlutenFree = false
    @State private var isWithoutSeafood = false
    @State private var isSugarFree = false
    @State private var isLactoseFreeOnly = false

    // UI state
    @State private var isSaving = false
    @State private var showSaved = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isOnline = true

    // Reachability
    private let pathMonitor = NWPathMonitor()
    private let pathQueue = DispatchQueue(label: "dietary-preferences-path")

    // Map label -> binding (keep your titles)
    var toggleItems: [(title: String, isOn: Binding<Bool>)] {
        [
            ("Vegetarian only", $isVegetarianOnly),
            ("Vegan only", $isVeganOnly),
            ("Peanut Free", $isPeanutFree),
            ("Tree Nut Free", $isTreeNutFree),
            ("Meat Free", $isMeatFree),
            ("Dairy Free", $isDairyFree),
            ("Egg Free", $isEggFree),
            ("Gluten Free", $isGlutenFree),
            ("Without Seafood", $isWithoutSeafood),
            ("Sugar Free", $isSugarFree),
            ("Lactose Free", $isLactoseFreeOnly)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .center) {
                            Text("Dietary Preferences")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                                .padding(.top, -10)

                            Spacer()

                            Button {
                                Task { await savePreferences() }
                            } label: {
                                HStack(spacing: 6) {
                                    if isSaving { ProgressView().tint(.white) }
                                    Text(isSaving ? "Saving..." : "Save")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background((isOnline ? Color.white.opacity(0.25) : Color.gray.opacity(0.25)))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isSaving || !isOnline)
                            .opacity(isOnline ? 1 : 0.7)
                            .overlay(alignment: .bottomTrailing) {
                                if !isOnline {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(6)
                                }
                            }
                        }

                        if !isOnline {
                            InlineBanner(text: "You’re offline. Changes will resume when connection is back.")
                        }

                        if isLoading {
                            HStack(spacing: 10) {
                                ProgressView().tint(.white)
                                Text("Loading preferences…").foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                        }

                        Text("Dietary Options")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, -5)
                            .padding(.top, -10)

                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(.bottom, 4)
                            .padding(.top, -20)

                        ForEach(toggleItems, id: \.title) { item in
                            ToggleRow(title: item.title, isOn: item.isOn)
                                .padding(.vertical, 10)
                                .opacity(isOnline ? 1 : 0.85)
                        }
                        .padding(.top, -20)
                    }
                    .padding()
                }
                .overlay(alignment: .top) {
                    if showError {
                        Toast(text: errorMessage, isError: true)
                            .padding(.top, 24)
                    } else if showSaved {
                        Toast(text: "Preferences saved", isError: false)
                            .padding(.top, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                startReachability()
                await loadPreferences()
            }
            .onDisappear {
                pathMonitor.cancel()
            }
        }
    }

    // MARK: - Convert current toggles <-> tags
    private func currentTags() -> [String] {
        toggleItems.compactMap { $0.isOn.wrappedValue ? $0.title : nil }
    }

    private func apply(tags: [String]) {
        for item in toggleItems {
            item.isOn.wrappedValue = tags.contains(item.title)
        }
    }

    // MARK: - Reachability
    private func startReachability() {
        pathMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOnline = (path.status == .satisfied)
            }
        }
        pathMonitor.start(queue: pathQueue)
    }

    // MARK: - Load from RPC
    private func loadPreferences() async {
        isLoading = true
        defer { isLoading = false }

        // If offline, don’t call network—just stop quietly
        guard isOnline else { return }

        do {
            // If user isn’t logged in, don’t blow up—just leave defaults
            _ = try? await supabase.auth.session

            struct PV: Decodable {
                let id: UUID
                let dietary_tags: [String]
            }

            let profile: PV = try await supabase
                .rpc("get_my_profile")           // defined below in SQL section
                .execute()
                .value

            apply(tags: profile.dietary_tags)
        } catch {
            let friendly = friendlyNetworkError(error)
            errorMessage = "Failed to load preferences: \(friendly)"
            showError = true
        }
    }

    // MARK: - Save via RPC
    private func savePreferences() async {
        guard !isSaving else { return }
        guard isOnline else {
            errorMessage = "You’re offline. Please reconnect to save."
            showError = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let tags = currentTags()
            try await supabase
                .rpc("set_my_dietary_tags", params: ["p_tags": tags]) // defined below in SQL section
                .execute()

            showSaved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { showSaved = false }
        } catch {
            let friendly = friendlyNetworkError(error)
            errorMessage = "Failed to save: \(friendly)"
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { showError = false }
        }
    }

    // MARK: - Error prettifier
    private func friendlyNetworkError(_ error: Error) -> String {
        if let urlErr = error as? URLError {
            switch urlErr.code {
            case .cannotFindHost: return "Server hostname can’t be found. Check your Supabase URL."
            case .notConnectedToInternet: return "No internet connection."
            case .timedOut: return "Request timed out."
            case .cannotConnectToHost: return "Can’t connect to server."
            case .networkConnectionLost: return "Network connection lost."
            default: break
            }
        }
        return error.localizedDescription
    }
}

// MARK: - Row + Toast components
struct ToggleRow: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title).foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct Toast: View {
    let text: String
    let isError: Bool
    var body: some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background((isError ? Color.red : Color.green).opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: text)
    }
}

private struct InlineBanner: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text(text)
        }
        .font(.subheadline)
        .foregroundColor(.white)
        .padding(10)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack { DietaryPreferencesWidget() }
}

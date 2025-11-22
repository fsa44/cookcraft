


import SwiftUI

private enum ArticleCardVisualState {
    case unseen
    case viewed
    case newlyLoaded
}

struct NutritionArticlesSection: View {
    @State private var allArticles: [NutritionArticle] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var viewedIDs: Set<String> = []
    @State private var newlyLoadedIDs: Set<String> = []

    @State private var currentStartIndex: Int = 0

    @State private var selectedArticle: NutritionArticle?
    @Namespace private var articleNamespace

    private let rotationTimer = Timer
        .publish(every: 60, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutritional Articles")
                .font(.headline)
                .foregroundColor(.white)

            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.subheadline)
            } else if currentWindow.isEmpty {
                Text("No articles available yet.")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(currentWindow) { article in
                            articleCard(for: article)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 4)
        .onAppear {
            Task { await loadArticlesIfNeeded() }
        }
        .onReceive(rotationTimer) { _ in
            advanceWindow(triggeredByTimer: true)
        }
        .overlay(
            expandedArticleOverlay
                .padding(.bottom, 80)   // ← add this
        )

        .animation(.spring(), value: selectedArticle)
        .animation(.easeInOut, value: currentWindow.map { $0.id })
    }

    // MARK: - Window

    private var currentWindow: [NutritionArticle] {
        guard !allArticles.isEmpty else { return [] }

        if allArticles.count >= 3 {
            let start = currentStartIndex % allArticles.count
            return (0..<3).map { offset in
                allArticles[(start + offset) % allArticles.count]
            }
        } else {
            return (0..<3).map { index in
                allArticles[index % allArticles.count]
            }
        }
    }

    // MARK: - Load

    private func loadArticlesIfNeeded() async {
        guard allArticles.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await NutritionArticleService.shared.fetchArticles()
            await MainActor.run {
                self.isLoading = false
                if fetched.isEmpty {
                    self.errorMessage = "No nutritional articles found."
                } else {
                    self.allArticles = fetched
                    self.newlyLoadedIDs = Set(self.currentWindow.map { $0.id })
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load articles."
            }
        }
    }

    // MARK: - Rotation

    private func advanceWindow(triggeredByTimer: Bool) {
        guard !allArticles.isEmpty else { return }

        currentStartIndex = (currentStartIndex + 3) % max(allArticles.count, 1)
        let newIDs = Set(currentWindow.map { $0.id })
        newlyLoadedIDs = newIDs.subtracting(viewedIDs)
    }

    // MARK: - Visual state

    private func visualState(for article: NutritionArticle) -> ArticleCardVisualState {
        if newlyLoadedIDs.contains(article.id) {
            return .newlyLoaded
        } else if viewedIDs.contains(article.id) {
            return .viewed
        } else {
            return .unseen
        }
    }

    // MARK: - Card

    @ViewBuilder
    private func articleCard(for article: NutritionArticle) -> some View {
        let state = visualState(for: article)

        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(cardBackground(for: state))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(borderColor(for: state), lineWidth: state == .newlyLoaded ? 2 : 1)
                    )

                VStack(spacing: 10) {
                    Spacer().frame(height: 4)

                    // Icon
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "doc.text.image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        )
                    }

                    // Image
                    if let url = article.imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 210, height: 110)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Text(article.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    stateBadge(for: state)

                    Spacer().frame(height: 4)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .frame(width: 230, height: 220)
            .shadow(radius: 10)
        }
        .opacity(state == .viewed ? 0.65 : 1.0)
        .scaleEffect(state == .newlyLoaded ? 1.03 : 1.0)
        .matchedGeometryEffect(
            id: article.id,
            in: articleNamespace,
            isSource: selectedArticle?.id != article.id
        )
        .onTapGesture {
            markAsViewed(article)
            withAnimation(.spring()) {
                selectedArticle = article
            }
        }
    }

    private func cardBackground(for state: ArticleCardVisualState) -> Color {
        switch state {
        case .unseen:     return Color.white.opacity(0.15)
        case .viewed:     return Color.white.opacity(0.08)
        case .newlyLoaded:return Color.white.opacity(0.22)
        }
    }

    private func borderColor(for state: ArticleCardVisualState) -> Color {
        switch state {
        case .unseen:     return Color.white.opacity(0.35)
        case .viewed:     return Color.gray.opacity(0.5)
        case .newlyLoaded:return Color.yellow.opacity(0.8)
        }
    }

    @ViewBuilder
    private func stateBadge(for state: ArticleCardVisualState) -> some View {
        switch state {
        case .unseen:
            Text("New")
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .clipShape(Capsule())

        case .viewed:
            Text("Viewed")
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.4))
                .foregroundColor(.white)
                .clipShape(Capsule())

        case .newlyLoaded:
            Text("Just Added")
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.9))
                .foregroundColor(.black)
                .clipShape(Capsule())
        }
    }

    private func markAsViewed(_ article: NutritionArticle) {
        viewedIDs.insert(article.id)
        newlyLoadedIDs.remove(article.id)
        advanceWindow(triggeredByTimer: false)
    }

    // MARK: - Expanded overlay (3/4 height + bottom padding 40)

    @ViewBuilder
    private var expandedArticleOverlay: some View {
        if let article = selectedArticle {
            ZStack {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { selectedArticle = nil }
                    }

                VStack(spacing: 18) {
                    ZStack(alignment: .topTrailing) {
                        if let url = article.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(
                                maxWidth: UIScreen.main.bounds.width * 0.9,
                                maxHeight: UIScreen.main.bounds.height * 0.75
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 20)
                            .matchedGeometryEffect(id: article.id, in: articleNamespace)
                        }

                        Button {
                            withAnimation(.spring()) {
                                selectedArticle = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                                .padding(12)
                        }
                    }

                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)   // ← added

                }
                .frame(height: UIScreen.main.bounds.height * 0.75)
                .padding(.horizontal)
                .padding(.bottom, 80)   // ← ★ NEW: bottom padding 40
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

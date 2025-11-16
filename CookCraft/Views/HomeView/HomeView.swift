//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: SupabaseAuthService
    private let recipeService = RecipeService()

    // MARK: – State
    @State private var allRecipes: [Recipe] = []
    @State private var filteredRecipes: [Recipe] = []
    @State private var selectedCategoryRecipes: [Recipe] = []
    @State private var showRecipeGroupModal: Bool = false
    @State private var searchDebounceTimer: Timer? = nil


    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    @State private var userName: String = "Guest"
    @State private var userInitials: String = "GG"
    @State private var selectedDietaryFilter: String = "None"

    private let dietaryFilters = ["None", "Vegetarian", "Gluten-Free", "Vegan", "Dairy-Free"]

    private let categoriesWithFiles: [(title: String, imageName: String, jsonFile: String)] = [
        ("Breakfast Recipes", "Breakfast Image 1", "recipes_breakfast_part0.json"),
        ("Lunch Recipes", "Lunch Image 1", "recipes_lunch_part0.json"),
        ("Dinner Recipes", "Dinner Image 1", "recipes_dinner_part0.json"),
        ("Snack Recipes", "Snack Image 2", "recipes_snack_part0.json"),
    ]

    private let articles = [
        ("Zinc Sources", "lightbulb.fill"),
        ("Vitamin A Sources", "cross.case.fill"),
        ("Healthy Eating Tips", "app.badge.checkmark")
    ]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // MARK: – Normalization for Swahili-friendly matching
    // MARK: – Normalization for Swahili-friendly matching
    private func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive],
                  locale: Locale(identifier: "sw_KE"))
         .lowercased()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: – Filtering (text + diet) — no aliases dependency
    private func filterRecipes(_ recipes: [Recipe], query: String, dietaryFilter: String) -> [Recipe] {
        let nq = normalize(query)
        return recipes.filter { recipe in
            let name = normalize(recipe.name)
            let matchesQuery = nq.isEmpty || name.contains(nq)

            let matchesDiet = dietaryFilter == "None" ||
                recipe.dietaryTags.contains { $0.caseInsensitiveCompare(dietaryFilter) == .orderedSame }

            return matchesQuery && matchesDiet
        }
    }


    // MARK: – Category loader (unchanged)
    private func loadCategory(title: String, jsonFile: String) {
        isLoading = true
        errorMessage = ""

        recipeService.fetchCategoryRecipes(categoryFile: jsonFile, categoryName: title) { recipes in
            self.isLoading = false
            if recipes.isEmpty {
                self.errorMessage = "No recipes found for \(title)."
            } else {
                self.selectedCategoryRecipes = recipes
                self.showRecipeGroupModal = true
            }
        }
    }

    // MARK: – Search helpers (submit + live + refilter)
    private func fetchMealIdeas(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        isLoading = true
        errorMessage = ""

        // Lazy-load the full catalog once, then filter
        if allRecipes.isEmpty {
            recipeService.fetchAllRecipes { recipes in
                self.allRecipes = recipes
                self.applySearchFilter()
            }
        } else {
            self.applySearchFilter()
        }
    }

    private func applySearchFilter() {
        let results = filterRecipes(allRecipes, query: searchText, dietaryFilter: selectedDietaryFilter)
        self.isLoading = false

        if results.isEmpty {
            self.errorMessage = "No recipes found."
            self.selectedCategoryRecipes = []
            self.showRecipeGroupModal = false
        } else {
            // Reuse the same modal used for categories
            self.selectedCategoryRecipes = Array(results.prefix(16))
            self.showRecipeGroupModal = true
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    profileHeader
                    searchBar
                    filterPicker

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.3))
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    CategoriesWidget(categories: categoriesWithFiles) { title, fileName in
                        loadCategory(title: title, jsonFile: fileName)
                    }
                    .offset(y: -5)

                    articleSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.colorFromHex("#58B361"), Color.colorFromHex("#264D2A")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .sheet(isPresented: $showRecipeGroupModal) {
                RecipeGroupModal(recipes: selectedCategoryRecipes, isPresented: $showRecipeGroupModal)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: fetchUserName)
        // Re-filter when the diet changes (if there’s an active query)
        .onChange(of: selectedDietaryFilter) { _,_ in
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fetchMealIdeas(query: searchText)
            }
        }
        // Live (instant) search as they type: comment out if you prefer submit-only
        .onChange(of: searchText) { _, newValue in
            let query = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

            // Invalidate any previous typing timer
            searchDebounceTimer?.invalidate()

            if query.isEmpty {
                // Clear UI when text is cleared
                self.errorMessage = ""
                self.showRecipeGroupModal = false
                self.selectedCategoryRecipes = []
                return
            }

            // Start a new timer (e.g., 0.6s after last key press)
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                // Ensure catalog loaded
                if allRecipes.isEmpty {
                    recipeService.fetchAllRecipes { recipes in
                        self.allRecipes = recipes
                        self.applySearchFilter()
                    }
                } else {
                    self.applySearchFilter()
                }
            }
        }

    }

    // MARK: – UI

    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting),")
                    .font(.system(size: 23, weight: .regular))
                    .foregroundColor(.white)
                Text(userName)
                    .font(.system(size: 30, weight: .bold))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.leading, -15)

            Spacer(minLength: 20)

            Text(userInitials)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(Color.white.opacity(0.25))
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.trailing, -10)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search for meal ideas...", text: $searchText)
                .foregroundColor(.black)
                .autocorrectionDisabled(true)               // no autocorrect (good for Swahili terms)
                .textInputAutocapitalization(.never)        // keep user’s casing as typed
                .keyboardType(.default)
                .submitLabel(.search)
                .onSubmit { fetchMealIdeas(query: searchText) } // ← submit triggers search
        }
        .padding(.horizontal)
        .frame(height: 45)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
    }

    private var filterPicker: some View {
        Picker("Dietary Preference", selection: $selectedDietaryFilter) {
            ForEach(dietaryFilters, id: \.self) { filter in
                Text(filter)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding(.horizontal)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
    }

    private var articleSection: some View {
        VStack(alignment: .leading) {
            Text("Educational Articles")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(articles, id: \.0) { article, icon in
                        articleCard(title: article, icon: icon)
                    }
                }
                .padding(.horizontal)
            }
        }
        .offset(y: -10)
    }

    private func articleCard(title: String, icon: String) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 210)

                VStack {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)

                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }

                    Text(title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .shadow(radius: 10)
        }
    }

    private func fetchUserName() {
        guard let user = authService.user else {
            userName = "Guest"
            userInitials = "GG"
            return
        }

        var first = ""
        var last = ""

        if let meta = user.userMetadata["first_name"], case let .string(value) = meta {
            first = value
        }

        if let meta = user.userMetadata["last_name"], case let .string(value) = meta {
            last = value
        }

        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        let emailFallback = user.email ?? "User"

        userName = fullName.isEmpty ? emailFallback : fullName

        if !first.isEmpty || !last.isEmpty {
            let firstInitial = first.first.map { String($0).uppercased() } ?? ""
            let lastInitial = last.first.map { String($0).uppercased() } ?? ""
            userInitials = "\(firstInitial)\(lastInitial)"
        } else if let email = user.email {
            let parts = email.components(separatedBy: "@").first ?? ""
            let chars = parts.prefix(2).uppercased()
            userInitials = chars
        } else {
            userInitials = "US"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SupabaseAuthService())
    }
}

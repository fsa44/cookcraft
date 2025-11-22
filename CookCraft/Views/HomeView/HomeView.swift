import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: SupabaseAuthService
    @EnvironmentObject var recommendationStore: RecommendationStore
    
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
    
    // NEW: Recommended meals modal state
    @State private var showRecommendedModal: Bool = false
    @State private var recommendedCategoryTitle: String = ""
    @State private var recommendedMealsForCategory: [MealDTO] = []

    private let dietaryFilters = ["None", "Vegetarian", "Gluten-Free", "Vegan", "Dairy-Free"]

    private let categoriesWithFiles: [(title: String, imageName: String, jsonFile: String)] = [
        ("Breakfast Recipes", "Breakfast Image 1", "recipes_breakfast_part0.json"),
        ("Lunch Recipes", "Lunch Image 1", "recipes_lunch_part0.json"),
        ("Dinner Recipes", "Dinner Image 1", "recipes_dinner_part0.json"),
        ("Snack Recipes", "Snack Image 2", "recipes_snack_part0.json"),
    ]

    // ✅ Nutrition Articles section
    private var articleSection: some View {
        NutritionArticlesSection()
            .offset(y: -30)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // MARK: – Normalization for Swahili-friendly matching
    private func normalize(_ s: String) -> String {
        s.folding(
            options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive],
            locale: Locale(identifier: "sw_KE")
        )
        .lowercased()
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: – Filtering (text + diet)
    private func filterRecipes(
        _ recipes: [Recipe],
        query: String,
        dietaryFilter: String
    ) -> [Recipe] {
        let nq = normalize(query)
        return recipes.filter { recipe in
            let name = normalize(recipe.name)
            let matchesQuery = nq.isEmpty || name.contains(nq)

            let matchesDiet =
                dietaryFilter == "None"
                || recipe.dietaryTags.contains {
                    $0.caseInsensitiveCompare(dietaryFilter) == .orderedSame
                }

            return matchesQuery && matchesDiet
        }
    }

    // MARK: – Category loader (uses recommendations first, then JSON fallback)
    private func loadCategory(title: String, jsonFile: String) {
        // 1) Try to use recommended meals if we have a latest response
        if let response = recommendationStore.latestResponse {
            let slots = response.mealRecommendations.slots

            let mealsForThisCategory: [MealDTO]
            switch title {
            case "Breakfast Recipes":
                mealsForThisCategory = slots.breakfast
            case "Lunch Recipes":
                mealsForThisCategory = slots.lunch
            case "Dinner Recipes":
                mealsForThisCategory = slots.dinner
            case "Snack Recipes":
                mealsForThisCategory = slots.snack
            default:
                mealsForThisCategory = []
            }

            if !mealsForThisCategory.isEmpty {
                self.recommendedCategoryTitle = title
                self.recommendedMealsForCategory = mealsForThisCategory
                self.showRecommendedModal = true
                return
            }
        }

        // 2) Fallback: static JSON
        isLoading = true
        errorMessage = ""

        recipeService.fetchCategoryRecipes(
            categoryFile: jsonFile,
            categoryName: title
        ) { recipes in
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
        let results = filterRecipes(
            allRecipes,
            query: searchText,
            dietaryFilter: selectedDietaryFilter
        )
        self.isLoading = false

        if results.isEmpty {
            self.errorMessage = "No recipes found."
            self.selectedCategoryRecipes = []
            self.showRecipeGroupModal = false
        } else {
            self.selectedCategoryRecipes = Array(results.prefix(16))
            self.showRecipeGroupModal = true
        }
    }

    // MARK: – Body

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
                    .offset(y: -20)

                    // ✅ Uses the new dynamic Articles section
                    articleSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.colorFromHex("#58B361"),
                            Color.colorFromHex("#264D2A")
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            // Fallback: JSON-based group modal
            .sheet(isPresented: $showRecipeGroupModal) {
                RecipeGroupModal(
                    recipes: selectedCategoryRecipes,
                    isPresented: $showRecipeGroupModal
                )
            }
            // Recommended meals modal (from BMI + XAI pipeline)
            .sheet(isPresented: $showRecommendedModal) {
                RecommendedMealsModal(
                    title: recommendedCategoryTitle,
                    meals: recommendedMealsForCategory,
                    isPresented: $showRecommendedModal
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: fetchUserName)
        .onChange(of: selectedDietaryFilter) { _, _ in
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fetchMealIdeas(query: searchText)
            }
        }
        .onChange(of: searchText) { _, newValue in
            let query = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

            searchDebounceTimer?.invalidate()

            if query.isEmpty {
                self.errorMessage = ""
                self.showRecipeGroupModal = false
                self.selectedCategoryRecipes = []
                return
            }

            searchDebounceTimer = Timer.scheduledTimer(
                withTimeInterval: 0.6,
                repeats: false
            ) { _ in
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
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, -15)

            Spacer(minLength: 20)

            Text(userInitials)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.25))
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.trailing, -10)
        .offset(y: -10)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search for meal ideas...", text: $searchText)
                .foregroundColor(.black)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.default)
                .submitLabel(.search)
                .onSubmit { fetchMealIdeas(query: searchText) }
        }
        .padding(.horizontal)
        .frame(height: 45)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .offset(y: -16)
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
        .offset(y: -20)
    }

    // MARK: – User Name

    private func fetchUserName() {
        guard let user = authService.user else {
            userName = "Guest"
            userInitials = "GG"
            return
        }

        var first = ""
        var last = ""

        if let meta = user.userMetadata["first_name"],
           case let .string(value) = meta {
            first = value
        }

        if let meta = user.userMetadata["last_name"],
           case let .string(value) = meta {
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

// MARK: – Recommended Meals Modal

struct RecommendedMealsModal: View {
    let title: String
    let meals: [MealDTO]
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(meals) { meal in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(meal.title)
                            .font(.headline)

                        if let description = meal.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 8) {
                            if let calories = meal.displayCalories {
                                TagView(text: calories)
                            }
                            if let diet = meal.dietPreference {
                                TagView(text: diet)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: – Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SupabaseAuthService())
            .environmentObject(RecommendationStore())
    }
}

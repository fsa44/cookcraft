
import SwiftUI

struct HomeView: View {
    // MARK: – Dependencies
    @EnvironmentObject var authService: SupabaseAuthService

    // MARK: – State
    @State private var searchText = ""
    @State private var mealSuggestions: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var userName: String = "Guest"
    @State private var userInitials: String = "GG"

    @State private var selectedDietaryFilter: String = "None"
    private let dietaryFilters = ["None", "Vegetarian", "Gluten-Free", "Vegan", "Dairy-Free"]

    private let categories = [
        ("Breakfast Ideas", "sun.max.fill"),
        ("Snack Ideas", "apple.logo"),
        ("Lunch Meals", "leaf.fill"),
        ("Dinner Recipes", "fork.knife")
    ]
    private let articles = [
        ("Zinc Sources", "lightbulb.fill"),
        ("Vitamin A Sources", "cross.case.fill"),
        ("Healthy Eating Tips", "app.badge.checkmark")
    ]

    // MARK: – Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var mealType: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "breakfast"
        case 12..<17: return "lunch"
        default: return "dinner"
        }
    }

    // MARK: – Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile Greeting
                    profileHeader

                    // Search Bar
                    searchBar

                    // Filter
                    filterPicker

                    // Loading + Errors
                    if isLoading {
                        ProgressView("Loading meal ideas...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Suggestions
                    if !mealSuggestions.isEmpty {
                        Text("Meal Suggestions:")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(mealSuggestions, id: \.self) { meal in
                            Text(meal)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }

                    // Sections
                    categorySection
                    articleSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.colorFromHex("#58B361"),
                        Color.colorFromHex("#264D2A")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
        .navigationBarHidden(true)
        .onAppear(perform: fetchUserName)
    }

    // MARK: – Profile Header with Initials
    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            // Greeting and Username on the left
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting),")
                    //.font(.title2)
                    .font(.system(size: 23, weight: .regular))
                    .foregroundColor(.white)
                Text(userName)
                    //.font(.title)
                    .font(.system(size: 30, weight: .bold))
                    //.font(.custom("Poppins-Bold", size: 35))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.leading, -15)

           Spacer(minLength: 20) // This will push the initials to the right side

            // Initials on the right
            Text(userInitials)
               // .font(.headline)
               // .font(.custom("Poppins-Bold", size: 30))
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
                .onSubmit { fetchMealIdeas(query: searchText) }
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

    private var categorySection: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.0) { category, icon in
                        categoryCard(title: category, icon: icon)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func categoryCard(title: String, icon: String) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 180)

                VStack {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
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

    // MARK: – Fetch Name + Initials
    private func fetchUserName() {
        guard let user = authService.user else {
            self.userName = "Guest"
            self.userInitials = "GG"
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

        self.userName = fullName.isEmpty ? emailFallback : fullName

        if !first.isEmpty || !last.isEmpty {
            let firstInitial = first.first.map { String($0).uppercased() } ?? ""
            let lastInitial = last.first.map { String($0).uppercased() } ?? ""
            self.userInitials = "\(firstInitial)\(lastInitial)"
        } else if let email = user.email {
            let parts = email.components(separatedBy: "@").first ?? ""
            let chars = parts.prefix(2).uppercased()
            self.userInitials = chars
        } else {
            self.userInitials = "US"
        }
    }

    // MARK: – API
    private func fetchMealIdeas(query: String) {
        guard !query.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let apiKey = "YOUR_API_KEY"
        let baseURL = "https://api.spoonacular.com/recipes/complexSearch"
        var urlString = "\(baseURL)?query=\(query)&mealType=\(mealType)&apiKey=\(apiKey)"

        if selectedDietaryFilter != "None" {
            urlString += "&diet=\(selectedDietaryFilter.lowercased())"
        }

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                defer { isLoading = false }
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    errorMessage = "No data received."
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]] {
                        mealSuggestions = results.compactMap { $0["title"] as? String }
                    } else {
                        errorMessage = "Unable to parse meal suggestions."
                    }
                } catch {
                    errorMessage = "Error parsing data."
                }
            }
        }.resume()
    }
}

// MARK: – Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SupabaseAuthService()) // Inject service
    }
}

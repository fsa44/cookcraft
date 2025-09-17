import SwiftUI
import FirebaseAuth



struct HomeView: View {
    // MARK: – State
    @State private var searchText = ""
    @State private var mealSuggestions: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var userName: String = "Guest"

    // Meal filtering options
    @State private var selectedDietaryFilter: String = "None"
    private let dietaryFilters = ["None", "Vegetarian", "Gluten-Free", "Vegan", "Dairy-Free"]

    // Example data
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
        case 5..<12:   return "Good Morning"
        case 12..<17:  return "Good Afternoon"
        default:       return "Good Evening"
        }
    }
    private var mealType: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:   return "breakfast"
        case 12..<17:  return "lunch"
        default:       return "dinner"
        }
    }

    // MARK: – Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Greeting + User Name
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(greeting),")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text(userName)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .onAppear(perform: fetchUserName)

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for meal ideas...", text: $searchText)
                            .foregroundColor(.black)
                            .onSubmit { fetchMealIdeas(query: searchText) }
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)

                    // Dietary Filter Picker
                    Picker("Dietary Preference", selection: $selectedDietaryFilter) {
                        ForEach(dietaryFilters, id: \.self) { filter in
                            Text(filter)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)

                    // Loading Indicator
                    if isLoading {
                        ProgressView("Loading meal ideas...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }

                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Meal Suggestions List
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

                    // Categories Section
                    Text("Categories")
                        .font(.headline)
                        .foregroundColor(.white)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categories, id: \.0) { category, icon in
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
                                            Text(category)
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
                        }
                        .padding(.horizontal)
                    }

                    // Educational Articles Section
                    Text("Educational Articles")
                        .font(.headline)
                        .foregroundColor(.white)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(articles, id: \.0) { article, icon in
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
                                            Text(article)
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
                        }
                        .padding(.horizontal)
                    }
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
    }

    // MARK: – Methods

    /// Fetches FirebaseAuth.currentUser and resolves a display name or fallback.
    private func fetchUserName() {
        guard let user = Auth.auth().currentUser else {
            userName = "Guest"
            return
        }

        if let fullName = user.displayName,
           !fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            // Capitalize each part of the name just in case
            userName = fullName
                .trimmingCharacters(in: .whitespaces)
                .split(separator: " ")
                .map { $0.capitalized }
                .joined(separator: " ")
        } else if let email = user.email,
                  let localPart = email.components(separatedBy: "@").first,
                  !localPart.isEmpty {
            userName = localPart
                .replacingOccurrences(of: ".", with: " ")
                .split(separator: " ")
                .map { $0.capitalized }
                .joined(separator: " ")
        } else {
            userName = "User"
            errorMessage = "Unable to fetch full name."
        }
    }

    /// Fetches meal ideas from the external API.
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
        }
        .resume()
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

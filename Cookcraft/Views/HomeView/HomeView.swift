import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var mealSuggestions: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Meal filtering options
    @State private var selectedDietaryFilter: String = "None"  // Default filter: No filter
    private let dietaryFilters = ["None", "Vegetarian", "Gluten-Free", "Vegan", "Dairy-Free"]
    
    // Example data
    let categories = [
        ("Breakfast Ideas", "sun.max.fill"),
        ("Snack Ideas", "apple.logo"),
        ("Lunch Meals", "leaf.fill"),
        ("Dinner Recipes", "fork.knife")
    ]
    
    let articles = [
        ("Zinc Sources", "lightbulb.fill"),
        ("Vitamin A Sources", "cross.case.fill"),
        ("Healthy Eating Tips", "app.badge.checkmark")
    ]
    
    // Computed property for dynamic greeting and meal type
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var mealType: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "breakfast"
        case 12..<17: return "lunch"
        default: return "dinner"
        }
    }

    // Function to fetch meal ideas based on search query and selected dietary filter
    func fetchMealIdeas(query: String) {
        guard !query.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        
        // Construct the API URL with filters
        let apiKey = "YOUR_API_KEY"  // Replace with your actual API key (e.g., Spoonacular, Edamam, etc.)
        let baseURL = "https://api.spoonacular.com/recipes/complexSearch"  // Replace with your meal API URL
        var urlString = "\(baseURL)?query=\(query)&mealType=\(mealType)&apiKey=\(apiKey)"
        
        // Add dietary filter to the request if selected
        if selectedDietaryFilter != "None" {
            urlString += "&diet=\(selectedDietaryFilter.lowercased())"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        // Perform the network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                    return
                }

                do {
                    // Parse the response JSON
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = jsonResponse["results"] as? [[String: Any]] {
                        self.mealSuggestions = results.compactMap { result in
                            return result["title"] as? String
                        }
                    } else {
                        self.errorMessage = "Unable to parse meal suggestions."
                    }
                } catch {
                    self.errorMessage = "Error parsing data."
                }

                self.isLoading = false
            }
        }.resume()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Greeting
                    VStack(alignment: .leading, spacing: 5) {
                        Text(greeting)
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Jane Doe")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for meal ideas...", text: $searchText)
                            .foregroundColor(.black)
                            .onSubmit {
                                fetchMealIdeas(query: searchText)  // Call function on submit
                            }
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
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Display Meal Suggestions
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

                    // Categories Section as Horizontal Scrolling Cards with Icons and Gradients for Icons
                    Text("Categories")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categories, id: \.0) { category, icon in
                                VStack {
                                    // Card for each category
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 200, height: 180)
                                        
                                        VStack {
                                            // Icon with gradient background
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

                    // Educational Articles Section as Horizontal Scrolling Cards with Icons and Gradients for Icons
                    Text("Educational Articles")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(articles, id: \.0) { article, icon in
                                VStack {
                                    // Card for each article
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 200, height: 210)
                                        
                                        VStack {
                                            // Icon with gradient background
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
}



#Preview {
    HomeView()
}

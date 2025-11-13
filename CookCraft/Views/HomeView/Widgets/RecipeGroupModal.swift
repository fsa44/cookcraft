////
////  RecipeGroupModal.swift
////  CookCraft
////
////  Created by Fatmasarah Abdikadir on 12/11/2025.
////


import SwiftUI

struct RecipeGroupModal: View {
    let recipes: [Recipe]
    @Binding var isPresented: Bool
    
    @State private var displayedRecipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?
    @State private var showDetailSheet: Bool = false
    
    private let daysOfWeek = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    @State private var selectedDays: Set<String> = []
    
    var groupedRecipes: [String: [Recipe]] {
        Dictionary(grouping: displayedRecipes) { $0.category ?? "Other" }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 15) {
                HStack {
                    Text("Meal Suggestions")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button("Shuffle") {
                        displayedRecipes = Array(recipes.shuffled().prefix(16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.bottom, 5)
                
                ScrollView {
                    ForEach(groupedRecipes.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .foregroundColor(.gray)
                            ForEach(groupedRecipes[category]!, id: \.id) { recipe in
                                Button(action: {
                                    selectedRecipe = recipe
                                    selectedDays = []
                                    showDetailSheet = true
                                }) {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
            .frame(maxWidth: 530)
            .shadow(radius: 20)
            .onAppear {
                displayedRecipes = Array(recipes.shuffled().prefix(16))
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title)
                    }
                    .padding(15)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            if let recipe = selectedRecipe {
                RecipeDetailSheet(recipe: recipe,
                                  selectedDays: $selectedDays,
                                  onSave: { days in
                                      showDetailSheet = false
                                      // Handle save here
                                  })
            }
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(recipe.name)
                .font(.headline)
            if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.15)
                }
                .frame(height: 120)
                .cornerRadius(10)
            }
            Text(recipe.description ?? "")
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
        .padding(6)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct RecipeDetailSheet: View {
    let recipe: Recipe
    @Binding var selectedDays: Set<String>
    var onSave: (Set<String>) -> Void
    
    private let daysOfWeek = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    func bindingForDay(_ day: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { selectedDays.contains(day) },
            set: { selected in
                if selected {
                    selectedDays.insert(day)
                } else {
                    selectedDays.remove(day)
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .bold()
                    
                    if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                    }
                    
                    Text("Ingredients:")
                        .font(.headline)
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("- \(ingredient)")
                    }
                    
                    if let desc = recipe.description {
                        Text("Description:")
                            .font(.headline)
                        Text(desc)
                    }
                    
                    Text("Select Days to Plan:")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    VStack(spacing: 10) {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Toggle(day, isOn: bindingForDay(day))
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Button("Save to Planner") {
                        onSave(selectedDays)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onSave(selectedDays)
                    }
                }
            }
        }
    }
}

//
//  FavouriteView.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 11/11/2025.
//


import SwiftUI

struct PlannerView: View {
    @Binding var plannedRecipes: [PlannedRecipe]
    private let daysOfWeek = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    
    @State private var selectedDayIndex = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.colorFromHex("#58B361"),
                        Color.colorFromHex("#264D2A")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Title with reduced top spacing
                    Text("Meal Planner")
                        .font(.system(size: 37, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 25)
                        .padding(.trailing, 130)
                    
                        .padding(.horizontal, 20)
                        .padding(.top, 4) // reduced space above
                        .padding(.bottom, 8)
                    
                    // Static Compact Day Bar
                    HStack(spacing: 8) {
                        ForEach(daysOfWeek.indices, id: \.self) { index in
                            let day = daysOfWeek[index]
                            Text(day)
                                .font(.subheadline)
                                .fontWeight(selectedDayIndex == index ? .heavy : .medium)
                                .foregroundColor(selectedDayIndex == index ? .white : .white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedDayIndex == index ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        selectedDayIndex = index
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // Meal list for the selected day
                    let selectedDay = daysOfWeek[selectedDayIndex]
                    let recipesForDay = plannedRecipes.filter { $0.assignedDays.contains(selectedDay) }
                    
                    if recipesForDay.isEmpty {
                        Spacer()
                        Text("No meals planned for \(selectedDay)")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            let categories = Array(Set(recipesForDay.compactMap { $0.recipe.category })).sorted()
                            
                            ForEach(categories, id: \.self) { category in
                                Section(header: Text(category).foregroundColor(.white)) {
                                    let categoryRecipes = recipesForDay.filter { $0.recipe.category == category }
                                    
                                    ForEach(categoryRecipes.prefix(5)) { planned in
                                        Text(planned.recipe.name)
                                            .foregroundColor(.white)
                                    }
                                    
                                    if categoryRecipes.count > 5 {
                                        Text("... and more")
                                            .foregroundColor(.white.opacity(0.6))
                                            .italic()
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .foregroundColor(.white)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

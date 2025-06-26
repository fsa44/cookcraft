//
//  ContentView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            // Add user session
            
            TabView {
                //Home Tab
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                //BMI Calculator Tab
                BMICalculatorView()
                    .tabItem {
                        Label("BMI Calculator", systemImage: "fan")
                    }
                
                // Meal Planner Tab
                MealPlannerView()
                    .tabItem {
                        Label("Meal Planner", systemImage: "chart.pie")
                    }
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
            .tint(.orange)
        }
    }
}

#Preview {
    ContentView()
}




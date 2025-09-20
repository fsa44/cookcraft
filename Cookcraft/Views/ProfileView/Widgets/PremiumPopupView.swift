//
//  PremiumPopupView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 20/09/2025.
//

import SwiftUI

struct PremiumPopupView: View {
    @Binding var showPopup: Bool
    
    // Price values
    let yearlyPrice = "$59.99/year"
    let monthlyPrice = "$6.99/month"
    let yearlyDiscount = "Save $23.89"
    
    // State to track the selected pricing option
    @State private var selectedOption: PricingOption? = nil
    
    enum PricingOption {
        case yearly
        case monthly
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("Cookcraft Premium")
                    .font(.title)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Unlock 1,000+ recipes from PhD in Bioscience and Medicine")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Get full access to your personal AI assistant")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Read and watch educational mini-courses and tips from 50+ nutritionists and doctors")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Track the balance of your meals by food groups and macronutrients")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 40)
                
                // Pricing options as selectable cards
                VStack(alignment: .leading, spacing: 15) {
                    // Yearly Option Card
                    Button(action: {
                        selectedOption = .yearly
                    }) {
                        HStack {
                            // Left: "Yearly"
                            Text("Yearly")
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Spacer(minLength: 8)

                            // Right: Price and optional discount
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(yearlyPrice)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)

                                if selectedOption == .yearly {
                                    Text(yearlyDiscount)
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding() // Inner padding for content
                        .frame(minWidth: 260, maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    selectedOption == .yearly ? Color.green : Color.gray.opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }

                    
                    // Monthly Option Card
                    Button(action: {
                        selectedOption = .monthly
                    }) {
                        HStack {
                            Text("Monthly")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Spacer(minLength: 8) // Reduced spacer for tighter layout
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(monthlyPrice)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                // No discount for monthly, but you can add here if needed
                                // Example:
                                // if selectedOption == .monthly {
                                //     Text("Some discount")
                                //         .foregroundColor(.green)
                                //         .font(.caption)
                                // }
                            }
                        }
                        .padding()
                        .frame(minWidth: 260, maxWidth: .infinity) // Same width style as yearly card
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    selectedOption == .monthly ? Color.green : Color.gray.opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 40)
                
                // Buttons
                HStack {
                    Button(action: {
                        showPopup = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // Handle activation here (e.g., activate premium)
                        showPopup = false
                    }) {
                        Text("Activate")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct PremiumPopupView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumPopupView(showPopup: .constant(true))
    }
}

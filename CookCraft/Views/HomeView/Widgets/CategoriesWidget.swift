//
//  CategoriesWidget.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 12/11/2025.
//

import SwiftUI

struct CategoriesWidget: View {
    let categories: [(title: String, imageName: String, jsonFile: String)]
    var onSelectCategory: (_ title: String, _ jsonFile: String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.title) { category in
                        categoryCard(title: category.title, imageName: category.imageName)
                            .onTapGesture {
                                onSelectCategory(category.title, category.jsonFile)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func categoryCard(title: String, imageName: String) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 180)

                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120 ) // adjust as needed
                        .clipShape(Circle()) // optional: makes image circular
                        .shadow(radius: 5)

                    Text(title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
            }
            .shadow(radius: 10)
        }
    }
}

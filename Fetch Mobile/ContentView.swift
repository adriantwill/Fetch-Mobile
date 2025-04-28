//
//  ContentView.swift
//  Fetch Mobile
//
//  Created by Adrian Will on 4/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if viewModel.isLoading {
                        ProgressView("Loading recipes...")
                    } else if (viewModel.errorMessage != nil) {
                        Text(viewModel.errorMessage ?? "Error loading recipes")
                    } else if (viewModel.recipes?.count ?? 0 < 1) {
                        Text("No recipes found")
                    } else {
                        ForEach(viewModel.recipes ?? [], id: \.uuid) { recipe in
                            RecipeRow(recipe: recipe)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) {recipe in
                RecipeView(recipe: recipe)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadRecipes()
            }
        }
        .refreshable {
            await viewModel.loadRecipes()
        }
    }
}

struct RecipeView: View {
    @State private var viewModel = ViewModel()
    let recipe: Recipe
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(recipe.cuisine)
                .font(.title)
            if let uiImage = viewModel.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }
            if let sourceUrl = recipe.source_url {
                Link(destination: URL(string: sourceUrl)!) {
                    HStack {
                        Image(systemName: "link")
                        Text("View Recipe Source")
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
            if let youtubeUrl = recipe.youtube_url {
                Link(destination: URL(string: youtubeUrl)!) {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                        Text("Watch on YouTube")
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(recipe.name)
        .onAppear{
            Task {
                await viewModel.getImage(recipe: recipe)
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @State private var viewModel = ViewModel()
    var body: some View {
        NavigationLink(value: recipe) {
            if let uiImage = viewModel.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.name)
                    .font(.title)
                    .bold()
                    .lineLimit(0)
                Text(recipe.cuisine)
            }
            .padding(.leading ,5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onAppear{
            Task {
                await viewModel.getImage(recipe: recipe)
            }
        }
    }
}

#Preview {
    ContentView()
}


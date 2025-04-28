//
//  ContentView-ViewModel.swift
//  Fetch Mobile
//
//  Created by Adrian Will on 4/27/25.
//

import Foundation
import UIKit

extension ContentView{
    @Observable
    class ViewModel{
        var recipes: [Recipe]?
        var isLoading = false
        var errorMessage: String? = nil
        var uiImage: UIImage?
        
        func loadRecipes() async {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await getRecipe(urlString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
                await MainActor.run {
                    recipes = response.recipes
                    isLoading = false
                }
            }  catch RecipeError.invalidData {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid Data"
                }
            } catch RecipeError.invalidURL {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid URL"
                }
            } catch RecipeError.invalidResponse {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid Response"
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error"
                }
            }
        }
        func getRecipe(urlString: String) async throws -> RecipeResponse{
            guard let url = URL(string: urlString) else {
                throw RecipeError.invalidURL
            }
            let request = URLRequest(url: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw RecipeError.invalidResponse
            }
            do {
                return try JSONDecoder().decode(RecipeResponse.self, from: data)
            } catch {
                throw RecipeError.invalidData
            }
        }
    }
}

extension RecipeView{
    @Observable
    class ViewModel{
        var uiImage: UIImage?
        func getImage(recipe: Recipe) async {
            do {
                guard let url = URL(string: recipe.photo_url_large ?? "") else {
                    throw RecipeError.invalidURL
                }
                uiImage = try await ImageDownloader().downloadImage(url: url)
            } catch RecipeError.invalidData {
                print("Invalid data")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension RecipeRow{
    @Observable
    class ViewModel{
        var uiImage: UIImage?
        func getImage(recipe: Recipe) async {
            do {
                guard let url = URL(string: recipe.photo_url_large ?? "") else {
                    throw RecipeError.invalidURL
                }
                uiImage = try await ImageDownloader().downloadImage(url: url)
            } catch RecipeError.invalidData {
                print("Invalid data")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

func downloadImageData(url: URL) async throws -> Data {
    let request = URLRequest(url: url)
    let (data, _) = try await URLSession.shared.data(for: request)
    return data
}

class ImageCache {
    var imageCache: NSCache<NSString, UIImage> = {
        return NSCache<NSString, UIImage>()
    }()
    func add(image: UIImage, url: URL){
        imageCache.setObject(image, forKey: url.absoluteString as NSString)
    }
    func get(name: URL) -> UIImage? {
        return imageCache.object(forKey: name.absoluteString as NSString)
    }
}

class ImageDownloader {
    private let imageCache = ImageCache()
    
    func downloadImage(url: URL) async throws -> UIImage {
        if let cachedImage = imageCache.get(name: url) {
            return cachedImage
        }
        let data = try await downloadImageData(url: url)
        guard let image = UIImage(data: data) else {
            throw RecipeError.invalidData
        }
        imageCache.add(image: image, url: url)
        return image
    }
}

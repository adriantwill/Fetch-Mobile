//
//  ContentView-Model.swift
//  Fetch Mobile
//
//  Created by Adrian Will on 4/27/25.
//

import Foundation

enum RecipeError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Hashable {
    let cuisine: String
    let name: String
    let photo_url_large: String?
    let photo_url_small: String?
    let source_url: String?
    let uuid: String
    let youtube_url: String?
}

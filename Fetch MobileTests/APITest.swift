//
//  APITest.swift
//  Fetch MobileTests
//
//  Created by Adrian Will on 4/25/25.
//

import XCTest
@testable import Fetch_Mobile

final class APITest: XCTestCase {

    let viewModel = ContentView.ViewModel()
    func testGetRecipe() async throws {
        let recipeResponse = try await viewModel.getRecipe(urlString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        XCTAssertFalse(recipeResponse.recipes.isEmpty, "Recipe response should contain recipes")
        
        if let firstRecipe = recipeResponse.recipes.first {
            XCTAssertFalse(firstRecipe.uuid.isEmpty, "Recipe UUID should not be empty")
            XCTAssertFalse(firstRecipe.name.isEmpty, "Recipe name should not be empty")
            XCTAssertFalse(firstRecipe.cuisine.isEmpty, "Recipe cuisine should not be empty")
            if let photoURLLarge = firstRecipe.photo_url_large {
                XCTAssertTrue(photoURLLarge.starts(with: "http"), "Large photo URL should be a valid URL")
            }
            if let photoURLSmall = firstRecipe.photo_url_small {
                XCTAssertTrue(photoURLSmall.starts(with: "http"), "Small photo URL should be a valid URL")
            }
            if let sourceURL = firstRecipe.source_url {
                XCTAssertTrue(sourceURL.starts(with: "http"), "Source URL should be a valid URL")
            }
            if let youtubeURL = firstRecipe.youtube_url {
                XCTAssertTrue(youtubeURL.starts(with: "http"), "YouTube URL should be a valid URL")
            }
        } else {
            XCTFail("There should be at least one recipe")
        }
    }
    func testGetRecipeErrorHandling() async {
        do {
            let _ = try await viewModel.getRecipe(urlString: "")
            XCTFail("Should have thrown an error for invalid URL")
        } catch RecipeError.invalidURL {
        } catch {
            XCTFail("Wrong error type thrown: \(error)")
        }
        do {
            let _ = try await viewModel.getRecipe(urlString: "https://d3jbb8n5wk0qxi.cloudfront.net/nonexistent.json")
            XCTFail("Should have thrown an error for invalid response")
        } catch RecipeError.invalidResponse {
        } catch {
            XCTFail("Wrong error type thrown: \(error)")
        }
        do {
            let _ = try await viewModel.getRecipe(urlString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")
            XCTFail("Should have thrown an error for invalid JSON")
        } catch RecipeError.invalidData {
        } catch {
            XCTFail("Wrong error type thrown: \(error)")
        }
    }
}

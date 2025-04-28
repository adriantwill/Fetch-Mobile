//
//  CacheTest.swift
//  Fetch MobileTests
//
//  Created by Adrian Will on 4/25/25.
//

import XCTest
@testable import Fetch_Mobile

final class CacheTest: XCTestCase {
    
    func testAddAndGetImage() {
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")!
        let image = UIImage(systemName: "star")!
        let imageCache = ImageCache()

        imageCache.add(image: image, url: url)
        let retrievedImage = imageCache.get(name: url)
        XCTAssertNotNil(retrievedImage, "Image should be retrieved from cache")
    }
    
    func testCorrectImageCache() async {
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")!
        let image = UIImage(systemName: "star")!
        let imageCache = ImageCache()
        var retrievedImage: UIImage?

        imageCache.add(image: image, url: url)
        do{
            retrievedImage = try await ImageDownloader().downloadImage(url: url)
        } catch {
            XCTFail("Error thrown: \(error)")
        }
        
        XCTAssertNotEqual(retrievedImage, image)
    }
}

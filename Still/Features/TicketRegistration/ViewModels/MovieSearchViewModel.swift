//
//  MovieSearchViewModel.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class MovieSearchViewModel {
    typealias SearchResult = (
        id: Int,
        originalTitle: String,
        title: String,
        releaseDate: String?
    )
    
    private(set) var searchResults: [SearchResult] = []
    private(set) var isLoading = false
    private(set) var didCompleteSearch = false
    private(set) var searchedQuery = ""
    
    private let searchService: TMDBSearchService
    @ObservationIgnored private var activeSearchID: UUID?
    
    init() {
        self.searchService = TMDBSearchService()
    }
    
    init(searchService: TMDBSearchService) {
        self.searchService = searchService
    }
    
    @discardableResult
    func searchMovie(title: String) async -> [SearchResult] {
        let query = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearSearchResults()
            return []
        }
        
        let searchID = UUID()
        activeSearchID = searchID
        searchedQuery = query
        searchResults = []
        didCompleteSearch = false
        isLoading = true
        defer {
            if activeSearchID == searchID {
                isLoading = false
                activeSearchID = nil
            }
        }
        
        do {
            let movies = try await searchService.searchMovie(title: query)
            guard activeSearchID == searchID else { return [] }
            
            let results = movies.map {
                (
                    id: $0.id,
                    originalTitle: $0.originalTitle,
                    title: $0.title,
                    releaseDate: $0.releaseDate
                )
            }
            
            searchResults = results
            didCompleteSearch = true
            return results
        } catch {
            guard activeSearchID == searchID else { return [] }
            
            searchResults = []
            didCompleteSearch = false
            return []
        }
    }
    
    func clearSearchResults() {
        activeSearchID = nil
        searchResults = []
        isLoading = false
        didCompleteSearch = false
        searchedQuery = ""
    }
}

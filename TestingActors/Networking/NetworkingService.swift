//
//  NetworkingService.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func executeRequestWithRetry<T>(url: URL, type: T.Type) async -> T? where T: Decodable
}

protocol PokemonServiceProtocol: AnyObject {
    func fetchResults() async -> Results?
    func obtainImagesForPokemon(results: Results?) async -> [Abilities]
}

actor NetworkServiceImplementation: NetworkServiceProtocol {
    
    private var ongoingRequests: [URL: AnyTask] = [:]
    
    private var retryAmount: Int {
        3
    }
    
    private var currentRetryAmount: Int = 0
    private var isRetrying: Bool = true
    
    private func createTask<T>(url: URL, type: T.Type) async -> Task<T, Error> where T: Decodable {
        let task = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResults = try JSONDecoder().decode(T.self, from: data)
            return decodedResults
        }
        
        return task
    }
    
    private func executeRequest<T>(url: URL, type: T.Type) async -> T? where T: Decodable {
        while isRetrying && currentRetryAmount <= retryAmount {
            
            let task = await createTask(url: url, type: type)
            ongoingRequests[url] = AnyTask(task: task)

            do {
                let results = try await task.value
                currentRetryAmount = 0
                isRetrying = false
                return results
            }
            catch {
                print("Error decoding request")
                print("Retrying request for the \(currentRetryAmount) time")
                print("")
                currentRetryAmount += 1
                isRetrying = true
            }
        }
        
        return nil
    }
    
    internal func executeRequestWithRetry<T>(url: URL, type: T.Type) async -> T? where T: Decodable {
        
        if let ongoingRequest = ongoingRequests[url] {
            do {
                return try await ongoingRequest.value()
            }
            catch {
                print("Error executing ongoing request")
                return nil
            }
        }
        
        defer { ongoingRequests.removeValue(forKey: url) }
        
        return await executeRequest(url: url, type: type)
    }
}

class PokemonServiceImplementation: PokemonServiceProtocol {
    
    private let networkServiceProtocol: NetworkServiceProtocol
    
    init(networkServiceProtocol: NetworkServiceProtocol) {
        self.networkServiceProtocol = networkServiceProtocol
    }
    
    func fetchResults() async -> Results? {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokmon") else { return nil }
        
        return await networkServiceProtocol.executeRequestWithRetry(url: url, type: Results.self)
    }
    
    func obtainImagesForPokemon(results: Results?) async -> [Abilities] {
        var abilities: [Abilities] = []
        
        guard let results = results else { return abilities }
        
        let pokemonURLs = results.results.compactMap { result in result.url }
        
        return await withTaskGroup(of: Abilities?.self) { [weak self] taskGroup in
            guard let self = self else { return abilities }
            
            for url in pokemonURLs {
                guard let url = URL(string: url) else {
                    print("Invalid URL string")
                    continue
                }
                
                taskGroup.addTask {
                    return await self.networkServiceProtocol.executeRequestWithRetry(url: url, type: Abilities.self)
                }
            }
            
            for await ability in taskGroup {
                if let ability = ability {
                    abilities.append(ability)
                }
            }
            
            return abilities
        }
    }
}

//
//  NetworkingService.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func executeRequest<T>(url: URL) async -> T? where T: Decodable
}

protocol PokemonServiceProtocol: AnyObject {
    func fetchResults() async -> Results?
    func obtainImagesForPokemon(results: Results?) async -> [Abilities]
}

actor NetworkServiceImplementation: NetworkServiceProtocol {
    
    private var ongoingRequests: [URL: AnyTask] = [:]
    
    internal func executeRequest<T>(url: URL) async -> T? where T: Decodable {
        
        if let ongoingRequest = ongoingRequests[url] {
            do {
                return try await ongoingRequest.value()
            }
            catch {
                print("Error executing ongoing request")
                return nil
            }
        }
        
        let task = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResults = try JSONDecoder().decode(T.self, from: data)
            return decodedResults
        }
        
        ongoingRequests[url] = AnyTask(task: task)
        
        defer { ongoingRequests.removeValue(forKey: url) }
        
        do {
            let results = try await task.value
            print(results)
            return results
        }
        catch {
            print("Error decoding information")
            return nil
        }
    }
}

class PokemonServiceImplementation: PokemonServiceProtocol {
    
    private let networkServiceProtocol: NetworkServiceProtocol
    
    init(networkServiceProtocol: NetworkServiceProtocol) {
        self.networkServiceProtocol = networkServiceProtocol
    }
    
    func fetchResults() async -> Results? {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon") else { return nil }
        
        return await networkServiceProtocol.executeRequest(url: url)
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
                    return await self.networkServiceProtocol.executeRequest(url: url)
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

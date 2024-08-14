//
//  Abilities.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import Foundation

struct Abilities: Decodable {
    let sprites: Sprites
}

struct Sprites: Decodable {
    let frontDefault: String
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

//
//  Results.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import Foundation

struct Results: Decodable {
    let results: [Result]
}

struct Result: Decodable {
    let name: String
    let url: String
}

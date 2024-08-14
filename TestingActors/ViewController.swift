//
//  ViewController.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import UIKit

class ResultsViewController: UIViewController {
    
    private let pokemonService: PokemonServiceProtocol
    
    init(pokemonService: PokemonServiceProtocol) {
        self.pokemonService = pokemonService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            await pokemonService.fetchResults()
        }
        
        Task {
            await pokemonService.fetchResults()
        }
    }
}


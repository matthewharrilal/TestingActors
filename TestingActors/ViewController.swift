//
//  ViewController.swift
//  TestingActors
//
//  Created by Space Wizard on 8/13/24.
//

import UIKit

class ResultsViewController: UIViewController {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            let results = try await networkService.fetchResults()
            await networkService.obtainImagesForPokemon(results: results)
        }
        
        Task {
            await networkService.fetchResults()
        }
    }
}


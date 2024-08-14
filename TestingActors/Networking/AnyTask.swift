//
//  AnyTask.swift
//  TestingActors
//
//  Created by Space Wizard on 8/14/24.
//

import Foundation

// 'AnyTask' abstracts a generic 'Task' to allow storing and managing tasks with different result types in a uniform way.
// It enables type-erased handling of tasks, useful for collections like dictionaries where the result type varies.

class AnyTask {
    // A closure that returns the task's result, type-erased to 'Any?'
    private var _value: () async throws -> Any?
    
    // Initializes with a generic 'Task' and stores its result in the '_value' closure.
    init<T>(task: Task<T, Never>) {
        self._value = { await task.value }
    }
    
    // Retrieves the task's value, casting it to the expected type 'T'.
    func value<T>() async throws -> T? where T: Decodable {
        return try await _value() as? T
    }
}

//
//  Delay.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/16/25.
//

import Foundation

actor Delay {
    private var seconds: Double
    var task: Task<Void, Never>?

    init(seconds: Double = 2.0) {
        self.seconds = seconds
    }

    func performWork(_ work: @Sendable @escaping () async -> Void) async {
        task?.cancel()
        
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            await work()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}


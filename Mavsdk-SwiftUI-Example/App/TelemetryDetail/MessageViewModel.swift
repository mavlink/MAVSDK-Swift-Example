//
//  MessageViewModel.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 21/05/21.
//

import Foundation

class MessageViewModel: ObservableObject {
    static let shared = MessageViewModel()
    private static let placeholder = "-"
    private var timer: Timer?
    
    @Published var message = MessageViewModel.placeholder {
        willSet {
            if newValue != MessageViewModel.placeholder {
                print("message: \(newValue)")
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
                self.message = MessageViewModel.placeholder
            }
        }
    }
}


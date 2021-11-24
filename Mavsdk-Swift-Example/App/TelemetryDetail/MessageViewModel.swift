//
//  MessageViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 21/05/21.
//

import Foundation

class MessageViewModel: ObservableObject {
    static let shared = MessageViewModel()
    private static let placeholder = "-"
    private var timer: Timer?
    @Published var allMessages: [LogRecord] = []
    
    @Published var message = MessageViewModel.placeholder {
        willSet {
            if newValue != MessageViewModel.placeholder {
                allMessages.append(LogRecord(newValue))
                print("message: \(newValue)")
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.message = MessageViewModel.placeholder
            }
        }
    }
}

struct LogRecord: Identifiable {
    let id = UUID()
    let date = Date()
    let message: String
    
    init(_ message: String) {
        self.message = message.replacingOccurrences(of: "\n", with: "")
    }
}


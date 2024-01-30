//
//  Task.swift
//  WebviewTestTask
//
//  Created by Tania Harbarchuk on 19.01.2024.
//

import Foundation

struct Task: Codable {
    let id: UUID
    var title: String
    var isComplete: Bool
    var date: Date?
    var time: Date?
    
    init(title: String, isComplete: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isComplete = isComplete
    }
}

//
//  QuoteManager.swift
//  LockIn
//
//  Created by Multazim Mesbah on 17/2/2026.
//
import SwiftUI

final class QuoteManager: ObservableObject {
    
    private let quoteBank: [String] = [
        "\"Lock in twin\" — Sun Tzu probably.",
        "\"If you can dodge a wrench, you can dodge a ball.\" — Dodgeball (2004)",
        "\"Just keep swimming\" — Finding Nemo (2003)",
        "\"You want to get out of the hole? First you’re going to have to put down the shovel.\" — Incredibles 2 (2018)",
        "\"Discipline beats motivation.\" — ChatGPT",
        "\"10 minutes is all it takes to start.\"",
        "\"6 7\" — Gen Alpha",
        "Who wrote these?!",
        "Who wrote these!?",
        "\"Sometimes I'll start a sentence and I don't even know where its going. I just hope I'll find it along the way\" — Michael Scott, The Office",
        "\"Friendship is like money—easier made than kept\" — Samuel Butler",
        "\"Meow\" — Queen"
    ]
    
    @Published var currentQuote: String = ""
    
    init() {
        rotateQuote()
    }
    
    func rotateQuote() {
        guard let next = quoteBank.randomElement() else { return }
        
        if quoteBank.count > 1, next == currentQuote {
            currentQuote = quoteBank.filter { $0 != next }.randomElement() ?? next
        } else {
            currentQuote = next
        }
    }
}

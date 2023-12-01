//
//  ContentView.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI


struct ContentView: View {
    var confettiRunning: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                VStack {
                    Spacer() // Pushes content to the bottom
                    HStack {
                        ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topRight)
                        Spacer()
                        ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topLeft)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(confettiRunning: true)
        .frame(width: 600, height: 400)
}

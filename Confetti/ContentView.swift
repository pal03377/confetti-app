//
//  ContentView.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI


struct ContentView: View {
    
    @State private var counter: Int = 0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                VStack {
                    Spacer() // Pushes content to the bottom
                    HStack {
                        SideConfettiCannon(counter: $counter, direction: .right, size: geometry.size)
                        .id("\(geometry.size.width)x\(geometry.size.height)") // Recreate on size changes while layouting
                        Spacer()
                        SideConfettiCannon(counter: $counter, direction: .left, size: geometry.size)
                        .id("\(geometry.size.width)x\(geometry.size.height)") // Recreate on size changes while layouting
                    }
                }
            }
            .onReceive(timer) { _ in
                self.counter += 1
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 600, height: 400)
}

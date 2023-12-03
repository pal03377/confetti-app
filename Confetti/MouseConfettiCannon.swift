//
//  MouseConfettiCannon.swift
//  Confetti
//
//  Created by Paul Schwind on 03.12.23.
//

import SwiftUI

struct MouseConfettiCannon: View {
    var mouseLocation: NSPoint
    
    var body: some View {
        Group {
            Rectangle()
                .fill(.yellow)
                .frame(width: 10, height: 10)
                .position(mouseLocation)
        }
    }
}

#Preview {
    @State var mouseLocation = NSPoint(x: 300, y: 200)
    
    return VStack {
        MouseConfettiCannon(mouseLocation: mouseLocation)
        Button("Test") {
            withAnimation {
                mouseLocation = NSPoint(x: 400, y: 500)
            }
        }
    }
    .frame(width: 600, height: 400)
}

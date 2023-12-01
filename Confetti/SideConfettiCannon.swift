//
//  SideConfettiCannon.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI
import ConfettiSwiftUI

enum ConfettiDirection {
    case left
    case right
}

struct SideConfettiCannon: View {
    @Binding
    var counter: Int
    var direction: ConfettiDirection
    var size: CGSize
    
    var body: some View {
        ConfettiCannon(
            counter: $counter,
            num: 50,
            confettiSize: 15,
            rainHeight: size.height,
            fadesOut: false,
            openingAngle: .degrees(direction == .right ? 0 : 0),
            closingAngle: .degrees(direction == .right ? 90 : -90),
            radius: max(size.width, size.height)
        )
    }
}

#Preview {
    @State var counter: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    return SideConfettiCannon(counter: $counter, direction: .right, size: CGSize(width: 600, height: 400))
        .onReceive(timer) { _ in
            counter += 1
        }
}

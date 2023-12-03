//
//  MouseConfettiCannon.swift
//  Confetti
//
//  Created by Paul Schwind on 03.12.23.
//

import SwiftUI

let MOUSE_CONFETTI_CANNON_DEBUGGING = false

class ConfettiCannonConfig: ObservableObject, Identifiable {
    init(id: UUID, position: NSPoint, direction: ConfettiDirection, velocity: Double, shooting: Bool) {
        self.id = id
        self.position = position
        self.direction = direction
        self.velocity = velocity
        self.shooting = shooting
    }

    let id: UUID
    let position: NSPoint
    let direction: ConfettiDirection
    let velocity: Double
    @Published
    var shooting: Bool = true
}

struct MouseConfettiCannon: View {
    @State
    private var mouseVelocity: CGFloat = 0
    @State
    private var lastMouseUpdateTime = Date()
    @State
    private var confettiCannonConfigs: [ConfettiCannonConfig] = []
    var mouseLocation: NSPoint
    
    var body: some View {
        Group {
            ForEach(confettiCannonConfigs) { cannonConfig in
                ConfettiCannonRepresentable(confettiRunning: cannonConfig.shooting, direction: cannonConfig.direction, emissionVelocity: cannonConfig.velocity)
                    .background(MOUSE_CONFETTI_CANNON_DEBUGGING ? .yellow : .clear)
                    .position(cannonConfig.position)
            }
            if MOUSE_CONFETTI_CANNON_DEBUGGING {
                Rectangle() // debug rect
                    .fill(.red)
                    .frame(width: 3, height: 3)
                    .position(mouseLocation)
            }
        }
        .onChange(of: mouseLocation) { (oldLocation, newLocation) in
            let distance = sqrt(pow(newLocation.x - oldLocation.x, 2) + pow(newLocation.y - oldLocation.y, 2))
            let velocity = distance / CGFloat(Date().timeIntervalSince(lastMouseUpdateTime))
            let angle = Angle.radians(atan2(0 - (newLocation.y - oldLocation.y), newLocation.x - oldLocation.x) + .pi / 2) // We reverted the y axis in ConfettiApp.swift => need to revert again for angles; angles are 90° rotated against each other
            if velocity > 1000 {
                let cannonConfig = ConfettiCannonConfig(
                    id: UUID(),
                    position: newLocation,
                    direction: ConfettiDirection(direction: angle, spread: .degrees(30)),
                    velocity: velocity,
                    shooting: true
                )
                confettiCannonConfigs.append(cannonConfig)
                // Turn off after Xs
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    confettiCannonConfigs.first { $0.id == cannonConfig.id }?.shooting = false
                }
                // Delete after Ys
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    confettiCannonConfigs.removeAll { $0.id == cannonConfig.id }
                }
            }
            lastMouseUpdateTime = Date()
        }
    }
}

#Preview {
    @State var mouseLocation = NSPoint(x: 300, y: 200)
    
    return MouseConfettiCannon(mouseLocation: mouseLocation)
        .frame(width: 600, height: 400)
}

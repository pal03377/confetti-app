//
//  MouseConfettiCannon.swift
//  Confetti
//
//  Created by Paul Schwind on 03.12.23.
//

import SwiftUI

let MOUSE_CONFETTI_CANNON_DEBUGGING = false

struct ConfettiCannonConfig: Identifiable {
    let id: UUID
    let position: NSPoint
    let direction: ConfettiDirection
    let velocity: Double
}

struct MouseConfettiCannon: View {
    @State private var mouseVelocity: CGFloat = 0
    @State private var lastMouseUpdateTime = Date()
    @State private var confettiCannonConfigs: [ConfettiCannonConfig] = []
    @State private var shootingIds: [UUID] = []
    var mouseLocation: NSPoint
    
    var body: some View {
        Group {
            ForEach(confettiCannonConfigs) { cannonConfig in
                ConfettiCannonRepresentable(
                    confettiRunning: shootingIds.contains(cannonConfig.id),
                    direction: cannonConfig.direction,
                    emissionVelocity: cannonConfig.velocity,
                    birthRate: Float(cannonConfig.velocity / 20) // Emit more when faster
                )
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
            let cannonConfig = ConfettiCannonConfig(
                id: UUID(),
                position: newLocation,
                direction: ConfettiDirection(direction: angle, spread: .degrees(30)),
                velocity: velocity / 2
            )
            confettiCannonConfigs.append(cannonConfig)
            shootingIds.append(cannonConfig.id)
            // Turn off after Xs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                shootingIds.removeAll { $0 == cannonConfig.id }
            }
            // Delete after Ys
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                confettiCannonConfigs.removeAll { $0.id == cannonConfig.id }
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

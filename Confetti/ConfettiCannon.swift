//
//  ConfettiCannon.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI

struct ConfettiDirection: Equatable {
    var direction: Angle // 0 degrees is down; counterclockwise
    var spread: Angle
    
    static var topRight: ConfettiDirection {
        return ConfettiDirection(direction: .degrees(135), spread: .degrees(45))
    }
    
    static var topLeft: ConfettiDirection {
        return ConfettiDirection(direction: .degrees(225), spread: .degrees(45))
    }
}

class ConfettiCannon: NSView {
    private var emitter = CAEmitterLayer()
    private var emissionVelocity: Double = 400
    private var direction: ConfettiDirection = .topRight
    private var birthRate: Float = 50
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupConfetti()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfetti()
    }
    
    private func updateCellProperties() {
        for cell in emitter.emitterCells ?? [] {
            cell.birthRate = birthRate
            cell.lifetime = 10
            cell.velocity = emissionVelocity
            cell.velocityRange = emissionVelocity / 2
            // Acceleration in opposite x direction of direction for drag effect
            cell.xAcceleration = 0.3 * emissionVelocity * CGFloat(cos(direction.direction.radians + .pi / 2)) // Angles are shifted 90° vs. the needed cos for the acceleration x direction
            // Gravity effect
            cell.yAcceleration = -2000 // Ensure min gravity to not look weird
            cell.spin = 0
            cell.spinRange = 10
            cell.scale = 0.5
            cell.scaleRange = 0.2
            cell.alphaSpeed = 0 - 1 / cell.lifetime // Ensure invisibility after lifetime
            cell.emissionLongitude = direction.direction.radians
            cell.emissionRange = direction.spread.radians
        }
    }
    
    func setDirection(_ direction: ConfettiDirection) {
        if direction != self.direction {
            self.direction = direction
            updateCellProperties()
        }
    }
    
    func setEmissionVelocity(_ emissionVelocity: Double) {
        if emissionVelocity != self.emissionVelocity {
            self.emissionVelocity = emissionVelocity
            updateCellProperties()
        }
    }
    
    func setBirthRate(_ birthRate: Float) {
        if birthRate != self.birthRate {
            self.birthRate = birthRate
            updateCellProperties()
        }
    }

    private func setupConfetti() {
        self.wantsLayer = true
        
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.birthRate = 1
        
        // see https://nshipster.com/caemitterlayer/ for confetti layer explaination
        // see https://bryce.co/caemitterbehavior/ for emitter behavior explaination - probably should not use
        
        emitter.emitterCells = []
        for shape in ["ellipse", "parallelogram", "spiral", "triangle"] {
            for colorIndex in 1...5 {
                let cell = CAEmitterCell()
                cell.contents = NSImage(named: NSImage.Name("\(shape)_\(colorIndex)"))?.cgImage(forProposedRect: nil, context: nil, hints: nil)
                emitter.emitterCells?.append(cell)
            }
        }
        updateCellProperties()

        emitter.beginTime = CACurrentMediaTime(); // Important fix for strange emitter behavior on stop, see https://stackoverflow.com/a/18933226/4306257. The fix does not seem to work in the preview, but it works in the final app.
        layer!.addSublayer(emitter)
    }
    
    func startConfetti() {
        emitter.lifetime = 10
    }

    func stopConfetti() {
        emitter.lifetime = 0
    }
}

struct ConfettiCannonRepresentable: NSViewRepresentable {
    var confettiRunning: Bool
    var direction: ConfettiDirection
    var emissionVelocity: Double = 400
    var birthRate: Float = 50

    func makeNSView(context: Context) -> ConfettiCannon {
        return ConfettiCannon()
    }
    
    func updateNSView(_ nsView: ConfettiCannon, context: Context) {
        nsView.setEmissionVelocity(emissionVelocity)
        nsView.setDirection(direction)
        nsView.setBirthRate(birthRate)
        if confettiRunning {
            nsView.startConfetti()
        } else {
            nsView.stopConfetti()
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: ConfettiCannon, context: Context) -> CGSize? {
        // Small 1x1 emitter
        return CGSize(width: 1, height: 1)
    }
}

#Preview {
    @State var confettiRunning = true
    
    return VStack {
        Spacer()
        HStack {
            ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topRight, emissionVelocity: 600)
                .background(Color.yellow)
            Spacer()
            Button("toggle") {
                confettiRunning.toggle()
            }
        }
    }
    .frame(width: 600, height: 400)
}

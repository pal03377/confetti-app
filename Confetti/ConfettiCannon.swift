//
//  SideConfettiCannon.swift
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
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupConfetti()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfetti()
    }
    
    func updateEmitterSize() {
        emitter.position = CGPoint(x: frame.size.width / 2, y: frame.size.height)
        emitter.emitterSize = CGSize(width: 1, height: 1)
    }

    func setDirection(_ direction: ConfettiDirection) {
        for cell in emitter.emitterCells ?? [] {
            cell.emissionLongitude = direction.direction.radians
            cell.emissionRange = direction.spread.radians
        }
    }

    private func setupConfetti() {
        updateEmitterSize()
        self.wantsLayer = true
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 1, height: 1)

        emitter.birthRate = 1

        let cell = CAEmitterCell()
        cell.name = "cell"
        cell.birthRate = 5
        cell.lifetime = 10
        cell.velocity = 700
        cell.velocityRange = 50
        cell.yAcceleration = -600 // Gravity-like effect
        cell.spinRange = 5
        cell.scale = 1
        cell.scaleRange = 0.4
        cell.contents = NSImage(named: NSImage.Name("Confetti"))?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        emitter.emitterCells = [cell]

        layer!.addSublayer(emitter)
    }
    
    func startConfetti() {
        print("Start confetti")
        emitter.birthRate = 1
        emitter.beginTime = CACurrentMediaTime(); // Weird hack to make birth rate change work correctly. Taken from https://stackoverflow.com/a/29994503/4306257. Only works in the real app, not the preview!
    }

    func stopConfetti() {
        print("Stop confetti")
        emitter.birthRate = 0
    }
}

struct ConfettiCannonRepresentable: NSViewRepresentable {
    var confettiRunning: Bool
    var direction: ConfettiDirection

    func makeNSView(context: Context) -> ConfettiCannon {
        return ConfettiCannon()
    }
    
    func updateNSView(_ nsView: ConfettiCannon, context: Context) {
        nsView.updateEmitterSize()
        nsView.setDirection(direction)
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
    return ConfettiCannonRepresentable(confettiRunning: true, direction: .topRight)
                .background(Color.yellow)
    .frame(width: 600, height: 400)
}

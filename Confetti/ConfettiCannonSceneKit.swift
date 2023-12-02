//
//  ConfettiCannonSceneKit.swift
//  Confetti
//
//  Created by Paul Schwind on 02.12.23.
//

import SwiftUI
import SceneKit

struct ConfettiCannonSceneKit: View {
    var scene: SCNScene? {
        SCNScene(named: "Confetti.scn")
    }
    
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        return cameraNode
    }
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: cameraNode,
            options: [
                .allowsCameraControl,
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled
            ]
        )
    }
}

#Preview {
    ConfettiCannonSceneKit()
}

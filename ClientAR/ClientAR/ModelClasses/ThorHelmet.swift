//
//  ThorHelmet.swift
//  ClientAR
//
//  Created by manukant tyagi on 13/12/22.
//

import Foundation
import ARKit
import SceneKit

class ThorHelmet: NSObject, VirtualContentController {
    
    static let imageName = "thor_s_helmet"
    
    var contentNode: SCNNode?
    
    var occlusionNode: SCNNode!
    
    /// - Tag: OcclusionMaterial
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
              anchor is ARFaceAnchor else { return nil }
        
#if targetEnvironment(simulator)
#error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
#else
        /*
         Write depth but not color and render before other objects.
         This causes the geometry to occlude other SceneKit content
         while showing the camera view beneath, creating the illusion
         that real-world objects are obscuring virtual 3D objects.
         */
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!, fillMesh: true)!
        print(faceGeometry.elements)
        faceGeometry.firstMaterial?.fillMode = .fill
        
        faceGeometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode.renderingOrder = -1
        
        // Add 3D asset positioned to appear as "glasses".
        let faceOverlayContent = SCNReferenceNode(named: "thor'sHelmet")
        // Assign a random color to the text.
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "thor's helmet_BaseColor")
        faceOverlayContent.childNode(withName: "text", recursively: true)?.geometry?.materials = [material]
//        faceOverlayContent.renderingOrder =
        
        faceOverlayContent.childNode(withName: "thor's", recursively: true)?.geometry?.materials = [material]
        contentNode = SCNNode()
        contentNode!.addChildNode(occlusionNode)
        contentNode!.addChildNode(faceOverlayContent)
        
        
#endif
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode.geometry as? ARSCNFaceGeometry,
              let faceAnchor = anchor as? ARFaceAnchor
        else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

//
//  Beard2.swift
//  ClientAR
//
//  Created by manukant tyagi on 29/12/22.
//

import Foundation
import ARKit
import SceneKit

class Beard2: NSObject, VirtualContentController {
    
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
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        faceGeometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode.renderingOrder = -1
        
        // Add 3D asset positioned to appear as "glasses".
        let faceOverlayContent = SCNReferenceNode(named: "beard 2")
        
        // Assign a random color to the text.
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "beard 2_BaseColor")
//        faceOverlayContent.childNode(withName: "text", recursively: true)?.geometry?.materials = [material]
        
        faceOverlayContent.childNode(withName: "beard", recursively: true)?.geometry?.materials = [material]
//        let vertices = [anchor.g]
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
        guard let childNode = node.childNode(withName: "beard", recursively: true) else {return}
        let vertices = [faceAnchor.geometry.vertices[32]]
        let newPos = vertices.reduce(vector_float3(), +) / Float(vertices.count)
       
        childNode.position.y = SCNVector3(newPos).y - childNode.boundingBox.max.y / 2 + 0.01
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    
    func getImage() -> UIImage? {
        nil
    }
}

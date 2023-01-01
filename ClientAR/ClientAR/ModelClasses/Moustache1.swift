//
//  Mustache1.swift
//  ClientAR
//
//  Created by manukant tyagi on 29/12/22.
//

import Foundation
import ARKit
import SceneKit

class Moustache1: NSObject, VirtualContentController {
    
    static let imageName = "moustache_1"
    
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
        let faceOverlayContent = SCNReferenceNode(named: "moustache 1")
        
        // Assign a random color to the text.
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "moustache 1_BaseColor")
//        faceOverlayContent.childNode(withName: "text", recursively: true)?.geometry?.materials = [material]
        
        faceOverlayContent.childNode(withName: "moustache", recursively: true)?.geometry?.materials = [material]
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
        let childNode = node.childNode(withName: "moustache", recursively: true)
        let vertices = [faceAnchor.geometry.vertices[2]]
        let newPos = vertices.reduce(vector_float3(), +) / Float(vertices.count)
        childNode?.position = SCNVector3(newPos)
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    
    func getImage() -> UIImage? {
        nil
    }
}

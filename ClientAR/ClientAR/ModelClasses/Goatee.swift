//
//  Goatee.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/12/22.
//

import Foundation
import ARKit
import SceneKit

class Goatee: NSObject, VirtualContentController {
    
    
    static let imageName = "goatee"
    
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
        let faceOverlayContent = SCNReferenceNode(named: "goatee")
        
        // Assign a random color to the text.
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "goatee_BaseColor")
//        faceOverlayContent.childNode(withName: "text", recursively: true)?.geometry?.materials = [material]
        
        faceOverlayContent.childNode(withName: "goatee", recursively: true)?.geometry?.materials = [material]
        
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
        guard let childNode = node.childNode(withName: "goatee", recursively: true) else {return}
        let vertices = [faceAnchor.geometry.vertices[34]]
        let newPos = vertices.reduce(vector_float3(), +) / Float(vertices.count)
       
        childNode.position.y = SCNVector3(newPos).y - childNode.boundingBox.max.y / 2
//        print(faceGeometry.boundingSphere.radius)
        faceGeometry.update(from: faceAnchor.geometry)
        
        
        
    }
}

//
//  NoFilter.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import Foundation
import ARKit
import SceneKit
class NoFilter: NSObject, VirtualContentController{
    var contentNode: SCNNode?
    
    func getImage() -> UIImage? {
        nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        
        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!
        
//        material.diffuse.contents = #imageLiteral(resourceName: "wireframeTexture") // Example texture map image.
        material.lightingModel = .physicallyBased
        material.transparency = 0
        
        contentNode = SCNNode(geometry: faceGeometry)
        #endif
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
}

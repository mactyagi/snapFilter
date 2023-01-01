//
//  TexturedFace.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import ARKit
import SceneKit

class TexturedFace: NSObject, VirtualContentController {

    var contentNode: SCNNode?
    
    /// - Tag: CreateARSCNFaceGeometry
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        
        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!
        
        
//        material.diffuse.contents = #imageLiteral(resourceName: "wireframeTexture") // Example texture map image.
//        material.diffuse.contents = UIImage(named: "t2")
        

        material.lightingModel = .physicallyBased
        faceGeometry.firstMaterial?.fillMode = .lines
        
        contentNode = SCNNode(geometry: faceGeometry)
        #endif
        return contentNode
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        var a = true
        if (a){
            a = false
//            for index in 0..<faceAnchor.geometry.vertices.count{
//                    let text = SCNText(string: String(index), extrusionDepth: 4)
//                    let material = SCNMaterial()
//                    material.diffuse.contents = UIColor.green
//                    material.specular.contents = UIColor.green
//                    text.materials = [material]
//                    let newNode = SCNNode()
//                    newNode.position =  SCNVector3Make(faceAnchor.geometry.vertices[index].x*1.0,faceAnchor.geometry.vertices[index].y*1.0,faceAnchor.geometry.vertices[index].z)
//                    newNode.scale = SCNVector3(x:0.00025, y:0.00025, z:0.0001)
//                    newNode.geometry = text
//                    node.addChildNode(newNode)
//                }
        }
        
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}


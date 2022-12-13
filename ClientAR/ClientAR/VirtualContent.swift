//
//  VirtualContent.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import ARKit
import SceneKit

enum VirtualContentType: Int, CaseIterable {
    case nothing, tattoo, anime, beard, transforms, texture, geometry, videoTexture, blendShape, gasMask, sunglasses, superhero
    
    func makeController() -> VirtualContentController {
        switch self {
        case .transforms:
            return TransformVisualization()
        case .texture:
            return TexturedFace()
        case .geometry:
            return FaceOcclusionOverlay()
        case .videoTexture:
            return VideoTexturedFace()
        case .blendShape:
            return BlendShapeCharacter()
        case .nothing:
            return NoFilter()
        case .gasMask:
            return GasMask()
        case .sunglasses:
            return Sunglasses()
        case .superhero:
            return SuperHero()
        case .tattoo:
            return Tattoo()
        case .beard:
            return Beard()
        case .anime:
            return Anime()
        }
    }
    
    
    
   func image() -> UIImage?{
       switch self {
       case .transforms:
           return TransformVisualization().getImage()
       case .texture:
           return TexturedFace().getImage()
       case .geometry:
           return FaceOcclusionOverlay().getImage()
       case .videoTexture:
           return VideoTexturedFace().getImage()
       case .blendShape:
           return BlendShapeCharacter().getImage()
       case .nothing:
           return NoFilter().getImage()
       case .gasMask:
           return GasMask().getImage()
       case .sunglasses:
           return Sunglasses().getImage()
       case .superhero:
           return SuperHero().getImage()
       case .tattoo:
           return Tattoo().getImage()
       case .beard:
           return Beard().getImage()
       case .anime:
           return Anime().getImage()
       }
    }
}

/// For forwarding `ARSCNViewDelegate` messages to the object controlling the currently visible virtual content.
protocol VirtualContentController: ARSCNViewDelegate {
    /// The root node for the virtual content.
    var contentNode: SCNNode? { get set }
    
    func getImage() -> UIImage?
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
}


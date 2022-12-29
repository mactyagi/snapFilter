//
//  VirtualContent.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import ARKit
import SceneKit

enum VirtualContentType: Int, CaseIterable {
    case nothing, ghoulMask, hieMask, kakashiHatake, kitsuneMask, sniperMask, sunglassesGold, sunglassesHeart, cyclops, thor, wolverine,  anime, beard, gasMask, sunglasses, superhero, transforms, texture, geometry, videoTexture, blendShape
    
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
        case .beard:
            return Beard()
        case .anime:
            return Anime()
        case .thor:
            return ThorHelmet()
        case .wolverine:
            return WolverineMask()
        case .cyclops:
            return CyclopsMask()
        case .sunglassesGold:
            return SunglassesGold()
        case .sunglassesHeart:
            return SunglassesHeart()
        case .ghoulMask:
            return GhoulMask()
        case .hieMask:
            return HieMask()
        case .kakashiHatake:
            return KakashiHatake()
        case .kitsuneMask:
            return KitsuneMask()
        case .sniperMask:
            return SniperMask()
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
       case .beard:
           return Beard().getImage()
       case .anime:
           return Anime().getImage()
       case .thor:
           return ThorHelmet().getImage()
       case .wolverine:
           return WolverineMask().getImage()
       case .cyclops:
           return CyclopsMask().getImage()
       case .sunglassesGold:
           return SunglassesGold().getImage()
       case .sunglassesHeart:
           return SunglassesHeart().getImage()
       case .ghoulMask:
           return GhoulMask().getImage()
       case .hieMask:
           return HieMask().getImage()
       case .kakashiHatake:
           return KakashiHatake().getImage()
       case .kitsuneMask:
           return KitsuneMask().getImage()
       case .sniperMask:
           return SniperMask().getImage()
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


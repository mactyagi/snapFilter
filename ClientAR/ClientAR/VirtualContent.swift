//
//  VirtualContent.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import ARKit
import SceneKit

enum VirtualContentType: Int, CaseIterable {
    case nothing, beauty1, beauty2, beauty3, beauty4, beauty5, beauty6, beauty7, beauty8, beauty9, beauty10, goatee, beard2, beard1, moustache1, moustache2, ghoulMask, hieMask, kakashiHatake, kitsuneMask, sniperMask, sunglassesGold, sunglassesHeart, cyclops, thor, wolverine,  anime, beard, gasMask, sunglasses, superhero, transforms, texture, geometry, videoTexture, blendShape
    
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
        case .moustache1:
            return Moustache1()
        case .moustache2:
            return Moustache2()
        case .beard1:
            return Beard1()
        case .beard2:
            return Beard2()
        case .goatee:
            return Goatee()
        case .beauty1:
            return Beauty1()
        case .beauty2:
            return Beauty2()
        case .beauty3:
            return Beauty3()
        case .beauty4:
            return Beauty4()
        case .beauty5:
            return Beauty5()
        case .beauty6:
            return Beauty6()
        case .beauty7:
            return Beauty7()
        case .beauty8:
            return Beauty8()
        case .beauty9:
            return Beauty9()
        case .beauty10:
            return Beauty10()
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
       case .moustache1:
           return Moustache1().getImage()
       case .moustache2:
           return Moustache2().getImage()
       case .beard1:
           return Beard1().getImage()
       case .beard2:
           return Beard2().getImage()
       case .goatee:
           return Goatee().getImage()
       case .beauty1:
           return Beauty1().getImage()
       case .beauty2:
           return Beauty2().getImage()
       case .beauty3:
           return Beauty3().getImage()
       case .beauty4:
           return Beauty4().getImage()
       case .beauty5:
           return Beauty5().getImage()
       case .beauty6:
           return Beauty6().getImage()
       case .beauty7:
           return Beauty7().getImage()
       case .beauty8:
           return Beauty8().getImage()
       case .beauty9:
           return Beauty9().getImage()
       case .beauty10:
           return Beauty10().getImage()
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


//
//  VirtualContent.swift
//  ClientAR
//
//  Created by manukant tyagi on 30/11/22.
//

import ARKit
import SceneKit

enum VirtualContentType: Int, CaseIterable {
    case nothing,thor,  beauty1, beauty2, beauty3, beauty4, beauty5, beauty6, beauty7, beauty8, beauty9, beauty10, goatee, beard2, beard1, moustache1, moustache2, ghoulMask, hieMask, kakashiHatake, kitsuneMask, sniperMask, sunglassesGold, sunglassesHeart, cyclops,  wolverine,  anime, beard, gasMask, sunglasses, superhero, videoTexture, blendShape
    
    func makeController() -> VirtualContentController {
        switch self {
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
    
    
    
   func imageName() -> String{
       switch self {
       case .videoTexture:
           return VideoTexturedFace.imageName
       case .blendShape:
           return BlendShapeCharacter.imageName
       case .nothing:
           return ""
       case .gasMask:
           return GasMask.imageName
       case .sunglasses:
           return Sunglasses.imageName
       case .superhero:
           return SuperHero.imageName
       case .beard:
           return Beard.imageName
       case .anime:
           return Anime.imageName
       case .thor:
           return ThorHelmet.imageName
       case .wolverine:
           return WolverineMask.imageName
       case .cyclops:
           return CyclopsMask.imageName
       case .sunglassesGold:
           return SunglassesGold.imageName
       case .sunglassesHeart:
           return SunglassesHeart.imageName
       case .ghoulMask:
           return GhoulMask.imageName
       case .hieMask:
           return HieMask.imageName
       case .kakashiHatake:
           return KakashiHatake.imageName
       case .kitsuneMask:
           return KitsuneMask.imageName
       case .sniperMask:
           return SniperMask.imageName
       case .moustache1:
           return Moustache1.imageName
       case .moustache2:
           return Moustache2.imageName
       case .beard1:
           return Beard1.imageName
       case .beard2:
           return Beard2.imageName
       case .goatee:
           return Goatee.imageName
       case .beauty1:
           return Beauty1.imageName
       case .beauty2:
           return Beauty2.imageName
       case .beauty3:
           return Beauty3.imageName
       case .beauty4:
           return Beauty4.imageName
       case .beauty5:
           return Beauty5.imageName
       case .beauty6:
           return Beauty6.imageName
       case .beauty7:
           return Beauty7.imageName
       case .beauty8:
           return Beauty8.imageName
       case .beauty9:
           return Beauty9.imageName
       case .beauty10:
           return Beauty10.imageName
       }
    }
}

/// For forwarding `ARSCNViewDelegate` messages to the object controlling the currently visible virtual content.
protocol VirtualContentController: ARSCNViewDelegate {
    /// The root node for the virtual content.
    var contentNode: SCNNode? { get set }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
}


//
//  FilterS.swift
//  ClientAR
//
//  Created by manukant tyagi on 23/11/22.
//

import Foundation
import ARKit

class FilterClass{
    var filters: [Filter] = []
    
    init(){
        filters.append(Filter(transperency: 1))
        filters.append(Filter(imageName: "s", meshName: "s", transperency: 1))
        filters.append(Filter(imageName: "blushing", meshName: "blushing", transperency: 1))
        filters.append(Filter(imageName: "s", modelName: "overlayModel", transperency: 0))
    }
}

func getFilterNode(index: Int, geometry: ARSCNFaceGeometry?)->SCNNode?{
    let newNode = SCNNode()
    
    return newNode
    
}

func getFilterImage(index: Int){
    
}


struct Filter{
    var imageName: String?
    var meshName: String?
    var modelName: String?
    var transperency: CGFloat
}

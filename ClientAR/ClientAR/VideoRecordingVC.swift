//
//  VideoRecordingVC.swift
//  drewPIC
//
//  Created by Ankit Gabani on 29/09/22.
//

import UIKit
import ARKit
import SceneKit
import Photos
import ARCapture

class VideoRecordingVC: UIViewController //, AVCaptureFileOutputRecordingDelegate
{
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    
    var filterArray : [VirtualContentType] = []
    
    var faceAnchorsAndContentControllers: [ARFaceAnchor: VirtualContentController] = [:]
    
    var capture: ARCapture?
    var isRecording:Bool = false
    
    
    var selectedVirtualContent: VirtualContentType? {
        didSet {
            guard oldValue != nil, oldValue != selectedVirtualContent
                else { return }
            
            // Remove existing content when switching types.
            for contentController in faceAnchorsAndContentControllers.values {
                contentController.contentNode?.removeFromParentNode()
            }
            
            // If there are anchors already (switching content), create new controllers and generate updated content.
            // Otherwise, the content controller will place it in `renderer(_:didAdd:for:)`.
            for anchor in faceAnchorsAndContentControllers.keys {
                
                if let contentController = selectedVirtualContent?.makeController(), let node = sceneView.node(for: anchor),
                let contentNode = contentController.renderer(sceneView, nodeFor: anchor) {
                    node.addChildNode(contentNode)
                    faceAnchorsAndContentControllers[anchor] = contentController
                }
            }
        }
    }
//    var filtersClass = FilterClass()
    var index = 0
    let myCollectionViewFlowLayout = MyCollectionViewFlowLayout()
    var centerCell: FilterCollectionViewCell?{
        didSet{
            if centerCell != nil{
                centerCell?.layer.borderWidth = 5
                selectedVirtualContent = filterArray[index]
            }else{
                selectedVirtualContent = filterArray[0]
            }
        
        }
    }
    
    
    
    //MARK: - View Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        lpgr.minimumPressDuration = 1
        collectionView.addGestureRecognizer(lpgr)
        capture = ARCapture(view: sceneView)
        
        let layoutMargin = collectionView.layoutMargins.left + collectionView.layoutMargins.right
        let sideInset = (view.frame.width / 2) - layoutMargin
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        sceneView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = myCollectionViewFlowLayout
        collectionView.showsHorizontalScrollIndicator = false
        
//        selectedVirtualContent = VirtualContentType(rawValue: 0)
        addVirtualContentTypeInArray()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
        
        
    }
    
    func addVirtualContentTypeInArray(){
        for virtual in VirtualContentType.allCases{
            filterArray.append(virtual)
        }
        selectedVirtualContent = filterArray.first
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
//           if gesture.state != .ended {
//               return
//           }

           let p = gesture.location(in: self.collectionView)

           if let indexPath = self.collectionView.indexPathForItem(at: p) {
               // get the cell at indexPath (the one you long pressed)
               let cell = self.collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
               
               if cell == centerCell{
                
                   switch gesture.state{
                       
                   case .possible:
                       print("possible")
                   case .began:
                       print("began")
                      cell?.layer.borderWidth = 5
                      cell?.layer.borderColor = UIColor.red.cgColor
                       capture?.start()
                       
                   case .changed:
                       print("changed")
                   case .ended:
                       print("ended")
                       cell?.layer.borderWidth = 5
                       cell?.layer.borderColor = UIColor.white.cgColor
                       capture?.stop({ isComplete in
                           print("recording Complete")
                       })
                   case .cancelled:
                       print("cancelled")
                   case .failed:
                       print("failed")
                   @unknown default:
                       print("unknown")
                   }
//                   print("center cell")
//                   cell?.layer.borderWidth = 4
//                   cell?.layer.borderColor = UIColor.red.cgColor
                   
               }
               // do stuff with the cell
           } else {
               print("couldn't find index path")
           }
       }


    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}



extension VideoRecordingVC: ARSCNViewDelegate {
        
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // If this is the first time with this anchor, get the controller to create content.
        // Otherwise (switching content), will change content when setting `selectedVirtualContent`.
        DispatchQueue.main.async {
            
            if let contentController = self.selectedVirtualContent?.makeController(), node.childNodes.isEmpty, let contentNode = contentController.renderer(renderer, nodeFor: faceAnchor) {
                node.addChildNode(contentNode)
                self.faceAnchorsAndContentControllers[faceAnchor] = contentController
            }
        }
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let contentController = faceAnchorsAndContentControllers[faceAnchor],
            let contentNode = contentController.contentNode else {
            return
        }
        
        contentController.renderer(renderer, didUpdate: contentNode, for: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        faceAnchorsAndContentControllers[faceAnchor] = nil
    }
}



extension VideoRecordingVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.filterImageView.image =  UIImage(named: filterArray[indexPath.row].imageName())
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.backgroundColor = .black
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + scrollView.contentOffset.x, y: collectionView.frame.size.height / 2 + scrollView.contentOffset.y)
        
        if let indexpath = collectionView.indexPathForItem(at: centerPoint), centerCell == nil{
            index = indexpath.row
            centerCell = collectionView.cellForItem(at: indexpath) as? FilterCollectionViewCell
            print(scrollView.decelerationRate)
            centerCell?.transformToLarge()
        }
        
        if let cell = centerCell{
            let offsetX = centerPoint.x - cell.center.x
            
            if offsetX < -34 || offsetX > 34{
                cell.transformToStandard()
                centerCell = nil
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let centerCell = centerCell{
//            if centerCell == collectionView.cellForItem(at: indexPath){
//                if isRecording{
//                    isRecording = false
////                    capture?.stop { complete in
////                    }
//                }else{
////                    capture?.start()
//                    isRecording = true
//                }
//
//
//            }
//        }
    }
    
    
}




final class MyCollectionViewFlowLayout: UICollectionViewFlowLayout{
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 15
        minimumLineSpacing = 15
        itemSize = CGSize(width: 70, height: 70)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)

        let itemSpace = itemSize.width + minimumInteritemSpacing
        var currentItemIdx = round(collectionView.contentOffset.x / itemSpace)

        // Skip to the next cell, if there is residual scrolling velocity left.
        // This helps to prevent glitches
        let vX = velocity.x
        if vX > 0 {
          currentItemIdx += 1
        } else if vX < 0 {
          currentItemIdx -= 1
        }

        let nearestPageOffset = currentItemIdx * itemSpace
        return CGPoint(x: nearestPageOffset,
                       y: parent.y)
      }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//            guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
//
//            var offsetAdjustment = CGFloat.greatestFiniteMagnitude
//            let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
//
//            let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
//
//            let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
//
//            layoutAttributesArray?.forEach({ (layoutAttributes) in
//                let itemOffset = layoutAttributes.frame.origin.x
//                if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
//                    offsetAdjustment = itemOffset - horizontalOffset
//                }
//            })
//
//            return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
//        }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
//        let horizontalOffset = proposedContentOffset.x + collectionView!.contentInset.left
//        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
//        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
//        layoutAttributesArray?.forEach({ (layoutAttributes) in
//            let itemOffset = layoutAttributes.frame.origin.x
//            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
//                offsetAdjustment = itemOffset - horizontalOffset
//            }
//        })
//        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
//    }
}






extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
           //catch the error somehow
        }
    }
}


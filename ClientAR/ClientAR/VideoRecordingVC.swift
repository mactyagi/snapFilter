//
//  VideoRecordingVC.swift
//  drewPIC
//
//  Created by Ankit Gabani on 29/09/22.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import ARKit
import SceneKit
import Photos

class VideoRecordingVC: UIViewController //, AVCaptureFileOutputRecordingDelegate
{
    //MARK: - IBOutlet
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    
    var filterArray : [VirtualContentType] = []
    
    var faceAnchorsAndContentControllers: [ARFaceAnchor: VirtualContentController] = [:]
    
    var snapshotArray:[[String:Any]] = [[String:Any]]()
    var lastTime:TimeInterval = 0
    var isRecording:Bool = false;
    
    var pixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor?
    var videoInput:AVAssetWriterInput?;
    var assetWriter:AVAssetWriter?;
    
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
    
    var progress: KDCircularProgress!
//    var filtersClass = FilterClass()
    var index = 0
    let myCollectionViewFlowLayout = MyCollectionViewFlowLayout()
    var centerCell: FilterCollectionViewCell?{
        didSet{
            if centerCell != nil{
                selectedVirtualContent = filterArray[index]
            }
        
        }
    }
    
    
    
    
//    let colors = [UIColor.red, UIColor.blue, UIColor.black, UIColor.green, UIColor.yellow, UIColor.systemPink, UIColor.green, UIColor.brown, UIColor.purple, UIColor.white, UIColor.cyan]
    
    @IBOutlet var lblCount: UILabel!
    @IBOutlet weak var btnStartREpo: UIButton!
    
    @IBOutlet weak var imgflash: UIImageView!
    
    @IBOutlet weak var viewMainPregress: KDCircularProgress!
    
    @IBOutlet weak var viewBig: UIView!
    @IBOutlet weak var viewSmall: UIView!
    
    var isFrontCamera: Bool = false
    
    var isStartRecrding: Bool = true
    var totalSeconds : Int = 0
    var faceNode = SCNNode()
    
    var counter = 44
    var timer = Timer()
    
    var recoderURL = NSURL()
    internal let context = CIContext(options: nil)
    
    var captureSession = AVCaptureSession()
    
    var movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    //MARK: - View Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let layoutMargin = collectionView.layoutMargins.left + collectionView.layoutMargins.right
        let sideInset = (view.frame.width / 2) - layoutMargin
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        //  cameraDelegate = self
        
        sceneView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = myCollectionViewFlowLayout
        collectionView.showsHorizontalScrollIndicator = false
        
//        selectedVirtualContent = VirtualContentType(rawValue: 0)
        addVirtualContentTypeInArray()
//
//        if setupSession() {
//            setupPreview()
//            startSession()
//        }
    
        
        lblCount.isHidden = true
        viewBig.isHidden = true
        viewSmall.isHidden = false
        
        viewMainPregress.startAngle = -90
        viewMainPregress.progressThickness = 0.3
        viewMainPregress.trackThickness = 0.3
        viewMainPregress.clockwise = true
        viewMainPregress.gradientRotateSpeed = 2
        viewMainPregress.roundedCorners = false
        viewMainPregress.glowMode = .forward
        viewMainPregress.glowAmount = 0
        viewMainPregress.set(colors: UIColor.red)
        viewMainPregress.trackColor = .white
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
//        btnStartREpo.addGestureRecognizer(longPressRecognizer)
        self.isFrontCamera = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
        
        
    }
    
    // Button Functionality
    func startRecording() {
        self.lastTime = 0;
        self.isRecording = true;
    }
        
    func stopRecording() {
        self.isRecording = false;
        self.saveVideo(withName: "test", imageArray: self.snapshotArray, fps: 30, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height));
    }
    
    public func didUpdateAtTime(time: TimeInterval) {
            
            if self.isRecording {
                if self.lastTime == 0 || (self.lastTime + 1/31) < time {
                    DispatchQueue.main.async { [weak self] () -> Void in
                        
                        print("UPDATE AT TIME : \(time)");
                        guard self != nil else { return }
                        self!.lastTime = time;
                        let snapshot:UIImage = self!.sceneView.snapshot()
                        
                        let scale = CMTimeScale(NSEC_PER_SEC)
                        
                        self!.snapshotArray.append([
                            "image":snapshot,
                            "time": CMTime(value: CMTimeValue((self?.sceneView.session.currentFrame!.timestamp)! * Double(scale)), timescale: scale)
                        ]);
                        
                    }
                }
            }
        }
    
    
    // MARK: SAVE VIDEO FUNCTIONALITY
    public func saveVideo(withName:String, imageArray:[[String:Any]], fps:Int, size:CGSize) {
            
            self.createURLForVideo(withName: withName) { (videoURL) in
                self.prepareWriterAndInput(imageArray:imageArray, size:size, videoURL: videoURL, completionHandler: { (error) in
                    
                    guard error == nil else {
                        // it errored.
                        return
                    }
                    
                    self.createVideo(imageArray: imageArray, fps: fps, size:size, completionHandler: { _ in
                        print("[F] saveVideo :: DONE");
                        
                        guard error == nil else {
                            // it errored.
                            return
                        }
                        
                        self.finishVideoRecordingAndSave();
                        
                    });
                });
            }
            
        }
        
        private func createURLForVideo(withName:String, completionHandler:@escaping (URL)->()) {
            // Clear the location for the temporary file.
            let temporaryDirectoryURL:URL = URL.init(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true);
            let targetURL:URL = temporaryDirectoryURL.appendingPathComponent("\(withName).mp4")
            // Delete the file, incase it exists.
            do {
                try FileManager.default.removeItem(at: targetURL);
                
            } catch let error {
                NSLog("Unable to delete file, with error: \(error)")
            }
            // return the URL
            completionHandler(targetURL);
        }
        
        private func prepareWriterAndInput(imageArray:[[String:Any]], size:CGSize, videoURL:URL, completionHandler:@escaping(Error?)->()) {
            
            do {
                self.assetWriter = try AVAssetWriter(outputURL: videoURL, fileType: AVFileType.mp4)
                
                let videoOutputSettings: Dictionary<String, Any> = [
                    AVVideoCodecKey : AVVideoCodecType.h264,
                    AVVideoWidthKey : size.width,
                    AVVideoHeightKey : size.height
                ];
        
                self.videoInput  = AVAssetWriterInput (mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
                self.videoInput!.expectsMediaDataInRealTime = true
                self.assetWriter!.add(self.videoInput!)
                
                // Create Pixel buffer Adaptor
                
                let sourceBufferAttributes:[String : Any] = [
                    (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                    (kCVPixelBufferWidthKey as String): Float(size.width),
                    (kCVPixelBufferHeightKey as String): Float(size.height)] as [String : Any]
                
                self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput!, sourcePixelBufferAttributes: sourceBufferAttributes);
        
                self.assetWriter?.startWriting();
                self.assetWriter?.startSession(atSourceTime: CMTime.zero);
                completionHandler(nil);
            }
            catch {
                print("Failed to create assetWritter with error : \(error)");
                completionHandler(error);
            }
        }
        
        private func createVideo(imageArray:[[String:Any]], fps:Int, size:CGSize, completionHandler:@escaping(String?)->()) {
            
            var currentframeTime:CMTime = CMTime.zero;
            var currentFrame:Int = 0;
            
            let startTime:CMTime = (imageArray[0])["time"] as! CMTime;
            
            while (currentFrame < imageArray.count) {
                
                // When the video input is ready for more media data...
                if (self.videoInput?.isReadyForMoreMediaData)!  {
                    print("processing current frame :: \(currentFrame)");
                    // Get current CG Image
                    let currentImage:UIImage = (imageArray[currentFrame])["image"] as! UIImage;
                    let currentCGImage:CGImage? = currentImage.cgImage;
                    
                    guard currentCGImage != nil else {
                        completionHandler("failed to get current cg image");
                        return
                    }
                    
                    // Create the pixel buffer
                    self.createPixelBufferFromUIImage(image: currentImage) { (error, pixelBuffer) in
                        
                        guard error == nil else {
                            completionHandler("failed to get pixelBuffer");
                            return
                        }
                        
                        // Calc the current frame time
                        currentframeTime = (imageArray[currentFrame])["time"] as! CMTime - startTime;
                        
                        print("SECONDS : \(currentframeTime.seconds)")
                        
                        print("Current frame time :: \(currentframeTime)");
                        
                        // Add pixel buffer to video input
                        self.pixelBufferAdaptor!.append(pixelBuffer!, withPresentationTime: currentframeTime);
                        
                        // increment frame
                        currentFrame += 1;
                    }
                }
            }
            
            // FINISHED
            completionHandler(nil);
        }
        
        
        private func createPixelBufferFromUIImage(image:UIImage, completionHandler:@escaping(String?, CVPixelBuffer?) -> ()) {
            //https://stackoverflow.com/questions/44400741/convert-image-to-cvpixelbuffer-for-machine-learning-swift
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else {
                completionHandler("Failed to create pixel buffer", nil)
                return
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            
            context?.translateBy(x: 0, y: image.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            completionHandler(nil, pixelBuffer)
        }
        
        
        private func finishVideoRecordingAndSave() {
            self.videoInput!.markAsFinished();
            self.assetWriter?.finishWriting(completionHandler: {
                print("output url : \(self.assetWriter?.outputURL)");
                
                PHPhotoLibrary.requestAuthorization({ (status) in
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (self.assetWriter?.outputURL)!)
                    }) { saved, error in
                        
                        if saved {
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            DispatchQueue.main.async {
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                        }
                        // Clear the original array
                        self.snapshotArray.removeAll();
                        // Clear memory
                        FileManager.default.clearTmpDirectory();
                    }
                })
            })
        }

    
    func addVirtualContentTypeInArray(){
        for virtual in VirtualContentType.allCases{
            filterArray.append(virtual)
        }
        selectedVirtualContent = filterArray.first
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
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = mainView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        mainView.layer.addSublayer(previewLayer)
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: camera!)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    @objc func startCapture() {
        
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
//    func startRecording() {
//
//        if movieOutput.isRecording == false {
//
//            let connection = movieOutput.connection(with: AVMediaType.video)
//
//            if (connection?.isVideoOrientationSupported)! {
//                connection?.videoOrientation = .portrait
//            }
//
//            if (connection?.isVideoStabilizationSupported)! {
//                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
//            }
//
//            let device = activeInput.device
//
//            if (device.isSmoothAutoFocusSupported) {
//
//                do {
//                    try device.lockForConfiguration()
//                    device.isSmoothAutoFocusEnabled = false
//                    device.unlockForConfiguration()
//                } catch {
//                    print("Error setting configuration: \(error)")
//                }
//
//            }
//
//            //EDIT2: And I forgot this
//            outputURL = tempURL()
//            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
//
//        }
//        else {
//            stopRecording()
//        }
//
//    }
    
//    func stopRecording() {
//
//        if movieOutput.isRecording == true {
//            movieOutput.stopRecording()
//        }
//    }
    
//    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
//
//    }
    
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//
//        if (error != nil) {
//
//            print("Error recording movie: \(error!.localizedDescription)")
//
//        } else {
//
//            let videoRecorded = outputURL! as URL
//
////            let editViewVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditRecordingVideoVC") as! EditRecordingVideoVC
////            editViewVC.VideoURL = self.recoderURL
////            self.navigationController?.pushViewController(editViewVC, animated: true)
//
//        }
//
//    }
    
    
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        print("longpressed")
//
//        if sender.state == .began
//        {
//            startRecording()
//            isStartRecrding = false
//
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
//
//            lblCount.isHidden = false
//
//            viewBig.isHidden = false
//            viewSmall.isHidden = true
//
//            // start the timer
//
//            viewMainPregress.animate(fromAngle: 0, toAngle: 360, duration: 44) { completed in
//                if completed {
//                    print("animation stopped, completed")
//                    print("Done")
//                    // self.stopRecording()
//                    self.timer.invalidate()
//
//                    UIView.animate(withDuration: 3, animations: { () -> Void in
//                        //                        let editViewVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditRecordingVideoVC") as! EditRecordingVideoVC
//                        //                        editViewVC.VideoURL = self.recoderURL
//                        //                        self.navigationController?.pushViewController(editViewVC, animated: true)
//                    })
//
//                } else {
//                    print("animation stopped, was interrupted")
//                }
//            }
//        }
//        else if sender.state == .ended
//        {
//            stopRecording()
//            timer.invalidate()
//
//            UIView.animate(withDuration: 3, animations: { () -> Void in
//
//            })
//
//        }
//
//    }
    
//    @objc func updateCounter() {
//        //example functionality
//        if counter != 1
//        {
//            counter -= 1
//            lblCount.text = "\(counter)"
//        }
//        else
//        {
//            stopRecording()
//            timer.invalidate()
//
//            UIView.animate(withDuration: 3, animations: { () -> Void in
//
//            })
//
//        }
//    }
    
    //MARK: - Video Recording Method
    
    
    //MARK: - Action Method
//    @IBAction func clickedVideoCReate(_ sender: Any) {
//
//
//    }
    
    
    @IBAction func clickedCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedFlashLight(_ sender: Any) {
        
        if let avDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            if (avDevice.hasTorch) {
                do {
                    try avDevice.lockForConfiguration()
                } catch {
                    print("aaaa")
                }
                
                if avDevice.isTorchActive {
                    avDevice.torchMode = AVCaptureDevice.TorchMode.off
                    self.imgflash.image = UIImage(named: "flash (1)")
                } else {
                    avDevice.torchMode = AVCaptureDevice.TorchMode.on
                    self.imgflash.image = UIImage(named: "flash")
                    
                }
            }
            // unlock your device
            avDevice.unlockForConfiguration()
        }
        
    }
    
    @IBAction func clickedBackCamera(_ sender: Any) {
        
        if isFrontCamera == true {
            
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
            else {
                print("Unable to access back camera!")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                //Step 9
                movieOutput = AVCaptureMovieFileOutput()
                
                if captureSession.canAddInput(input) && captureSession.canAddOutput(movieOutput) {
                    
                    // Setup Microphone
                    let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
                    
                    do {
                        let micInput = try AVCaptureDeviceInput(device: microphone)
                        if captureSession.canAddInput(micInput) {
                            captureSession.addInput(micInput)
                        }
                    } catch {
                        print("Error setting device audio input: \(error)")
                        
                    }
                    
                    
                    captureSession.addInput(input)
                    captureSession.addOutput(movieOutput)
                    
                    
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.connection?.videoOrientation = .portrait
                    mainView.layer.addSublayer(previewLayer)
                    
                    //Step12
                    
                    DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                        self.captureSession.startRunning()
                        //Step 13
                        
                        DispatchQueue.main.async {
                            self.previewLayer.frame = self.mainView.bounds
                        }
                    }
                    
                }
                
            }
            catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
            isFrontCamera = false
        } else {
            
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            else {
                print("Unable to access back camera!")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                //Step 9
                movieOutput = AVCaptureMovieFileOutput()
                
                if captureSession.canAddInput(input) && captureSession.canAddOutput(movieOutput) {
                    
                    // Setup Microphone
                    let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
                    
                    do {
                        let micInput = try AVCaptureDeviceInput(device: microphone)
                        if captureSession.canAddInput(micInput) {
                            captureSession.addInput(micInput)
                        }
                    } catch {
                        print("Error setting device audio input: \(error)")
                        
                    }
                    
                    captureSession.addInput(input)
                    captureSession.addOutput(movieOutput)
                    
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.connection?.videoOrientation = .portrait
                    mainView.layer.addSublayer(previewLayer)
                    
                    //Step12
                    
                    DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                        self.captureSession.startRunning()
                        //Step 13
                        
                        DispatchQueue.main.async {
                            self.previewLayer.frame = self.mainView.bounds
                        }
                    }
                    
                }
                
            }
            catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
            isFrontCamera = true
        }
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        didUpdateAtTime(time: time)
    }
}



extension VideoRecordingVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.filterImageView.image = filterArray[indexPath.row].image()
        cell.backgroundColor = .blue
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + scrollView.contentOffset.x, y: collectionView.frame.size.height / 2 + scrollView.contentOffset.y)
        
        if let indexpath = collectionView.indexPathForItem(at: centerPoint), centerCell == nil{
            index = indexpath.row
            centerCell = collectionView.cellForItem(at: indexpath) as? FilterCollectionViewCell
            print(scrollView.decelerationRate)
//            print(scrollView.isDragging)
            centerCell?.transformToLarge()
        }
        
        if let cell = centerCell{
            let offsetX = centerPoint.x - cell.center.x
            
            if offsetX < -15 || offsetX > 15{
                cell.transformToStandard()
                centerCell = nil
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let centerCell = centerCell{
            if centerCell == collectionView.cellForItem(at: indexPath){
                print("yes")
                if isRecording{
                    stopRecording()
                }else{
                    startRecording()
                }
               
                
            }
        }
    }
    
    
}




final class MyCollectionViewFlowLayout: UICollectionViewFlowLayout{
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 16
        minimumLineSpacing = 16
        itemSize = CGSize(width: 32, height: 32)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView!.contentInset.left
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
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

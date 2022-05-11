//
//  SkyNetController.swift
//  2.12MLModelTTest
//
//  Created by Sergii Kotyk on 20/1/2022.
//

import AVFoundation
import UIKit
import Vision

class SkyNetController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBAction func destroyButton(_ sender: Any) {
        let noFace = CGRect(x: 0, y: 0, width: 0, height: 0)
        if face != noFace{
            rocketLaunch(frame: face)
        }
        face = noFace
        
    }
    @IBAction func rotateButton(_ sender: Any) {

        guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
            return
        }
        guard let currentCameraOutput: AVCaptureOutput = captureSession.outputs.first else {
            return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(currentCameraInput)
        captureSession.removeOutput(currentCameraOutput)
        
        rotate = !rotate
        addCameraInput(front: rotate)
        getCameraFrames()
        captureSession.commitConfiguration()
    }
    
    private var captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var rotate = true
    private var drawings: [CAShapeLayer] = []
    var face = CGRect(x: 0, y: 0, width: 0, height: 0)


    
    
    
    
    private func addCameraInput(front: Bool) {
        if front{
            guard var device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .front).devices.first
            else {
                fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
            }
            let cameraInput = try! AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)
            print("1")
        } else {
            guard var device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .back).devices.first
            else {
                fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
            }
            print("2")

            let cameraInput = try! AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)

        }


        
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspect
        self.mainView.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = mainView.frame
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
                DispatchQueue.main.async {
                    if let results = request.results as? [VNFaceObservation] {
                        self.handleFaceDetectionResults(results)
                    } else {
                        self.clearDrawings()
                    }
                }
            })
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
            try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            self.face = faceBoundingBoxOnScreen
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            return faceBoundingBoxShape
        })
        
        // Рамки вокруг лица
//        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox)
//        })
        self.drawings = facesBoundingBoxes
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    func rocketLaunch(frame: CGRect){
        let rocket = UIImageView(image: UIImage(named: "rocket"))
        let boom = UIImageView(image: UIImage(named: "boom"))
        let rocsize = CGSize(width: 50, height: 100)
        let boomsize = CGSize(width: 200, height: 150)
        rocket.frame = CGRect(origin: CGPoint.zero, size: rocsize)
        rocket.center = CGPoint(x: Double(Int(view.frame.size.width / 2)), y: Double(Int(view.frame.size.height - rocket.image!.size.height / 8)))
        boom.frame = CGRect(origin: CGPoint.zero, size: boomsize)
        boom.center = CGPoint(x: Double(Int(self.face.origin.x + self.face.size.width / 2)), y: Double(Int(self.face.origin.y + self.face.size.height / 2)))
        boom.alpha = 1
        boom.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        view.addSubview(rocket)
        view.addSubview(boom)
        
        DispatchQueue.global(qos: .default).async {
            while rocket.center != boom.center{
                DispatchQueue.main.async {
                    boom.frame = CGRect(origin: CGPoint.zero, size: boomsize)
                    boom.center = CGPoint(x: Double(Int(self.face.origin.x + self.face.size.width / 2)), y: Double(Int(self.face.origin.y + self.face.size.height / 2)))
                    boom.alpha = 0
                    boom.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    rocket.removeFromSuperview()
                    if rocket.center.x > boom.center.x{
                        rocket.center.x -= 1
                    } else {
                        rocket.center.x += 1
                    }
                    if rocket.center.y > boom.center.y{
                        rocket.center.y -= 1
                    } else {
                        rocket.center.y += 1
                    }
                    self.view.addSubview(rocket)
                      
                  }
                Thread.sleep(forTimeInterval: 0.002)
                print(rocket.center.y)

                  }
            DispatchQueue.main.async {
            if rocket.center == boom.center{
                rocket.removeFromSuperview()
                UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
                    boom.alpha = 1
                    boom.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        }, completion: {(_) in
                            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
                                boom.alpha = 0
                                })
                            })
                 }
                
            }
        }
     
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraInput(front: rotate)
        showCameraFeed()
        getCameraFrames()
        captureSession.startRunning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = self.mainView.frame
    }

}
    
extension SkyNetController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                debugPrint("unable to get image from sample buffer")
                return
            }
            self.detectFace(in: frame)
    }
}

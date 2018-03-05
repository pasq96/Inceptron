//
//  ViewController.swift
//  Resistor
//
//  Created by Valitutto Giuseppe on 05/03/18.
//  Copyright © 2018 Team 5.2. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import SceneKit
import ARKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ARSCNViewDelegate {
    
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let backCamera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera) else {
                return session
        }
        session.addInput(input)
        return session
    }()
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    var visionRequests = [VNRequest]()
    
    private let context = CIContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // --- ARKIT ---
        /*
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene() // SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        */
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "queue"))
        captureSession.addOutput(output)
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        /*
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        */
        
        // --- ML & Vision ---
        
        // Setup Vision Model
        guard let selectedModel = try? VNCoreMLModel(for: resistor_model().model) else {
            fatalError("Could not load model.")
        }
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
        // Start video capture.
        captureSession.startRunning()
        
        
        debugTextView.bringSubview(toFront: imageView)
        
        //orientamento dell'immagine
        guard let connection = output.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = AVCaptureDevice.Position.back == .front
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //richiamato per ogni frame
        
        guard let pixelBuffet: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffet)
        
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        DispatchQueue.main.async { [unowned self] in
            self.imageView.image = uiImage
        }
        
        print("chiamato")
 
        
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Run Vision Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }

    
    
    
    // MARK: - MACHINE LEARNING
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...1] // top 2 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        // Render Classifications
        DispatchQueue.main.async {
            // Print Classifications
            // print(classifications)
            // print("-------------")
            
            // Display Debug Text on screen
            self.debugTextView.text = "TOP 3 PROBABILITIES: \n" + classifications
            
            // Display Top Symbol
            var symbol = "❎"
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // Only display a prediction if confidence is above 1%
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                if (topPredictionName == "resistenza") { symbol = "👊" }
                if (topPredictionName == "noresistenza") { symbol = "🖐" }
            }
            
//            self.textOverlay.text = symbol
            
        }
    }

}


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


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet private weak var highlightView: UIView!
    {
        didSet {
            self.highlightView?.layer.borderColor = UIColor.red.cgColor
            self.highlightView?.layer.borderWidth = 3
            self.highlightView?.backgroundColor = .clear
        }
    }
    
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
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
	private var device: AVCaptureDevice =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
	
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var visionRequests = [VNRequest]()
    private let context = CIContext()
	
    
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!

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
        
        // make the camera appear on the screen
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
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
		
		// --- END ML & Vision ---
		
        // Start video capture.
        captureSession.startRunning()
        
        //orientamento dell'immagine
        guard let connection = output.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = AVCaptureDevice.Position.back == .front
 
        viewWidth = highlightView.bounds.width * UIScreen.main.scale //* highlightView.transform.a
        viewHeight = highlightView.bounds.height * UIScreen.main.scale //* highlightView.transform.d
		
		
		//Implementing gesture for flash on/off
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
		swipeLeft.direction = .left
		self.view.addGestureRecognizer(swipeLeft)
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
		swipeRight.direction = .right
		self.view.addGestureRecognizer(swipeRight)
    }
	
	// ----- FLASH
	@IBAction func toggleFlash(_ sender: UISwitch!, forEvent event: UIEvent) {
		if (device.hasTorch) {
			do {
				try device.lockForConfiguration()
				if (sender.isOn)
				{
					device.torchMode = .on
					try device.setTorchModeOn(level: 1.0)
				}
				else {
					if (!sender.isOn)
					{
						device.torchMode = .off
					}
				}
				device.unlockForConfiguration()
			}
			catch {
				print(error)
			}
		}
	}
	
	//gesture function
	@objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
		if (device.hasTorch) {
			do {
				try device.lockForConfiguration()
				switch gesture.direction
				{
					case UISwipeGestureRecognizerDirection.right:
						device.torchMode = .on
						try device.setTorchModeOn(level: 1.0)
						break
					case UISwipeGestureRecognizerDirection.left:
						device.torchMode = .off
						break
					default:
						break
				}
				device.unlockForConfiguration()
			}
			catch {
				print(error)
			}
			
		}
	}
	
	//---- FLASH END
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

	@IBOutlet weak var imageViewCropped: UIImageView!
	var c = 0
    var c1 = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		
		
		
		
//      richiamato per ogni frame
        c += 1
//      guard let pixelBuffet: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
//      let ciImage = CIImage(cvPixelBuffer: pixelBuffet)
//		let cropped = ciImage.cropped(to: CGRect(origin: view.center, size: CGSize(width: 400.0, height: 200.0)))
		
		//execute func defined at the end of the code
        guard let croppedCGI = getImageFromSampleBuffer(buffer: sampleBuffer) else { return }
		
        let croppedCII = CIImage(cgImage: croppedCGI)
		
		//Remove/add comment if you want view how it's displayed dropped camera
         DispatchQueue.main.async { [unowned self] in
			
			//execute func defined at the end of the code
             self.imageViewCropped.image = self.convert(cmage: croppedCII)
//           self.imageViewCropped.center = self.view.center
         }
		
        if(c >= 10){
            c1 += 1
//          print("entrato \(c1)")
            
            // Prepare CoreML/Vision Request
			let imageRequestHandler = VNImageRequestHandler(ciImage: croppedCII, options: [:])
            
            // Run Vision Image Request
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print(error)
            }
			
			
            c = 0;
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

            // Display Debug Text on screen
            self.debugTextView.text = "TOP 2 PROBABILITIES: \n" + classifications

            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
			
            // Only display a prediction if confidence is above 1%
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                if (topPredictionName == "resistenza" && topPredictionScore! > 0.40) {
					
                    self.highlightView?.layer.borderColor = UIColor.green.cgColor
					
					
                } else {
                    self.highlightView?.layer.borderColor = UIColor.red.cgColor
                }
                if (topPredictionName == "noresistenza") { }
            }
            
            //self.textOverlay.text = symbol
            
        }
    }
    
//    messa a fuoco
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = cameraView.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: cameraView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: cameraView).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
					
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    }
    
	var pivotPinchScale: CGFloat!
	
	@IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
			do {
				try device.lockForConfiguration()
				switch sender.state {
				case .began:
					self.pivotPinchScale = device.videoZoomFactor
				case .changed:
					var factor = self.pivotPinchScale * (sender.scale * 1.2)
					factor = max(1, min(factor, device.activeFormat.videoMaxZoomFactor))
					device.videoZoomFactor = factor
				default:
					break
				}
				device.unlockForConfiguration()
			} catch {
				// handle exception
			}
		}
	
	// Convert CIImage to UImage
	func convert(cmage:CIImage) -> UIImage
	{
		let context:CIContext = CIContext.init(options: nil)
		let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
		let image:UIImage = UIImage.init(cgImage: cgImage)
		return image
	}
	
	//get CGImage from CMSampleBuffer
	func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> CGImage? {
		
		if(viewHeight == nil) { return nil }
		
		if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
			
			let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
			let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
			let uiImage = UIImage(cgImage: cgImage!)
			
			let rect = CGRect(x: (uiImage.size.width - viewWidth) / 2, y: (uiImage.size.height - viewHeight / 2) / 2, width: viewWidth, height: viewHeight)
			
			let cropped = ciImage.cropped(to: rect)
			
			//          let context = CIContext()
			if let image = context.createCGImage(cropped, from: cropped.extent) {
				return image
			}
		}
		return nil
	}
	
}


//
//  CameraController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/25/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    fileprivate let capturePhotoButtonBottomConstant: CGFloat = 24
    fileprivate let capturePhotoButtonLength: CGFloat = 80
    fileprivate let dismissButtonConstant: CGFloat = 12
    fileprivate let dismissButtonLength: CGFloat = 50
    
    let output = AVCapturePhotoOutput()
    
    lazy var capturePhotoButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        button.addTarget(this, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    lazy var dismissButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow"), for: .normal)
        button.addTarget(this, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupHUD()
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard let photoSampleBuffer = photoSampleBuffer, let previewPhotoSampleBuffer = previewPhotoSampleBuffer,
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else { return }
        
        let previewImage = UIImage(data: imageData)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        containerView.fillSuperview()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Setups
extension CameraController {
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)
        
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: capturePhotoButtonBottomConstant, rightConstant: 0, widthConstant: capturePhotoButtonLength, heightConstant: capturePhotoButtonLength)
        capturePhotoButton.anchorCenterXToSuperview()
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: dismissButtonConstant, leftConstant: 0, bottomConstant: 0, rightConstant: dismissButtonConstant, widthConstant: dismissButtonLength, heightConstant: dismissButtonLength)
    }
    
    fileprivate func setupCaptureSession() {
        
        // Input setup
        let captureSession = AVCaptureSession()
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                
            }
        } catch let err {
            print("Could not setup camera input: ", err)
            return
        }

        // Output setup
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // Preview setup
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
        
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    
}

// MARK: - Handlers 

extension CameraController {
    func handleCapturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

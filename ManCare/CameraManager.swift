//
//  CameraManager.swift
//  ManCare
//
//  Created by Mehmet Ali Kısacık on 2.09.2025.
//

import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var isFlashlightOn = false
    @Published var permissionGranted = false
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var captureDevice: AVCaptureDevice?
    private var currentPhotoDelegate: PhotoCaptureDelegate?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                }
            }
        case .denied, .restricted:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }
    
    func setupPreview(in view: UIView) {
        guard permissionGranted else { 
            print("❌ Camera permission not granted")
            return 
        }
        
        print("📷 Setting up camera preview...")
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { 
            print("❌ Failed to create capture session")
            return 
        }
        
        captureSession.sessionPreset = .photo
        
        // Setup camera input
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ Failed to get camera device")
            return
        }
        
        self.captureDevice = captureDevice
        print("✅ Camera device found")
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                print("✅ Camera input added")
            } else {
                print("❌ Cannot add camera input")
                return
            }
        } catch {
            print("❌ Error setting up camera input: \(error)")
            return
        }
        
        // Setup photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            print("✅ Photo output added")
        } else {
            print("❌ Cannot add photo output")
            return
        }
        
        // Setup preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        
        if let previewLayer = videoPreviewLayer {
            view.layer.addSublayer(previewLayer)
            print("✅ Preview layer added")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if !captureSession.isRunning {
                captureSession.startRunning()
                print("✅ Capture session started")
            } else {
                print("ℹ️ Capture session already running")
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        print("📸 Attempting to capture photo...")
        
        guard let photoOutput = photoOutput else {
            print("❌ Photo output not available")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        guard let captureSession = captureSession, captureSession.isRunning else {
            print("❌ Capture session not running")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Create photo settings
        let settings = AVCapturePhotoSettings()
        if let device = captureDevice, device.hasFlash {
            settings.flashMode = isFlashlightOn ? .on : .off
        }
        
        // Retain the delegate to prevent it from being deallocated
        let delegate = PhotoCaptureDelegate { [weak self] image in
            DispatchQueue.main.async {
                self?.currentPhotoDelegate = nil // Release the delegate
                completion(image)
            }
        }
        
        currentPhotoDelegate = delegate
        
        print("📸 Capturing photo with settings...")
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    func toggleFlashlight() {
        guard let device = captureDevice, device.hasFlash else { return }
        
        do {
            try device.lockForConfiguration()
            if device.torchMode == .off {
                device.torchMode = .on
                isFlashlightOn = true
            } else {
                device.torchMode = .off
                isFlashlightOn = false
            }
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flashlight: \(error)")
        }
    }
    
    func showImagePicker() {
        // This would typically present an image picker
        // For now, we'll just print a message
        print("Show image picker")
        // TODO: Implement UIImagePickerController or PhotosPicker
    }
    
    private func setupCaptureSession() {
        // Additional setup if needed
    }
}

// MARK: - Photo Capture Delegate

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private var hasCompleted = false
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
        
        // Add a timeout to prevent hanging
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self, !self.hasCompleted else { return }
            print("⏰ Photo capture timeout")
            self.hasCompleted = true
            self.completion(nil)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard !hasCompleted else { return }
        hasCompleted = true
        
        if let error = error {
            print("❌ Error capturing photo: \(error)")
            completion(nil)
            return
        }
        
        print("📸 Photo processing completed, extracting image data...")
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("❌ Failed to get image data from photo")
            completion(nil)
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            print("❌ Failed to create UIImage from data")
            completion(nil)
            return
        }
        
        print("✅ Photo captured successfully, size: \(image.size)")
        completion(image)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Will begin capture for settings")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Will capture photo")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 Did capture photo")
    }
}

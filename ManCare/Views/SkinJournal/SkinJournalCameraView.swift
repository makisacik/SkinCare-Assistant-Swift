//
//  SkinJournalCameraView.swift
//  ManCare
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct SkinJournalCameraView: View {
    @StateObject private var cameraManager = SkinJournalCameraManager()
    @State private var showGhostOverlay = true
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var showInstructions = true
    
    let lastSelfieImage: UIImage?
    let onPhotoCapture: (UIImage) -> Void
    
    var body: some View {
        ZStack {
            // Camera preview
            SkinJournalCameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            // Face guide overlay - dotted template for alignment
            if showGhostOverlay {
                FaceGuideOverlay()
                    .allowsHitTesting(false)
            }
            
            // Processing overlay
            if isProcessing {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Analyzing photo...")
                        .font(ThemeManager.shared.theme.typo.body)
                        .foregroundColor(.white)
                }
            }
            
            // Controls overlay
            VStack {
                // Top controls
                HStack {
                    Spacer()
                    
                    // Always show the guide toggle
                    Button {
                        withAnimation {
                            showGhostOverlay.toggle()
                            
                            // Show instructions again when guide is turned on
                            if showGhostOverlay {
                                showInstructions = true
                                // Auto-hide after 1.5 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showInstructions = false
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: showGhostOverlay ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(showGhostOverlay ? "Hide Guide" : "Show Guide")
                                .font(ThemeManager.shared.theme.typo.caption.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(22)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Instructions (auto-hide after 1.5 seconds)
                if showGhostOverlay && showInstructions {
                    VStack(spacing: 8) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        Text("Align your face with the guide")
                            .font(ThemeManager.shared.theme.typo.body.weight(.semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Keep your face centered in the oval")
                            .font(ThemeManager.shared.theme.typo.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                Spacer()
                
                // Bottom controls
                HStack(spacing: 40) {
                    // Flash toggle
                    Button {
                        cameraManager.toggleFlashlight()
                    } label: {
                        Image(systemName: cameraManager.isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(cameraManager.isFlashlightOn ? .yellow : .white)
                            .frame(width: 60, height: 60)
                    }
                    
                    // Capture button
                    Button {
                        capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 92, height: 92)
                        }
                    }
                    .disabled(isProcessing)
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 60, height: 60)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.requestCameraPermission()
            
            // Auto-hide instructions after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showInstructions = false
                }
            }
        }
    }
    
    private func capturePhoto() {
        isProcessing = true
        
        cameraManager.capturePhoto { image in
            if let image = image {
                print("📸 Photo captured in camera view, passing to parent...")
                // Add a small delay for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isProcessing = false
                    print("📸 Calling onPhotoCapture callback")
                    onPhotoCapture(image)
                    print("📸 Photo capture complete - parent will handle transition")
                    // Don't dismiss here - let the parent view handle the transition
                }
            } else {
                isProcessing = false
                print("❌ Failed to capture photo")
            }
        }
    }
}

// MARK: - Camera Manager for Front Camera

class SkinJournalCameraManager: NSObject, ObservableObject {
    @Published var isFlashlightOn = false
    @Published var permissionGranted = false
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var captureDevice: AVCaptureDevice?
    private var currentPhotoDelegate: SkinJournalPhotoCaptureDelegate?
    
    override init() {
        super.init()
    }
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("✅ Camera permission already granted")
            permissionGranted = true
        case .notDetermined:
            print("📷 Requesting camera permission...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        print("✅ Camera permission granted by user")
                    } else {
                        print("❌ Camera permission denied by user")
                    }
                }
            }
        case .denied, .restricted:
            print("❌ Camera permission denied or restricted")
            permissionGranted = false
        @unknown default:
            print("⚠️ Unknown camera permission status")
            permissionGranted = false
        }
    }
    
    func setupPreview(in view: UIView) {
        guard permissionGranted else {
            print("❌ Camera permission not granted")
            return
        }
        
        print("📷 Setting up front camera preview...")
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {
            print("❌ Failed to create capture session")
            return
        }
        
        captureSession.sessionPreset = .photo
        
        // Setup FRONT camera input
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ Failed to get front camera device")
            return
        }
        
        self.captureDevice = captureDevice
        print("✅ Front camera device found")
        
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
        
        // Mirror the preview for front camera (looks more natural)
        if let connection = videoPreviewLayer?.connection,
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        
        if let previewLayer = videoPreviewLayer {
            view.layer.addSublayer(previewLayer)
            print("✅ Preview layer added")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if !captureSession.isRunning {
                captureSession.startRunning()
                print("✅ Capture session started")
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
        
        let settings = AVCapturePhotoSettings()
        
        // Front camera usually doesn't have flash, but check anyway
        if let device = captureDevice, device.hasFlash {
            settings.flashMode = isFlashlightOn ? .on : .off
        }
        
        let delegate = SkinJournalPhotoCaptureDelegate { [weak self] image in
            DispatchQueue.main.async {
                self?.currentPhotoDelegate = nil
                completion(image)
            }
        }
        
        currentPhotoDelegate = delegate
        
        print("📸 Capturing photo with front camera...")
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
}

// MARK: - Photo Capture Delegate

class SkinJournalPhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private var hasCompleted = false
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
        
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
        
        // Don't mirror the captured image - only the preview is mirrored
        // This ensures saved photos are stored in the correct orientation
        
        print("✅ Photo captured successfully, size: \(image.size)")
        completion(image)
    }
}

// MARK: - Camera Preview View

struct SkinJournalCameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: SkinJournalCameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // Wait a bit for permission to be granted before setting up preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if cameraManager.permissionGranted {
                cameraManager.setupPreview(in: view)
            } else {
                print("⚠️ Waiting for camera permission...")
                // Try again after another delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cameraManager.setupPreview(in: view)
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update frame if needed
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Face Guide Overlay

struct FaceGuideOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Face oval
                Ellipse()
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [10, 10]))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.45)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                
                // Crosshair for centering
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 1, height: 30)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.45)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 1, height: 30)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 30, height: 1)
                    
                    Spacer()
                        .frame(width: geometry.size.width * 0.6)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 30, height: 1)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
            }
        }
    }
}

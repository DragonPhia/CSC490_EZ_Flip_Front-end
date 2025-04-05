//
//  CameraView.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/29/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var photoOutput: AVCapturePhotoOutput?
        var session: AVCaptureSession?

        init(parent: CameraView, photoOutput: AVCapturePhotoOutput, session: AVCaptureSession) {
            self.parent = parent
            self.photoOutput = photoOutput
            self.session = session
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                return
            }
            parent.didCaptureImage(image)
        }

        @objc func captureImage() {
            guard let session = session, session.isRunning, let photoOutput = photoOutput else { return }
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    var didCaptureImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(for: .video) else {
            return Coordinator(parent: self, photoOutput: AVCapturePhotoOutput(), session: session)
        }

        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch {
            return Coordinator(parent: self, photoOutput: AVCapturePhotoOutput(), session: session)
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        return Coordinator(parent: self, photoOutput: photoOutput, session: session)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Set up camera preview
        guard let session = context.coordinator.session else { return viewController }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        // iOS-style capture button
        let buttonSize: CGFloat = 80
        let innerSize: CGFloat = 64

        // Outer ring (white ring with transparent center)
        let outerRing = UIView()
        outerRing.frame = CGRect(x: (viewController.view.bounds.width - buttonSize) / 2,
                                 y: viewController.view.bounds.height - buttonSize - 100,
                                 width: buttonSize,
                                 height: buttonSize)
        outerRing.backgroundColor = .clear
        outerRing.layer.cornerRadius = buttonSize / 2
        outerRing.layer.borderColor = UIColor.white.cgColor
        outerRing.layer.borderWidth = 6
        outerRing.layer.shadowColor = UIColor.black.cgColor
        outerRing.layer.shadowOpacity = 0.2
        outerRing.layer.shadowOffset = CGSize(width: 0, height: 4)
        outerRing.layer.shadowRadius = 6

        // Inner solid white circle
        let innerCircle = UIButton(type: .custom)
        innerCircle.frame = CGRect(x: (buttonSize - innerSize) / 2,
                                   y: (buttonSize - innerSize) / 2,
                                   width: innerSize,
                                   height: innerSize)
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = innerSize / 2
        innerCircle.layer.masksToBounds = true

        // Add tap action
        innerCircle.addTarget(context.coordinator, action: #selector(Coordinator.captureImage), for: .touchUpInside)

        // Shrink animation on tap
        innerCircle.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.1, animations: {
                innerCircle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    innerCircle.transform = .identity
                }
            }
        }, for: .touchUpInside)

        outerRing.addSubview(innerCircle)

        DispatchQueue.main.async {
            viewController.view.addSubview(outerRing)
        }

        // Start session
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No dynamic updates needed for now
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(didCaptureImage: { _ in })
            .edgesIgnoringSafeArea(.all)
    }
}

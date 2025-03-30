//
//  CameraView.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/29/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }
    }

    var didCaptureImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Set up the camera session
        let session = AVCaptureSession()
        session.sessionPreset = .high

        // Set up the camera device
        guard let camera = AVCaptureDevice.default(for: .video) else { return viewController }
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch {
            return viewController
        }

        // Add input to session
        if session.canAddInput(input) {
            session.addInput(input)
        }

        // Set up the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        // Start the camera session
        session.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(didCaptureImage: { _ in })
            .edgesIgnoringSafeArea(.all)
    }
}

//
//  VisualScanView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI
import PhotosUI

struct VisualScanView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var capturedImage: UIImage? = nil
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            // CameraView displays the live camera feed
            CameraView(didCaptureImage: { image in
                self.capturedImage = image
            })
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer() // Pushes the button to the right
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Select from Library")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { newValue in
                        // Handle the change when `selectedItem` changes
                        if let selectedItem = newValue {
                            loadImage(from: selectedItem)
                        }
                    }
                    .padding(.top, 20) 
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // Display the captured image or selected image
            if let image = selectedImage ?? capturedImage {
                VStack {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding()
                }
            }
        }
    }

    // Function to load the image asynchronously from the photo library
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
                // Load image data
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            } catch {
                print("Error loading selected item: \(error)")
            }
        }
    }
}

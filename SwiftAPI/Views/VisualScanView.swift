//
//  VisualScanView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct VisualScanView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var capturedImage: UIImage? = nil
    @State private var selectedImage: UIImage? = nil
    @StateObject private var viewModel = SearchViewModel()

    var onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            // Live camera view
            CameraView(didCaptureImage: { image in
                self.capturedImage = image
                if let image = capturedImage {
                    onImageSelected(image)
                    presentationMode.wrappedValue.dismiss()
                }
            })
            .edgesIgnoringSafeArea(.all)

            // Bottom-right icon-only photo picker
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 18)) // Smaller icon
                            .foregroundColor(.white)
                            .padding(10) // Smaller background circle
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .onChange(of: selectedItem) { newValue in
                        if let selectedItem = newValue {
                            loadImage(from: selectedItem)
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.trailing, 20)
                }
            }

            // Optional image preview
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

    // Async image loader
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    onImageSelected(image)
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Error loading selected item: \(error)")
            }
        }
    }
}

struct VisualScanView_Previews: PreviewProvider {
    static var previews: some View {
        VisualScanView(onImageSelected: { _ in })
            .edgesIgnoringSafeArea(.all)
    }
}

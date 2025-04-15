//
//  AddMomentView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/30/25.
//

import SwiftUI
import PhotosUI

struct AddMomentView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (Moment) -> Void

    @State private var caption = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Caption")) {
                    TextField("Add a caption...", text: $caption)
                }

                Section(header: Text("Photo")) {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Pick a photo")
                        }
                    }

                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add Moment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let moment = Moment(caption: caption, imageData: selectedImageData)
                        onSave(moment)
                        dismiss()
                    }
                    .disabled(caption.isEmpty)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
}

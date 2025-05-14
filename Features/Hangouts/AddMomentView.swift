//
//  AddMomentView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/30/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct AddMomentView: View {
    @Environment(\.dismiss) var dismiss
    var sessionId: String
    var checkpointId: String
    var checkpointTitle: String
    var onSave: () -> Void

    @AppStorage("username") var username: String = ""

    @State private var caption = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var isUploading = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Caption")) {
                    TextField("Add a caption...", text: $caption)
                }

                Section(header: Text("Photos")) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Pick photos")
                        }
                    }

                    if !selectedImagesData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImagesData, id: \.self) { data in
                                    if let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                if isUploading {
                    ProgressView("Uploading moments...")
                }
            }
            .navigationTitle("Add Moments")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await uploadMoments() }
                    }
                    .disabled(caption.isEmpty || selectedImagesData.isEmpty || isUploading)
                }
            }
            .task(id: selectedItems) {
                selectedImagesData = []
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImagesData.append(data)
                    }
                }
            }
        }
    }

    func uploadMoments() async {
        isUploading = true
        let db = Firestore.firestore()
        let storage = Storage.storage()

        for (index, imageData) in selectedImagesData.enumerated() {
            let momentId = UUID().uuidString
            let imageRef = storage.reference().child("moments/\(momentId).jpg")

            do {
                _ = try await imageRef.putDataAsync(imageData)
                let url = try await imageRef.downloadURL()

                let momentData: [String: Any] = [
                    "caption": caption,
                    "imageURL": url.absoluteString,
                    "createdBy": username,
                    "timestamp": Timestamp(date: Date())
                ]

                try await db
                    .collection("hangoutSessions")
                    .document(sessionId)
                    .collection("checkpoints")
                    .document(checkpointId)
                    .collection("moments")
                    .document(momentId)
                    .setData(momentData)

                print("✅ Uploaded moment \(index + 1) → \(url.absoluteString)")

                let feedEntry: [String: Any] = [
                    "username": username,
                    "location": checkpointTitle,
                    "timestamp": Timestamp(date: Date()),
                    "caption": caption,
                    "memoryThumbnailURLs": [url.absoluteString],
                    "isPublic": true
                ]
                try await db.collection("feed").addDocument(data: feedEntry)

            } catch {
                print("❌ Upload failed for image \(index + 1): \(error)")
            }
        }

        isUploading = false
        onSave()
        dismiss()
    }
}

//
//  MomentEditorView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/2/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct MomentEditorView: View {
    @Environment(\.dismiss) var dismiss

    let sessionId: String
    let checkpointId: String
    let moment: Moment
    var onDelete: () -> Void
    var onUpdate: (String) -> Void

    @State private var newCaption: String
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false

    init(sessionId: String, checkpointId: String, moment: Moment, onDelete: @escaping () -> Void, onUpdate: @escaping (String) -> Void) {
        self.sessionId = sessionId
        self.checkpointId = checkpointId
        self.moment = moment
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        _newCaption = State(initialValue: moment.caption)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Caption")) {
                    TextField("Caption", text: $newCaption)
                }

                Section {
                    Button("Save Changes") {
                        Task {
                            await updateMoment()
                        }
                    }
                    .disabled(newCaption.trimmingCharacters(in: .whitespaces).isEmpty || newCaption == moment.caption)

                    Button("Delete Moment") {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }

                if isSaving || isDeleting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Edit Moment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Moment?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteMoment()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove the moment and its photo.")
            }
        }
    }

    func updateMoment() async {
        isSaving = true
        let db = Firestore.firestore()
        let docRef = db.collection("hangoutSessions")
            .document(sessionId)
            .collection("checkpoints")
            .document(checkpointId)
            .collection("moments")
            .document(moment.id)

        do {
            try await docRef.updateData(["caption": newCaption])
            onUpdate(newCaption)
            dismiss()
        } catch {
            print("❌ Failed to update caption: \(error)")
        }

        isSaving = false
    }

    func deleteMoment() async {
        isDeleting = true
        let db = Firestore.firestore()
        let storage = Storage.storage()

        let docRef = db.collection("hangoutSessions")
            .document(sessionId)
            .collection("checkpoints")
            .document(checkpointId)
            .collection("moments")
            .document(moment.id)

        do {
            try await docRef.delete()

            if let urlStr = moment.imageURL,
               let imageRef = try? storage.reference(forURL: urlStr) {
                try await imageRef.delete()
            }

            onDelete()
            dismiss()
        } catch {
            print("❌ Failed to delete moment: \(error)")
        }

        isDeleting = false
    }
}

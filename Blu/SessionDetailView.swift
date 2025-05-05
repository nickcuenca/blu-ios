//
//  SessionDetailView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

struct SessionDetailView: View {
    var sessionId: String
    @AppStorage("username") var username: String = ""

    @State private var sessionTitle = ""
    @State private var participants: [String] = []
    @State private var checkpoints: [Checkpoint] = []

    @State private var showAllSummary = false
    @State private var showAllSettleUp = false
    @State private var showEditHangout = false
    @State private var showingAddCheckpoint = false
    @State private var newCheckpointTitle = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection

                        if checkpoints.isEmpty {
                            Text("No checkpoints yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        } else {
                            ForEach(checkpoints) { checkpoint in
                                NavigationLink(destination:
                                    CheckpointDetailView(
                                        sessionId: sessionId,
                                        checkpoint: .constant(checkpoint),
                                        participants: participants
                                    )
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(checkpoint.title)
                                                    .font(.headline)
                                                if let time = checkpoint.time {
                                                    Text(time, style: .time)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }

                Button(action: {
                    showingAddCheckpoint = true
                }) {
                    Text("Add Checkpoint")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
            }
            .navigationTitle(sessionTitle)
            .onAppear {
                fetchSessionMetadata()
                fetchCheckpoints()
            }
            .sheet(isPresented: $showingAddCheckpoint) {
                VStack(spacing: 20) {
                    Text("Add Checkpoint")
                        .font(.title2)
                    TextField("Checkpoint Title", text: $newCheckpointTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Save") {
                        addCheckpoint(title: newCheckpointTitle)
                    }
                    .disabled(newCheckpointTitle.isEmpty)

                    Button("Cancel") {
                        newCheckpointTitle = ""
                        showingAddCheckpoint = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }
        }
    }

    // MARK: - Firebase Integration

    func fetchSessionMetadata() {
        let db = Firestore.firestore()
        db.collection("hangoutSessions").document(sessionId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch session: \(error)")
                return
            }

            guard let data = snapshot?.data() else { return }

            self.sessionTitle = data["title"] as? String ?? "Unnamed"
            self.participants = data["participants"] as? [String] ?? []
        }
    }

    func fetchCheckpoints() {
        let db = Firestore.firestore()
        db.collection("hangoutSessions")
            .document(sessionId)
            .collection("checkpoints")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch checkpoints: \(error)")
                    return
                }

                guard let docs = snapshot?.documents else { return }

                do {
                    self.checkpoints = try docs.map { try $0.data(as: Checkpoint.self) }
                } catch {
                    print("❌ Failed to decode checkpoints: \(error)")
                }
            }
    }

    func addCheckpoint(title: String) {
        let db = Firestore.firestore()
        let id = UUID()
        let checkpoint = Checkpoint(
            id: id,
            title: title,
            time: Date(),
            location: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            expenses: [],
            moments: []
        )

        do {
            try db.collection("hangoutSessions")
                .document(sessionId)
                .collection("checkpoints")
                .document(id.uuidString)
                .setData(from: checkpoint)

            self.checkpoints.append(checkpoint)
            self.newCheckpointTitle = ""
            self.showingAddCheckpoint = false
        } catch {
            print("❌ Failed to add checkpoint: \(error)")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text(sessionTitle)
                .font(.largeTitle.bold())
                .padding(.horizontal)
            Spacer()
            Button(action: {
                showEditHangout = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }
}

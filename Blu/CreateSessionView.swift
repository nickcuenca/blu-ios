import SwiftUI
import CoreLocation

struct CreateSessionView: View {
    @AppStorage("username") var username: String = ""
    @State private var title = ""
    @State private var selectedParticipants: [String] = []

    let allPeople = ["Nick", "Max", "Armeen", "John", "Lisa"]

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Session Info
                Section(header: Text("Session Info")) {
                    TextField("Title", text: $title)
                }

                // MARK: - Participants
                Section(header: Text("Select Participants")) {
                    let sortedPeople = [username] + allPeople.filter { $0 != username }
                    ForEach(sortedPeople, id: \.self) { person in
                        Toggle(isOn: Binding(
                            get: { selectedParticipants.contains(person) },
                            set: { isSelected in
                                if isSelected {
                                    selectedParticipants.append(person)
                                } else {
                                    selectedParticipants.removeAll { $0 == person }
                                }
                            })) {
                                Text(person)
                            }
                    }
                }

                // MARK: - Create Button
                Section {
                    Button("Create Hangout") {
                        var finalParticipants = selectedParticipants
                        if !finalParticipants.contains(username) {
                            finalParticipants.append(username)
                        }

                        let coordinate = CodableCoordinate(latitude: 0, longitude: 0)
                        let newSession = HangoutSession(
                            id: UUID(),
                            title: title,
                            date: Date(),
                            location: coordinate.clLocationCoordinate,  // ✅ fixed here
                            participants: finalParticipants,
                            expenses: [],
                            checkpoints: []
                        )


                        print("Created Session: \(newSession)")
                        // Add logic to save or navigate
                    }
                }
            }
            .navigationTitle("New Hangout")
        }
    }
}

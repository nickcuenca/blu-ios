import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import FirebaseAuth

/// A modernized user‑profile screen with editable payment + social handles,
/// tappable friends list, profile‑photo picker, and a settings sheet.
struct ProfileViewEnhanced: View {
    // MARK: ‑ Stored user defaults
    @AppStorage("userID")          private var currentUserID: String = ""
    @AppStorage("username")        private var username: String = ""
    @AppStorage("userHandle")      private var userHandle: String = ""
    @AppStorage("userEmail")       private var userEmail: String = ""
    @AppStorage("venmoUsername")   private var venmoUsername: String = ""
    @AppStorage("cashAppTag")      private var cashAppTag: String = ""
    @AppStorage("zelleInfo")       private var zelleInfo: String = ""
    @AppStorage("instagram")       private var instagram: String = ""
    @AppStorage("snapchat")        private var snapchat: String = ""
    @AppStorage("tiktok")          private var tiktok: String = ""

    // MARK: ‑ View state
    @State private var profileImage: UIImage? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil

    @State private var editing        = false
    @State private var showSettings   = false
    @State private var signedOut      = false

    // temp fields while editing
    @State private var tempVenmo      = ""
    @State private var tempCashApp    = ""
    @State private var tempZelle      = ""
    @State private var tempInstagram  = ""
    @State private var tempSnapchat   = ""
    @State private var tempTiktok     = ""

    // friends
    @State private var friends: [UserPreview] = []

    // MARK: ‑ Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileImageSection
                    userInfoSection
                    Divider()
                    Group {
                        if editing { editableFormSection } else { readOnlyFormSection }
                    }
                    Divider()
                    friendsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editing ? "Cancel" : "Edit") { toggleEditing() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSettings = true } label: { Image(systemName: "gear") }
                }
            }
            .navigationDestination(for: UserPreview.self) { friend in
                FriendProfileView(friend: friend)
            }
            .sheet(isPresented: $showSettings) { settingsSheet }
            .fullScreenCover(isPresented: $signedOut) { GoogleSignInView() }
            .task {
                await fetchProfileImage()
                await fetchFriends()
            }
        }
    }

    // MARK: ‑ Sections
    private var profileImageSection: some View {
        VStack(spacing: 12) {
            Group {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Image(systemName: "person.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Edit Profile Picture")
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    guard let item  = newItem,
                          let data  = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }

                    profileImage = image
                    await uploadProfileImage(data: data)
                }
            }
        }
    }

    private var userInfoSection: some View {
        VStack(spacing: 4) {
            Text(username).font(.title2).bold()
            Text("@\(userHandle)").font(.subheadline).foregroundColor(.secondary)
        }
    }

    private var editableFormSection: some View {
        VStack(spacing: 16) {
            paymentSocialFields
                .textFieldStyle(.roundedBorder)
            Button("Save Changes", action: saveChanges)
                .buttonStyle(.borderedProminent)
        }
    }

    private var readOnlyFormSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            labelledRow("creditcard",  venmoUsername)
            labelledRow("dollarsign.circle", cashAppTag)
            labelledRow("envelope",    zelleInfo)
            labelledRow("camera",      instagram)
            labelledRow("bolt.fill",   snapchat)
            labelledRow("music.note",  tiktok)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Friends").font(.headline)
            ForEach(friends) { friend in
                NavigationLink(value: friend) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(friend.username)
                            Text("@\(friend.handle)").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: ‑ Settings sheet
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Button(role: .destructive, action: signOut) {
                        Label("Sign Out", systemImage: "arrow.backward.square")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showSettings = false } } }
        }
    }

    // MARK: ‑ Helpers (UI)
    private var paymentSocialFields: some View {
        VStack(spacing: 10) {
            TextField("Venmo",     text: $tempVenmo)
            TextField("Cash App",  text: $tempCashApp)
            TextField("Zelle",     text: $tempZelle)
            TextField("Instagram", text: $tempInstagram)
            TextField("Snapchat",  text: $tempSnapchat)
            TextField("TikTok",    text: $tempTiktok)
        }
    }

    private func labelledRow(_ systemName: String, _ value: String) -> some View {
        HStack { Label(value, systemImage: systemName); Spacer() }
    }

    private func toggleEditing() {
        if editing {
            editing = false
        } else {
            tempVenmo     = venmoUsername
            tempCashApp   = cashAppTag
            tempZelle     = zelleInfo
            tempInstagram = instagram
            tempSnapchat  = snapchat
            tempTiktok    = tiktok
            editing       = true
        }
    }

    private func saveChanges() {
        venmoUsername = tempVenmo
        cashAppTag    = tempCashApp
        zelleInfo     = tempZelle
        instagram     = tempInstagram
        snapchat      = tempSnapchat
        tiktok        = tempTiktok
        editing       = false
    }

    // MARK: ‑ Helpers (data I/O)
    @MainActor
    private func fetchProfileImage() async {
        let db = Firestore.firestore()
        guard let doc = try? await db.collection("users").document(currentUserID).getDocument(),
              let urlString = doc.data()? ["profileImageURL"] as? String,
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else { return }
        profileImage = uiImage
    }

    private func uploadProfileImage(data: Data) async {
        let storageRef = Storage.storage().reference().child("profileImages/\(currentUserID).jpg")
        do {
            _ = try await storageRef.putDataAsync(data)
            let url = try await storageRef.downloadURL()
            try await Firestore.firestore().collection("users").document(currentUserID).updateData(["profileImageURL": url.absoluteString])
        } catch { print("❌ Upload failed: \(error)") }
    }

    @MainActor
    private func fetchFriends() async {
        let db = Firestore.firestore()
        guard let userDoc = try? await db.collection("users").document(currentUserID).getDocument(),
              let friendIDs = userDoc.data()? ["friends"] as? [String] else { return }

        var fetched: [UserPreview] = []
        for id in friendIDs {
            if let fdoc = try? await db.collection("users").document(id).getDocument(),
               let data = fdoc.data() {
                let uname  = data["username"] as? String ?? "Unknown"
                let handle = data["handle"]   as? String ?? ""
                fetched.append(UserPreview(id: id, username: uname, handle: handle))
            }
        }
        friends = fetched
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            signedOut = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

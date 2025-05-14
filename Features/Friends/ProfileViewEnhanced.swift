//  ProfileViewEnhanced.swift

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import FirebaseAuth

struct ProfileViewEnhanced: View {
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
    @AppStorage("bio")             private var bio: String = ""
    @AppStorage("phoneNumber")     private var phoneNumber: String = ""
    @AppStorage("defaultPayment")  private var defaultPaymentMethod: String = ""

    @State private var tempBio = ""
    @State private var tempPhone = ""
    @State private var tempDefaultPayment = ""


    @State private var profileImage: UIImage? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var editing = false
    @State private var showSettings = false
    @State private var signedOut = false
    @State private var showConflictAlert = false
    @State private var joinDateString: String = ""

    @State private var tempNameInput = ""
    @State private var tempHandleInput = ""
    @State private var tempEmailInput = ""
    @State private var tempVenmo = ""
    @State private var tempCashApp = ""
    @State private var tempZelle = ""
    @State private var tempInstagram = ""
    @State private var tempSnapchat = ""
    @State private var tempTiktok = ""

    @State private var friends: [UserPreview] = []
    @State private var pastHangouts: [HangoutPreview] = []

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
                    friendsPreviewSection
                    Divider()
                    memoriesSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editing ? "Cancel" : "Edit") { toggleEditing() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationDestination(for: UserPreview.self) { friend in
                FriendProfileView(friend: friend)
            }
            .sheet(isPresented: $showSettings) { settingsSheet }
            .task {
                await fetchProfileImage()
                await fetchFriends()
                await fetchPastHangouts()
                await fetchJoinDate()
            }
            .alert("Username or email already in use", isPresented: $showConflictAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private var profileImageSection: some View {
        VStack(spacing: 12) {
            Group {
                if let image = profileImage {
                    Image(uiImage: image).resizable()
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
                    guard let item = newItem,
                          let data = try? await item.loadTransferable(type: Data.self),
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
            if !joinDateString.isEmpty {
                Text("Joined \(joinDateString)").font(.caption).foregroundColor(.gray)
            }
        }
    }

    private var editableFormSection: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $tempNameInput)
            TextField("Handle", text: $tempHandleInput)
            TextField("Email", text: $tempEmailInput)
            TextField("Bio", text: $tempBio)
            TextField("Phone Number", text: $tempPhone)
            TextField("Default Payment", text: $tempDefaultPayment)
            paymentSocialFields.textFieldStyle(.roundedBorder)
            Button("Save Changes") {
                Task { await saveChanges() }
            }
            .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
    }

    private var readOnlyFormSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !venmoUsername.isEmpty {
                labelledGroup(label: "Venmo", icon: "creditcard", value: venmoUsername)
            }
            if !cashAppTag.isEmpty {
                labelledGroup(label: "Cash App", icon: "dollarsign.circle", value: cashAppTag)
            }
            if !zelleInfo.isEmpty {
                labelledGroup(label: "Zelle", icon: "envelope", value: zelleInfo)
            }
            if !instagram.isEmpty {
                labelledGroup(label: "Instagram", icon: "camera", value: instagram)
            }
            if !snapchat.isEmpty {
                labelledGroup(label: "Snapchat", icon: "bolt.fill", value: snapchat)
            }
            if !tiktok.isEmpty {
                labelledGroup(label: "TikTok", icon: "music.note", value: tiktok)
            }
            if !bio.isEmpty {
                labelledGroup(label: "Bio", icon: "quote.bubble", value: bio)
            }
            if !phoneNumber.isEmpty {
                labelledGroup(label: "Phone", icon: "phone", value: phoneNumber)
            }
            if !defaultPaymentMethod.isEmpty {
                labelledGroup(label: "Default Payment", icon: "creditcard.fill", value: defaultPaymentMethod)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var friendsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Friends").font(.headline)
                Spacer()
                NavigationLink("Show All") { FullFriendsListView(friends: friends) }
            }
            ForEach(friends.prefix(3)) { friend in
                NavigationLink(value: friend) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(friend.username)
                            Text("@\(friend.handle)").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hangout Memories").font(.headline)
                Spacer()
                NavigationLink("See All") { FullHangoutHistoryView(userID: currentUserID) }
            }
            ForEach(pastHangouts.prefix(2)) { hangout in
                VStack(alignment: .leading, spacing: 2) {
                    Text(hangout.title).bold()
                    Text(hangout.dateFormatted).font(.caption).foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labelledGroup(label: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundColor(.gray)
            Label(value, systemImage: icon)
        }
    }

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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showSettings = false }
                }
            }
        }
    }

    private var paymentSocialFields: some View {
        VStack(spacing: 10) {
            TextField("Venmo",     text: $tempVenmo)
            TextField("Cash App",  text: $tempCashApp)
            TextField("Zelle",     text: $tempZelle)
            TextField("Instagram", text: $tempInstagram)
            TextField("Snapchat",  text: $tempSnapchat)
            TextField("TikTok",    text: $tempTiktok)
        }
    }

    private func toggleEditing() {
        if editing {
            editing = false
        } else {
            tempNameInput   = username
            tempHandleInput = userHandle
            tempEmailInput  = userEmail
            tempVenmo       = venmoUsername
            tempCashApp     = cashAppTag
            tempZelle       = zelleInfo
            tempInstagram   = instagram
            tempSnapchat    = snapchat
            tempTiktok      = tiktok
            tempBio = bio
            tempPhone = phoneNumber
            tempDefaultPayment = defaultPaymentMethod
            editing         = true
        }
    }

    private func saveChanges() async {
        if await isHandleOrEmailTaken(except: currentUserID, handle: tempHandleInput, email: tempEmailInput) {
            showConflictAlert = true
            return
        }
        username      = tempNameInput
        userHandle    = tempHandleInput
        userEmail     = tempEmailInput
        venmoUsername = tempVenmo
        bio = tempBio
        phoneNumber = tempPhone
        defaultPaymentMethod = tempDefaultPayment
        cashAppTag    = tempCashApp
        zelleInfo     = tempZelle
        instagram     = tempInstagram
        snapchat      = tempSnapchat
        tiktok        = tempTiktok
        editing       = false
    }

    private func signOut() {
        try? AuthService.shared.signOut()
    }

    @MainActor
    private func fetchProfileImage() async {
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(currentUserID).getDocument()
            guard let urlString = doc.data()? ["profileImageURL"] as? String,
                  let url = URL(string: urlString) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                profileImage = uiImage
            }
        } catch {
            print("2757fe0f Failed to fetch profile image: \(error)")
        }
    }

    private func uploadProfileImage(data: Data) async {
        let storageRef = Storage.storage().reference().child("profileImages/\(currentUserID).jpg")
        do {
            _ = try await storageRef.putDataAsync(data)
            let url = try await storageRef.downloadURL()
            try await Firestore.firestore().collection("users").document(currentUserID).updateData([
                "profileImageURL": url.absoluteString
            ])
        } catch {
            print("2757fe0f Upload failed: \(error)")
        }
    }

    @MainActor
    private func fetchFriends() async {
        let db = Firestore.firestore()
        guard let userDoc = try? await db.collection("users").document(currentUserID).getDocument(),
              let friendIDs = userDoc.data()? ["friends"] as? [String] else { return }
        var fetched: [UserPreview] = []
        for id in friendIDs.prefix(3) {
            if let fdoc = try? await db.collection("users").document(id).getDocument(),
               let data = fdoc.data() {
                let uname  = data["username"] as? String ?? "Unknown"
                let handle = data["handle"]   as? String ?? ""
                fetched.append(UserPreview(id: id, username: uname, handle: handle))
            }
        }
        friends = fetched
    }

    @MainActor
    private func fetchPastHangouts() async {
        let db = Firestore.firestore()
        do {
            let snap = try await db.collection("hangouts")
                .whereField("participants", arrayContains: currentUserID)
                .order(by: "date", descending: true)
                .limit(to: 2)
                .getDocuments()
            pastHangouts = snap.documents.map {
                let data = $0.data()
                return HangoutPreview(
                    id: $0.documentID,
                    title: data["title"] as? String ?? "Untitled",
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
        } catch {
            print("2757fe0f Failed to fetch hangouts: \(error)")
        }
    }

    @MainActor
    private func fetchJoinDate() async {
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(currentUserID).getDocument()
            if let timestamp = doc.data()?["joinedAt"] as? Timestamp {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                joinDateString = formatter.string(from: timestamp.dateValue())
            }
        } catch {
            print("2757fe0f Failed to fetch join date: \(error)")
        }
    }

    private func isHandleOrEmailTaken(except userID: String, handle: String, email: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let handleSnapshot = try await db.collection("users")
                .whereField("handle", isEqualTo: handle)
                .whereField(FieldPath.documentID(), isNotEqualTo: userID)
                .getDocuments()

            let emailSnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .whereField(FieldPath.documentID(), isNotEqualTo: userID)
                .getDocuments()

            return !handleSnapshot.documents.isEmpty || !emailSnapshot.documents.isEmpty
        } catch {
            print("2757fe0f Conflict check failed: \(error)")
            return true
        }
    }
}

struct HangoutPreview: Identifiable, Hashable {
    let id: String
    let title: String
    let date: Date

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

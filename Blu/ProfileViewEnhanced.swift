import SwiftUI
import FirebaseAuth

struct ProfileViewEnhanced: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userHandle") var userHandle: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("venmoUsername") var venmoUsername: String = ""
    @AppStorage("cashAppTag") var cashAppTag: String = ""
    @AppStorage("zelleInfo") var zelleInfo: String = ""
    @AppStorage("instagram") var instagram: String = ""
    @AppStorage("snapchat") var snapchat: String = ""
    @AppStorage("tiktok") var tiktok: String = ""
    @AppStorage("userProfileImageData") var userProfileImageData: Data?

    @State private var editing = false
    @State private var tempVenmo = ""
    @State private var tempCashApp = ""
    @State private var tempZelle = ""
    @State private var tempInstagram = ""
    @State private var tempSnapchat = ""
    @State private var tempTiktok = ""
    @State private var signedOut = false

    let friends = ["Max", "Armeen", "John", "Lisa"]

    var body: some View {
        Form {
            Section(header: Text("Profile Info")) {
                HStack(spacing: 16) {
                    if let data = userProfileImageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(Text("👤").font(.title))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(username).font(.headline)
                        Text("@\(userHandle)").font(.subheadline).foregroundColor(.gray)
                        HStack(spacing: 6) {
                            Image(systemName: "envelope").foregroundColor(.gray)
                            Text(userEmail).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }
            }

            Section(header: Text("Payment Handles")) {
                if editing {
                    TextField("Venmo Username", text: $tempVenmo)
                    TextField("Cash App Tag", text: $tempCashApp)
                    TextField("Zelle Email/Phone", text: $tempZelle)
                } else {
                    Label("Venmo: \(venmoUsername)", systemImage: "creditcard")
                    Label("Cash App: \(cashAppTag)", systemImage: "dollarsign.circle")
                    Label("Zelle: \(zelleInfo)", systemImage: "envelope")
                }
            }

            Section(header: Text("Socials")) {
                if editing {
                    TextField("Instagram", text: $tempInstagram)
                    TextField("Snapchat", text: $tempSnapchat)
                    TextField("TikTok", text: $tempTiktok)
                } else {
                    Label("Instagram: \(instagram)", systemImage: "camera")
                    Label("Snapchat: \(snapchat)", systemImage: "bolt.fill")
                    Label("TikTok: \(tiktok)", systemImage: "music.note")
                }
            }

            if editing {
                Button("Save Changes") {
                    venmoUsername = tempVenmo
                    cashAppTag = tempCashApp
                    zelleInfo = tempZelle
                    instagram = tempInstagram
                    snapchat = tempSnapchat
                    tiktok = tempTiktok
                    editing = false
                }
            }

            Section(header: Text("Friends")) {
                ForEach(friends, id: \.self) { friend in
                    Label(friend, systemImage: "person")
                }
            }

            Section {
                Button(role: .destructive) {
                    signOut()
                } label: {
                    Label("Sign Out", systemImage: "arrow.backward.square")
                }
            }

            #if DEBUG
            Section(header: Text("Developer Tools")) {
                Button(role: .destructive) {
                    clearUserData()
                } label: {
                    Label("Reset Profile", systemImage: "arrow.counterclockwise")
                }
            }
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(editing ? "Cancel" : "Edit") {
                    if editing {
                        editing = false
                    } else {
                        tempVenmo = venmoUsername
                        tempCashApp = cashAppTag
                        tempZelle = zelleInfo
                        tempInstagram = instagram
                        tempSnapchat = snapchat
                        tempTiktok = tiktok
                        editing = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $signedOut) {
            GoogleSignInView()
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            clearUserData()
            signedOut = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func clearUserData() {
        username = ""
        userHandle = ""
        userEmail = ""
        venmoUsername = ""
        cashAppTag = ""
        zelleInfo = ""
        userProfileImageData = nil
        instagram = ""
        snapchat = ""
        tiktok = ""
    }
}

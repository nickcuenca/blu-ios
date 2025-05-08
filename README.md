# 💸 Blü — Group Expense Splitting App

Blü is a SwiftUI-powered iOS app that helps friend groups track and split expenses during hangouts. Whether you're grabbing boba, hosting a BBQ, or road-tripping to Vegas, Blü keeps your group outings fun, organized, and fair.

---

## ✨ Features

- 🧑‍🤝‍🧑 **Create Hangout Sessions**  
  Organize expenses by events — like “Vegas Trip 2025” or “Birthday Bash.”

- 📍 **Add Checkpoints**  
  Add specific events (e.g., "Boba Run", "Dinner", "Gas") with optional timestamps and locations.

- 💵 **Track Expenses Per Checkpoint**  
  Record who paid and split costs either **equally** or **custom** across users.

- 📷 **Capture Moments**  
  Upload and caption images tied to each checkpoint for memory-keeping.

- 📊 **Automatic Settle Up**  
  Instantly calculate balances — who owes whom and how much.

- 🧑‍💼 **Rich Profiles**  
  View your social/payment handles, friends list, and past hangout history.

- 🔐 **Firebase Auth Integration**  
  Register and log in securely using Firebase Authentication.

- ☁️ **Realtime Cloud Sync**  
  Sync all hangouts, expenses, and moments live using Firebase Firestore.

---

## 🛠️ Tech Stack

| Layer         | Tech Stack                                       |
|---------------|--------------------------------------------------|
| **Frontend**  | SwiftUI, UIKit (occasionally), MapKit, PhotosUI |
| **Backend**   | Firebase Firestore, Firebase Auth               |
| **Media**     | Firebase Storage for image Moments              |
| **Storage**   | Firestore structured documents (sessions, expenses, etc.) |

---

## 🧪 How It Works

Each **Hangout** is a session made up of multiple **Checkpoints**.  
Each Checkpoint supports:

- Expenses (split equally/custom)
- Moments (photos + captions)
- Location and optional timestamp

The app automatically compiles this into:

- **Summaries**: see total paid/owed
- **Settle Up**: calculate reimbursements
- **Memories**: revisit visual highlights
- **Friends**: see shared users and profiles

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/nickcuenca/BluApp.git
   ```
2. Open `BluApp.xcodeproj` in Xcode
3. Add your `GoogleService-Info.plist` if you're using Firebase
4. Build & run on a simulator or physical iPhone

---

## 👨‍💻 Developers

**Nicolas Cuenca**  
📍 UCLA CS Grad • Software Engineer & iOS & Full Stack Developer  
🔗 [GitHub](https://github.com/nickcuenca) | [LinkedIn](https://www.linkedin.com/in/nicolaswcuenca)

**Ethan Maldonado**  
📍 UCLA CS Grad • Software Engineer & iOS & Full Stack Developer  
🔗 [GitHub](https://github.com/eamaldonado01)

---

## ✅ To-Do / Roadmap

- [ ] Venmo / Apple Pay integration for direct payment
- [ ] Tip and tax support per expense
- [ ] Dark mode + animation polish
- [ ] Map-based checkpoint picker
- [ ] Search and add friends by username or contact
- [ ] Activity feed (e.g. "Ethan added Boba Run")

---

## 📄 License

MIT License. See [`LICENSE`](LICENSE) for details.

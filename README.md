# 💸 Blü — Group Expense Splitting App

Blü is a SwiftUI-powered iOS app that makes it easy for friend groups to track and split expenses during hangouts. Whether you're grabbing boba, hosting a BBQ, or going on a weekend trip, Blü keeps your group outings and finances simple and visual.

---

## ✨ Features

- 🧑‍🤝‍🧑 **Create Hangout Sessions**  
  Organize expenses by events — like “Bash” or “Vegas Trip 2025.”

- 📍 **Add Checkpoints**  
  Tag specific events (e.g., "Boba Run", "Dinner", "Gas") inside hangouts.

- 💵 **Track Expenses Per Checkpoint**  
  Log who paid and split expenses either **equally** or **custom**.

- 📷 **Capture Moments** *(Optional)*  
  Add photos with captions to keep memories from each checkpoint.

- 📊 **Automatic Settle Up**  
  Calculate how much each person owes or is owed — automatically.

- 🔐 **Firebase Auth Integration**  
  Sign up/login securely via Firebase.

- ☁️ **Cloud Sync with Firestore**  
  Real-time updates across devices using Firebase Firestore.

---

## 🛠️ Tech Stack

| Layer         | Tech                                       |
|---------------|--------------------------------------------|
| **Frontend**  | SwiftUI, UIKit (occasionally), MapKit      |
| **Backend**   | Firebase Firestore, Firebase Auth          |
| **Storage**   | Firestore for structured session data      |
| **Media**     | Firebase Storage for moments (images)      |

---

## 🧪 How It Works

Each **Hangout** is a container for one or more **Checkpoints**.  
Each Checkpoint can contain:

- Expenses (split equally/custom)
- Optional photo Moments with captions
- Location and time tagging

All data is calculated into a **summary** and a **settle up list** so friends know what’s owed — and who owes it.

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/nickcuenca/BluApp.git
   ```
2. Open `BluApp.xcodeproj` in Xcode
3. If using Firebase, add your `GoogleService-Info.plist` into the project
4. Run on a Simulator or your iPhone

---

## 🧠 Author

Built by [**Nicolas Cuenca**](https://github.com/nickcuenca)  
👨‍🎓 UCLA Computer Science  
🔧 Full Stack Developer • iOS Builder • Firebase Enthusiast  
📫 DM-friendly on GitHub or [LinkedIn](https://www.linkedin.com/in/nicolaswcuenca)

---

## ✅ To-Do / Future Features

- Venmo/Apple Pay integration (launch payment directly)
- Tip support
- Map-based checkpoint creation
- Dark mode polish
- Friends tab (add/search users)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

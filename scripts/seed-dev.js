process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

const admin = require("firebase-admin");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

// ✅ Explicitly match emulator UI project
admin.initializeApp({ projectId: "bluapp-4d4de" });

const db = getFirestore();

// ---------- Sample users ----------
const users = [
  { uid: "abc", email: "a@example.com", displayName: "Alice" },
  { uid: "xyz", email: "x@example.com", displayName: "Xander" },
  { uid: "pqr", email: "p@example.com", displayName: "Priya" }
];

const batch = db.batch();

users.forEach(u => {
  batch.set(db.doc(`users/${u.uid}`), {
    email: u.email,
    displayName: u.displayName,
    createdAt: FieldValue.serverTimestamp()
  });
});

// ---------- Pending friend request ----------
batch.set(db.doc("friendRequests/abc_xyz"), {
  from: "abc",
  to: "xyz",
  status: "pending",
  sentAt: FieldValue.serverTimestamp()
});

// ---------- Accepted friendship ----------
batch.set(db.doc("friends/abc-xyz"), {
  users: ["abc", "xyz"],
  createdAt: FieldValue.serverTimestamp()
});

// ---------- Hangout session + expense ----------
const sessionRef = db.doc("hangoutSessions/sesh1");
batch.set(sessionRef, {
  owner: "abc",
  participants: ["abc", "xyz"],
  startedAt: FieldValue.serverTimestamp(),
  title: "Coffee catch-up"
});
batch.set(sessionRef.collection("expenses").doc("exp1"), {
  payer: "abc",
  amount: 12.75,
  description: "Cappuccinos",
  splitType: "equal"
});

// ---------- Commit ----------
batch.commit().then(() => {
  console.log("✅  Seed data written");
  process.exit(0);
}).catch(err => {
  console.error("❌  Seed failed:", err);
  process.exit(1);
});

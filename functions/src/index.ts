import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// ---------- FRIEND ADDED ----------
export const onFriendCreate = functions.firestore
  .document("friends/{pairId}")
  .onCreate(async snap => {
    const { users } = snap.data() as { users: string[] };
    const inc = admin.firestore.FieldValue.increment(1);
    const batch = db.batch();
    users.forEach(uid =>
      batch.update(db.doc(`users/${uid}`), { "stats.friends": inc })
    );
    await batch.commit();
  });

// ---------- HANGOUT CREATED ----------
export const onHangoutCreate = functions.firestore
  .document("hangoutSessions/{id}")
  .onCreate(async snap => {
    const { owner } = snap.data() as { owner: string };
    await db.doc(`users/${owner}`)
      .update({ "stats.hangouts": admin.firestore.FieldValue.increment(1) });
  });

// ---------- EXPENSE WRITE ----------
export const onExpenseWrite = functions.firestore
  .document("hangoutSessions/{sid}/expenses/{eid}")
  .onWrite(async change => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return;

    const splits = after.splits || {};
    const batch  = db.batch();

    Object.entries(splits).forEach(([uid, amt]) => {
      const prev = before?.splits?.[uid] ?? 0;
      const diff = Number(amt) - Number(prev);
      batch.update(
        db.doc(`users/${uid}`),
        { "stats.balanceOwed": admin.firestore.FieldValue.increment(diff) }
      );
    });
    await batch.commit();
  });

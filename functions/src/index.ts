import * as functions from "firebase-functions/v1";               // v1 interface
import * as admin from "firebase-admin";
import { Change, EventContext } from "firebase-functions/v1";
import {
  DocumentSnapshot,
  FieldValue             // ✅ import FieldValue directly
} from "firebase-admin/firestore";

admin.initializeApp();
const db = admin.firestore();

// ---------- Helper: increment stats ----------
async function inc(uid: string, field: string, by = 1) {
  await db.doc(`stats/${uid}`).set(
    { [field]: FieldValue.increment(by) },   // ✅ safe, FieldValue always defined
    { merge: true }
  );
}

// ---------- 1. Friend created ----------
export const onFriendCreate = functions.firestore
  .document("friends/{pairID}")
  .onCreate(async (snap: DocumentSnapshot, ctx: EventContext) => {
    const users = snap.get("users") as string[] | undefined;
    if (!users || users.length !== 2) return;

    await Promise.all(users.map((u) => inc(u, "friends")));
  });

// ---------- 2. Hang-out session created ----------
export const onHangoutCreate = functions.firestore
  .document("hangoutSessions/{sessionID}")
  .onCreate(async (snap: DocumentSnapshot, ctx: EventContext) => {
    const users = snap.get("participants") as string[] | undefined;
    if (!users) return;

    await Promise.all(users.map((u) => inc(u, "hangouts")));
  });

// ---------- 3. Expense written ----------
export const onExpenseWrite = functions.firestore
  .document("hangoutSessions/{sessionID}/expenses/{expenseID}")
  .onWrite(async (change: Change<DocumentSnapshot>, ctx: EventContext) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;

    const delta = (after?.amount ?? 0) - (before?.amount ?? 0);
    if (delta === 0) return;

    const payer = after?.payer ?? before?.payer;
    if (!payer) return;

    await inc(payer, "expensesTotal", delta);
  });

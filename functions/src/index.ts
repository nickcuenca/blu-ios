import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { DocumentSnapshot } from "firebase-functions/v1/firestore";
import { Change } from "firebase-functions";
import { EventContext } from "firebase-functions/v1";
admin.initializeApp();

const db = admin.firestore();

/* ─────────── Helper: increment stats field ──────────── */
async function inc(uid: string,
                   field: string,
                   by = 1) {
  await db.doc(`stats/${uid}`).set(
    { [field]: admin.firestore.FieldValue.increment(by) },
    { merge: true }
  );
}

/* ─────────── 1. track new friend-pair creation ───────── */
export const onFriendCreate = functions.firestore
  .document("friends/{pairID}")
  .onCreate(async (snap: DocumentSnapshot, ctx: EventContext) => {
    const users = snap.get("users") as string[] | undefined;
    if (!users || users.length !== 2) return;

    await Promise.all(users.map(u => inc(u, "friends")));
  });

/* ─────────── 2. fan-out new hangout ──────────────────── */
export const onHangoutCreate = functions.firestore
  .document("hangouts/{hid}")
  .onCreate(async (snap: DocumentSnapshot, ctx: EventContext) => {
    const data  = snap.data();
    const users = data?.participants as string[] | undefined;
    if (!users) return;

    const batch = db.batch();
    users.forEach(uid => {
      batch.set(db.doc(`feed/${uid}/hangouts/${snap.id}`), data);
    });
    await batch.commit();

    await Promise.all(users.map(u => inc(u, "hangouts")));
  });

/* ─────────── 3. update pair-balances on expense write ── */
export const onExpenseWrite = functions.firestore
  .document("hangouts/{hid}/expenses/{expenseID}")
  .onWrite(async (change: Change<DocumentSnapshot>,
                  ctx: EventContext) => {

    const after  = change.after.exists ? change.after.data()  : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return;                           // only care about create / update

    const amount = after.amount     as number;
    const payer  = after.paidBy     as string;
    const parts  = after.participants as string[];
    const share  = amount / parts.length;

    // negate values if this is an update; recalc diff
    const multiplier = before ? -1 : +1;

    const batch = db.batch();
    parts.forEach(uid => {
      const pair = (uid < payer) ? `${uid}-${payer}` : `${payer}-${uid}`;
      const delta = (uid === payer ? amount - share : -share) * multiplier;

      batch.set(
        db.doc(`friends/${pair}`),
        { users: [uid, payer],               // in case doc is brand-new
          balances: { [uid]  : admin.firestore.FieldValue.increment(delta),
                       [payer]: admin.firestore.FieldValue.increment(-delta) } },
        { merge: true }
      );
    });

    await batch.commit();
  });

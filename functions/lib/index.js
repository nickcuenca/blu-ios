"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onExpenseWrite = exports.onHangoutCreate = exports.onFriendCreate = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
// ---------- FRIEND ADDED ----------
exports.onFriendCreate = functions.firestore
    .document("friends/{pairId}")
    .onCreate(async (snap) => {
    const { users } = snap.data();
    const inc = admin.firestore.FieldValue.increment(1);
    const batch = db.batch();
    users.forEach(uid => batch.update(db.doc(`users/${uid}`), { "stats.friends": inc }));
    await batch.commit();
});
// ---------- HANGOUT CREATED ----------
exports.onHangoutCreate = functions.firestore
    .document("hangoutSessions/{id}")
    .onCreate(async (snap) => {
    const { owner } = snap.data();
    await db.doc(`users/${owner}`)
        .update({ "stats.hangouts": admin.firestore.FieldValue.increment(1) });
});
// ---------- EXPENSE WRITE ----------
exports.onExpenseWrite = functions.firestore
    .document("hangoutSessions/{sid}/expenses/{eid}")
    .onWrite(async (change) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after)
        return;
    const splits = after.splits || {};
    const batch = db.batch();
    Object.entries(splits).forEach(([uid, amt]) => {
        const prev = before?.splits?.[uid] ?? 0;
        const diff = Number(amt) - Number(prev);
        batch.update(db.doc(`users/${uid}`), { "stats.balanceOwed": admin.firestore.FieldValue.increment(diff) });
    });
    await batch.commit();
});

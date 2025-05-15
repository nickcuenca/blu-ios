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
const functions = __importStar(require("firebase-functions/v1")); // v1 interface
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-admin/firestore");
admin.initializeApp();
const db = admin.firestore();
// ---------- Helper: increment stats ----------
async function inc(uid, field, by = 1) {
    await db.doc(`stats/${uid}`).set({ [field]: firestore_1.FieldValue.increment(by) }, // ✅ safe, FieldValue always defined
    { merge: true });
}
// ---------- 1. Friend created ----------
exports.onFriendCreate = functions.firestore
    .document("friends/{pairID}")
    .onCreate(async (snap, ctx) => {
    const users = snap.get("users");
    if (!users || users.length !== 2)
        return;
    await Promise.all(users.map((u) => inc(u, "friends")));
});
// ---------- 2. Hang-out session created ----------
exports.onHangoutCreate = functions.firestore
    .document("hangoutSessions/{sessionID}")
    .onCreate(async (snap, ctx) => {
    const users = snap.get("participants");
    if (!users)
        return;
    await Promise.all(users.map((u) => inc(u, "hangouts")));
});
// ---------- 3. Expense written ----------
exports.onExpenseWrite = functions.firestore
    .document("hangoutSessions/{sessionID}/expenses/{expenseID}")
    .onWrite(async (change, ctx) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const delta = (after?.amount ?? 0) - (before?.amount ?? 0);
    if (delta === 0)
        return;
    const payer = after?.payer ?? before?.payer;
    if (!payer)
        return;
    await inc(payer, "expensesTotal", delta);
});

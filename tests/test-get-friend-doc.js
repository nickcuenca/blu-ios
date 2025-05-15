const fs = require("fs");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, getDoc } = require("firebase/firestore");

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: "demo-project",
    firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
  });

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc("friends/abc-xyz").set({ users: ["abc", "xyz"] });
  });

  const ctx = testEnv.authenticatedContext("abc");
  const db = ctx.firestore();

  try {
    const snap = await getDoc(doc(db, "friends/abc-xyz"));
    console.log(snap.exists() ? "✅ PASS" : "❌ FAIL");
  } catch {
    console.log("❌ FAIL");
  }

  await testEnv.cleanup();
})();

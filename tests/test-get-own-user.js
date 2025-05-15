const fs = require("fs");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, getDoc } = require("firebase/firestore");

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: "demo-project",
    firestore: {
      rules: fs.readFileSync("firestore.rules", "utf8")
    }
  });

  const abcUser = testEnv.authenticatedContext("abc");
  const db = abcUser.firestore();

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc("users/abc").set({ displayName: "abc" });
  });

  try {
    const snap = await getDoc(doc(db, "users/abc"));
    console.log(snap.exists() ? "✅ PASS" : "❌ FAIL (not found)");
  } catch (e) {
    console.error("❌ FAIL", e.message);
  }

  await testEnv.cleanup();
})();

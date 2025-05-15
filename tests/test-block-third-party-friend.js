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

  const ctx = testEnv.authenticatedContext("pqr");
  const db = ctx.firestore();

  try {
    await getDoc(doc(db, "friends/abc-xyz"));
    console.log("❌ FAIL: Unauthorized read allowed");
  } catch {
    console.log("✅ PASS: Read correctly denied");
  }

  await testEnv.cleanup();
})();

const fs = require("fs");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, updateDoc } = require("firebase/firestore");

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: "demo-project",
    firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
  });

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc("friendRequests/abc_xyz").set({
      from: "abc",
      to: "xyz"
    });
  });

  const ctx = testEnv.authenticatedContext("xyz");
  const db = ctx.firestore();

  try {
    await updateDoc(doc(db, "friendRequests/abc_xyz"), {
      status: "accepted"
    });
    console.log("✅ PASS");
  } catch {
    console.log("❌ FAIL");
  }

  await testEnv.cleanup();
})();

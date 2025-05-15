const fs = require("fs");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, setDoc } = require("firebase/firestore");

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: "demo-project",
    firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
  });

  const ctx = testEnv.authenticatedContext("xyz");
  const db = ctx.firestore();

  try {
    await setDoc(doc(db, "users/abc"), { displayName: "hacked" });
    console.log("❌ FAIL: Unauthorized write allowed");
  } catch {
    console.log("✅ PASS: Write correctly denied");
  }

  await testEnv.cleanup();
})();

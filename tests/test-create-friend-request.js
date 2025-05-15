const fs = require("fs");
const { initializeTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, setDoc } = require("firebase/firestore");

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: "demo-project",
    firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
  });

  const ctx = testEnv.authenticatedContext("abc");
  const db = ctx.firestore();

  try {
    await setDoc(doc(db, "friendRequests/abc_xyz"), {
      from: "abc",
      to: "xyz"
    });
    console.log("✅ PASS");
  } catch {
    console.log("❌ FAIL");
  }

  await testEnv.cleanup();
})();

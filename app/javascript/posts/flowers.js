// === 🌸 Flower stage updater ===
function updateFlowerStages() {
  const flowerButtons = document.querySelectorAll(".post-actions .action-icon");
  const flowerStages = ["🌱", "🌿", "🌷", "🌹", "🌸", "🌺", "💐"];

  flowerButtons.forEach((btn) => {
    const countSpan = btn.nextElementSibling;
    if (!countSpan) return;

    const count = parseInt(countSpan.textContent, 10) || 0;
    const stageIndex = Math.min(count, flowerStages.length - 1);
    const newIcon = flowerStages[stageIndex];

    if (btn.textContent.trim() !== newIcon) {
      btn.textContent = newIcon;
      console.log(`🌼 updated button to "${newIcon}" (count: ${count})`);
    }
  });
}

// === Turbo lifecycle bindings ===
["turbo:load", "turbo:render", "turbo:after-stream-render"].forEach((event) => {
  document.addEventListener(event, () => {
    console.log(`💐 flower stage script triggered: ${event}`);

    // DOMの書き換えが終わった後に確実に走らせる
    setTimeout(updateFlowerStages, 80);
  });
});

// ✅ Turboがstreamを処理したあとに明示的に呼び直す
document.addEventListener("turbo:submit-end", (e) => {
  if (e.target.action.includes("/flower")) {
    console.log("🌺 Turbo submit for flower detected → re-run updater");
    setTimeout(updateFlowerStages, 120);
  }
});

console.log("🌸 flower stage script loaded");

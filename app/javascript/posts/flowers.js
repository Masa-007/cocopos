// 🌸 Flower stage updater
function updateFlowerStages() {
  const flowerButtons = document.querySelectorAll(".flower-btn");
  const flowerStages = ["🌱", "🌿", "🌷", "🌹", "🌸", "🌺", "💐"];

  flowerButtons.forEach((btn) => {
    const countSpan = btn.querySelector(".flower-count");
    const iconSpan = btn.querySelector(".flower-icon");
    if (!countSpan || !iconSpan) return;

    const count = parseInt(countSpan.textContent, 10) || 0;
    const stageIndex = Math.min(count, flowerStages.length - 1);
    const newIcon = flowerStages[stageIndex];

    if (iconSpan.textContent.trim() !== newIcon) {
      iconSpan.textContent = newIcon;
      console.log(`🌼 updated flower icon to "${newIcon}" (count: ${count})`);
    }
  });
}

// Turbo lifecycle bindings
["turbo:load", "turbo:render", "turbo:after-stream-render"].forEach((event) => {
  document.addEventListener(event, () => {
    console.log(`💐 flower stage script triggered: ${event}`);
    setTimeout(updateFlowerStages, 80);
  });
});

document.addEventListener("turbo:submit-end", (e) => {
  if (e.target.action.includes("/flower")) {
    console.log("🌺 Turbo submit for flower detected → re-run updater");
    setTimeout(updateFlowerStages, 120);
  }
});

console.log("🌸 flower stage script loaded");

window.updateFlowerStages = updateFlowerStages;

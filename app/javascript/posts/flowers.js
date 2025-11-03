// 🌸 Flower stage updater (メインロジック)
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
    }
  });
}

// 🌷 Turbo lifecycle bindings（差し替え後にも発火）
["turbo:load", "turbo:after-stream-render"].forEach((event) => {
  document.addEventListener(event, () => {
    setTimeout(updateFlowerStages, 150);
  });
});

// 🌺 フォーム送信完了時（花ボタン）
document.addEventListener("turbo:submit-end", (e) => {
  const form = e.target;
  if (form?.action?.includes("/flower")) {
    setTimeout(updateFlowerStages, 200);
  }
});

// 🌼 Turbo置換後のアニメーション再適用
document.addEventListener("turbo:after-stream-render", (e) => {
  const target = e.target.getAttribute("target");
  if (
    e.target.getAttribute("action") === "replace" &&
    target?.startsWith("flower_btn_")
  ) {
    const replaced = document.querySelector(`#${target}`);
    if (replaced) {
      replaced.classList.remove("animate-bloom");
      void replaced.offsetWidth; // reflowでアニメーション再トリガー
      replaced.classList.add("animate-bloom");
    }
  }
});

// グローバルに登録
window.updateFlowerStages = updateFlowerStages;

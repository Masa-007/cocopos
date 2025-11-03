
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

["turbo:load", "turbo:after-stream-render"].forEach((event) => {
  document.addEventListener(event, () => {
    setTimeout(updateFlowerStages, 150);
  });
});


document.addEventListener("turbo:submit-end", (e) => {
  const form = e.target;
  if (form?.action?.includes("/flower")) {
    setTimeout(updateFlowerStages, 200);
  }
});


document.addEventListener("turbo:after-stream-render", (e) => {
  const target = e.target.getAttribute("target");
  if (
    e.target.getAttribute("action") === "replace" &&
    target?.startsWith("flower_btn_")
  ) {
    const replaced = document.querySelector(`#${target}`);
    if (replaced) {
      replaced.classList.remove("animate-bloom");
      void replaced.offsetWidth; 
      replaced.classList.add("animate-bloom");
    }
  }
});


window.updateFlowerStages = updateFlowerStages;

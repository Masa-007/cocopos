// ===============================
// 🌸 投稿カードアニメーション部分
// ===============================
document.addEventListener("turbo:render", () => {
  console.log("🌸 posts.js reloaded");

  // === 投稿カードクリック ===
  const postCards = Array.from(document.querySelectorAll(".post-card"));
  postCards.forEach((card) => {
    card.addEventListener("click", (e) => {
      if (e.target.closest(".action-icon")) return;
      console.log(`投稿詳細ページへ遷移予定: ${card.dataset.id}`);
    });
  });

  // === 花ボタン ===
  const flowerButtons = document.querySelectorAll(".post-actions .action-icon");
  const flowerStages = ["🌱", "🌿", "🌷", "🌹", "🌸", "🌺", "💐"];

  flowerButtons.forEach((button) => {
    if (button.textContent.includes("💬")) return;
    let clickCount = 0;
    let stage = 0;
    const maxStage = flowerStages.length - 1;

    button.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      clickCount++;
      if (clickCount % 5 === 0 && stage < maxStage) {
        stage++;
        button.textContent = flowerStages[stage];
      }

      button.style.transition = "transform 0.3s ease, text-shadow 0.3s ease";
      button.style.transform = "scale(1.5) rotate(5deg)";
      button.style.textShadow = "0 0 15px rgba(255, 182, 193, 0.9)";
      setTimeout(() => {
        button.style.transform = "scale(1)";
        button.style.textShadow = "none";
      }, 300);
    });
  });
});


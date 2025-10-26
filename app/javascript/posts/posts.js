document.addEventListener("turbo:render", () => {
  console.log("🌸 posts.js reloaded");

  // === 投稿カードクリック ===
  const postCards = Array.from(document.querySelectorAll(".post-card"));
  postCards.forEach((card) => {
    card.addEventListener("click", (e) => {
      // アクションアイコンをクリックした場合は詳細へ飛ばさない
      if (e.target.closest(".action-icon")) return;
      console.log(`投稿詳細ページへ遷移予定: ${card.dataset.id}`);
      // window.location.href = `/posts/${card.dataset.id}`;
    });
  });

  // === 花ボタン（進化→最終で止まる） ===
  const flowerButtons = document.querySelectorAll(".post-actions .action-icon");
  const flowerStages = ["🌱", "🌿", "🌷", "🌹", "🌸", "🌺", "💐"];

  flowerButtons.forEach((button) => {
    // コメントボタンは除外
    if (button.textContent.includes("💬")) return;

    let clickCount = 0;
    let stage = 0;
    const maxStage = flowerStages.length - 1;

    button.addEventListener("click", (e) => {
      e.preventDefault(); // ← aタグリンクを止める
      e.stopPropagation(); // ← 親の投稿カードクリックを止める
      clickCount++;

      // 5回ごとに進化、最終形（💐）で止まる
      if (clickCount % 5 === 0 && stage < maxStage) {
        stage++;
        button.textContent = flowerStages[stage];
      }

      // 光る演出（どの段階でも発生）
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

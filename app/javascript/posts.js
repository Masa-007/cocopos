// app/javascript/posts.js

document.addEventListener("turbo:load", () => {
  // === 重複イベント防止 ===
  document
    .querySelectorAll(".filter-btn, .flower-btn, #sortSelect")
    .forEach((el) => el.replaceWith(el.cloneNode(true)));

  // === 絞り込み機能 ===
  const filterButtons = document.querySelectorAll(".filter-btn");
  const postCards = Array.from(document.querySelectorAll(".post-card"));
  const postsGrid = document.getElementById("posts-grid");

  if (filterButtons.length && postCards.length && postsGrid) {
    filterButtons.forEach((button) => {
      button.addEventListener("click", () => {
        filterButtons.forEach((btn) => btn.classList.remove("active"));
        button.classList.add("active");

        const filter = button.dataset.filter;
        postCards.forEach((card) => {
          const match = filter === "all" || card.dataset.category === filter;
          card.style.display = match ? "block" : "none";
          card.style.animation = "none";
          if (match) {
            setTimeout(() => {
              card.style.animation = "fadeIn 0.5s ease-out";
            }, 10);
          }
        });
      });
    });
  }

  // === 並び替え（新着順・古い順） ===
  const sortSelect = document.querySelector("#sortSelect");
  if (sortSelect && postsGrid) {
    sortSelect.addEventListener("change", () => {
      const selected = sortSelect.value;
      const sortedCards = [...postCards];

      sortedCards.sort((a, b) => {
        const dateA = new Date(a.dataset.createdAt);
        const dateB = new Date(b.dataset.createdAt);
        return selected === "古い順" ? dateA - dateB : dateB - dateA;
      });

      postsGrid.innerHTML = "";
      sortedCards.forEach((card) => postsGrid.appendChild(card));

      sortedCards.forEach((card) => {
        card.style.animation = "none";
        setTimeout(() => (card.style.animation = "fadeIn 0.5s ease-out"), 10);
      });
    });
  }

  // === 投稿カードクリック ===
  postCards.forEach((card) => {
    card.addEventListener("click", (e) => {
      if (e.target.closest(".action-icon")) return;
      console.log(`投稿詳細ページへ遷移予定: ${card.dataset.id}`);
      // window.location.href = `/posts/${card.dataset.id}`;
    });
  });

  // === 花ボタン（進化→最終で止まる） ===
  const flowerButtons = document.querySelectorAll(".post-actions .action-icon");
  const flowerStages = ["🌱", "🌿", "🌷", "🌹", "🌸", "🌺", "💐"];

  flowerButtons.forEach((button) => {
    if (button.textContent.includes("💬")) return; // コメントボタン除外

    let clickCount = 0;
    let stage = 0;
    let maxStage = flowerStages.length - 1;

    button.addEventListener("click", (e) => {
      e.stopPropagation();
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

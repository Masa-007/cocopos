document.addEventListener("turbo:load", () => {
  const postForm = document.getElementById("postForm");
  if (!postForm) return;

  const postTypeRadios = document.querySelectorAll(".post-type-radio");
  const opinionSection = document.getElementById("opinionSection");
  const bodyTextarea = postForm.querySelector("#post_body");
  const charCount = document.getElementById("charCount");
  const loadingScreen = document.getElementById("loadingScreen");
  const completionScreen = document.getElementById("completionScreen");

  // === 投稿タイプ切替 ===
  postTypeRadios.forEach((radio) => {
    radio.addEventListener("change", (e) => {
      opinionSection.classList.toggle("hidden", e.target.value !== "organize");
    });
  });

  // === 文字数カウント ===
  if (bodyTextarea && charCount) {
    bodyTextarea.addEventListener("input", () => {
      charCount.textContent = bodyTextarea.value.length;
    });
  }

  // === 投函処理 ===
  postForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    const formData = new FormData(postForm);
    const postType = formData.get("post[post_type]");
    const body = formData.get("post[body]")?.trim();

    if (!postType) return alert("投函する箱を選択してください");
    if (!body) return alert("本文を入力してください");

    // 🎬 ローディング画面を表示
    loadingScreen.classList.add("active");

    // 💌 手紙アニメーションを再起動（何度でも動くように）
    const letter = loadingScreen.querySelector(".letter");
    if (letter) {
      letter.style.animation = "none";
      void letter.offsetWidth; // 強制リフロー
      letter.style.animation = "letterInsert 4.5s ease-in-out forwards";
    }

    try {
      const response = await fetch(postForm.action, {
        method: "POST",
        body: formData,
        headers: { Accept: "application/json" },
      });

      if (!response.ok) throw new Error("サーバーエラー");

      // 🎬 投函中アニメーションを5秒間見せる
      setTimeout(() => {
        loadingScreen.classList.remove("active");
        completionScreen.classList.add("active");
      }, 5000);
    } catch (err) {
      loadingScreen.classList.remove("active");
      alert("投稿に失敗しました。");
    }
  });
});

// === X（旧Twitter）共有 ===
window.shareOnX = (event) => {
  event.preventDefault();
  const text = "投稿しました📮 #cocopos";
  const url = window.location.origin;
  const shareUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(
    text
  )}&url=${encodeURIComponent(url)}`;
  window.open(shareUrl, "_blank", "width=550,height=420");
};

document.addEventListener("turbo:load", () => {
  const postForm = document.getElementById("postForm");
  if (!postForm) return;

  // === 投稿タイプ切替 ===
  const postTypeRadios = document.querySelectorAll(".post-type-radio");
  const opinionSection = document.getElementById("opinionSection");

  postTypeRadios.forEach((radio) => {
    radio.addEventListener("change", (e) => {
      opinionSection.classList.toggle("hidden", e.target.value !== "organize");
    });
  });

  // === 文字数カウント ===
  const bodyTextarea = postForm.querySelector('textarea[name="post[body]"]');
  const charCount = document.getElementById("charCount");

  if (bodyTextarea && charCount) {
    bodyTextarea.addEventListener("input", () => {
      charCount.textContent = bodyTextarea.value.length;
    });
  }

  // === 投稿送信処理 ===
  postForm.addEventListener("submit", (e) => {
    e.preventDefault();

    const postType = postForm.querySelector(
      'input[name="post[post_type]"]:checked'
    );
    const body = bodyTextarea.value.trim();

    if (!postType) {
      alert("投函する箱を選択してください");
      return;
    }

    if (!body) {
      alert("本文を入力してください");
      return;
    }

    const loadingScreen = document.getElementById("loadingScreen");
    loadingScreen.classList.remove("hidden");

    const formData = new FormData(postForm);

    // 投稿処理（演出付き）
    fetch(postForm.action, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        // 3秒ローディング演出
        setTimeout(() => {
          loadingScreen.classList.add("hidden");

          if (data.success) {
            const completion = document.getElementById("completionScreen");
            -completion.classList.add("active");
            +completion.classList.remove("hidden");

            const letter = completion.querySelector(".letter");
            if (letter) {
              letter.classList.add("sent");
              setTimeout(() => letter.classList.add("fade-out"), 1000);
            }
          } else {
            alert("投稿に失敗しました: " + data.errors.join(", "));
          }
        }, 3000);
      })
      .catch((error) => {
        setTimeout(() => {
          loadingScreen.classList.add("hidden");
          alert("エラーが発生しました");
          console.error("Error:", error);
        }, 3000);
      });
  });
});

// === X（旧Twitter）共有 ===
function shareOnX(event) {
  event.preventDefault();
  const text = "投稿しました📮 #cocopos";
  const url = window.location.origin;
  const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(
    text
  )}&url=${encodeURIComponent(url)}`;
  window.open(twitterUrl, "_blank", "width=550,height=420");
}

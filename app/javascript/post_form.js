document.addEventListener("turbo:load", () => {
  const postForm = document.getElementById("postForm");

  if (!postForm) return;

  // 投稿タイプ選択で意見セクション表示切替
  const postTypeRadios = document.querySelectorAll(".post-type-radio");
  const opinionSection = document.getElementById("opinionSection");

  postTypeRadios.forEach((radio) => {
    radio.addEventListener("change", (e) => {
      if (e.target.value === "organize") {
        opinionSection.classList.remove("hidden");
      } else {
        opinionSection.classList.add("hidden");
      }
    });
  });

  // 文字数カウント
  const bodyTextarea = postForm.querySelector('textarea[name="post[body]"]');
  const charCount = document.getElementById("charCount");

  if (bodyTextarea && charCount) {
    bodyTextarea.addEventListener("input", () => {
      charCount.textContent = bodyTextarea.value.length;
    });
  }

  // フォーム送信
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

    // ローディング表示
    const loadingScreen = document.getElementById("loadingScreen");
    loadingScreen.classList.remove("hidden");

    const formData = new FormData(postForm);

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
        loadingScreen.classList.add("hidden");

        if (data.success) {
          document.getElementById("completionScreen").classList.add("active");
        } else {
          alert("投稿に失敗しました: " + data.errors.join(", "));
        }
      })
      .catch((error) => {
        loadingScreen.classList.add("hidden");
        alert("エラーが発生しました");
        console.error("Error:", error);
      });
  });
});

function shareOnX(event) {
  event.preventDefault();
  const text = "投稿しました📮 #cocopos";
  const url = window.location.origin;
  const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(
    text
  )}&url=${encodeURIComponent(url)}`;
  window.open(twitterUrl, "_blank", "width=550,height=420");
}

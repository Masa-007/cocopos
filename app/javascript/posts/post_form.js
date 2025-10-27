// ===============================
// 投稿フォームの送信制御
// ===============================
const initPostForm = () => {
  const form = document.querySelector("#postForm");
  if (!form) return;

  const loading = document.querySelector("#loadingScreen");
  const complete = document.querySelector("#completionScreen");

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const data = new FormData(form);
    const postType = data.get("post[post_type]");
    const body = data.get("post[body]")?.trim();

    if (!postType) {
      alert("投函する箱を選択してください");
      return;
    }
    if (!body) {
      alert("本文を入力してください");
      return;
    }

    loading.classList.add("active");

    const letter = loading.querySelector(".letter");
    if (letter) {
      // アニメをリセットして再起動
      letter.style.animation = "none";
      void letter.offsetWidth;
      letter.style.animation = "letterInsert 4.5s ease-in-out forwards";
    }

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await fetch(form.action, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": token,
        },
        body: data,
      });

      const result = await response.json();

      if (result.success) {
        if (letter) {
          // 手紙アニメが終わったら完了画面へ
          letter.addEventListener(
            "animationend",
            () => {
              loading.classList.remove("active");
              complete.classList.add("active");
            },
            { once: true }
          );
        } else {
          // 念のため fallback
          loading.classList.remove("active");
          complete.classList.add("active");
        }
      } else {
        throw new Error(result.errors?.join(", ") || "投稿に失敗しました");
      }
    } catch (error) {
      loading.classList.remove("active");
      alert("投稿に失敗しました。");
      console.error("投稿エラー:", error);
    }
  });
};

document.addEventListener("turbo:load", initPostForm);

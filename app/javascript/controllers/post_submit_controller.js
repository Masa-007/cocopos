import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit(event) {
    event.preventDefault();

    const form = event.target;
    const loading = document.getElementById("loadingScreen");
    const completion = document.getElementById("completionScreen");

    if (!loading || !completion) {
      alert("画面構成に問題があります");
      return;
    }

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

    // loading 表示
    loading.classList.add("active");

    const submitBtn = form.querySelector("[type='submit']");
    if (submitBtn) submitBtn.disabled = true;

    // アニメーション開始時刻
    const animationDuration = 4500; // ← CSS と必ず合わせる

    const letter = loading.querySelector(".letter");
    if (letter) {
      letter.style.animation = "none";
      letter.offsetHeight;
      letter.style.animation = "letterInsert 4.5s ease-in-out forwards";
    }

    // 投稿処理
    fetch(form.action, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: data,
    })
      .then(async (res) => {
        if (!res.ok) throw new Error("投稿に失敗しました");

        // ★ アニメーション完了を待ってから完了画面へ
        setTimeout(() => {
          loading.classList.remove("active");
          completion.classList.add("active");
        }, animationDuration);
      })
      .catch((err) => {
        loading.classList.remove("active");
        alert(err.message || "通信エラーが発生しました");
      })
      .finally(() => {
        if (submitBtn) submitBtn.disabled = false;
      });
  }
}

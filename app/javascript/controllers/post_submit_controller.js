import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit(event) {
    event.preventDefault();

    const form = event.target;
    const loading = document.getElementById("loadingScreen");
    const completion = document.getElementById("completionScreen");

    if (!loading || !completion) {
      form.submit();
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

    loading.classList.add("active");

    const submitBtn = form.querySelector("[type='submit']");
    if (submitBtn) submitBtn.disabled = true;

    const animationDuration = 4500;

    const letter = loading.querySelector(".letter");
    if (letter) {
      letter.style.animation = "none";
      letter.offsetHeight;
      letter.style.animation = "letterInsert 4.5s ease-in-out forwards";
    }

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
        const contentType = res.headers.get("content-type") || "";
        const isJson = contentType.includes("application/json");
        const payload = isJson ? await res.json() : null;

        if (!res.ok) {
          const errors = payload?.errors;
          if (Array.isArray(errors) && errors.length > 0) {
            throw new Error(errors.join("\n"));
          }
          throw new Error(payload?.message || "投稿に失敗しました");
        }

        setTimeout(() => {
          loading.classList.remove("active");

          document.documentElement.classList.add("modal-open");
          document.body.classList.add("modal-open");

          completion.classList.add("active");

          // 完了画面内のリンクを押したらスクロールロック解除（残留対策）
          completion.querySelectorAll("a, button").forEach((el) => {
            el.addEventListener(
              "click",
              () => {
                document.documentElement.classList.remove("modal-open");
                document.body.classList.remove("modal-open");
              },
              { once: true },
            );
          });
        }, animationDuration);
      })
      .catch((err) => {
        loading.classList.remove("active");
        document.documentElement.classList.remove("modal-open");
        document.body.classList.remove("modal-open");

        alert(err.message || "通信エラーが発生しました");
      })
      .finally(() => {
        if (submitBtn) submitBtn.disabled = false;
      });
  }
}

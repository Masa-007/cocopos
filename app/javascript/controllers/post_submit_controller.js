import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    enabled: { type: Boolean, default: true },
    validate: { type: Boolean, default: true },
    animate: { type: Boolean, default: true },
    ajax: { type: Boolean, default: true },
    completion: { type: Boolean, default: true },
    animationDuration: { type: Number, default: 4500 },
  };

  submit(event) {
    if (!this.enabledValue) return; // 何もしない（通常submitに任せる）

    const form = event.target;

    // A: 事前バリデーション（ここが邪魔なら validate=false で切れる）
    if (this.validateValue) {
      const data = new FormData(form);
      const postType = data.get("post[post_type]");
      const body = (data.get("post[body]") || "").trim();

      if (!postType) {
        event.preventDefault();
        alert("投函する箱を選択してください");
        return;
      }
      if (!body) {
        event.preventDefault();
        alert("本文を入力してください");
        return;
      }
    }

    // C を切るなら、ここで通常submitに戻す（アニメだけ出したい、など）
    if (!this.ajaxValue) return;

    event.preventDefault();

    const loading = document.getElementById("loadingScreen");
    const completion = document.getElementById("completionScreen");

    // ローディング/完了が無いなら通常submit
    if (!loading || !completion) {
      form.submit();
      return;
    }

    // B: ローディング
    if (this.animateValue) {
      loading.classList.add("active");
      const letter = loading.querySelector(".letter");
      if (letter) {
        letter.style.animation = "none";
        letter.offsetHeight;
        letter.style.animation = "letterInsert 4.5s ease-in-out forwards";
      }
    }

    const submitBtn = form.querySelector("[type='submit']");
    if (submitBtn) submitBtn.disabled = true;

    const tokenEl = document.querySelector('meta[name="csrf-token"]');
    const token = tokenEl ? tokenEl.content : null;

    fetch(form.action, {
      method: "POST",
      headers: {
        Accept: "application/json",
        ...(token ? { "X-CSRF-Token": token } : {}),
      },
      body: new FormData(form),
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

        // D: 完了画面
        const showCompletion = () => {
          if (this.animateValue) loading.classList.remove("active");

          if (this.completionValue) {
            document.documentElement.classList.add("modal-open");
            document.body.classList.add("modal-open");
            completion.classList.add("active");
          }
        };

        if (this.animateValue) {
          setTimeout(showCompletion, this.animationDurationValue);
        } else {
          showCompletion();
        }
      })
      .catch((err) => {
        if (this.animateValue) loading.classList.remove("active");
        document.documentElement.classList.remove("modal-open");
        document.body.classList.remove("modal-open");
        alert(err.message || "通信エラーが発生しました");
      })
      .finally(() => {
        if (submitBtn) submitBtn.disabled = false;
      });
  }
}

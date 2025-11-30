// 投稿フォーム初期化
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

      if (!response.ok) throw new Error(`HTTPエラー: ${response.status}`);

      const result = await response.json();

      if (result.success) {
        if (letter) {
          letter.addEventListener(
            "animationend",
            () => {
              loading.classList.remove("active");
              complete.classList.add("active");
            },
            { once: true }
          );
        } else {
          loading.classList.remove("active");
          complete.classList.add("active");
        }
      } else {
        loading.classList.remove("active");

        if (result.errors && result.errors.length > 0) {
          alert(`投稿に失敗しました。\n\n${result.errors.join("\n")}`);
        } else {
          alert("投稿に失敗しました。");
        }

        throw new Error(result.errors?.join(", ") || "投稿に失敗しました");
      }
    } catch (error) {
      loading.classList.remove("active");
      console.error("投稿エラー:", error);

      if (!error.message.includes("NG") && !error.message.includes("失敗")) {
        alert(
          "予期しないエラーが発生しました。⚠️NGワードが含まれている可能性があります。"
        );
      }
    }
  });
};

// カード形式のラジオボタン初期化
const initCardRadios = () => {
  function refreshCardsByName(name) {
    const group = document.querySelectorAll(
      `input[type="radio"][name="${name}"]`
    );
    group.forEach((input) => {
      const card = input.closest("label")?.querySelector(".card-ui");
      if (!card) return;
      card.classList.toggle("border-orange-400", input.checked);
      card.classList.toggle("ring-2", input.checked);
      card.classList.toggle("ring-orange-200", input.checked);
    });
  }

  const radios = document.querySelectorAll('input[type="radio"]');
  radios.forEach((r) => {
    r.addEventListener("change", () => refreshCardsByName(r.name));
  });

  const names = [...new Set(Array.from(radios).map((r) => r.name))];
  names.forEach((name) => refreshCardsByName(name));
};

// 公開・コメント不可制御アラート
const setupVisibilityAlert = () => {
  const publicRadios = document.querySelectorAll(
    'input[name="post[is_public]"]'
  );
  const commentRadios = document.querySelectorAll(
    'input[name="post[comment_allowed]"]'
  );
  if (!publicRadios.length || !commentRadios.length) return;

  const checkInvalidCombo = () => {
    const isPublic =
      document.querySelector('input[name="post[is_public]"]:checked')?.value ===
      "true";
    const commentAllowed =
      document.querySelector('input[name="post[comment_allowed]"]:checked')
        ?.value === "true";

    console.log(`公開=${isPublic} / コメント=${commentAllowed}`);
    if (!isPublic && commentAllowed) {
      alert("⚠️ 非公開投稿ではコメントを募集できません。");
      const commentOff = document.querySelector(
        'input[name="post[comment_allowed]"][value="false"]'
      );
      if (commentOff) {
        commentOff.checked = true;
        commentOff.dispatchEvent(new Event("change"));
      }
    }
  };

  [...publicRadios, ...commentRadios].forEach((r) => {
    r.removeEventListener("change", checkInvalidCombo);
    r.addEventListener("change", checkInvalidCombo);
  });

  checkInvalidCombo();
};

// 💡 心の整理を選んだら mood セクションを表示
const setupMoodToggle = () => {
  const moodSection = document.querySelector("#moodSection");
  if (!moodSection) return;

  const postTypeRadios = document.querySelectorAll(
    'input[name="post[post_type]"]'
  );

  postTypeRadios.forEach((radio) => {
    radio.addEventListener("change", () => {
      if (radio.value === "organize") {
        moodSection.classList.remove("hidden");
      } else {
        moodSection.classList.add("hidden");
      }
    });
  });

  if (document.querySelector("input[name='post[mood]']:checked")) {
    moodSection.classList.remove("hidden");
  }
};

// 初期化
document.addEventListener("turbo:load", () => {
  initPostForm();
  initCardRadios();
  setupVisibilityAlert();
  setupMoodToggle(); 
});

document.addEventListener("turbo:load", () => {
  // === 文字数カウント ===
  const textarea = document.querySelector('textarea[name="post[body]"]');
  const charCount = document.getElementById("charCount");

  if (textarea && charCount) {
    // 初期文字数の表示（編集時に既存文字がある場合に対応）
    charCount.textContent = textarea.value.length;

    textarea.addEventListener("input", () => {
      charCount.textContent = textarea.value.length;
    });
  }

  // === 意見カード（編集ページ用） ===
  const opinionRadios = document.querySelectorAll(".opinion-radio");
  opinionRadios.forEach((radio) => {
    radio.addEventListener("change", () => {
      document
        .querySelectorAll(".opinion-card .opinion-content")
        .forEach((content) => {
          content.classList.remove("border-orange-400", "bg-orange-50");
          content.classList.add("border-gray-200");
        });

      radio.parentElement
        .querySelector(".opinion-content")
        .classList.remove("border-gray-200");
      radio.parentElement
        .querySelector(".opinion-content")
        .classList.add("border-orange-400", "bg-orange-50");
    });
  });
});

document.addEventListener("turbo:load", () => {
  const textarea = document.querySelector('textarea[name="post[body]"]');
  const charCount = document.getElementById("charCount");

  if (textarea && charCount) {
    charCount.textContent = textarea.value.length;

    if (!textarea.dataset.charCountBound) {
      textarea.addEventListener("input", () => {
        charCount.textContent = textarea.value.length;
      });
      textarea.dataset.charCountBound = "1";
    }
  }

  document.querySelectorAll(".opinion-radio").forEach((radio) => {
    if (radio.dataset.opinionBound) return;

    radio.addEventListener("change", () => {
      document
        .querySelectorAll(".opinion-card .opinion-content")
        .forEach((content) => {
          content.classList.remove("border-orange-400", "bg-orange-50");
          content.classList.add("border-gray-200");
        });

      const content = radio.parentElement?.querySelector(".opinion-content");
      if (!content) return;

      content.classList.remove("border-gray-200");
      content.classList.add("border-orange-400", "bg-orange-50");
    });

    radio.dataset.opinionBound = "1";
  });
});

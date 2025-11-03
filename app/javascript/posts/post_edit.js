document.addEventListener("turbo:load", () => {
  const textarea = document.querySelector('textarea[name="post[body]"]');
  const charCount = document.getElementById("charCount");

  if (textarea && charCount) {
    charCount.textContent = textarea.value.length;

    textarea.addEventListener("input", () => {
      charCount.textContent = textarea.value.length;
    });
  }

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

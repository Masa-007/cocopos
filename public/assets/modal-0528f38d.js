// app/javascript/modal.js
document.addEventListener("turbo:render", () => {
  console.log("turbo:render fired");

  const helpButton = document.querySelector("#helpButton");
  const helpModal = document.querySelector("#helpModal");
  const closeBtn = document.querySelector(".modal-close");

  if (!helpButton || !helpModal || !closeBtn) {
    console.log("必要な要素が見つかりません");
    return;
  }

  helpButton.onclick = () => {
    console.log("button clicked");
    helpModal.classList.add("active");
  };

  closeBtn.onclick = () => {
    console.log("close clicked");
    helpModal.classList.remove("active");
  };

  helpModal.onclick = (e) => {
    if (e.target === helpModal) {
      console.log("background clicked");
      helpModal.classList.remove("active");
    }
  };
});

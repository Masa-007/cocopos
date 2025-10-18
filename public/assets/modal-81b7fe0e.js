// app/javascript/modal.js
document.addEventListener("turbo:load", () => {
  console.log("turbo:load fired");
  const helpButton = document.querySelector("#helpButton");
  const helpModal = document.querySelector("#helpModal");
  const closeBtn = document.querySelector(".modal-close");
  const howToLink = document.querySelector("#howToLink");
  if (!helpModal || !closeBtn) {
    console.log("\u5FC5\u8981\u306A\u8981\u7D20\u304C\u898B\u3064\u304B\u308A\u307E\u305B\u3093");
    return;
  }
  const openModal = () => {
    console.log("modal opened");
    helpModal.classList.add("active");
  };
  const closeModal = () => {
    console.log("modal closed");
    helpModal.classList.remove("active");
  };
  if (helpButton && !helpButton.dataset.listenerAdded) {
    helpButton.addEventListener("click", openModal);
    helpButton.dataset.listenerAdded = "true";
  }
  if (howToLink && !howToLink.dataset.listenerAdded) {
    howToLink.addEventListener("click", (e) => {
      e.preventDefault();
      openModal();
    });
    howToLink.dataset.listenerAdded = "true";
  }
  closeBtn.addEventListener("click", closeModal);
  helpModal.addEventListener("click", (e) => {
    if (e.target === helpModal) closeModal();
  });
});
//# sourceMappingURL=/assets/modal-f9450a2c.js.map

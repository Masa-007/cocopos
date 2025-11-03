document.addEventListener("turbo:load", () => {
  requestAnimationFrame(() => {
    const helpButton = document.querySelector("#helpButton");
    const helpModal = document.querySelector("#helpModal");
    const closeBtn = document.querySelector(".modal-close");
    const howToLink = document.querySelector("#howToLink");

    if (!helpModal || !closeBtn) return;

    const openModal = () => {
      helpModal.classList.add("active");
    };

    const closeModal = () => {
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
});

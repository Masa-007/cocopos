document.addEventListener("turbo:load", () => {
  requestAnimationFrame(() => {
    const helpButton = document.querySelector("#helpButton");
    const helpModal = document.querySelector("#helpModal");
    const howToLink = document.querySelector("#howToLink");

    if (!helpModal) return;

    const closeButtons = helpModal.querySelectorAll(".modal-close");

    const openModal = () => {
      helpModal.classList.add("active");
      document.body.classList.add("modal-open");
    };

    const closeModal = () => {
      helpModal.classList.remove("active");
      document.body.classList.remove("modal-open");
    };

    // もしHTML側の初期状態で active が付いていた場合に備えて整える（任意）
    if (helpModal.classList.contains("active")) {
      document.body.classList.add("modal-open");
    } else {
      document.body.classList.remove("modal-open");
    }

    // open: helpButton
    if (helpButton && !helpButton.dataset.listenerAdded) {
      helpButton.addEventListener("click", openModal);
      helpButton.dataset.listenerAdded = "true";
    }

    // open: howToLink
    if (howToLink && !howToLink.dataset.listenerAdded) {
      howToLink.addEventListener("click", (e) => {
        e.preventDefault();
        openModal();
      });
      howToLink.dataset.listenerAdded = "true";
    }

    // close: close buttons（複数あってもOK）
    closeButtons.forEach((btn) => {
      if (btn.dataset.listenerAdded) return;
      btn.addEventListener("click", closeModal);
      btn.dataset.listenerAdded = "true";
    });

    // close: backdrop click
    if (!helpModal.dataset.listenerAdded) {
      helpModal.addEventListener("click", (e) => {
        if (e.target === helpModal) closeModal();
      });
      helpModal.dataset.listenerAdded = "true";
    }

    // close: Esc
    if (!document.body.dataset.helpModalEscListenerAdded) {
      document.addEventListener("keydown", (e) => {
        if (e.key !== "Escape") return;
        const modal = document.querySelector("#helpModal");
        if (modal && modal.classList.contains("active")) {
          modal.classList.remove("active");
          document.body.classList.remove("modal-open");
        }
      });
      document.body.dataset.helpModalEscListenerAdded = "true";
    }
  });
});

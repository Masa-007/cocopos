document.addEventListener("turbo:load", () => {
  console.log("turbo:load fired");

  requestAnimationFrame(() => {
    const helpButton = document.querySelector("#helpButton");
    const helpModal = document.querySelector("#helpModal");
    const closeBtn = document.querySelector(".modal-close");
    const howToLink = document.querySelector("#howToLink");

    if (!helpModal || !closeBtn) {
      console.log("必要な要素が見つかりません");
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
});

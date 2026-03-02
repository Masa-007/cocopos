document.addEventListener("turbo:load", () => {
  const trigger = document.getElementById("accountDeleteButton");
  const modal = document.getElementById("accountDeleteModal");
  if (!trigger || !modal) return;

  const closeButtons = modal.querySelectorAll("[data-modal-close]");
  const blockedDeleteButton = modal.querySelector("[data-demo-account-delete-block]");

  const openModal = (e) => {
    e.preventDefault();
    modal.classList.add("active");
  };

  const closeModal = (e) => {
    if (e) e.preventDefault();
    modal.classList.remove("active");
  };

  const showBlockedFlash = (message) => {
    const flashContainer = document.getElementById("flash-container");
    if (!flashContainer || !message) return;

    const flash = document.createElement("div");
    flash.className = "flash bg-red-100 text-red-800 border border-red-300 px-4 py-2 rounded shadow";
    flash.textContent = message;
    flashContainer.appendChild(flash);

    setTimeout(() => {
      flash.classList.add("fade-out");
      setTimeout(() => flash.remove(), 500);
    }, 2000);
  };

  trigger.addEventListener("click", openModal);

  closeButtons.forEach((btn) => btn.addEventListener("click", closeModal));

  if (blockedDeleteButton) {
    blockedDeleteButton.addEventListener("click", (e) => {
      e.preventDefault();
      showBlockedFlash(blockedDeleteButton.dataset.message);
      closeModal();
    });
  }

  modal.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
  });
});

document.addEventListener("turbo:load", () => {
  const trigger = document.getElementById("accountDeleteButton");
  const modal = document.getElementById("accountDeleteModal");
  if (!trigger || !modal) return;

  const closeButtons = modal.querySelectorAll("[data-modal-close]");

  const openModal = (e) => {
    e.preventDefault();
    modal.classList.add("active");
  };

  const closeModal = (e) => {
    if (e) e.preventDefault();
    modal.classList.remove("active");
  };

  trigger.addEventListener("click", openModal);

  closeButtons.forEach((btn) => btn.addEventListener("click", closeModal));

  modal.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
  });
});

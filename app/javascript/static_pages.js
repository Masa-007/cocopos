const helpButton = document.getElementById("helpButton");
const helpModal = document.getElementById("helpModal");
const closeBtn = document.querySelector(".modal-close");

helpButton?.addEventListener("click", () => {
  helpModal.classList.add("active");
});

closeBtn?.addEventListener("click", () => {
  helpModal.classList.remove("active");
});

helpModal?.addEventListener("click", (e) => {
  if (e.target === helpModal) helpModal.classList.remove("active");
});

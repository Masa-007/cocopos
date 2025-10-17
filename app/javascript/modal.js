// app/javascript/modal.js
document.addEventListener("turbo:load", () => {
  console.log("turbo:load fired");

  const helpButton = document.querySelector("#helpButton");
  const helpModal = document.querySelector("#helpModal");
  const closeBtn = document.querySelector(".modal-close");
  const howToLink = document.querySelector("#howToLink"); // ← 追加（ヘッダーの使い方リンク）

  if (!helpModal || !closeBtn) {
    console.log("必要な要素が見つかりません");
    return;
  }

  // モーダルを開く関数
  const openModal = () => {
    console.log("modal opened");
    helpModal.classList.add("active");
  };

  // モーダルを閉じる関数
  const closeModal = () => {
    console.log("modal closed");
    helpModal.classList.remove("active");
  };

  // ❓ボタン
  if (helpButton && !helpButton.dataset.listenerAdded) {
    helpButton.addEventListener("click", openModal);
    helpButton.dataset.listenerAdded = "true";
  }

  // ヘッダーの「使い方」リンク
  if (howToLink && !howToLink.dataset.listenerAdded) {
    howToLink.addEventListener("click", (e) => {
      e.preventDefault();
      openModal();
    });
    howToLink.dataset.listenerAdded = "true";
  }

  // 閉じるボタン
  closeBtn.addEventListener("click", closeModal);

  // 背景クリックで閉じる
  helpModal.addEventListener("click", (e) => {
    if (e.target === helpModal) closeModal();
  });
});

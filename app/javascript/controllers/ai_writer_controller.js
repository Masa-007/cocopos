import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "loading", "options"];

  connect() {
    this.toggle();

    document.addEventListener("change", (e) => {
      if (e.target.name === "post[post_type]") {
        this.toggle();
      }
    });
  }

  toggle() {
    const selected = document.querySelector(
      'input[name="post[post_type]"]:checked'
    )?.value;

    if (selected === "organize") {
      this.element.classList.remove("hidden");
    } else {
      this.element.classList.add("hidden");
    }
  }

  async generate() {
    const bodyField = document.getElementById("post_body");
    if (!bodyField) return;

    this.originalText = bodyField.value;
    this.loadingTarget.classList.remove("hidden");

    try {
      const res = await fetch("/ai/generate_text", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({
          prompt: this.originalText,
          post_type: document.querySelector(
            'input[name="post[post_type]"]:checked'
          )?.value,
        }),
      });

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || `HTTP Error: ${res.status}`);
      }

      const data = await res.json();

      if (Array.isArray(data.options)) {
        this.renderOptions(this.originalText, data.options);
        this.modalTarget.classList.remove("hidden");
      } else {
        alert(data.error || "AI生成に失敗しました");
      }
    } catch (e) {
      console.error(e);
      alert("通信エラーが発生しました、本日のAI利用回数を超過している可能性があります");
    } finally {
      this.loadingTarget.classList.add("hidden");
    }
  }

  renderOptions(original, aiOptions) {
    this.optionsTarget.innerHTML = "";

    const allOptions = [
      { label: "あなたの本文（そのまま）", text: original },
      { label: "AI案①", text: aiOptions[0] },
      { label: "AI案②", text: aiOptions[1] },
    ];

    allOptions.forEach((opt, index) => {
      // 文頭・各行のインデントを完全除去（改行は保持）
      const normalizedText = (opt.text || "")
        .replace(/^\s+/gm, "")
        .replace(/\s+$/g, "");

      const escapedText = this.escapeHtml(normalizedText);

      this.optionsTarget.insertAdjacentHTML(
        "beforeend",
        `<label class="block p-3 border rounded-xl cursor-pointer hover:bg-orange-50">
  <div class="flex items-start gap-3">
    <input
      type="radio"
      name="ai_option"
      value="${escapedText}"
      class="mt-1"
      ${index === 0 ? "checked" : ""}
    >
    <div class="flex-1 min-w-0">
      <strong class="block mb-1">${opt.label}</strong>
      <div class="text-sm text-gray-700 whitespace-pre-wrap max-h-[45vh] overflow-y-auto pr-2 sm:max-h-[55vh]">${escapedText}</div>
    </div>
  </div>
</label>`
      );
    });
  }

  apply() {
    const selected = this.element.querySelector(
      'input[name="ai_option"]:checked'
    );
    if (!selected) return;

    document.getElementById("post_body").value = selected.value;
    this.close();
  }

  cancel() {
    this.close();
  }

  close() {
    this.modalTarget.classList.add("hidden");
  }

  escapeHtml(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }
}

// app/javascript/controllers/mood_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["section"];

  connect() {
    const checked = document.querySelector("input[name='post[mood]']:checked");

    // edit の場合：すでに mood が保存されていれば自動で表示
    if (checked) {
      this.sectionTarget.classList.remove("hidden");
    }
  }

  show() {
    // post_type が organize のときに呼ばれる
    this.sectionTarget.classList.remove("hidden");
  }

  hide() {
    this.sectionTarget.classList.add("hidden");
  }
}

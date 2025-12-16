import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["section"];

  connect() {
    this.toggle();
  }

  toggle() {
    const postType = document.querySelector(
      "input[name='post[post_type]']:checked"
    )?.value;

    if (postType === "organize") {
      this.show();
    } else {
      this.hide();
    }
  }

  show() {
    this.sectionTarget.classList.remove("hidden");
  }

  hide() {
    this.sectionTarget.classList.add("hidden");
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["future", "organize", "thanks"];

  connect() {
    this.toggle();
  }

  toggle() {
    const postType = document.querySelector(
      "input[name='post[post_type]']:checked"
    )?.value;

    this.hideAll();

    if (postType === "future" && this.hasFutureTarget)
      this.show(this.futureTarget);
    if (postType === "organize" && this.hasOrganizeTarget)
      this.show(this.organizeTarget);
    if (postType === "thanks" && this.hasThanksTarget)
      this.show(this.thanksTarget);
  }

  hideAll() {
    if (this.hasFutureTarget) this.hide(this.futureTarget);
    if (this.hasOrganizeTarget) this.hide(this.organizeTarget);
    if (this.hasThanksTarget) this.hide(this.thanksTarget);
  }

  show(section) {
    section.classList.remove("hidden");
    this.setDisabled(section, false);
  }

  hide(section) {
    section.classList.add("hidden");
    this.setDisabled(section, true);
  }

  setDisabled(section, disabled) {
    section.querySelectorAll("input, select, textarea").forEach((el) => {
      el.disabled = disabled;
    });
  }
}

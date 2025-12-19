import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "template", "item", "count"];

  connect() {
    this.updateCount();
  }

  add() {
    if (this.itemTargets.length >= 10) return;

    const content = this.templateTarget.content.cloneNode(true);
    this.listTarget.appendChild(content);

    this.updateCount();
  }

  remove(event) {
    if (this.itemTargets.length <= 1) return;

    event.currentTarget.closest("[data-milestones-target='item']").remove();
    this.updateCount();
  }

  updateCount() {
    if (this.hasCountTarget) {
      this.countTarget.textContent = `${this.itemTargets.length} / 10`;
    }
  }
}

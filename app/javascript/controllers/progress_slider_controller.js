import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "value"];

  connect() {
    this.update();
  }

  update() {
    const value = this.inputTarget.value;
    this.valueTarget.textContent = `${value}%`;
  }
}

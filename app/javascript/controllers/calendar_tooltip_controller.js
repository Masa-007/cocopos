import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tooltip"];
  hideTimeout = null;
  isPinned = false; 

  show() {
    if (this.isPinned) return;
    this.clearHideTimeout();
    this.tooltipTarget.classList.remove("hidden");
    this.tooltipTarget.style.opacity = "1";
  }

  scheduleHide() {
    if (this.isPinned) return;
    this.clearHideTimeout();
    this.hideTimeout = setTimeout(() => this.hide(), 300);
  }

  cancelHide() {
    if (this.isPinned) return;
    this.clearHideTimeout();
  }

  hide() {
    if (this.isPinned) return;
    this.tooltipTarget.style.opacity = "0";
    setTimeout(() => {
      this.tooltipTarget.classList.add("hidden");
    }, 250);
  }

  togglePin() {
    this.isPinned = !this.isPinned;

    if (this.isPinned) {
      this.show();
      this.tooltipTarget.classList.add("pinned");
    } else {
      this.hide();
      this.tooltipTarget.classList.remove("pinned");
    }
  }

  clearHideTimeout() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }
  }
}

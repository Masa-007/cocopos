import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["slide"];
  static values = {
    interval: { type: Number, default: 4000 }, // 4秒間隔
  };

  connect() {
    this.index = 0;
    this.showSlide(this.index);
    this.startAutoPlay();
  }

  disconnect() {
    this.stopAutoPlay();
  }

  startAutoPlay() {
    this.timer = setInterval(() => {
      this.next();
    }, this.intervalValue);
  }

  stopAutoPlay() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  next() {
    this.index = (this.index + 1) % this.slideTargets.length;
    this.showSlide(this.index);
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      if (i === index) {
        slide.classList.add("active");
        slide.classList.remove("hidden");
      } else {
        slide.classList.remove("active");
        slide.classList.add("hidden");
      }
    });
  }
}

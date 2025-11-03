import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  share(event) {
    event.preventDefault();

    const text = "cocoposで心を投函しました📮\n#cocopos\n#心の目安箱\n";
    const url = window.location.origin + "/";
    const shareUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(
      text + url
    )}`;

    window.open(shareUrl, "_blank", "noopener,noreferrer");

    window.location.href = "/mypage";
  }
}

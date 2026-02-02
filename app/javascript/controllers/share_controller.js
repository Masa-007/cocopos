import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
  };

  share(event) {
    event.preventDefault();

    const hashtag = this.selectedHashtag();
    const url = (this.urlValue || `${window.location.origin}/`).trim();

    // URL の前にスペースが入らないように、必ず改行直後に URL を置く
    const text = `cocoposで心を投函しました📮\n#cocopos\n${hashtag}\n${url}`;

    const shareUrl = new URL("https://twitter.com/intent/tweet");
    shareUrl.searchParams.set("text", text);

    window.open(shareUrl.toString(), "_blank", "noopener,noreferrer");
    window.location.href = "/mypage";
  }

  selectedHashtag() {
    const selected = document.querySelector(
      "input[name='post[post_type]']:checked",
    );
    const hashtags = {
      future: "#未来宣言箱",
      organize: "#心の整理箱",
      thanks: "#感謝箱",
    };

    if (!selected) {
      return "#あなたへの目安箱";
    }

    return hashtags[selected.value] || "#あなたへの目安箱";
  }
}

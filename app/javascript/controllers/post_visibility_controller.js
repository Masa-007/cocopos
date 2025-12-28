import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.check();
  }

  check() {
    const isPublic = this.isPublicChecked();
    const commentAllowed = this.isCommentAllowedChecked();

    if (!isPublic && commentAllowed) {
      alert("⚠️ 非公開投稿ではコメントを募集できません。");

      const commentOff = this.element.querySelector(
        'input[name="post[comment_allowed]"][value="false"]'
      );

      if (commentOff) {
        commentOff.checked = true;
        commentOff.dispatchEvent(new Event("change"));
      }
    }
  }

  isPublicChecked() {
    return (
      this.element.querySelector('input[name="post[is_public]"]:checked')
        ?.value === "true"
    );
  }

  isCommentAllowedChecked() {
    return (
      this.element.querySelector('input[name="post[comment_allowed]"]:checked')
        ?.value === "true"
    );
  }
}

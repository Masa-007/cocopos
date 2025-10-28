import "@hotwired/turbo-rails";
import "./modal";
import "./controllers/season_controller";

// === posts 関連 ===
import "./posts/post_form";
import "./posts/post_edit";
import "./posts/placeholder_switch";
import "./posts/flowers";

// === Turbo ログ確認 ===
["turbo:load", "turbo:render"].forEach((event) => {
  document.addEventListener(event, () => {
    const cssLoaded = Array.from(document.styleSheets).some((s) =>
      s.href?.includes("application")
    );
    const hasCustom = Array.from(document.styleSheets).some((s) => {
      try {
        return Array.from(s.cssRules || []).some((r) =>
          r.selectorText?.includes(".wooden-header")
        );
      } catch {
        return false;
      }
    });

    console.log(`⚡ ${event}: css=${cssLoaded}, custom=${hasCustom}`);
  });
});

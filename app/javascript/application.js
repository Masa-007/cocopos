import "@hotwired/turbo-rails";
import "./modal";
import "./controllers/season_controller";


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

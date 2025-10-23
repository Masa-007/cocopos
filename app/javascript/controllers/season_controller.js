// app/javascript/controllers/season_controller.js

document.addEventListener("turbo:load", updateSeason);
document.addEventListener("DOMContentLoaded", updateSeason);

function updateSeason() {
  // body に季節クラスがあるか確認
  const season = ["spring", "summer", "autumn", "winter"].find((s) =>
    document.body.classList.contains(s)
  );

  if (!season) {
    console.log("❌ No season class found on body");
    return;
  }

  console.log(`🌸 Season active: ${season}`);

  // 既存の花びらを削除
  document.querySelectorAll(".petal").forEach((p) => p.remove());

  // 花びらを再生成
  [10, 25, 40, 60, 80].forEach((left, i) => {
    const petal = document.createElement("div");
    petal.className = "petal";
    petal.style.left = `${left}%`;
    petal.style.animationDelay = `${i}s`;
    document.body.appendChild(petal);
  });

  console.log(`🌸 Petals regenerated for: ${season}`);
}



document.addEventListener("turbo:load", updateSeason);
document.addEventListener("DOMContentLoaded", updateSeason);

function updateSeason() {
  const season = ["spring", "summer", "autumn", "winter"].find((s) =>
    document.body.classList.contains(s)
  );

  if (!season) return;

  document.querySelectorAll(".petal").forEach((p) => p.remove());

  [10, 25, 40, 60, 80].forEach((left, i) => {
    const petal = document.createElement("div");
    petal.className = "petal";
    petal.style.left = `${left}%`;
    petal.style.animationDelay = `${i}s`;
    document.body.appendChild(petal);
  });
}


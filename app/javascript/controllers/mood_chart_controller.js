import { Controller } from "@hotwired/stimulus";
import Chart from "chart.js/auto";

export default class extends Controller {
  static values = { data: Array };

  connect() {
    console.log("🎨 mood-chart connected");
    console.log("data:", this.dataValue);

    if (!this.hasDataValue || this.dataValue.length === 0) return;

    const canvas = this.element;
    const ctx = canvas.getContext("2d");

    const labels = this.dataValue.map((d) => d.date);
    const scores = this.dataValue.map((d) => d.score);

    // ▼ score に対応する絵文字（score=2 は「😣 モヤモヤ」で統一）
    const scoreToEmoji = {
      5: "🤩", // ワクワク
      4: "😊", // 嬉しい
      3: "😌", // 穏やか
      2: "😣", // モヤモヤ（統一）
      1: "😔", // 悲しい
    };

    new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            data: scores,
            borderColor: "#8b5cf6",
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 0, // ← 絵文字を使うので点は消す
          },
        ],
      },
      options: {
        plugins: { legend: { display: false } },
        scales: {
          x: {
            offset: true, // ← 両端に余白をつけて違和感を解消
            ticks: {
              maxRotation: 0,
              minRotation: 0,
            },
          },
          y: {
            min: 0,
            max: 5,
            ticks: { stepSize: 1 },
          },
        },
      },

      // ▼ 絵文字を描画するカスタムプラグイン
      plugins: [
        {
          afterDatasetDraw(chart) {
            const { ctx } = chart;
            const meta = chart.getDatasetMeta(0);

            ctx.save();
            ctx.font = "28px serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            meta.data.forEach((point, i) => {
              const score = scores[i];
              const emoji = scoreToEmoji[score] || "🌟";
              ctx.fillText(emoji, point.x, point.y);
            });

            ctx.restore();
          },
        },
      ],
    });
  }
}

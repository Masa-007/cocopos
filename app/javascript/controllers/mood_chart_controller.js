import { Controller } from "@hotwired/stimulus";
import Chart from "chart.js/auto";

export default class extends Controller {
  static values = { data: Array };

  connect() {
    if (!this.hasDataValue || this.dataValue.length === 0) return;

    // 既存があれば必ず破棄（Turbo遷移/戻る対策）
    this.destroyChart();

    const canvas = this.element;
    const ctx = canvas.getContext("2d");

    const labels = this.dataValue.map((d) => d.date);
    const scores = this.dataValue.map((d) => d.score);

    const scoreToEmoji = {
      5: "🤩",
      4: "😊",
      3: "😌",
      2: "😣",
      1: "😔",
    };

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            data: scores,
            borderColor: "#8b5cf6",
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 0,
          },
        ],
      },
      options: {
        plugins: { legend: { display: false } },
        scales: {
          x: { offset: true, ticks: { maxRotation: 0, minRotation: 0 } },
          y: { min: 0, max: 5, ticks: { stepSize: 1 } },
        },
      },
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
              const emoji = scoreToEmoji[scores[i]] || "🌟";
              ctx.fillText(emoji, point.x, point.y);
            });

            ctx.restore();
          },
        },
      ],
    });
  }

  disconnect() {
    // Turboが要素を入れ替えるときも呼ばれるので確実に破棄
    this.destroyChart();
  }

  destroyChart() {
    // Chart.js 側が保持している既存インスタンスも拾って破棄
    const existing = Chart.getChart(this.element);
    if (existing) existing.destroy();

    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  }
}

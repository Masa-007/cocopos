document.addEventListener("turbo:load", () => {
  console.log("✏️ placeholder_switch loaded");

  const postBody = document.getElementById("post_body");
  const postTitle = document.getElementById("post_title");
  const typeRadios = document.querySelectorAll(".post-type-radio");

  if (!typeRadios.length || !postBody || !postTitle) return;

  const placeholders = {
    future: {
      title: "例：来年こそは資格を取って新しい仕事に挑戦したい！",
      body: "例：今年は何かを変えたい。自分の力を試したい。そんな想いを書いてください。",
    },
    organize: {
      title: "例：最近ずっと気になっていることがある",
      body: "例：あの日の言葉がまだ心に残っている。どう受け止めればいいのか分からない…。",
    },
    thanks: {
      title: "例：家族に伝えたい感謝の気持ち",
      body: "例：いつも支えてくれる人へ、ありがとう。小さなことでも構いません。",
    },
  };

  typeRadios.forEach((radio) => {
    radio.addEventListener("change", () => {
      const type = radio.value;
      postTitle.placeholder = placeholders[type]?.title || "";
      postBody.placeholder = placeholders[type]?.body || "";
    });
  });

  const checkedRadio = document.querySelector(".post-type-radio:checked");
  if (checkedRadio) {
    const type = checkedRadio.value;
    postTitle.placeholder = placeholders[type]?.title || "";
    postBody.placeholder = placeholders[type]?.body || "";
  }
});

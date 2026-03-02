(() => {
  const now = new Date();
  const target = document.querySelector(".content");
  if (!target || document.querySelector(".js-stamp")) {
    return;
  }

  const stamp = document.createElement("div");
  stamp.className = "center-note js-stamp";
  stamp.textContent = `Prototype loaded - ${now.toLocaleString("de-AT")}`;
  target.appendChild(stamp);
})();

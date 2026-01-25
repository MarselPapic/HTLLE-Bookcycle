(() => {
  const now = new Date();
  const stamp = document.createElement('div');
  stamp.className = 'hint';
  stamp.textContent = `Prototype geladen • ${now.toLocaleString('de-AT')}`;

  const target = document.querySelector('.hero-card, .login-card, .table-card');
  if (target) {
    target.appendChild(document.createElement('div')).className = 'divider';
    target.appendChild(stamp);
  }
})();

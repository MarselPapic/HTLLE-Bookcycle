document.addEventListener('DOMContentLoaded', () => {
  const rows = document.querySelectorAll('[data-action]');
  rows.forEach((row) => {
    row.addEventListener('click', () => {
      const action = row.getAttribute('data-action');
      const payload = row.getAttribute('data-payload');
      if (!action) return;
      if (action === 'open-report' && payload) {
        window.location.href = `/admin/reports#${payload}`;
      }
    });
  });
});

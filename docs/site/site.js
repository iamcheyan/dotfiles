(() => {
  const root = document.documentElement;
  const saved = localStorage.getItem('dotfiles-theme');
  root.dataset.theme = saved || 'dark';
  document.querySelectorAll('.theme-toggle').forEach((button) => {
    button.addEventListener('click', () => {
      root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
      localStorage.setItem('dotfiles-theme', root.dataset.theme);
    });
  });
  document.querySelectorAll('.menu-toggle').forEach((button) => {
    button.addEventListener('click', () => {
      const nav = document.getElementById(button.getAttribute('aria-controls'));
      const open = button.getAttribute('aria-expanded') !== 'true';
      button.setAttribute('aria-expanded', String(open));
      nav?.classList.toggle('open', open);
    });
  });
  const search = document.getElementById('site-search');
  if (search) {
    const rows = [...document.querySelectorAll('.section-row')];
    const noResults = document.getElementById('no-results');
    const hint = document.getElementById('search-hint');
    const apply = () => {
      const query = search.value.trim().toLocaleLowerCase();
      let visible = 0;
      rows.forEach((row) => {
        const show = !query || row.dataset.search.toLocaleLowerCase().includes(query);
        row.hidden = !show;
        if (show) visible += 1;
      });
      noResults.hidden = visible !== 0;
      hint.hidden = query.length > 0;
    };
    search.addEventListener('input', apply);
    document.addEventListener('keydown', (event) => {
      if (event.key === '/' && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        event.preventDefault(); search.focus();
      }
      if (event.key === 'Escape' && document.activeElement === search) {
        search.value = ''; apply(); search.blur();
      }
    });
  }
})();

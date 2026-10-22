(() => {
  const root = document.documentElement;
  const stored = localStorage.getItem('dotfiles-theme');
  root.dataset.theme = stored === 'dark' ? 'dark' : 'light';

  document.querySelectorAll('.theme-toggle').forEach((button) => {
    button.addEventListener('click', () => {
      root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
      localStorage.setItem('dotfiles-theme', root.dataset.theme);
    });
  });

  document.querySelectorAll('.menu-toggle').forEach((button) => {
    button.addEventListener('click', () => {
      const nav = document.getElementById(button.getAttribute('aria-controls'));
      if (!nav) return;
      const open = button.getAttribute('aria-expanded') !== 'true';
      button.setAttribute('aria-expanded', String(open));
      nav.classList.toggle('open', open);
    });
  });

  const search = document.getElementById('site-search');
  if (search) {
    const rows = [...document.querySelectorAll('.toc-row')];
    const empty = document.getElementById('no-results');
    const hint = document.getElementById('search-hint');

    const apply = () => {
      const query = search.value.trim().toLocaleLowerCase();
      let shown = 0;
      rows.forEach((row) => {
        const haystack = (row.dataset.search || row.textContent).toLocaleLowerCase();
        const match = query === '' || haystack.includes(query);
        row.hidden = !match;
        if (match) shown += 1;
      });
      if (empty) empty.hidden = shown !== 0;
      if (hint) hint.hidden = query.length > 0;
    };

    search.addEventListener('input', apply);

    document.addEventListener('keydown', (event) => {
      const typing = ['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName);
      if (event.key === '/' && !typing) {
        event.preventDefault();
        search.focus();
        search.select();
      }
      if (event.key === 'Escape' && document.activeElement === search) {
        search.value = '';
        apply();
        search.blur();
      }
    });
  }
})();

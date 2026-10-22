(() => {
  const root = document.documentElement;
  const stored = localStorage.getItem('dotfiles-theme');
  root.dataset.theme = stored === 'dark' ? 'dark' : 'light';

  document.querySelectorAll('.theme-toggle').forEach((button) => {
    button.addEventListener('click', () => {
      root.dataset.theme = root.dataset.theme === 'dark' ? 'dark' : 'light';
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
  if (!search) return;

  const blocks = [...document.querySelectorAll('.section-block')];
  const empty = document.getElementById('no-results');
  const hint = document.getElementById('search-hint');

  const apply = () => {
    const query = search.value.trim().toLocaleLowerCase();
    let shown = 0;

    blocks.forEach((block) => {
      let blockMatches = 0;
      block.querySelectorAll('.doc-link').forEach((link) => {
        const text = link.textContent.toLocaleLowerCase();
        const match = query === '' || text.includes(query);
        link.hidden = !match;
        if (match) blockMatches += 1;
      });
      block.hidden = blockMatches === 0;
      shown += blockMatches;
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
})();

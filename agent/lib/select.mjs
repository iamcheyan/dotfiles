#!/usr/bin/env node
// Interactive selector for cc (provider/model) and cx (profile)
//
// Usage:
//   node select.mjs --provider <config.json>    # Select provider/model from opencode.json
//   node select.mjs --profile <profiles-dir>    # Select profile from directory of .json files
//
// Output: JSON to stdout, UI to stderr

import { readFileSync, readdirSync, existsSync } from 'fs';
import { homedir } from 'os';

const args = process.argv.slice(2);

let mode = '';
let source = '';
let showAll = false;

// Parse args
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--provider' && args[i + 1]) {
    mode = 'provider';
    source = args[++i];
  } else if (args[i] === '--profile' && args[i + 1]) {
    mode = 'profile';
    source = args[++i];
  } else if (args[i] === '--all') {
    showAll = true;
  }
}

if (!mode) {
  console.error('Usage: select.mjs --provider <config.json> | --profile <profiles-dir>');
  process.exit(1);
}

// ── Build item list based on mode ────────────────────────────────────────────

let items = [];
let lastUsedKey = '';

if (mode === 'provider') {
  const config = JSON.parse(readFileSync(source, 'utf8'));

  // Read last used model
  let lastProvider = '';
  let lastModel = '';
  const lastModelPath = `${homedir()}/.cache/cc_last_model`;
  if (existsSync(lastModelPath)) {
    const lines = readFileSync(lastModelPath, 'utf8').split('\n');
    lastProvider = (lines[0] || '').trim();
    lastModel = (lines[1] || '').trim();
  }
  lastUsedKey = `${lastProvider}\t${lastModel}`;

  for (const [provKey, prov] of Object.entries(config.provider)) {
    if (provKey === 'mimo') continue; // Skip Xiaomi MiMo OpenAI version
    const provName = prov.name || provKey;
    for (const [modelKey, model] of Object.entries(prov.models || {})) {
      const modelName = model.name || modelKey;
      const ctx = model.limit?.context;
      const ctxStr = ctx >= 1048576 ? `${(ctx / 1048576).toFixed(0)}M` : ctx >= 1024 ? `${(ctx / 1024).toFixed(0)}K` : `${ctx}`;
      items.push({
        id: JSON.stringify({ provider: provKey, model: modelKey }),
        label: `${provName} / ${modelName}`,
        extra: ctxStr,
      });
    }
  }
} else if (mode === 'profile') {
  const files = readdirSync(source).filter(f => f.endsWith('.json')).sort();
  for (const f of files) {
    const name = f.replace(/\.json$/, '');
    items.push({ id: JSON.stringify({ profile: name }), label: name, extra: '' });
  }
}

if (items.length === 0) {
  console.error('No items found.');
  process.exit(1);
}

// ── Find last used item ──────────────────────────────────────────────────────

function getKey(item) {
  const parsed = JSON.parse(item.id);
  if (mode === 'provider') return `${parsed.provider}\t${parsed.model}`;
  return parsed.profile || '';
}

const lastItem = items.find(it => getKey(it) === lastUsedKey) || null;

// ── TUI ──────────────────────────────────────────────────────────────────────

let filter = '';
let cursor = 0;

function getFiltered() {
  if (!filter) {
    if (showAll) return items;
    return lastItem ? [lastItem] : items.slice(0, 1);
  }
  const q = filter.toLowerCase();
  return items.filter(it => it.label.toLowerCase().includes(q));
}

function render() {
  const filtered = getFiltered();
  if (cursor >= filtered.length) cursor = Math.max(0, filtered.length - 1);

  process.stderr.write('\x1b[2J\x1b[H');
  process.stderr.write(`\x1b[1;36mSearch:\x1b[0m ${filter}_\n\n`);

  if (filtered.length === 0) {
    process.stderr.write('  (no matches)\n');
  } else {
    const maxLen = Math.max(...filtered.map(it => it.label.length));
    for (let i = 0; i < filtered.length; i++) {
      const it = filtered[i];
      const mark = i === cursor ? '\x1b[1;32m > \x1b[0m' : '   ';
      const extra = it.extra ? `  \x1b[2m${it.extra}\x1b[0m` : '';
      process.stderr.write(`${mark}${it.label.padEnd(maxLen)}${extra}\n`);
    }
  }
  const hint = filter
    ? '↑/↓ move  Enter select  Backspace edit  Esc quit'
    : showAll
      ? '↑/↓ move  Enter select  type to filter  Esc quit'
      : '↑/↓ move  Enter select last  type to search all  Esc quit';
  process.stderr.write(`\n\x1b[2m${hint}\x1b[0m\n`);
}

if (!process.stdin.isTTY) {
  console.error('Error: interactive selection requires a terminal');
  process.exit(1);
}

process.stdin.setRawMode(true);
process.stdin.resume();
process.stdin.setEncoding('utf8');

render();

let esc = '';

process.stdin.on('data', (data) => {
  for (let i = 0; i < data.length; i++) {
    const ch = data[i];

    if (ch === '\x1b') {
      esc = ch;
      continue;
    }
    if (esc) {
      esc += ch;
      if (esc.length < 3) continue;

      const seq = esc;
      esc = '';

      if (seq === '\x1b[A') { if (cursor > 0) cursor--; render(); continue; }
      if (seq === '\x1b[B') { const f = getFiltered(); if (cursor < f.length - 1) cursor++; render(); continue; }
      continue;
    }

    if (ch === '\r' || ch === '\n') {
      const filtered = getFiltered();
      if (filtered.length > 0 && filtered[cursor]) {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        process.stderr.write('\x1b[2J\x1b[H');
        console.log(filtered[cursor].id);
        process.exit(0);
      }
    } else if (ch === '\x1b') {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.exit(1);
    } else if (ch === '\x7f' || ch === '\b') {
      filter = filter.slice(0, -1);
      cursor = 0;
      render();
    } else if (ch === '\x03') {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.exit(1);
    } else if (ch >= ' ') {
      filter += ch;
      cursor = 0;
      render();
    }
  }
});

#!/usr/bin/env node
// Interactive model selector for cc script
// Usage: cc-select.mjs <config-path>
// Output: JSON to stdout, UI to stderr

import { readFileSync, existsSync } from 'fs';
import { homedir } from 'os';

const configPath = process.argv[2];
if (!configPath) {
  console.error('Usage: cc-select.mjs <config-path>');
  process.exit(1);
}

const config = JSON.parse(readFileSync(configPath, 'utf8'));

// Read last used model
let lastProvider = '';
let lastModel = '';
const lastModelPath = `${homedir()}/.cache/cc_last_model`;
if (existsSync(lastModelPath)) {
  const lines = readFileSync(lastModelPath, 'utf8').split('\n');
  lastProvider = (lines[0] || '').trim();
  lastModel = (lines[1] || '').trim();
}

// Flatten all provider/model pairs (only Anthropic API for Claude Code)
const items = [];
for (const [provKey, prov] of Object.entries(config.provider)) {
  // Skip non-Anthropic providers (Claude Code requires Anthropic API format)
  if (prov.api !== 'anthropic') continue;

  const provName = prov.name || provKey;
  for (const [modelKey, model] of Object.entries(prov.models || {})) {
    const modelName = model.name || modelKey;
    const ctx = model.limit?.context;
    const ctxStr = ctx >= 1048576 ? `${(ctx / 1048576).toFixed(0)}M` : ctx >= 1024 ? `${(ctx / 1024).toFixed(0)}K` : `${ctx}`;
    items.push({ provider: provKey, model: modelKey, label: `${provName} / ${modelName}`, ctx: ctxStr });
  }
}

// Find last used item
const lastItem = items.find(it => it.provider === lastProvider && it.model === lastModel) || null;

let filter = '';
let cursor = 0;

function getFiltered() {
  if (!filter) {
    // No filter: show only last used model
    return lastItem ? [lastItem] : items.slice(0, 1);
  }
  const q = filter.toLowerCase();
  return items.filter(it =>
    it.label.toLowerCase().includes(q) ||
    it.provider.toLowerCase().includes(q) ||
    it.model.toLowerCase().includes(q)
  );
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
      process.stderr.write(`${mark}${it.label.padEnd(maxLen)}  \x1b[2m${it.ctx}\x1b[0m\n`);
    }
  }
  const hint = filter
    ? '↑/↓ move  Enter select  Backspace edit  Esc quit'
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

// Buffer to accumulate escape sequences
let esc = '';

process.stdin.on('data', (data) => {
  for (let i = 0; i < data.length; i++) {
    const ch = data[i];

    // Start or continue buffering an escape sequence
    if (ch === '\x1b') {
      esc = ch;
      continue;
    }
    if (esc) {
      esc += ch;
      if (esc.length < 3) continue; // keep buffering \x1b[

      // We have a full 3-byte sequence or something unrecognized
      const seq = esc;
      esc = '';

      if (seq === '\x1b[A') { if (cursor > 0) cursor--; render(); continue; }
      if (seq === '\x1b[B') { const f = getFiltered(); if (cursor < f.length - 1) cursor++; render(); continue; }
      // Unrecognized escape — ignore
      continue;
    }

    // Normal characters
    if (ch === '\r' || ch === '\n') {
      const filtered = getFiltered();
      if (filtered.length > 0 && filtered[cursor]) {
        process.stdin.setRawMode(false);
        process.stdin.pause();
        process.stderr.write('\x1b[2J\x1b[H');
        console.log(JSON.stringify(filtered[cursor]));
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

const fs = require('fs');
const files = [
  '<SNOWLUMA_DIR>/config/onebot.json',
  '<SNOWLUMA_DIR>/config/onebot_<QQ_UIN_2>.json',
  '<SNOWLUMA_DIR>/config/onebot_<QQ_UIN_1>.json',
];
for (const f of files) {
  if (!fs.existsSync(f)) { console.log('skip (missing):', f); continue; }
  const raw = fs.readFileSync(f, 'utf8');
  const cfg = JSON.parse(raw);
  cfg.statusCommand = cfg.statusCommand || {};
  cfg.statusCommand.enabled = false;
  if (!cfg.statusCommand.swallow) cfg.statusCommand.swallow = false;
  if (typeof cfg.statusCommand.cooldownSeconds !== 'number') cfg.statusCommand.cooldownSeconds = 5;
  if (!cfg.statusCommand.trigger) cfg.statusCommand.trigger = '#sl';
  fs.copyFileSync(f, f + '.bak-statuscmd');
  fs.writeFileSync(f, JSON.stringify(cfg, null, 2) + '\n', 'utf8');
  console.log('updated', f, '->', JSON.stringify(cfg.statusCommand));
}

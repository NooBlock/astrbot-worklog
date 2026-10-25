const BASE = 'http://127.0.0.1:5099';

async function main() {
  const login = await fetch(BASE + '/api/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ password: '<REDACTED_PASSWORD>' }),
  });
  const { token } = await login.json();
  const auth = { authorization: 'Bearer ' + token, 'content-type': 'application/json' };

  for (const uin of ['<QQ_UIN_2>', '<QQ_UIN_1>']) {
    const g = await fetch(BASE + '/api/config/' + uin, { headers: auth });
    const { config } = await g.json();
    config.statusCommand = Object.assign({}, config.statusCommand, { enabled: false });
    const p = await fetch(BASE + '/api/config/' + uin, {
      method: 'POST',
      headers: auth,
      body: JSON.stringify(config),
    });
    const txt = await p.text();
    console.log(uin, '->', p.status, txt.slice(0, 400));
  }
}

main().catch((e) => { console.error('ERR', e); process.exit(1); });

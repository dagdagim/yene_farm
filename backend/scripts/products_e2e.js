const base = process.env.BASE_URL || 'http://localhost:8080';
const adminKey = process.env.ADMIN_API_KEY;
const fetch = global.fetch;

if (!fetch) {
  console.error('Global fetch is not available in this Node runtime. Node 18+ required.');
  process.exit(2);
}

async function jsonRes(res) {
  try { return await res.json(); } catch (e) { return { status: res.status, text: await res.text() }; }
}

async function main() {
  try {
    const h = await fetch(`${base}/health`);
    if (!h.ok) { console.error('health failed', h.status); process.exit(2); }
    console.log('health ok');

    // List products
    let r = await fetch(`${base}/api/products?limit=2`);
    console.log('list status', r.status);
    console.log(await jsonRes(r));

    if (!adminKey) {
      console.log('ADMIN_API_KEY not set — skipping admin create/update/delete tests');
      process.exit(0);
    }

    // Create product
    const payload = { title: `e2e-test-${Date.now()}`, description: 'e2e product', price: 9.99 };
    r = await fetch(`${base}/api/products`, { method: 'POST', headers: { 'content-type': 'application/json', 'x-admin-key': adminKey }, body: JSON.stringify(payload) });
    const created = await jsonRes(r);
    console.log('create', r.status, created);
    if (!r.ok) return process.exit(3);
    const id = created.id || (created.data && created.data.id) || created;

    // Read product
    r = await fetch(`${base}/api/products/${id}`);
    console.log('get', r.status, await jsonRes(r));

    // Update product
    const update = { title: payload.title + '-updated', price: 12.5 };
    r = await fetch(`${base}/api/products/${id}`, { method: 'PUT', headers: { 'content-type': 'application/json', 'x-admin-key': adminKey }, body: JSON.stringify(update) });
    console.log('update', r.status, await jsonRes(r));

    // Delete product
    r = await fetch(`${base}/api/products/${id}`, { method: 'DELETE', headers: { 'x-admin-key': adminKey } });
    console.log('delete', r.status);

    process.exit(0);
  } catch (err) {
    console.error('e2e error', err);
    process.exit(1);
  }
}

main();

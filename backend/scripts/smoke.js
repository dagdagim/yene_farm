const base = process.env.BASE_URL || 'http://localhost:8080';

async function main() {
  try {
    const h = await fetch(`${base}/health`);
    const j = await h.json();
    console.log('health', j);
    process.exit(0);
  } catch (err) {
    console.error('smoke failed', err.message);
    process.exit(2);
  }
}

main();

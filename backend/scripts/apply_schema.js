const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

async function main() {
  const databaseUrl = process.env.DATABASE_URL || process.env.SUPABASE_DATABASE_URL;
  if (!databaseUrl) {
    console.error('Please set DATABASE_URL environment variable (postgres://USER:PASS@HOST:PORT/DB)');
    process.exit(2);
  }

  const sqlPath = path.join(__dirname, '..', 'schema', 'supabase_schema.sql');
  if (!fs.existsSync(sqlPath)) {
    console.error('Schema file not found at', sqlPath);
    process.exit(2);
  }

  const sql = fs.readFileSync(sqlPath, 'utf8');

  const client = new Client({ connectionString: databaseUrl, ssl: { rejectUnauthorized: false } });
  try {
    console.log('Connecting to database...');
    await client.connect();
    console.log('Connected. Running schema...');
    // Split statements and run in a transaction
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('Schema applied successfully.');
    process.exit(0);
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch (e) {}
    console.error('Error applying schema:', err.message || err);
    process.exit(1);
  } finally {
    await client.end().catch(() => {});
  }
}

main();
 
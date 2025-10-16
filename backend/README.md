Backend for Yene Farm

This backend is a lightweight Node.js + Express API that acts as a server-side layer for the Flutter app.
It uses Supabase as the primary database and auth provider. It requires a Supabase project and the service_role
key for server-side operations.

Contents
- src/
  - index.js (Express app)
  - routes/
    Backend for Yene Farm

    This is a lightweight Express backend that performs privileged operations against Supabase using the service role key. It provides product and order management endpoints and examples of validation, logging, and rate limiting.

    Project layout

    - src/
      - index.js (Express app)
      - routes/
        - products.js
        - orders.js
        - auth.js
      - lib/
        - supabaseClient.js (server-side Supabase client)
    - schema/
      - supabase_schema.sql
    - Dockerfile
    - package.json
    - .env.example

    Quick start (local):

    1. Copy `.env.example` to `.env` and set the values (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PORT, CORS_ORIGIN).
    2. npm install
    3. npm run dev

    Environment variables (in `.env`):

    - SUPABASE_URL - Your Supabase project URL
    - SUPABASE_SERVICE_ROLE_KEY - Service role key (keep secret)
    - PORT - Optional server port (default 8080)
    - CORS_ORIGIN - Comma-separated origins allowed for CORS (default *)

    API endpoints:

    - GET /health
    - GET /api/products
    - GET /api/products/:id
    - POST /api/products (admin/service role expected)
    - PUT /api/products/:id (admin)
    - DELETE /api/products/:id (admin)
    - POST /api/orders
    - GET /api/orders/:userId
    - POST /api/auth/verify

    Notes:

    - The server uses `morgan` for access logging, `express-rate-limit` for basic rate limiting, and `joi` for input validation.
    - To run the endpoints successfully, set `SUPABASE_SERVICE_ROLE_KEY` in `.env`. Keep it secret — do not commit it.

    For production readiness, consider adding authentication middleware, robust error handling, monitoring, and CI/CD.

    If you'd like, I can continue by adding auth middleware, unit tests, and deployment manifests.

    Admin notes

    - For administrative product/category writes, the server supports either a user with app_metadata.role === 'admin' (when authenticated via Supabase) or a request header `X-Admin-Key` that matches the `ADMIN_API_KEY` environment variable. This lets CI or deploy scripts perform admin actions without a user token.

    Applying the database schema

    This project includes a schema file at `schema/supabase_schema.sql` which defines `products`, `categories`, and `orders` tables. To apply it to your Supabase project:

    1. Open the Supabase dashboard for your project and go to SQL Editor. Paste the SQL from `schema/supabase_schema.sql` and run it.
    2. Or, use `psql` to connect to your database and run the SQL file.

    There is a helper script `scripts/apply_schema.js` in this repo that prints guidance; automatic execution against Supabase via public REST is not enabled by default. If you want, provide the `SUPABASE_SERVICE_ROLE_KEY` and I can attempt to apply it here (I will not keep the key in the repo).


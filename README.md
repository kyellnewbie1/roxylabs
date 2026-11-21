# Roxy Main API v1.0.0

Premium-style API platform starter: Next.js frontend (Vercel), Express API service (Railway), Supabase Auth/Postgres, Free/Premium quotas, API key middleware, endpoint documentation, live JSON tester, manual WhatsApp upgrade flow, API logs and admin endpoint metadata UI.

## Design direction
Minimal premium anime SaaS: calm royal-blue/lavender palette, DM Sans typography, generous whitespace, restrained glass/gradient effects, responsive sidebar and Roxy character art. Chibi Roxy is used as the favicon asset (`frontend/public/roxy/favicon.jpg`).

## Local setup
1. Install Node.js 20+ and npm.
2. Copy `.env.example` values into `frontend/.env.local` and `backend/.env` (do not commit real secrets).
3. Create a Supabase project and run `supabase/schema.sql` in its SQL editor.
4. In Supabase Auth, enable Email + Password. Configure email confirmation and redirect URLs for localhost and your Vercel domain.
5. Install dependencies from the repository root: `npm install`.
6. Run both services: `npm run dev`.
7. Frontend: http://localhost:3000. Backend health: http://localhost:4000/health.

## Deploy
- Vercel: set Root Directory to `frontend`; add `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_ADMIN_WHATSAPP`.
- Railway: deploy `backend`; add `PORT`, `CORS_ORIGINS`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `ADMIN_BOOTSTRAP_TOKEN`.
- Never expose `SUPABASE_SERVICE_ROLE_KEY` or `ADMIN_BOOTSTRAP_TOKEN` as `NEXT_PUBLIC_*` variables.

## Important implementation notes before public launch
This repository is a working UI/backend foundation, not a fully production-certified service. The login/register/profile pages are UI placeholders and must be connected to Supabase Auth before launch. Add server-side role-based admin authorization (use verified Supabase JWT + an admin role table/claim) to every admin route; the current bootstrap-token route is temporary scaffolding and must not be treated as final multi-admin auth. Replace the illustrative dashboard values with database queries. Add a Redis-backed distributed rate limiter for multi-instance Railway deployments. Quota increments should be implemented as an atomic Postgres RPC/transaction to prevent concurrent requests bypassing daily limits; the current middleware is a starter and needs that hardening. Add request-body schema validation, provider-specific handlers, timeout controls, log redaction/retention, and IP privacy policy. Do not store raw API keys in logs. The live tester calls the real backend and therefore requires a valid API key and configured handler.

## Endpoint management model
The admin form stores endpoint metadata. A new endpoint becomes executable only after a trusted handler is added to `backend/src/handlers/registry.ts` and its route is registered. Never execute arbitrary JavaScript or SQL entered into the admin UI/database. This registry model keeps endpoint creation controlled and auditable.

## Current demo handlers
- `POST /api/v1/ai/chat`: safe echo demonstration, premium-gated (not a real LLM integration).
- `POST /api/v1/text/encode`: Base64 text encoding.
- `POST /api/v1/tools/qr`: returns 501 until a QR provider/implementation is connected.
- `POST /api/v1/image/enhance`: returns 501 until an image provider is connected.

## Manual Premium activation
The Pricing page opens WhatsApp using `NEXT_PUBLIC_ADMIN_WHATSAPP`. Admin activation UI and server-side subscription mutation/audit workflow still need to be completed with verified admin auth. No payment gateway is included by design.

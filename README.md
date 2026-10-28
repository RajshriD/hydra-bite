# HydraBite — self-hosted Food & Water Reminder

Responsive React PWA starter with Supabase-managed email/password authentication and PostgreSQL storage. Includes meal logging, water intake logging, daily water goal, recurring meal/water schedules, browser notifications, and a dashboard. AI is not required and no AI API key is used.

## Stack
- Vite + React static frontend — deploy to Vercel or a similar static host.
- Supabase Auth + PostgreSQL — managed authentication and database.
- PostgreSQL Row Level Security (RLS) — users can only access their own records.
- PWA manifest + service worker — installable app shell and basic static caching.

## 1. Set up Supabase
1. Create a project at https://supabase.com/dashboard.
2. Open **SQL Editor** and run the full `supabase/schema.sql` file.
3. In the Supabase project API settings, copy the project URL and public anon/publishable key.
4. Under **Authentication → URL Configuration**, set Site URL to your eventual HTTPS app URL. Add localhost and preview URLs to Redirect URLs as needed.
5. Decide whether to require email confirmation for sign-up; if enabled, users must confirm their address.

**Never put the Supabase service-role/secret key in frontend environment variables.** Only the public anon/publishable key is used by this app. RLS policies are required for user-data isolation.

## 2. Run locally
Install Node.js 20 or newer, then from this folder:

```bash
cp .env.example .env.local
# Edit .env.local and replace the two placeholder values.
npm install
npm run dev
```

Open the localhost URL Vite prints. Create a production build with `npm run build`; preview it with `npm run preview`.

## 3. Deploy to Vercel
1. Create a private Git repository and push these files, or import the folder through your preferred workflow.
2. In https://vercel.com/new, import the repository.
3. Use Vite; build command `npm run build`; output directory `dist`.
4. In Vercel Project → Settings → Environment Variables, add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` using your Supabase values. Add to Production and Preview as appropriate.
5. Deploy. Add the final Vercel HTTPS URL to Supabase Auth URL Configuration, then redeploy if you changed environment variables. Vite reads `VITE_` variables at build time.

`vercel.json` supplies a single-page-app rewrite. This package does not deploy itself and contains no credentials.

## 4. Install as a PWA
- Android/desktop Chromium: open the HTTPS site and use the browser's Install app option if available.
- iPhone/iPad: open the site in Safari → Share → Add to Home Screen. Open it from the Home Screen icon.
- Grant notification permission only after tapping Enable notifications.

## 5. Notification limitation — important
This starter checks due times while the app is open in a browser tab/PWA. It does **not** guarantee alerts while the app is fully closed. A service worker cannot independently run an arbitrary daily timer while terminated. Reliable background notifications need a push subscription and server-side push sender (e.g. a scheduled Supabase Edge Function and web-push provider, or Firebase Cloud Messaging). Treat that as a later feature. iOS web push requires a supported iOS version and the app added to the Home Screen; the user must grant permission.

## 6. Keep costs low
- No paid AI model or AI key is needed.
- Start with provider free tiers only after checking current quotas and terms at Vercel and Supabase; pricing and commercial-use rules may change.
- Watch database size, monthly active users, bandwidth and backup requirements. If the product becomes commercial or receives meaningful traffic, review plan terms and upgrade before relying on free quotas.

## 7. Security checklist before inviting public users
- Keep the repository private during development if you don't want the source public.
- Never commit `.env.local`, access tokens, service-role keys, or database passwords.
- Verify RLS is enabled and test with two accounts: account A must not access account B's rows.
- Configure production auth redirect URLs and appropriate email verification.
- Add account deletion/export, privacy policy, abuse controls, backups and data-retention decisions before a public launch.
- Use HTTPS only. Water goals are personal preferences, not medical advice.

## Current scope
- Reminder schedules repeat daily, but notifications are foreground/best-effort only until background push is added.
- Progress graph currently charts today's aggregate; historical daily totals are marked as a follow-up, not represented as real historical data.
- This is an installable PWA starter, not a native App Store / Play Store release.
- AI is deliberately omitted from the core product to keep running costs low.

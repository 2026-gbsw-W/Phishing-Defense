# Landing Page + Background Pattern — Design Spec

## Context

The frontend MVP (branch `feat/web-landing-page`) currently sends any
unauthenticated visitor of `/` straight to `/login` via `ProtectedRoute`.
Separately, the repo root has a static `index.html` (~1850 lines) — a
marketing landing page ("피싱 디펜스") that was built earlier on this same
branch but was never wired into the React app (`frontend/`); its CTA
buttons don't link anywhere.

User feedback on the current login screen (screenshot): the `.hex-bg`
hexagon background texture is too visually loud, and entering the app
should show a landing page before login, not the login form directly.

This spec covers two changes:
1. Route `/` to a real landing page for anonymous visitors, with working
   CTAs into signup, while authenticated visitors still land on the
   dashboard.
2. Tone down the `.hex-bg` pattern opacity across the whole app.

## 1. Routing

`/` becomes a smart root:
- Unauthenticated → renders the new `LandingPage`.
- Authenticated → `<Navigate to="/home" replace />`.

The existing dashboard (`HomePage` → `Dashboard`) moves from `/` to
`/home`, still behind `ProtectedRoute`.

```tsx
// App.tsx (routes section)
<Route path="/" element={<RootRoute />} />
<Route path="/login" element={<LoginPage />} />
<Route path="/signup" element={<SignupPage />} />
<Route element={<ProtectedRoute />}>
  <Route path="/home" element={<HomePage />} />
  <Route path="/game/:recordId" element={<GamePage />} />
</Route>
<Route path="*" element={<NotFoundPage />} />
```

`RootRoute` (new, small component — lives in `App.tsx` or
`pages/RootRoute.tsx`, implementer's call):
```tsx
function RootRoute() {
  const { isAuthenticated } = useAuth()
  return isAuthenticated ? <Navigate to="/home" replace /> : <LandingPage />
}
```

**No other call site changes.** Every existing `navigate('/')` /
`<Link to="/">` (post-login/signup redirect in `LoginPage.tsx` /
`SignupPage.tsx`, `GameLayout`'s back button, `Stage6_Result`'s
`onClaimed` → `GamePage.tsx`, `NotFoundPage`'s "홈으로" link) keeps
working unchanged: an authenticated user hitting `/` is bounced to
`/home` by `RootRoute` itself, so none of these call sites need to know
about `/home` directly.

## 2. `LandingPage` component

New file: `frontend/src/pages/LandingPage.tsx` (plus a co-located
`LandingPage.css` or a new block appended to `index.css` — implementer's
call, follow whichever convention keeps the file focused; given the
size, a dedicated stylesheet imported only by this page is preferable to
bloating the global `index.css`).

Port `index.html`'s full body content 1:1 into JSX:
nav → hero → `#flow` (이용 과정) → stats/`#why` → mid-page CTA banner →
`#types` (사기 유형) → footer CTA → footer. Reuse the existing design
tokens from `index.css` (`--bg`, `--alarm`, `--text`, etc.) — do not
redefine them locally, since this page runs inside the same app and
already inherits `:root`.

**CTA wiring** (the one functional gap vs. the static original): every
button that reads "시작하기" or "무료로 훈련 시작하기" (nav CTA, hero CTA,
mid-page CTA, footer CTA link) navigates to `/signup` via
`useNavigate()`. In-page nav links (`#types`, `#flow`, `#why`) stay as
same-page anchor scroll — no change needed there.

**Scroll animation port**: the original has ~280 lines of vanilla JS
across 4 `<script>` blocks:
- Fade-in-on-scroll for `.thesis-block` / `.type-card` / `.footer-cta-inner`
  (`prefers-reduced-motion` disables all transitions/opacity animation —
  preserve this check).
- An SVG "spine" that draws a connecting curve through a row of badges,
  animated via `stroke-dashoffset` tied to scroll position
  (`build()` / `updateProgress()` / scroll+resize listeners).
- A second "page-wide spine" of glowing line segments from hero to
  footer, inserted at the front of `<body>`.

Port this logic into `useEffect` hooks using `useRef` for the DOM nodes
the vanilla JS currently looks up by class/id. Requirements:
- Re-derive coordinates the same way (`getBoundingClientRect`), same
  math for the SVG path and `stroke-dashoffset` progress.
- Attach `scroll`/`resize` listeners inside the effect; **remove them in
  the cleanup function** — the original assumed a single static page
  load, but this component can mount/unmount repeatedly in an SPA
  (visit `/`, go elsewhere, come back), so leaked listeners are a real
  regression risk here that didn't exist in the original static page.
- Keep the `prefers-reduced-motion` short-circuit.
- IntersectionObserver-driven fade-ins (if that's what drives
  `.thesis-block` etc. — confirm by reading the actual script) should
  similarly disconnect their observer on cleanup.

**Known nuance — the "page-wide spine" segments**: one script currently
does `document.body.insertBefore(segmentDiv, document.body.firstChild)`
for 3 absolutely-positioned glow-line `<div>`s, explicitly relying on
DOM order (not z-index) so later sections visually paint over the line.
Doing this as a raw imperative DOM mutation is a React anti-pattern
(React doesn't know about these nodes). Port it as: render these 3 divs
as real JSX children at the start of `LandingPage`'s own root element
(not literally `document.body`), and use `z-index` to keep them behind
the sections that need to paint over them — same visual result (line
appears to run behind the content), achieved through React-owned
markup instead of manual DOM insertion. If `z-index` stacking alone
doesn't reproduce the effect exactly, a `createPortal` into a dedicated
container div is the fallback — but try the CSS-stacking approach
first since it keeps everything inside React's normal render tree.

The static root `index.html` file itself is left as-is (untouched,
reference-only); no build step change is needed since Vite doesn't serve
the repo-root `index.html` as part of the `frontend/` app.

## 3. Background pattern (`.hex-bg`)

In `frontend/src/index.css`, change only the two color tokens (structure
of the pattern is unchanged):

```css
--hexline: rgba(255, 69, 63, 0.05);   /* was 0.16 */
--hexfill: rgba(255, 69, 63, 0.015);  /* was 0.04 */
```

This automatically softens `.hex-bg` everywhere it's used: `LoginPage`,
`SignupPage`, `Dashboard`, `NotFoundPage`, and the new `LandingPage`
(which reuses `.hex-bg` for its own hero decoration, per the original
markup). Update the token values documented in `docs/DESIGN_SYSTEM.md`
§4 to match.

## 4. Testing

- `LandingPage.test.tsx`: renders the page; clicking each "시작하기"/
  "무료로 훈련 시작하기" CTA navigates to `/signup`. Mount/unmount without
  throwing (smoke-level coverage for the scroll-animation effects,
  since `getBoundingClientRect`/`IntersectionObserver` behave
  differently under jsdom than a real browser — don't try to assert
  exact animation values).
- Routing test (new or added to existing `App`-level test): visiting
  `/` unauthenticated renders the landing page; visiting `/`
  authenticated redirects to `/home` (assert dashboard content or the
  URL lands on `/home`).
- Update any existing test that assumes the dashboard is at `/` (e.g.
  post-login/signup navigation assertions, `GamePage.integration.test.tsx`
  if it checks a final URL) to expect `/home` instead — audit at
  implementation time by grepping test files for `'/'` route
  assumptions tied to the dashboard specifically (not the smart root).
- Full verification: `npm test`, `npm run type-check`, `npm run lint`
  clean, matching the rest of this branch's standard.

## Out of scope

- No changes to the static root `index.html`.
- No new "already have an account? log in" link added to the landing
  page nav — out of scope unless requested later; the nav's single CTA
  goes to signup, matching the original design's single-CTA intent.
- No visual/copy changes to the ported landing content beyond making
  CTAs functional — this is a faithful port, not a redesign.

# Motion

## Transitions (`/animation/css-transitions/`)

- List properties explicitly: `transition: transform 250ms, opacity 400ms;`. Never `transition: all` (unrelated properties start animating later).
- Delay goes after duration: `transition: opacity 250ms 300ms;`.
- Easing by intent:
  - `ease-out`: things **entering** (modal appearing, toast sliding in).
  - `ease-in`: things **leaving** to off-screen or invisible.
  - `ease-in-out`: symmetric loops.
  - `ease` (default): fine for most on-screen moves. `linear`: rarely right (except spinners, colour cycles).
- **Think in actions**: base rule = the slow "leave" timing, `:hover` rule = the fast "enter" timing.
  ```css
  .btn { transition: transform 450ms; }
  .btn:hover { transform: translateY(-10px); transition: transform 125ms; }
  ```
- **Hover-intent delay** for dropdowns (cursor travelling diagonally doesn't close it):
  ```css
  .dropdown { opacity: 0; transition: opacity 400ms; transition-delay: 300ms; }
  .wrapper:hover .dropdown { opacity: 1; transition: opacity 100ms; transition-delay: 0ms; }
  ```
- Prefer `transform: translate` over `margin`/`top` (sub-pixel smooth, no layout).
- `will-change: transform` avoids the GPU hand-off "snap" at start/end. Only on elements that really animate (costs video memory).
- **Doom flicker**: if the hovered element moves out from under the cursor, hover toggles rapidly. Separate trigger and effect: keep `:hover` on the parent, move a child.
  ```css
  .btn:hover .background { transform: translateY(-10px); transition: transform 150ms; }
  ```
- Test on the slowest device you target.

## Keyframes (`/animation/keyframe-animations/`)

- Declarations apply **only while running**. Fill modes fix that: `forwards` (keep last frame), `backwards` (apply first frame during the delay), `both` (he wishes it were the default).
  ```css
  .enter { animation: slide-in 1000ms ease-out both; animation-delay: 500ms; }
  ```
- Easing applies **per step** between keyframes, not to the whole animation.
- `animation-direction: alternate` ping-pongs; a 4 s grow-and-shrink becomes a 2 s `alternate` loop.
  `animation: breathe 2000ms ease-in-out infinite alternate;`
- Spinners: `linear`, `infinite`.
- Keyframe names are global; don't reuse names.
- Parameterise with variables, design the API for the consumer:
  ```css
  @keyframes bounce { to { transform: translateY(calc(var(--bounce-height) * -1)); } }
  .box { --bounce-height: 20px; animation: bounce 400ms infinite alternate; }
  ```

## Partial keyframes (`/animation/partial-keyframes/`)

Omit `from` or `to` and the missing end is the element's **current** value, so one keyframe works for any resting state.

```css
@keyframes fadeFromTransparent { from { opacity: 0; } }   /* fade in TO whatever opacity it has */
@keyframes fadeToTransparent { to { opacity: 0; } }        /* fade out FROM wherever it is */
.icon-btn { opacity: 0.7; animation: fadeFromTransparent 1000ms; }
```

- Two keyframe animations on the same property **combine** (twinkle + fade): `animation: twinkle 250ms alternate infinite, fadeFromTransparent 2000ms;`. Mobile Safari before iOS 17 ran them sequentially; for old Safari nest two elements.
- Variables in keyframes give per-element values: `style="--amount: 16px"`.

## Springs in CSS: `linear()` (`/animation/linear-timing-function/`)

- `linear(0, 0.1, 0.25, ..., 1)` draws straight segments between progress points; values > 1 overshoot. Time-positioned points (`0.971 47.2%`) need fewer values.
- Don't hand-trace: an 11-point spring "doesn't feel great"; ~50 computed points (or ~25 time-positioned) do. Generate with **Linear() Easing Generator** (Archibald & Argyle, derives duration from when the spring settles) or **Easing Wizard**.
- Token pattern with a Bézier fallback that "kinda" overshoots:
  ```css
  html {
    --spring-smooth: cubic-bezier(0.3, 0.7, 0.4, 1.5);
    --spring-smooth-time: 1000ms;
    @supports (animation-timing-function: linear(0, 1)) {
      /* stiffness 235, damping 10 */
      /* prettier-ignore */
      --spring-smooth: linear(/* generated */);
    }
  }
  @media (prefers-reduced-motion: no-preference) {
    .thing { transition: transform var(--spring-smooth) var(--spring-smooth-time); }
  }
  ```
- Limits: CSS needs a duration (no infinite zero-damping spring); interrupted CSS transitions reverse "tight and quick", while JS springs keep inertia.
- Cost: 100+ values run as smoothly as `linear(0,1)`; three ~75-value springs ≈ 1.3 kB gzipped. Reuse via variables.
- Support (article, Oct 2025): ~88 %, all major browsers since Dec 2023.

## Spring physics (`/animation/a-friendly-introduction-to-spring-physics/`)

- Springs are described by **mass** (inertia), **tension/stiffness** (snappiness), **friction/damping** (how fast oscillation dies). Zero friction = oscillates forever.
- Most good springs barely bounce; the point is the organic settle. Sandbox default `{ mass: 1.75, tension: 200, friction: 12 }`; boop uses `{ tension: 300, friction: 10 }`.
- Use springs for motion, not for colour or opacity.

## Squash and stretch (`/animation/squash-and-stretch/`)

- Disney principle for micro-interactions: an arrow icon whose shaft lengthens and whose tip pulls in on hover.
  ```css
  @media (prefers-reduced-motion: no-preference) {
    .shaft, .tip { transition: d 300ms; }
    .btn:hover .shaft, .btn:focus-visible .shaft { d: path("M 5,12 h 17"); }
  }
  ```
  CSS `d` transitions don't work in Safari (~79 % support, Apr 2026); use the Motion library (`{ type: 'spring', stiffness: 300, damping: 12 }`) for cross-browser morphs.
- Bouncing ball: separate `translate` and `scale` properties so two animations don't fight over `transform`; `transform-origin: center bottom`; hold 5 % at the bottom; keep ratios subtle (25-50 % of a demo).
- Boop-style: on `pointerenter` stretch, then revert after ~150 ms even if still hovered.

## CSS vs JavaScript (`/animation/css-vs-javascript/`)

- Per-frame JS math is cheap; the problem is sharing the **main thread**. CSS animations/transitions (and the Web Animations API, which Motion uses) run separately and stay in sync with time.
- Use a library only for what CSS can't do (path morphing, physics, interruptible springs). Wrappers around transitions "aren't worth using".
- Sequence with `animationend` / `transitionend` when strictly sequential.

## Scroll-driven animations (`/animation/scroll-driven-animations/`)

```css
@media (prefers-reduced-motion: no-preference) {
  .reveal { animation: fadeIn linear backwards; animation-timeline: view(); animation-range: entry; }
}
.progress {               /* reading indicator */
  position: fixed; inset: 0 0 auto; height: 4px; transform-origin: left center;
  animation: grow linear; animation-timeline: scroll();
}
@keyframes grow { from { transform: scaleX(0); } }
```

- `animation-range`: `cover` (default), `contain`, `entry`, `exit`, with percentages: `cover 0% cover 50%`.
- Use `backwards` or the 0 % keyframe isn't applied before the range starts.
- Linked timelines: `view-timeline: --x` on the tracked element, `timeline-scope: --x` on a shared ancestor, `animation-timeline: --x` on the animated one.
- Parallax and many moving layers can trigger vestibular symptoms; always gate.
- Support (article, mid-2026): ~85 %, Firefox behind a flag; fine for cosmetic effects. Polyfill: flackr/scroll-timeline (no linked timelines).

## Reduced motion (`/react/prefers-reduced-motion/`)

- **No-motion-first** (preferred): static styles outside, `transition`/`animation` inside `@media (prefers-reduced-motion: no-preference)`.
- He discourages the global `* { animation-duration: 0.01ms !important }` kill-switch: not all animation is motion, and JS springs ignore it.
- JS: `const reduce = !matchMedia('(prefers-reduced-motion: no-preference)').matches;` and listen for `change`. With SSR start as "reduced" and update after mount.
- Reduced ≠ nothing: keep colour/opacity feedback, show static sparkles, drop movement.

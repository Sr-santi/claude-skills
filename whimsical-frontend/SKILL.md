---
name: whimsical-frontend
description: Josh W. Comeau's frontend craft (joshwcomeau.com) for adding delight to a UI - springy hovers, pushable 3D buttons, boops, sparkles, rainbow/@property gradients, color shifting, layered colour-matched shadows, gradients without the grey dead zone, frosted glass, linear() springs, scroll-driven animations, FLIP, sprites, SVG draw-on - plus the foundations underneath (modern CSS reset, rem vs px, stacking contexts, full-bleed grid, no-flicker dark mode, reduced motion). Use when asked to make an interface feel alive, polished, playful, "whimsical", or "like Josh Comeau"; when adding hover/press/enter animations, button effects, shadows, gradients, glass; or when reviewing CSS animation quality, performance or accessibility.
---

# Whimsical frontend (after Josh W. Comeau)

Distilled from Josh W. Comeau's tutorials (sources at the end; details in `references/`). Use his ideas, write your own code, credit him when a recipe is recognisably his.

## The mindset

1. **Delight with restraint.** Whimsy is a seasoning: one hero effect per screen (the 3D button is "ostentatious, use it selectively"). Small, quick, subtle beats big and slow.
2. **Motion should feel physical.** Things lift with a little overshoot, press almost instantly, and settle slowly. Springs over curves; squash and stretch kept to 25-50 % of the "demo" amount.
3. **Think in actions, not states.** Enter and exit are different events and deserve different timings (fast hover-in, relaxed hover-out; `ease-out` to enter, quicker `ease-in` to leave).
4. **No motion first.** Write the static design, then add motion inside `@media (prefers-reduced-motion: no-preference)`. Unsupported browsers and users who asked for less motion get the calm version for free. Fades are usually fine; movement, parallax and spinning are not.
5. **Native CSS first.** Reach for a JS library only for what CSS can't do (interruptible springs with inertia, path morphing in Safari, physics). CSS keyframes and transitions run off the main thread.
6. **Animate the cheap properties.** `transform`, `opacity`, `filter`. Not `height`, `top`, `margin`, `width`, layered `box-shadow`. Move a cheap layer instead of animating an expensive property (the 3D button slides layers instead of animating shadows).
7. **Consistency is beauty.** One light source for every shadow; shadow colour from the background hue; a few motion and elevation tokens reused everywhere (if > 20 % of transitions need custom curves, the tokens are wrong).
8. **Accessibility is part of the craft.** Keep focus rings (`:focus-visible`), keep contrast while things animate (text-shadow on shifting gradients), use real `<img alt>` even when drawing with backgrounds, respect the user's font size (rem).

## Starter tokens

```css
:root {
  /* Curves from the 3D button article */
  --ease-settle: cubic-bezier(0.3, 0.7, 0.4, 1);     /* release / return: 600ms */
  --ease-spring: cubic-bezier(0.3, 0.7, 0.4, 1.5);   /* hover-in with overshoot: 250ms */
  --press: 34ms;                                      /* ~2 frames: the press must feel instant */
}
@supports (animation-timing-function: linear(0, 1)) {
  :root { --ease-spring: linear(/* generated spring, see references/motion.md */); }
}
@media (prefers-reduced-motion: no-preference) {
  .thing { transition: transform 600ms var(--ease-settle); }
  .thing:hover { transform: translateY(-2px); transition-duration: 250ms; transition-timing-function: var(--ease-spring); }
  .thing:active { transform: translateY(1px); transition-duration: var(--press); }
}
```

Gotcha: a fallback by repeating the declaration does not work when the value is a `var()` (the browser only checks `var()` syntax). Swap the variable inside `@supports` instead.

## Recipe index

| Want | Recipe | File |
|---|---|---|
| Hover/press that feels good | asymmetric transition timings, doom-flicker fix | `references/motion.md` |
| Springs and bounces in pure CSS | `linear()` with generated points, tokens + `@supports` | `references/motion.md` |
| Reusable, composable keyframes | partial keyframes, CSS variables in keyframes, fill modes | `references/motion.md` |
| Scroll effects | `animation-timeline: view()/scroll()`, `animation-range`, linked timelines | `references/motion.md` |
| Pushable button | shadow / edge / front layers | `references/recipes.md` |
| Icon reacts on hover then returns | boop (timer-based un-boop) | `references/recipes.md` |
| Twinkling sparkles | random-interval generator, two nested keyframes | `references/recipes.md` |
| Animated gradient | `@property` / `CSS.registerProperty` colour stops | `references/recipes.md` |
| Colour cycling without grey | `filter: hue-rotate()` or `@property --hue` | `references/recipes.md` |
| Reorder / layout change animation | FLIP | `references/recipes.md` |
| Frame-by-frame | sprites with `object-position` + `steps(n, jump-none)` | `references/recipes.md` |
| Line drawing itself | SVG `stroke-dasharray` / `stroke-dashoffset`, `pathLength` | `references/recipes.md` |
| Enter animation on mount | keyframes (`from` only) vs `@starting-style` gotcha | `references/recipes.md` |
| Header that changes colour per section | sticky "blocker" elements, no JS | `references/recipes.md` |
| Paper-fold / 3D | perspective, `rotateX`, `backface-visibility` | `references/recipes.md` |
| Beautiful shadows | layered, colour-matched, one light source, elevation tokens | `references/visual.md` |
| Beautiful gradients | `in oklch` + dense-stop fallback | `references/visual.md` |
| Frosted glass | extended backdrop + mask, glassy edge | `references/visual.md` |
| Colour system | HSL/OKLCH tokens built with `calc()` | `references/visual.md` |
| Transforms | % translate, origin, order (orbit), inline gotcha | `references/visual.md` |
| Base CSS | modern reset, rem vs px, stacking contexts, full-bleed, heights, dark mode | `references/foundations.md` |

Read only the file you need.

## Ship checklist

- [ ] Every movement lives inside `prefers-reduced-motion: no-preference` (or JS checks `matchMedia`). Test with DevTools → "Emulate CSS prefers-reduced-motion".
- [ ] Only `transform` / `opacity` / `filter` animate; no `transition: all`.
- [ ] Hover-in, hover-out and press have different timings; press ≤ ~50 ms.
- [ ] Hover effects that move the element use a separate trigger (parent) and effect (child) to avoid doom flicker.
- [ ] `:focus-visible` outline is visible (with `outline-offset`) on every animated control.
- [ ] Text stays readable at every frame of an animated background.
- [ ] Shadows share one light direction and are tinted with the surface hue.
- [ ] Specificity: an `:is()` / ID / inline style isn't silently beating a hover, `@starting-style` or animation rule (check computed `transform` on hover, not just the screenshot).
- [ ] Tested on a slow device or with CPU throttling; `will-change: transform` only on things that actually move.
- [ ] Browser-support numbers in `references/` are dated by the article; check caniuse for anything critical and give a static fallback.

## Sources (Josh W. Comeau, joshwcomeau.com)

Motion: `/animation/css-transitions/`, `/animation/keyframe-animations/`, `/animation/partial-keyframes/`, `/animation/linear-timing-function/`, `/animation/a-friendly-introduction-to-spring-physics/`, `/animation/squash-and-stretch/`, `/animation/css-vs-javascript/`, `/animation/scroll-driven-animations/`, `/react/prefers-reduced-motion/`.
Recipes: `/animation/3d-button/`, `/react/boop/`, `/react/animated-sparkles-in-react/`, `/react/rainbow-button/`, `/animation/color-shifting/`, `/react/folding-the-dom/`, `/react/animating-the-unanimatable/`, `/animation/sprites/`, `/css/starting-style/`, `/css/header-blockers/`, `/svg/friendly-introduction-to-svg/`, `/svg/interactive-guide-to-paths/`.
Visual: `/css/designing-shadows/`, `/css/introducing-shadow-palette-generator/`, `/css/make-beautiful-gradients/`, `/css/backdrop-filter/`, `/css/color-formats/`, `/css/transforms/`.
Foundations: `/css/custom-css-reset/`, `/css/surprising-truth-about-pixels-and-accessibility/`, `/css/stacking-contexts/`, `/css/full-bleed/`, `/css/height-enigma/`, `/react/dark-mode/`.
Tools he points to: Shadow Palette Generator (`/shadow-palette/`), Gradient Generator (`/gradient-generator/`), Easing Wizard, Linear() Easing Generator (Jake Archibald & Adam Argyle). His courses: css-for-js.dev, whimsy.joshwcomeau.com.

Extracted 2026-11-01 from the live articles. Values are his; vanilla ports of React-only recipes are marked as ports.

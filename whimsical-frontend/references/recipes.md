# Recipes

Vanilla ports of React-only recipes are marked **port** (the idea is his, the code is ours).

## Pushable 3D button (`/animation/3d-button/`)

Three stacked layers; only the front and shadow move (transform), nothing animates `box-shadow`.

```html
<button class="pushable"><span class="shadow"></span><span class="edge"></span><span class="front">Reservar</span></button>
```
```css
/* Our condensed version of his recipe; values from the article. */
.pushable {
  --hue: 345deg; --radius: 12px;
  --settle: 600ms cubic-bezier(0.3, 0.7, 0.4, 1);
  --spring: 250ms cubic-bezier(0.3, 0.7, 0.4, 1.5);
  position: relative; padding: 0; border: 0; background: none; cursor: pointer; outline-offset: 4px;
  transition: filter 250ms;
}
.pushable > span { border-radius: var(--radius); }
.shadow, .edge { position: absolute; inset: 0; }
.shadow { background: hsl(0deg 0% 0% / 0.25); }
.edge { background: linear-gradient(to left, hsl(var(--hue) 100% 16%), hsl(var(--hue) 100% 32%) 8% 92%, hsl(var(--hue) 100% 16%)); }
.front { position: relative; display: block; padding: 12px 42px; color: white; background: hsl(var(--hue) 100% 47%); }
/* rest -> hover -> press: the face rises above the edge, the shadow drops below it */
.shadow { transform: translateY(2px); }   .front { transform: translateY(-4px); }
.pushable:hover { filter: brightness(110%); }
.pushable:hover .shadow { transform: translateY(4px); }  .pushable:hover .front { transform: translateY(-6px); }
.pushable:active .shadow { transform: translateY(1px); } .pushable:active .front { transform: translateY(-2px); }
.pushable:focus:not(:focus-visible) { outline: none; }
@media (prefers-reduced-motion: no-preference) {
  .shadow, .front { will-change: transform; transition: transform var(--settle); }
  .pushable:hover :is(.shadow, .front) { transition: transform var(--spring); }
  .pushable:active :is(.shadow, .front) { transition: transform 34ms; }
}
```

- Three timings: release 600 ms settle, hover 250 ms overshoot, press 34 ms (~2 frames).
- Shadow moves opposite to the front; optional `filter: blur(4px)` on it. Edge gradient darkens the rounded ends.
- Use one per screen. The reduced-motion gate is our addition (the article doesn't have one).
- Single-element approximation: `box-shadow: 0 4px 0 <darker cta>` that grows on hover and shrinks on press, with `translateY` (cheaper markup, slightly costlier paint).

## Boop (`/react/boop/`)

Hover snaps an icon to a transformed state, then it returns after a timer even if the pointer stays: a reaction, not a state.

- Defaults: `timing = 150` ms, spring `{ tension: 300, friction: 10 }`. Transform: `translate(x,y) rotate(r) scale(s)`, identity defaults so callers set only what they need.
- Animated element must be `display: inline-block` (inline elements can't transform).
- Trigger and effect can be different elements (hover the button, boop the icon).
- **Port** (CSS transition instead of a spring):
  ```js
  function boop(trigger, target, transform = 'rotate(15deg) scale(1.1)', timing = 150) {
    if (!matchMedia('(prefers-reduced-motion: no-preference)').matches) return;
    let t;
    trigger.addEventListener('mouseenter', () => {
      target.style.transform = transform;
      clearTimeout(t); t = setTimeout(() => (target.style.transform = ''), timing);
    });
  }
  /* css: .icon { display: inline-block; transition: transform 400ms var(--ease-spring); } */
  ```
- Star demo: 5 dots 42 px out, per-dot timing 450-600 ms growing by 22 % per index, friction 15-40, so they ripple instead of moving in lockstep.

## Sparkles (`/react/animated-sparkles-in-react/`)

- Final values: size `random(10, 20)` px, position `top/left random(0,100)%`, colour `#FFC700`, start with 3, add one every `random(50, 450)` ms, remove after 750 ms.
- Two nested elements so scale and rotation have independent easing:
  ```css
  @media (prefers-reduced-motion: no-preference) {
    .sparkle { animation: comeInOut 700ms forwards; }      /* wrapper */
    .sparkle svg { animation: spin 1000ms linear; }
  }
  @keyframes comeInOut { 0% { transform: scale(0); } 50% { transform: scale(1); } 100% { transform: scale(0); } }
  @keyframes spin { to { transform: rotate(180deg); } }
  .sparkle { position: absolute; pointer-events: none; z-index: 2; }
  ```
- Random intervals feel organic; `setInterval` feels mechanical. Reduced motion: 3-4 static sparkles, no generator.
- **Port**: recursive `setTimeout(tick, 50 + Math.random() * 400)`; each tick append one sparkle and remove nodes older than 750 ms.
- **CSS-only cheat** (fixed positions): 3 absolutely placed stars with the same keyframe and staggered `animation-delay`s.

## Rainbow / animated gradients (`/react/rainbow-button/`)

Gradients can't be transitioned, but registered custom properties can, and the gradient repaints as they tween.

```css
@property --c0 { syntax: '<color>'; inherits: false; initial-value: hsl(0deg 96% 55%); }
/* ...--c1, --c2 */
.magic { background: linear-gradient(170deg, var(--c0), var(--c1), var(--c2));
  transition: --c0 1000ms linear, --c1 1000ms linear, --c2 1000ms linear; }
```

- JS shifts each colour one slot along a 7-colour palette every 1000 ms via `el.style.setProperty`.
- `CSS.registerProperty` is global: unique names per instance; feature-detect and keep the static gradient as fallback.
- Keep text readable: text-shadow and darken the warm end. ~0.3 ms repaint at 6x CPU throttle.
- Rotating ring variant: `@property --angle { syntax: '<angle>'; inherits: false; initial-value: 0deg; }` + `conic-gradient(from var(--angle), ...)` on a `border-box` background, animate `--angle` to `360deg`. Pass colours to themes as a list variable (`--ring-colors`), not a whole gradient: a `var()` inside a custom property resolves where it's declared, freezing the angle.

## Colour shifting (`/animation/color-shifting/`)

- `background-color` interpolates in RGB, so hue shifts go grey midway, and `hsl(0)` → `hsl(360)` does nothing.
- Preferred: `@keyframes hueRotate { to { filter: hue-rotate(720deg); } }` (180-540° is a practical range; start from slightly lighter, less saturated colours because filter darkens).
- Alternative: `@property --hue { syntax: '<angle>'; ... }`, `background: hsl(var(--hue) 100% 80%)`, `transition: --hue 2000ms linear`.
- Random pastel: `hsl(${Math.round(Math.random()*359)}deg 100% 80%)`. Give each particle its own `--twinkle-duration` so they don't flicker in sync.

## FLIP (`/react/animating-the-unanimatable/`)

First, Last, Invert, Play, for reorders and layout changes that CSS can't transition.

```js
const first = new Map(items.map((el) => [el.dataset.id, el.getBoundingClientRect()]));
mutateDom();
for (const el of items) {
  const a = first.get(el.dataset.id), b = el.getBoundingClientRect();
  el.style.transition = 'none';
  el.style.transform = `translate(${a.left - b.left}px, ${a.top - b.top}px)`;
  requestAnimationFrame(() => requestAnimationFrame(() => {
    el.style.transition = 'transform 500ms'; el.style.transform = '';
  }));
}
```
Double rAF commits the inverted frame first. Reduced motion: skip the transition. Today he'd use Motion's layout animations in React.

## Sprites (`/animation/sprites/`)

```css
.sprite { width: 200px; height: 400px; object-fit: cover; animation: sprite 1s steps(5, jump-none) infinite; }
@keyframes sprite { from { object-position: 0% 0%; } to { object-position: 100% 0%; } }
```
- `jump-none` for loops (all 5 frames shown); default `jump-end` never reaches 100 % (good for one-shot with `forwards`).
- Pausable (`animation-play-state`), consistent timing, AVIF far smaller than GIF. Procedural effects are often better on modern devices.

## SVG draw-on (`/svg/friendly-introduction-to-svg/`)

```css
path { stroke-dasharray: 100 10000; stroke-dashoffset: 100; transition: stroke-dashoffset 3000ms; }
.drawn path { stroke-dashoffset: 0; }
```
with `<path pathLength="100" ...>` (or measure with `el.getTotalLength()`). Stroke properties are CSS, so they transition. Seamless dash loops: offset by dash + gap length. `stroke-miterlimit: 100` stops sharp joins turning bevelled.

## Enter animations: keyframes vs `@starting-style` (`/css/starting-style/`)

- `@starting-style` follows normal specificity, so an ID rule or JS inline style beats it and the element just appears.
- Simplest reliable enter: `@keyframes enter { from { opacity: 0; transform: translateY(8px); } }` (partial keyframe, high cascade priority).
- `@starting-style` wins when an enter can be interrupted (dialog dismissed mid-fade fades from the current value). Fix specificity with variables, `transform: translate(var(--x), var(--y))`, not `!important`.

## Header blockers (`/css/header-blockers/`)

Transparent fixed header, plus a `position: sticky; top: 0; height: var(--header-height)` "blocker" inside each section with that section's background. The blocker scrolls away with its section, so the header seems to change colour. Needs ~5rem of free space above content; otherwise fall back to a JS scroll class.

## Folding the DOM (`/react/folding-the-dom/`)

Top half = clipped real `<img alt>`; bottom half = same image as background shifted up, `transform-origin: center top; transform: rotateX(deg)` inside `perspective: 500px`, `transform-style: preserve-3d`; back face `rotateX(180deg) translateZ(.5px)` with `backface-visibility: hidden`; a shade layer whose opacity grows over the first 90°.

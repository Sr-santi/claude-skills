# Visual style

## Shadows (`/css/designing-shadows/`, `/css/introducing-shadow-palette-generator/`)

1. **One light source.** Every shadow on the page uses the same offset direction (light above and slightly left: y = 2 × x).
2. **Elevation** = bigger offset, bigger blur, lower opacity.
3. **Layer** shadows (offsets and blur doubling) for a soft, realistic falloff instead of one muddy blur.
4. **Tint with the background hue**: same hue, lower lightness, less saturation. Black shadows desaturate coloured backgrounds. On `hsl(220deg 100% 80%)` use `hsl(220deg 60% 50%)`, not black or `hsl(220deg 100% 50%)`.

```css
:root {
  --shadow-color: 220deg 60% 50%;            /* bare HSL components; redefine per surface */
  --shadow-elevation-low: 0.5px 1px 1px hsl(var(--shadow-color) / 0.7);
  --shadow-elevation-medium:
    1px 2px 2px hsl(var(--shadow-color) / 0.333),
    2px 4px 4px hsl(var(--shadow-color) / 0.333),
    3px 6px 6px hsl(var(--shadow-color) / 0.333);
  --shadow-elevation-high:
    1px 2px 2px hsl(var(--shadow-color) / 0.2),
    2px 4px 4px hsl(var(--shadow-color) / 0.2),
    4px 8px 8px hsl(var(--shadow-color) / 0.2),
    8px 16px 16px hsl(var(--shadow-color) / 0.2),
    16px 32px 32px hsl(var(--shadow-color) / 0.2);
}
.dark-section { --shadow-color: 250deg 40% 10%; }   /* the shadow follows the backdrop */
```

- Generate with his Shadow Palette Generator (`/shadow-palette/`): 3 elevations, 5-6 layers, one tint.
- `filter: drop-shadow()` follows transparent shapes (tooltips with tips, PNG icons): stack `1px 2px 3px`, `2px 4px 6px`, `4px 8px 12px` at `/ 0.3`.
- Layers cost paint ("5x more work"). Don't animate a layered shadow; animate `transform`/`opacity` of a pre-shadowed layer instead.

## Gradients (`/css/make-beautiful-gradients/`)

- RGB interpolation between complementary colours passes through a grey **dead zone**.
- Interpolate in a perceptual space, with an RGB fallback line first:
  ```css
  background: linear-gradient(to right, yellow, blue);
  background: linear-gradient(to right in oklch, yellow, blue);
  ```
- Universal trick: precompute ~10 intermediate stops in a perceptual mode (chroma.js: lab/hcl/oklch) and list them all; between near-identical stops RGB interpolation is invisible. Works for radial and conic too.
- HSL keeps saturation and lightness constant but ignores perception (yellow looks lighter than blue at the same L). Try a few modes per gradient. Generator: `/gradient-generator/`. Support for `in <space>` was ~91 % in late 2025.

## Frosted glass (`/css/backdrop-filter/`)

`backdrop-filter` only blurs what's directly behind the element, so content approaching the header isn't blurred yet. Extend the blurred layer below the element and cut it off:

```css
header { position: relative; overflow: hidden; background: hsl(0deg 0% 100% / 0.5); }
.backdrop {
  position: absolute; inset: 0; height: 200%; pointer-events: none;
  backdrop-filter: blur(16px) saturate(140%);
  mask-image: linear-gradient(to bottom, black 0% 50%, transparent 50% 100%);
  background: linear-gradient(to bottom, hsl(0deg 0% 95%) 0%, transparent 50%); /* page bg, hides top-edge flicker */
}
.backdrop-edge {             /* thin glassy rim under the header */
  --thickness: 4px; position: absolute; inset: 0; transform: translateY(100%); pointer-events: none;
  backdrop-filter: blur(12px) brightness(0.96);
  mask-image: linear-gradient(to bottom, black 0 var(--thickness), transparent var(--thickness));
}
@supports not ((backdrop-filter: blur(1px)) or (-webkit-backdrop-filter: blur(1px))) {
  header { background: hsl(0deg 0% 100% / 0.95); }
}
```
- `saturate()` offsets blur muddiness; raise blur or opacity if text behind hurts readability.
- `pointer-events: none` on masked layers (hidden parts still catch clicks). Rounded glass: SVG `<mask>` with `rx`.
- Firefox: sticky + ancestor `overflow` + `border-radius` breaks it (bug 1803813); `overscroll-behavior: none` fixed one flicker. Support ~97 % (Oct 2026).

## Colour (`/css/color-formats/`)

- He uses HSL day to day (readable, easy to tweak); OKLCH is perceptually uniform and wide-gamut, his planned next step.
- Modern syntax: `rgb(255 0 0 / 0.5)`, `hsl(0deg 100% 50% / 0.5)`. P3 with fallback: `background: rgb(255 0 0); background: color(display-p3 1 0 0);`.
- Token families with `calc()`, which stay live for themes and dark mode:
  ```css
  html {
    --red-hue: 0deg; --red-sat: 100%; --red-lit: 50%;
    --red: hsl(var(--red-hue) var(--red-sat) var(--red-lit));
    --dark-red: hsl(var(--red-hue) var(--red-sat) calc(var(--red-lit) - 20%));
    --soft-red: hsl(var(--red-hue) calc(var(--red-sat) - 30%) calc(var(--red-lit) + 10%));
  }
  ```
- Modern alternative: `color-mix(in oklab, var(--cta), black 30%)` for edges and hovers.

## Transforms (`/css/transforms/`)

- Percent `translate` is relative to the element itself: `translateY(-100%)` lifts it by its own height (close button sitting above a dialog).
- `rotate` accepts `turn`. `transform-origin` is the pivot (grow from an anchor, fold from the top edge).
- Order is right to left: `rotate(...) translateX(80px)` orbits; reversed it spins in place.
  ```css
  @keyframes orbit { from { transform: rotate(0deg) translateX(80px); } to { transform: rotate(360deg) translateX(80px); } }
  ```
- Inline elements can't be transformed: use `inline-block` (common boop bug).
- Individual properties `translate`, `scale`, `rotate` let two animations touch "transform" without overriding each other.

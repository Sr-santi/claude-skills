# Foundations

## Modern CSS reset (`/css/custom-css-reset/`, released to the public domain)

```css
*, *::before, *::after { box-sizing: border-box; }
*:not(dialog) { margin: 0; }
@media (prefers-reduced-motion: no-preference) { html { interpolate-size: allow-keywords; } }
body { line-height: 1.5; -webkit-font-smoothing: antialiased; }
img, picture, video, canvas, svg { display: block; max-width: 100%; }
input, button, textarea, select { font: inherit; }
p, h1, h2, h3, h4, h5, h6 { overflow-wrap: break-word; }
p { text-wrap: pretty; }
h1, h2, h3, h4, h5, h6 { text-wrap: balance; }
#root, #__next { isolation: isolate; }
```
- `dialog` keeps its `margin: auto` centring. `interpolate-size` enables `height: 0 → auto` transitions (Chromium-only in 2025; no animation elsewhere is acceptable). Still prefer `transform: scale` when possible.
- `font: inherit` because controls default to ~13px and iOS zooms inputs under 16px.
- Own your reset; test it before dropping it into an existing codebase.

## Animating to `height: auto`

- `interpolate-size: allow-keywords` (from the reset), then `transition: height 400ms` between `0` and `auto`.
- For `<details>`: `details::details-content { block-size: 0; overflow: clip; transition: block-size 500ms, content-visibility 500ms allow-discrete; } details[open]::details-content { block-size: auto; }`. Unsupported browsers just open instantly.

## Pixels vs rem (`/css/surprising-truth-about-pixels-and-accessibility/`)

Ask: *should this grow when the user raises their default font size?* Yes: `rem`. No: `px`.
- Font sizes: always rem/em (px ignores the user's setting).
- Media queries: rem, so big-text users get the narrower layout.
- Borders, horizontal padding, shadows: px is fine. Vertical margins: rem/em.
- Don't use the `62.5%` trick; use variables like `--18px: 1.125rem` or `calc(18rem / 16)`.
- Test by setting the browser default font to 32 px.

## Stacking contexts (`/css/stacking-contexts/`)

- `z-index` only competes **within** a stacking context; a child can't escape its parent's context.
- Created by: positioned + `z-index`, `opacity < 1`, `position: fixed/sticky`, `transform`, `filter`, `clip-path`, `perspective`, `mix-blend-mode`, `will-change: transform/opacity`, `isolation: isolate`, and `z-index` on flex/grid children.
- `isolation: isolate` on a component root keeps its internal z-indexes internal without picking a number. "z-index is an escape hatch, like `!important`."
- Inside an isolated element, a `z-index: -1` child paints **above** the element's own background but below its text: useful for shine/glow layers inside a button.
- Accidental contexts from `will-change` and `transform` are a classic source of "my modal is behind the header".

## Full-bleed layout (`/css/full-bleed/`)

```css
.wrapper {
  --viewport-padding: 16px;
  display: grid;
  grid-template-columns: 1fr min(42rem, 100%) 1fr;
  padding-inline: var(--viewport-padding);
}
.wrapper > * { grid-column: 2; }
.full-bleed { grid-column: 1 / -1; margin-inline: calc(var(--viewport-padding) * -1); }
```
42rem ≈ 65 characters. Avoid `ch` for the column (depends on the "0" glyph and each element's font size).

## Heights (`/css/height-enigma/`)

- Width flows down from the parent; height flows up from children. `height: 50%` only works if the parent's height is known (explicit, not `min-height`).
- To make children fill a `min-height` parent, make the parent `display: grid` (or flex + `flex: 1`) instead of chaining `height: 100%`.
- Use `svh`/`dvh` instead of `html, body { height: 100% }`.

## Dark mode without flicker (`/react/dark-mode/`)

1. Style everything through CSS variables.
2. A blocking inline `<script>` in `<head>` (before body) picks the mode: saved `localStorage` → `prefers-color-scheme` → light. It sets the variables (or `data-theme`) on `<html>` before first paint. ~12 µs, worth blocking.
3. Don't render the toggle's checked state until the client knows the mode (render nothing at build time).
4. Without JS: a `<style>` with default variables plus `@media (prefers-color-scheme: dark)`.

## SVG paths (`/svg/interactive-guide-to-paths/`)

`M` move, `L` line, `Q` quadratic, `C` cubic, `A rx ry rot large-arc sweep x y` arc, `Z` close; lowercase = relative; `S`/`T` mirror the previous control point for smooth joins. Format path data with commas and newlines (gzip makes it free).

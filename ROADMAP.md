# Roadmap — resolve-toolkit

Architecture and specs live here; implementation happens in a normal (Sonnet/Opus) session with the
`davinci-resolve-effects` skill loaded. **Nothing is "done" until Svei tests it inside Resolve and confirms.**

Estado / status: ⬜ not built · 🔧 built, waiting for Svei's test · ✅ confirmed working in Resolve

---

## Phase 1 — Must-have effects (build first)

### 1.1 ⬜ ESV Privacy Blur (`templates/Edit/Effects/ESV Privacy Blur.setting`)

Blur/censor box for hiding RFC, CFDI data, names, emails in screen recordings.
**Type: Effect** (drag onto clip — needs the MediaIn + AudioDisplay pattern from the skill).

Node graph (all pieces are proven patterns from `ESV Magnifying v2.setting`):
- `MediaIn1_1` (verbatim block from skill) → `HeavyBlur` (Blur) → MainOutput1.
- `BlurRegion` = RectangleMask, aspect-proof (GetPrefs MaskWidth/MaskHeight, Height×aspect compensation),
  UserControls: `RegionCenter` (Point/crosshair "Position"), `RegionWidth`, `RegionHeight`.
- `HeavyBlur.EffectMask` ← `BlurRegion.Mask`; `Filter = Multi-box`;
  `XBlurSize` expression: `BlurAmount * comp:GetPrefs("Comp.FrameFormat.Width") / 1920` (UserControl `BlurAmount`).

Inspector page "Region": Position (crosshair), Width (0.3), Height (0.15), Angle, Corner Radius (0.2),
Edge Softness (0.003, MaxScale 0.05), Invert checkbox (= "blur everything EXCEPT the box"), Blur Strength (45, max 150).

Test checklist for Svei: drops onto a clip without errors · box follows crosshair · text under box unreadable at default strength · works on a 9:16 timeline · Invert blurs outside.

v2 ideas (only after v1 ✅): pixelate mode, solid-fill mode, tracking note (Fusion tracker manual step).

### 1.2 ⬜ ESV Keystroke (`templates/Edit/Generators/ESV Keystroke.setting`)

On-screen shortcut badge ("Ctrl + Shift + V") for Excel tutorials. **Type: Generator.**

Node graph:
- `BadgeMask` = RectangleMask aspect-proof (UserControls `BadgeWidth` 0.2, `BadgeHeight` 0.06), CornerRadius 0.4, Center fixed {0.5, 0.5}.
- `BadgeBG` = Background (GetPrefs Width/Height), dark glass: RGB ≈ 0.05/0.05/0.07, `TopLeftAlpha` 0.85, `EffectMask` ← BadgeMask.
- `KeyText` = TextPlus: `UseFrameFormatSettings = 1`, Font "Segoe UI" Bold, Size 0.05, color = brand pale gold `#F1EBDF` → Red1 0.945 / Green1 0.922 / Blue1 0.875, StyledText default "Ctrl + V".
- `TextOverBadge` = Merge (BG ← BadgeBG, FG ← KeyText).
- Pop-in: `PopAnim` = BezierSpline KeyFrames `[0]={0}, [6]={1.06}, [9]={1}` driving `PopXF` (Transform) `Size`.
- `PlaceXF` = Transform: exposed Position (default {0.5, 0.14} = bottom-center) and Scale.

Inspector pages: "Keystroke" (Text, Text Size, Text R/G/B), "Badge" (Width, Height, Corner Radius, Badge R/G/B, Opacity), "Transform" (Position, Scale).

Test checklist: appears in Generators · pop-in animates first ~9 frames · text editable · badge auto-sizes acceptably when text longer (if not: widen Badge Width manually — v2 could auto-width) · vertical timeline OK.

## Phase 2 — Approved effects

### 2.1 ⬜ ESV Callout (`Generators`)
Animated connector line from a point of interest to a text label. Elements: anchor dot (Ellipse mask + Background),
line that grows from anchor → label (RectangleMask with animated Width, anchored at one end via Center expression —
same trick as SocialLowerThird's bar: `Center.X = anchor + Width/2`), Text+ label that fades in after the line lands
(Merge.Blend spline). Controls: Anchor Position, Label Position (line auto-connects the two — compute line length/angle
via expressions `atan2`/`sqrt` between the two points), texts, colors, line thickness. This is the most expression-heavy
one — build AFTER 1.1/1.2 are ✅ to reuse the learnings.

### 2.2 ⬜ ESV Step Counter (`Generators`)
"Paso 2 de 5" badge / progress pips for multi-step tutorials. Simple version: badge (reuse Keystroke chassis) with
two Text+ ("PASO" small, "2 / 5" big) and optional progress bar (RectangleMask Width = `Current/Total * BarMax`,
UserControls Current + Total as integer sliders). Pop-in reused from Keystroke.

## Phase 3 — Idea backlog (propose to Svei when Phase 2 is ✅)

- **Click ripple** — expanding circle at cursor position to emphasize a click (Ellipse mask + time expression).
- **Before/After wipe** — Effect with animated split to compare two states of a sheet.
- **Number pop counter** — animated count-up for stats ("$12,450") — Text+ value via `math.floor(time-driven expression)`.
- **Excel formula bar overlay** — branded recreation of the formula bar to show a formula big on screen.
- **Subscribe/Like reminder** — small animated corner badge reusing SocialLowerThird's platform-logo dropdown.
- **Chapter title card** — full-screen intro card matching ESV branding.

## Toolkit — Python scripting (specs in SKILL.md, build in this order)

- ⬜ **T1 `scripts/resolve_toolkit/connect.py` + `rtk.py info`** — bootstrap connection (code sketch in skill), print
  project/timeline/fps/marker count. Acceptance: Svei runs `python scripts\rtk.py info` with Resolve open, sees his project.
  One-time manual step: Preferences → System → General → External scripting using = **Local**.
- ⬜ **T2 `rtk.py markers`** — list markers (frame, timecode, color, name, note, duration), `--color` filter, `--json`.
- ⬜ **T3 `rtk.py apply <TemplateName> [--color X]`** — for each (filtered) marker: `SetCurrentTimecode` → `InsertFusionGeneratorIntoTimeline`.
  Generators/Titles only (API can't apply Effects — document). Verify empirically which track it lands on.
- ⬜ **T4 `rtk.py export`** — whole timeline with `--preset`, or `--by-markers --color X` using duration markers as MarkIn/MarkOut segments. `rtk.py presets` lists render presets.
- ⬜ **T5** config file `marker-map.json` (marker color → template name) so one command dresses a whole timeline.

## Housekeeping

- ⬜ Clean `.bak` files out of AppData once repo history is trusted (they were the old backup system).
- ⬜ `SocialLowerThird` logo Loaders hardcode `D:\NextCloud\...\brand icons\*.png` — consider copying icons into the repo and repointing, so templates survive a NextCloud reorganization.
- ✅ Existing library imported to repo (2026-07-03): Circle1/2, Arrow1/2, Check1/2, Cross1, Frame1, Underline1,
  Highlight Marker (+FX), BrandBadge, BrandBox (+Glass), SocialLowerThird, Tech Lower Third, ESV Magnifying (+v2), Code Clarity.

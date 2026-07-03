# resolve-toolkit

Fusion templates + scripting automation for Svei's DaVinci Resolve workflow (Excel Solutions V).
*Plantillas Fusion + automatización por scripting para el flujo de trabajo de Svei en DaVinci Resolve.*

This repo is the **source of truth**. Resolve reads templates from AppData; you edit here and deploy.
*Este repo es la fuente de verdad. Resolve lee las plantillas desde AppData; aquí se editan y luego se despliegan.*

## Folder tree / Estructura

```
resolve-toolkit/
├── templates/Edit/
│   ├── Generators/    → drag to timeline as a clip (circles, arrows, lower thirds…)
│   └── Effects/       → drag ONTO an existing clip (magnifier, blur…)
├── scripts/           → Python toolkit (Resolve Scripting API) — see ROADMAP.md
├── skill/             → copy of the Claude Code skill (master lives in ~/.claude/skills/)
├── deploy.ps1         → repo → AppData (installs templates into Resolve)
├── pull.ps1           → AppData → repo (imports changes made inside Resolve)
└── ROADMAP.md         → effect specs + build order / especificaciones y orden de construcción
```

## Install templates into Resolve / Instalar plantillas en Resolve

```powershell
.\deploy.ps1        # copies templates/Edit/* to the Resolve Templates folder (backs up first)
```

Then **restart Resolve** (templates are not hot-reloaded). Find them in
**Effects Library → Toolbox → Generators / Effects**, named like the file (no extension).
*Después reinicia Resolve (no recarga plantillas en caliente). Aparecen en Effects Library → Toolbox → Generators / Effects con el nombre del archivo.*

- **Generators**: drag to an empty video track above your footage. / *Arrastra a una pista de video vacía sobre tu material.*
- **Effects**: drag on top of the clip you want to process. / *Arrastra encima del clip que quieres procesar.*

Manual alternative / alternativa manual: copy any `.setting` to
`C:\Users\svei\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Templates\Edit\{Generators|Effects}\`.

## If you edited a template inside Resolve / Si editaste una plantilla dentro de Resolve

```powershell
.\pull.ps1          # brings AppData changes back into the repo, then: git diff / commit
```

## Workflow with Claude / Flujo con Claude

Template work runs with the `davinci-resolve-effects` skill (auto-triggers on any Resolve/effect request).
Architecture and specs are already written — implementation sessions should run on **Sonnet/Opus**, not Fable.
Every template is **untested until Svei confirms it in Resolve** — each ROADMAP item carries a test checklist.
*Cada plantilla queda "sin probar" hasta que Svei la confirma dentro de Resolve.*

## Template catalog / Catálogo

All templates are aspect-proof (one file works on 16:9 and 9:16 — relative coordinates via
`comp:GetPrefs("Comp.FrameFormat.…")`). ✅ = in use / confirmed by Svei.

| Template | Type | What it is |
|---|---|---|
| Circle1 / Circle2 ✅ | Generator | Circle highlight/callout ring |
| Arrow1 / Arrow2 ✅ | Generator | Pointer / directional arrow |
| Check1 / Check2, Cross1 ✅ | Generator | Check ✓ / cross ✗ marks |
| Frame1 ✅ | Generator | Highlight box / frame |
| Underline1 ✅ | Generator | Animated underline |
| Highlight Marker ✅ (+ FX) | Gen / Effect | Marker-style highlight |
| BrandBadge, BrandBox ✅ (+ Glass) | Gen / Effect | ESV brand badge / box |
| SocialLowerThird ✅ | Generator | Lower third w/ platform logos + auto CTA (see its README) |
| Tech Lower Third ✅ | Generator | Lower third, color presets + timed reveal |
| ESV Magnifying v2 ✅ | Effect | Magnifying glass zoom on footage |
| Code Clarity ✅ | Effect | Code/screen readability effect |
| ESV Privacy Blur ⬜ | Effect | Censor blur box (spec in ROADMAP 1.1) |
| ESV Keystroke ⬜ | Generator | Shortcut badge (spec in ROADMAP 1.2) |

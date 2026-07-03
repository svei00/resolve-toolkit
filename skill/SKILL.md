---
name: davinci-resolve-effects
description: Build, fix, and deploy DaVinci Resolve Fusion templates (.setting files) and Resolve Python scripting automation for Svei's video workflow. Use whenever Svei asks for a new video effect, overlay, lower third, callout, template fix, marker automation, batch apply/export in DaVinci Resolve, or anything touching .setting files or the resolve-toolkit repo.
---

# DaVinci Resolve Effects & Automation — Svei's workflow

## Environment (verified 2026-07-03)

- **DaVinci Resolve Studio 21.0.1** (Studio = external scripting from terminal works)
- Windows 11, Python 3.14 (`python` on PATH)
- Repo (source of truth): `D:\repos\resolve-toolkit`
- Live templates dir (what Resolve reads):
  `C:\Users\svei\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Templates\Edit\`
  with subfolders `Generators\` (drag to timeline as clips) and `Effects\` (drag ONTO an existing clip)
- Scripting API present:
  - `C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll`
  - `C:\ProgramData\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules\DaVinciResolveScript.py`
- Svei is an accountant/Excel-content creator (Excel Solutions V). Content: Excel/SAT/CFDI tutorials, single-shoot screen recordings, published horizontal (16:9) AND vertical (9:16). Brand palette: pale gold text `#F1EBDF`, dark glass bars. Template prefix: `ESV`.

## Golden rules

1. **Never claim a template works.** You cannot preview Fusion output. Every new/changed `.setting` is UNTESTED until Svei opens Resolve and confirms. Deliver, tell him exactly what to test, wait for his report, fix from his exact symptom.
2. **One aspect-proof file, never 16:9/9:16 duplicates.** Use `comp:GetPrefs("Comp.FrameFormat.Width/Height")` expressions (patterns below) so the same template works on any timeline resolution.
3. **Work in the repo, deploy to AppData.** Edit files in `D:\repos\resolve-toolkit\templates\...`, then run `deploy.ps1` (copies to AppData). Never edit AppData copies directly. Commit after Svei confirms a template works.
4. **Before modifying a working template**, the repo git history is the backup (old habit was `Name.BACKUP-YYYY-MM-DD.setting.bak` files — don't create more of those in AppData).
5. **Steal from the proven templates first.** Before writing any node graph, READ the closest working example in the repo:
   - Simple generator with exposed controls: `Circle1.setting`
   - Advanced generator (color presets via `iif`, time-based reveal animation, gradients): `Tech Lower Third.setting`
   - Animated multi-element generator with keyframe splines: `SocialLowerThird.setting` (its README `SocialLowerThird_README.md` documents the approach)
   - **Effect applied onto a clip** (MediaIn pattern, canonical): `ESV Magnifying v2.setting`
6. **Docs bilingual**: English structure, Spanish notes where helpful (Svei's preference).
7. **Model policy**: architecture/specs on the premium model only when Svei asks; template implementation and fix-iteration loops run on Sonnet/Opus. This skill file is the handoff — keep it updated when a new pattern is proven.

## Resolve refresh gotcha (tell Svei every delivery)

After deploying a new/changed `.setting`, Resolve does NOT hot-reload templates. Svei must restart Resolve (safest), or re-open the project. Effects appear in **Effects Library → Toolbox → Generators / Effects** under the filename (no extension).

## Anatomy of a .setting template

Lua-table text file, tab-indented. Skeleton:

```lua
{
	Tools = ordered() {
		ESVMyEffect = MacroOperator {
			CtrlWZoom = false,
			Inputs = ordered() {
				Input1 = InstanceInput {
					SourceOp = "SomeToolName",   -- tool inside Tools below
					Source = "SomeInputName",    -- input id on that tool (or a UserControl id)
					Name = "Label in Inspector",
					Page = "Tab name in Inspector",   -- groups controls into tabs
					Default = 0.3,               -- MUST match the tool's actual value
					-- optional: MinScale, MaxScale
				},
				-- Input2, Input3... exposure order = Inspector order
			},
			Outputs = {
				MainOutput1 = InstanceOutput { SourceOp = "LastTool", Source = "Output", },
			},
			ViewInfo = GroupInfo { Pos = { 0, 0 } },
			Tools = ordered() {
				-- node graph here; names are comp-global, keep them unique & prefixed
			},
		}
	},
	ActiveTool = "ESVMyEffect"
}
```

Gotchas:
- Colors are exposed as three separate number InstanceInputs (`TopLeftRed/Green/Blue` on Background, `Red1/Green1/Blue1` on Text+) — that is the existing convention (see Circle1). Alpha (`TopLeftAlpha`) = opacity slider.
- `FuID { "Fast Gaussian" }` syntax for enum-ish inputs.
- Expressions live inside an Input: `Width = Input { Value = 0.3, Expression = "MyControl", }` — keep a sane `Value` as fallback; escape quotes as `\"` inside Expression strings.
- Visibility animation goes on `Merge.Blend`, NOT Transform (Transform has no opacity).
- Point inputs (positions) are `{ x, y }` in 0–1 relative coords, origin bottom-left, `{0.5, 0.5}` = center.

## Proven pattern: aspect-proof mask + custom controls

From `ESV Magnifying v2.setting` (confirmed working on 16:9 and 9:16). A RectangleMask whose Width/Height sliders mean "fraction of screen width" on BOTH axes (so equal values = square on screen):

```lua
MyMask = RectangleMask {
	CtrlWShown = false,
	Inputs = {
		Filter = Input { Value = FuID { "Fast Gaussian" }, },
		MaskWidth = Input { Expression = "comp:GetPrefs(\"Comp.FrameFormat.Width\")", },
		MaskHeight = Input { Expression = "comp:GetPrefs(\"Comp.FrameFormat.Height\")", },
		PixelAspect = Input { Value = { 1, 1 }, },
		ClippingMode = Input { Value = FuID { "None" }, },
		Center = Input { Expression = "MyCenter", }, MyCenter = Input { Value = { 0.5, 0.5 }, },
		Width = Input { Value = 0.3, Expression = "MyWidth", },
		Height = Input { Value = 0.533, Expression = "MyHeight * (comp:GetPrefs(\"Comp.FrameFormat.Width\")/comp:GetPrefs(\"Comp.FrameFormat.Height\"))", },
		CornerRadius = Input { Value = 0.2, },
		SoftEdge = Input { Value = 0.003, }
	},
	ViewInfo = OperatorInfo { Pos = { -275, 60 } },
	UserControls = ordered() { MyWidth = { INP_Default = 0.3, INPID_InputControl = "SliderControl", LINKS_Name = "Width", LINKID_DataType = "Number", }, MyHeight = { INP_Default = 0.3, INPID_InputControl = "SliderControl", LINKS_Name = "Height", LINKID_DataType = "Number", }, MyCenter = { LINKID_DataType = "Point", INPID_PreviewControl = "CrosshairControl", CHC_Style = 0, INPID_InputControl = "OffsetControl", LINKS_Name = "Position", } }
}
```

Expose `MyCenter` / `MyWidth` / `MyHeight` via InstanceInputs (`Source = "MyCenter"` etc.). The UserControls one-liner format above is exactly how the working files do it.

Full-frame transparent canvas for generators:

```lua
TransparentBG = Background {
	CtrlWShown = false,
	Inputs = {
		Width = Input { Expression = "comp:GetPrefs(\"Comp.FrameFormat.Width\")", },
		Height = Input { Expression = "comp:GetPrefs(\"Comp.FrameFormat.Height\")", },
		["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },
		TopLeftAlpha = Input { Value = 0, }
	},
},
```

For pixel-denominated inputs (e.g. `Blur.XBlurSize`), scale by width: `Expression = "MyAmount * comp:GetPrefs(\"Comp.FrameFormat.Width\") / 1920"`.

Text+: set `UseFrameFormatSettings = Input { Value = 1 }` so text renders at timeline resolution; `Size` is already resolution-relative.

## Proven pattern: Effect applied onto a clip (Templates\Edit\Effects)

An Effect macro must CONTAIN a `MediaIn` (Resolve rewires it to the target clip) and audio passthrough. Copy this trio verbatim from `ESV Magnifying v2.setting` into the macro's `Tools`:

```lua
MediaIn1_1 = MediaIn {
	ExtentSet = true,
	CtrlWZoom = false,
	CtrlWShown = false,
	CustomData = { MediaProps = { MEDIA_HEIGHT = 1080, MEDIA_AUDIO_TRACKS_DESC = { { MEDIA_AUDIO_BIT_DEPTH = 32, MEDIA_AUDIO_TRACK_ID = "Timeline Audio", MEDIA_AUDIO_TRACK_NAME = "Timeline Audio [Timeline 1]", MEDIA_AUDIO_FRAME_RATE = 30, MEDIA_AUDIO_START_TIME = 0, MEDIA_AUDIO_SAMPLE_RATE = 48000, MEDIA_AUDIO_NUM_CHANNELS = 2 } }, MEDIA_IS_SOURCE_RES = false, MEDIA_PAR = 1, MEDIA_START_FRAME = 0, MEDIA_WIDTH = 1920, MEDIA_AUDIO_TRACKS_NUM = 1, MEDIA_SRC_FRAME_RATE = 30, MEDIA_MARK_OUT = 246, MEDIA_HAS_AUDIO = true, MEDIA_NUM_FRAMES = 247, MEDIA_MARK_IN = 0, MEDIA_NAME = "Adjustment Clip" }, },
	Inputs = {
		GlobalOut = Input { Value = 246, },
		AudioTrack = Input { Value = FuID { "Timeline Audio" }, },
		Layer = Input { Value = "", },
		ClipTimeEnd = Input { Value = 246, },
		DeepOutputMode = Input { Value = 0, Disabled = true, },
		LeftAudio = Input { SourceOp = "Left", Source = "Data", },
		RightAudio = Input { SourceOp = "Right", Source = "Data", }
	},
	Version = 1
},
-- ...your processing chain, Input = MediaIn1_1.Output...
Left = AudioDisplay { CtrlWZoom = false, },
Right = AudioDisplay { CtrlWZoom = false, }
```

And in the macro's `Outputs`, alongside `MainOutput1` (the video), add:

```lua
Output1 = InstanceOutput { SourceOp = "Left", Source = "Data", },
Output2 = InstanceOutput { SourceOp = "Right", Source = "Data", }
```

Generators (Templates\Edit\Generators) need NO MediaIn — just build over a TransparentBG.

## Animation patterns (both proven in the library)

1. **Keyframe splines** (SocialLowerThird): a `BezierSpline` op at top level of the macro's Tools, driven input references it:
   `Size = Input { SourceOp = "PopAnim", Source = "Value" }` with
   `PopAnim = BezierSpline { SplineColor = { Red = 225, Green = 255, Blue = 0 }, KeyFrames = { [0] = { 0 }, [6] = { 1.06 }, [9] = { 1 } } }`
   Bare values interpolate smooth. Timing is frame-locked — document it in the README (Svei trims clips to fit).
2. **Time expressions** (Tech Lower Third): smoothstep reveal tied to clip length, e.g.
   `min(1,max(0,time/RevealSpeed))^2 * (3-2*min(1,max(0,time/RevealSpeed)))` and mirrored with `(comp.RenderEnd-time)` for the out-animation. This auto-adapts to clip duration — prefer it for in/out reveals.
3. Drop shadow: use the ResolveFX node `ofx.com.blackmagicdesign.resolvefx.DropShadow` (see ESV Magnifying v2 lines ~430 for the full input block incl. required `resolvefxVersion = "2.0"`).

## Delivery / test loop (every template task)

1. Read the closest proven template. 2. Write/edit in repo `templates\Edit\...`. 3. Run `D:\repos\resolve-toolkit\deploy.ps1`. 4. Tell Svei: restart Resolve → where to find it → the 3–5 things to check (appears? controls work? both 16:9 and 9:16? animation timing?). 5. Wait for his report; fix minimally; redeploy. 6. On confirmation: update `templates/README.md` status to ✅ and commit.

## Python scripting toolkit (architecture — implement per ROADMAP.md)

Planned home: `D:\repos\resolve-toolkit\scripts\`. See `ROADMAP.md` in the repo for phases/specs. Key facts already verified:

- Studio license → external scripting OK. In Resolve: **Preferences → System → General → External scripting using = Local** must be set once.
- Connection bootstrap (no env vars needed if you append the module path):
  ```python
  import sys, os
  sys.path.append(r"C:\ProgramData\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules")
  os.environ.setdefault("RESOLVE_SCRIPT_LIB", r"C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll")
  import DaVinciResolveScript as dvr
  resolve = dvr.scriptapp("Resolve")   # None if Resolve closed or scripting disabled
  ```
  Resolve must be RUNNING. If `import` fails on Python 3.14, test with 3.12/3.13 (Blackmagic lags on new Python).
- Markers: `timeline.GetMarkers()` → `{frameOffset: {color, name, note, duration, customData}}`; offsets are relative to `timeline.GetStartFrame()`; fps from `timeline.GetSetting("timelineFrameRate")` (string, may be fractional).
- Batch apply: `timeline.SetCurrentTimecode(tc)` to move playhead, then `timeline.InsertFusionGeneratorIntoTimeline(name)` (name = .setting filename, no extension) or `InsertFusionTitleIntoTimeline` / `InsertTitleIntoTimeline`. **API limitation: Effects (drag-onto-clip) cannot be batch-applied — only Generators/Titles.** Insert behavior (track/duration) must be verified empirically — treat like a template: Svei confirms.
- Batch export: `project.LoadRenderPreset(name)`, `project.SetRenderSettings({"TargetDir":..., "CustomName":..., "MarkIn": f, "MarkOut": f})`, `project.AddRenderJob()`, `project.StartRendering()`, poll `project.IsRenderingInProgress()`. Presets list: `project.GetRenderPresetList()`.

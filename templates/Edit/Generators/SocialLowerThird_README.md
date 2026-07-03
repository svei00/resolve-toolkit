# SocialLowerThird — Lower Third Social (glass oscuro)

Generator para la página **Edit**. Aparece en **Effects Library → Generators → SocialLowerThird**.
Arrástralo a una pista del timeline como cualquier otro clip (igual que Circle1, Arrow1, etc.).

## Secuencia de animación (≈ frames 0–120)
1. **0–28**: el círculo (con logo) popea de pequeño a grande con *bounce*.
2. **12–42**: la **barra** se expande de izquierda→derecha (anclada a su borde izquierdo).
3. **12–42**: la **línea vertical |** crece de abajo→arriba.
4. **38–58**: los **textos** aparecen (fade).
5. **58–90**: *hold* (todo visible).
6. **90–108**: barra, pipe y texto se ocultan derecha→izquierda.
7. **110–120**: el círculo se encoge y desaparece (último).

> El timing está atado a números de frame. Si tu clip dura distinto, recorta/estira el clip en el timeline.

## Controles (Inspector → página "Controls")
- **Position / Scale / Rotation** — coloca todo el lower third.
- **Line 1 (CTA)** — texto superior pequeño. Default "Follow Me" (cámbialo por "Connect", "Subscribe", etc.).
- **Line 2 (Handle)** — texto inferior grande. Default "@handle".
- **Text Color** — swatch (default F1EBDF pálido dorado). Una línea controla ambas (Line 2 hereda por expresión).
- **Bar Color** + **Glass Opacity** — color de la barra + su alpha (transparencia "glass").
- **Border Color** / **Border Thickness** — borde de la barra. Thickness 0 = sin borde.
- **Accent Line Color** — color de la línea vertical (pipe).
- **Circle Color** — color del disco del círculo.

### Página "Shadow"
- Shadow Strength / Blur / Distance / Angle (sombra de la barra).

## LOGO — dropdown "Platform"
El control **Platform** cambia el logo automáticamente. Opciones (en este orden):
`Instagram, TikTok, X (Twitter), YouTube, Facebook, LinkedIn, Threads, Rumble, Custom (none)`.

Los logos están **hardcodeados** como Loaders con ruta absoluta a:
`D:\NextCloud\svei\Excel\Proyecto Excel Soluciones\Blog\imagenes\brand icons\*.png`
> Si mueves esa carpeta, los Loaders quedarán *offline* (rojo). Para reubicarlos, en Fusion
> selecciona cada `Loader_XX` y reapunta el archivo.

- **Logo Size** — escala el logo dentro del círculo (default 0.2). Como cada PNG tiene su
  resolución, usa este slider para encuadrarlo bien.
- **Logo Position** — mueve el logo dentro del disco (default = centro del círculo).
- **Custom (none)** — no muestra ningún logo (disco blanco vacío) para que pongas el tuyo:
  en Fusion añade un Loader/MediaIn y conéctalo al Foreground de `LogoM_RU` con su `Blend`
  en 1, o reemplaza el Foreground de `MergeDisc`.

> El logo escala y rebota junto con el círculo porque `CircleXF` transforma todo `MergeDisc`.

### Si actualizan el logo de una plataforma
Reemplaza el PNG en la carpeta NextCloud (mismo nombre) y listo. O en Fusion, reapunta el
`Loader_XX` correspondiente a la nueva imagen.

## Texto CTA — auto por plataforma + override (Line 1)
**Line 1 (CTA override)** funciona así:
- Si lo dejas **vacío** → el texto cambia solo según la plataforma:
  | Plataforma | CTA automático |
  |---|---|
  | YouTube / Rumble | Subscribe |
  | LinkedIn | Connect |
  | Facebook | Like &amp; Follow |
  | Instagram / TikTok / X / Threads | Follow Me |
- Si **escribes algo** en el campo → manda tu texto (override) para cualquier plataforma.

Line 2 (Handle) es siempre editable normal.

## Pipe — colores de marca automáticos por plataforma
El pipe toma el color/gradiente exacto de cada marca según el dropdown **Platform**:
| Plataforma | Color del pipe (hex) |
|---|---|
| Instagram | gradiente #feda75 → #fa7e1e → #d62976 → #962fbf → #4f5bd5 |
| TikTok | gradiente #FE2C55 (rojo) → #25F4EE (cian) |
| YouTube | #FF0000 rojo |
| Facebook | #1877F2 azul |
| LinkedIn | #0A66C2 azul |
| Rumble | #85BB47 verde |
| X (Twitter) | #FFFFFF blanco* |
| Threads | #FFFFFF blanco* |

\* La marca de X y Threads es negra, pero el negro no se ve sobre la barra oscura, así que
use blanco. Si quieres negro real, cambia `PipeX` / `PipeTH` en Fusion.

- **Pipe Position** mueve el pipe libremente; **Pipe Thickness** ajusta el grosor.
- El control **Accent Line Color** quedó como fallback (ya no se usa porque todas las
  plataformas tienen color propio); ignóralo o lo quitamos después.

## Controles de tamaño/forma añadidos
- **Circle Size** — diámetro del círculo (se mantiene redondo).
- **Bar Height** — alto de la barra (el borde sigue automáticamente).
- **Corner Radius** — redondeo de las esquinas de la barra.
- **Text Position / Text Size** — mueve y escala las dos líneas de texto juntas.
- **Logo Size / Logo Position** — el logo se recorta al círculo (no se desborda).
- La sombra del círculo sigue a la de la barra (mismos controles en la página Shadow).

## Gradientes por plataforma (manual)
La línea/pipe usa color plano por defecto. Para gradientes reales (TikTok, Instagram):
1. En Fusion, selecciona `PipeBG` → cambia **Type** de *Solid* a *Gradient*.
2. Define los stops (Instagram: amarillo→rosa→púrpura; TikTok: cian→rosa sobre negro).

## "Glass" real
Un Generator NO puede leer el video detrás, así que el efecto glass aquí = barra oscura
semi-transparente + borde claro (look moderno). El **frosted/blur real** necesita el plano de
fondo: si lo quieres, se haría como **Effect** (adjustment clip) sobre el footage, no como Generator.

## Notas técnicas
- Aspect-proof: máscaras y textos usan `comp:GetPrefs("Comp.FrameFormat.Width/Height")`.
- Barra anclada a la izquierda: `Center.X = Point(0.17 + Width/2, 0.18)` con Width vía spline.
- Pipe anclado abajo: `Center.Y = 0.115 + Height/2`.
- Círculo: `CircleXF` Transform con Pivot en la posición del círculo, Size vía spline (pop+bounce).
- Textos: visibilidad por `Blend` del Merge (spline), no por Opacity (Transform no tiene Opacity).

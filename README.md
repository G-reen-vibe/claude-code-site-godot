# Octopath Traveler-Style Shaders for Godot 4.3

A fully functional, self-contained **HD-2D** demo project: pixel-art sprites living
inside a lit 3D diorama, finished with the tilt-shift / bloom / grade stack that
defines *Octopath Traveler*'s look. No external assets or plugins — clone, open,
press **F5**.

![HD-2D](icon.svg)

## Getting started

1. Install [Godot 4.3](https://godotengine.org/download) (Forward+ renderer, the default).
2. Open `project.godot` in the editor and let it import the SVG sprites (a few seconds).
3. Run the project (**F5**). The main scene is `scenes/octopath_demo.tscn`.

### Controls

| Input | Action |
| --- | --- |
| `WASD` | Pan the camera rig |
| `Q` / `E` | Rotate the rig |
| Right mouse drag | Orbit |
| Mouse wheel | Zoom (clamped) |
| `1` | Toggle tilt-shift depth of field |
| `2` | Toggle vignette |
| `3` | Toggle color grade |
| `4` | Toggle film grain + chromatic aberration |
| `5` | Toggle the entire post-process layer |
| `R` / `F` | Move the tilt-shift focus band up / down |
| `H` | Hide/show help · `Esc` quit |

## What's inside

### Shaders (`shaders/`)

| File | Type | Effect |
| --- | --- | --- |
| `octopath_post.gdshader` | `canvas_item` | Single-pass post stack: **tilt-shift DoF** (mip-based blur around a vertical focus band), **chromatic aberration**, **color grade** (contrast/saturation + cool shadows, warm highlights), **vignette**, **film grain**. Every stage has a bool toggle and tunable uniforms. |
| `sprite_hd2d.gdshader` | `spatial` | HD-2D billboard sprite: Y-axis billboarding in the vertex stage, scene-lit with alpha-scissored shadows, silhouette-edge **rim backlight**, and luminance-keyed emission so bright texels (lantern glass) feed the bloom pass. |
| `foliage_hd2d.gdshader` | `spatial` | The sprite shader plus **vertex wind sway**, weighted by UV so canopies wave while trunks stay planted, phase-offset per tree by world position. |
| `water_hd2d.gdshader` | `spatial` | Stylized water: sine-wave vertex bobbing, two scrolling noise layers, **depth-buffer shallow→deep fade**, contact + rim **foam**, fresnel sky tint, and sparse HDR **sparkle glints** that bloom. |
| `god_rays.gdshader` | `spatial` | Additive unshaded "light shaft card" — drifting sunbeams that fade toward the ground and the card edges. |

### Scene-level effects (configured in the `.tscn`)

- **WorldEnvironment**: ACES tonemapping, screen-blended **glow/bloom**, **SSAO**,
  **volumetric fog**, procedural golden-hour sky driving sky-based ambient light.
- **DirectionalLight3D** sun with shadows; warm **flickering OmniLight** on the lantern
  (three unsynced sine waves, `scripts/lantern_flicker.gd`).
- **GPUParticles3D** floating dust motes with emissive material — tiny bloom sparks in the air.
- Pixel-art sprites are 16–32 px SVGs rendered with `filter_nearest` for crisp texels.

### Scripts (`scripts/`)

- `demo_controller.gd` — hotkey toggles that flip the post shader's bool uniforms at runtime.
- `hd2d_camera.gd` — pan/orbit/zoom rig that keeps the fixed low-angle diorama pitch.
- `lantern_flicker.gd` — organic candle flicker for any `OmniLight3D`.

## Using the shaders in your own game

- **Post stack**: add a `CanvasLayer` → full-rect `ColorRect`, set its material to a
  `ShaderMaterial` with `octopath_post.gdshader`, and set `mouse_filter` to *Ignore*.
  Draw UI on a higher `CanvasLayer` so it stays sharp.
- **Sprites**: use a `MeshInstance3D` with a `QuadMesh` (not a `Sprite3D`), assign
  `sprite_hd2d.gdshader` as the mesh material, and set `albedo_texture` to your sprite.
  Shadow casting works out of the box thanks to the alpha scissor.
- **Water**: needs a subdivided `PlaneMesh` and a seamless `NoiseTexture2D` in `wave_noise`.
  The depth-buffer effects require the Forward+ (or Mobile) renderer.
- Tilt-shift focus: `focus_center` is in screen UV — animate it from a script
  (see `_nudge_focus()` in `demo_controller.gd`) to rack focus cinematically.

## Compatibility notes

- Built for **Godot 4.3, Forward+**. Mobile renderer works with reduced glow quality;
  the Compatibility renderer lacks volumetric fog and SSAO (everything else runs).
- All textures are generated (SVG + `NoiseTexture2D`), so the repo stays a few KB.

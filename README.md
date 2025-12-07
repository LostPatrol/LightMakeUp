# LightMakeUp
A Simple Minecraft shader (Java).

## Disclaimer
This is an educational and non-commercial project developed solely for academic purposes, not a publicly distributed shader.

This project is created EXCLUSIVELY as a final assignment for the "Virtual Reality Technology" course. It serves as a demonstration of OpenGL/GLSL shader programming skills and an academic exploration of real-time rendering techniques as well as learning material for computer graphics education.

## Usage
1. Install [Minecraft](https://minecraft.net) and [Optifine](https://optifine.net).
2. Download the shader pack (as a zip file or a folder) and place it in the `shaderpacks` folder of your Minecraft installation.
3. Launch Minecraft (via HMCL, for example) and select the shader pack from the ESC-Video options.

## Tested on
* Minecraft 1.21.4 (Java Edition)
* Nvidia RTX
* Windows 11
* Optifine 1.21.4 J3

## Credit

- Enhanced ambient occlusion is based on Capt Tatsu's ambient occlusion used in
  BSL Shaders:
  https://bitslablab.com/bslshaders/

- Shadow bias technique from Emin implementation, based on a concept
  reimagined by gri573:
  https://www.complementary.dev/

- Interleaved noise from:
  "NEXT GENERATION POST PROCESSING IN CALL OF DUTY: ADVANCED WARFARE"
  http://advances.realtimerendering.com/s2014/index.html

- Water texture and some basic libs is from:
  https://github.com/javiergcim/MakeUpUltraFast

- TAA is based on Erkaman's TAA simple implementation:
  https://gist.github.com/Erkaman

- Phi noise by delu:
  https://www.shadertoy.com/view/Nst3R7
  Based on TinyTexel:
  https://www.shadertoy.com/view/wltSDn
  Based on:
  http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/

- R dither based on:
  http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/

- Dither 13 and Dther 17 by atyuwen:
  https://www.shadertoy.com/view/wl3cWX
  Based on:
  https://developer.oculus.com/blog/tech-note-shader-snippets-for-efficient-2d-dithering/
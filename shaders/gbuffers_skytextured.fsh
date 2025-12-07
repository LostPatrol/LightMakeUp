#version 120
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_SKYTEXTURED
#define NO_SHADOWS

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform sampler2D tex;


/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;  // Flat

// MAIN FUNCTION ------------------

void main() {
    // Extract the color from the solid color block
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
    
    block_color.rgb *= sky_luma_correction;

    #include "/src/writebuffers.glsl"
}

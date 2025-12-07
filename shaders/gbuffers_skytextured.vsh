#version 120
/* MakeUp - gbuffers_skytextured.vsh
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

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;

#include "/src/taa_offset.glsl"

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    tint_color = gl_Color;

    sky_luma_correction = luma(day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR));

    #if defined UNKNOWN_DIM
        sky_luma_correction = 1.0;
    #else
        sky_luma_correction = 3.5 / ((sky_luma_correction * -2.5) + 3.5);
    #endif

    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    gl_Position.xy += taa_offset * gl_Position.w;
}

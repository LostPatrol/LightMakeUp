#version 120
/* MakeUp - gbuffers_basic.vsh
Render: Basic elements - lines
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_BASIC
#define NO_SHADOWS
#define SHADER_LINE

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 gbufferModelViewInverse;
#endif

/* Ins / Outs */

varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;

/* Utility functions */

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#include "/src/taa_offset.glsl"

// MAIN FUNCTION ------------------

void main() {
    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"
    tint_color = gl_Color;

    basic_light = day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    basic_light = mix(basic_light, ZENITH_SKY_RAIN_COLOR * luma(basic_light), rainStrength);

    vec2 illumination = clamp(abs(lmcoord), 0.0, 1.0);  // Fix lines without correct illumination data
    illumination.y = (max(illumination.y, 0.065) - 0.065) * 1.06951871657754;

    vec3 candle_color =
        CANDLE_BASELIGHT * ((illumination.x * illumination.x) + pow(illumination.x * 1.165, 6.0));

    basic_light += candle_color;
}

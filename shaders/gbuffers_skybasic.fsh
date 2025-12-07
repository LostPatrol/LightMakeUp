#version 120
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_SKYBASIC
#define NO_SHADOWS

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform sampler2D gaux4;
uniform float pixel_size_x;
uniform float pixel_size_y;

/* Ins / Outs */

varying vec4 star_data;

/* Utility functions */

// MAIN FUNCTION ------------------

void main() {
    // Extract the color from the solid color block
    vec4 background_color = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0);

    vec4 block_color = star_data;

    block_color = mix(background_color, block_color, block_color);

    block_color.rgba = vec4(texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb, clamp(star_data.a * 2.0, 0.0, 1.0));

    #include "/src/writebuffers.glsl"
}

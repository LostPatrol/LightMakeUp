#version 120
/* MakeUp - prepare.fsh
Render: Sky
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif

#define PREPARE_SHADER
#define NO_SHADOWS
#define SET_FOG_COLOR

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float rainStrength;

/* Ins / Outs */

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

/* Utility functions */

#include "/lib/dither.glsl"

// MAIN FUNCTION ------------------

void main() {
        float dither = shifted_r_dither(gl_FragCoord.xy);

        dither = (dither - .5) * 0.0625;

        vec4 fragpos =
            gbufferProjectionInverse *
            (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
        vec3 nfragpos = normalize(fragpos.xyz);
        float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
        vec3 block_color =
            mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(n_u, 0.333)));

        block_color = xyz_to_rgb(block_color);
    
    #include "/src/writebuffers.glsl"
}

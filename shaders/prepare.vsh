#version 120
/* MakeUp - prepare.vsh
Render: Sky
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif

#define PREPARE_SHADER
#define NO_SHADOWS

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform mat4 gbufferModelView;
uniform float rainStrength;

/* Ins / Outs */

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"

    up_vec = normalize(gbufferModelView[1].xyz);
}

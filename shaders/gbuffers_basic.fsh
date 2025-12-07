#version 120
/* MakeUp - gbuffers_basic.fsh
Render: Basic elements - lines
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_BASIC
#define NO_SHADOWS

#include "/lib/config.glsl"

/* Uniforms, ins, outs */
varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;

// MAIN FUNCTION ------------------

void main() {
    vec4 block_color = tint_color;
    block_color.rgb *= basic_light;

    #include "/src/writebuffers.glsl"
}

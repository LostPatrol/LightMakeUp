#version 120
/* MakeUp - gbuffers_skybasic.vsh
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

/* Uniforms */

uniform mat4 gbufferModelView;

/* Ins / Outs */

varying vec4 star_data;

/* Utility functions */

#include "/src/taa_offset.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    gl_Position.xy += taa_offset * gl_Position.w;

    // star_data = vec4(
    //     float(gl_Color.r == gl_Color.g &&
    //     gl_Color.g == gl_Color.b &&
    //     gl_Color.r > 0.0) * gl_Color.r
    // );

    star_data = vec4(0.0);
}

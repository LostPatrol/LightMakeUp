#version 120
/* MakeUp - final.fsh
Render: Final renderer
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define FINAL_SHADER

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform sampler2D gaux3;

/* Ins / Outs */

varying vec2 texcoord;
varying float exposure;

#include "/lib/luma.glsl"

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;

    exposure = texture2D(gaux3, vec2(0.5)).r;
}

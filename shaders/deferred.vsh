#version 120
/* MakeUp - deferred.vsh
Render: Ambient occlusion, volumetric clouds
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define DEFERRED_SHADER

#include "/lib/config.glsl"

/* Color utils */

 #include "/lib/color_utils.glsl"

/* Uniforms */

uniform mat4 gbufferModelView;

#if (!defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    uniform float rainStrength;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 up_vec;

#if (!defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

varying float fog_density_coeff;

/* Utility functions */

#if (!defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/luma.glsl"
#endif

    // MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;
    up_vec = normalize(gbufferModelView[1].xyz);


    fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
}

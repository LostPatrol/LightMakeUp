#version 120
/* MakeUp - deferred.fsh
Render: Ambient occlusion, volumetric clouds
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define DEFERRED_SHADER
#define NO_SHADOWS

#include "/lib/config.glsl"

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform sampler2D colortex1;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D gaux3;
uniform int frameCounter;

uniform sampler2D gaux2;
uniform float inv_aspect_ratio;
uniform float fov_y_inv;

#if !defined UNKNOWN_DIM
    uniform sampler2D noisetex;
    uniform vec3 cameraPosition;
    uniform vec3 sunPosition;
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;

uniform mat4 gbufferProjection;
uniform float frameTimeCounter;
uniform sampler2D colortex2;

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 up_vec;  // Flat

#if (!defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

varying float fog_density_coeff;

/* Utility functions */ 

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"


#include "/lib/dither.glsl"
#include "/lib/ao.glsl"

#if (!defined UNKNOWN_DIM)
    #include "/lib/projection_utils.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);
    float d = texture2DLod(depthtex0, texcoord, 0).r;
    float linear_d = ld(d);

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    vec3 view_vector = vec3(1.0);

    float dither = shifted_dither_makeup(gl_FragCoord.xy);

    #if (!defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        if(linear_d > 0.9999) {  // Only sky
            vec4 world_pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
            view_vector = normalize(world_pos.xyz);


            float bright = dot(view_vector, normalize((gbufferModelViewInverse * vec4(sunPosition, 0.0)).xyz));
            bright = clamp(bright * bright * bright, 0.0, 1.0);

            block_color.rgb = get_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG, umbral, cloud_color, dark_cloud_color);
        }

    #else
        if(linear_d > 0.9999 && isEyeInWater == 1) {  // Only sky and water
            vec4 screen_pos = vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0);
            vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

            vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
            view_vector = normalize(world_pos.xyz);
        }
    #endif

    // AO distance attenuation
    float ao_att =
        pow(clamp(linear_d * 1.6, 0.0, 1.0), mix(fog_density_coeff, 1.0, rainStrength));

    float final_ao = mix(dbao(dither), 1.0, ao_att);
    block_color.rgb *= final_ao;

    #define NIGHT_CORRECTION day_blend_float(1.0, 1.0, 0.1)

    // Underwater sky
    if(isEyeInWater == 1) {
        if(linear_d > 0.9999) {
            block_color.rgb = mix(NIGHT_CORRECTION * WATER_COLOR * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667), block_color.rgb, max(clamp(view_vector.y - 0.1, 0.0, 1.0), rainStrength));
        }
    }

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:14 */
    gl_FragData[0] = vec4(block_color.rgb, d);
    gl_FragData[1] = block_color;
}
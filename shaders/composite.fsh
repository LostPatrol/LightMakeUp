#version 120
/* MakeUp - composite.fsh
Render: Bloom and volumetric light
*/

#define USE_BASIC_SH // Sets the use of a "basic" or "generic" shader for custom dimensions, instead of the default overworld shader. This can solve some rendering issues as the shader is closer to vanilla rendering.

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define COMPOSITE_SHADER


#include "/lib/config.glsl"
const bool colortex1MipmapEnabled = true;

/* Color utils */


#include "/lib/color_utils.glsl"


/* Uniforms */

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D depthtex0;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;

uniform float darknessFactor;

uniform sampler2D depthtex1;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float light_mix;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform float vol_mixer;


/* Ins / Outs */

varying vec2 texcoord;
varying vec3 direct_light_color;
varying float exposure;

varying vec3 vol_light_color;
varying vec2 lightpos;
varying vec3 astro_pos;

varying mat4 modeli_times_projectioni;


/* Utility functions */

#include "/lib/basic_utils.glsl"
#include "/lib/depth.glsl"

#ifdef BLOOM
    #include "/lib/luma.glsl"
#endif

#include "/lib/dither.glsl"
#include "/lib/volumetric_light.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);
    float d = texture2DLod(depthtex0, texcoord, 0).r;
    float linear_d = ld(d);

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    // Depth to distance
    float screen_distance = linear_d * far * 0.5;

    // Underwater fog
    if(isEyeInWater == 1) {
        float water_absorption = clamp(-pow((-linear_d + 1.0), (4.0 + (WATER_ABSORPTION * 4.0))) + 1.0, 0.0, 1.0);
        
        block_color.rgb =
            mix(block_color.rgb, WATER_COLOR * direct_light_color * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667), water_absorption);

    } else if(isEyeInWater == 2) {
        block_color = mix(block_color, vec4(1.0, .1, 0.0, 1.0), clamp(sqrt(linear_d * far * 0.125), 0.0, 1.0));
    }
    
    if((blindness > .01 || darknessFactor > .01) && linear_d > 0.999) {
        block_color.rgb = vec3(0.0);
    }

    float dither = shifted_dither17(gl_FragCoord.xy);

    float vol_light = ss_godrays(dither);

    vec4 center_world_pos = modeli_times_projectioni * (vec4(0.5, 0.5, 1.0, 1.0) * 2.0 - 1.0);
    vec3 center_view_vector = normalize(center_world_pos.xyz);

    vec4 world_pos = modeli_times_projectioni * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
    vec3 view_vector = normalize(world_pos.xyz);

    // Light source position for depth based godrays intensity calculation
    vec3 intermediate_vector =
        normalize((gbufferModelViewInverse * vec4(astro_pos, 0.0)).xyz);
    float vol_intensity =
        clamp(dot(center_view_vector, intermediate_vector), 0.0, 1.0);
    vol_intensity *= dot(view_vector, intermediate_vector);
    vol_intensity =
        pow(clamp(vol_intensity, 0.0, 1.0), vol_mixer) * 0.5 * abs(light_mix * 2.0 - 1.0);

    block_color.rgb =
        mix(block_color.rgb, vol_light_color * vol_light, vol_intensity * (vol_light * 0.5 + 0.5) * (1.0 - rainStrength));


    // Inside the snow
    #ifdef BLOOM
        if(isEyeInWater == 3) {
            block_color.rgb =
                mix(block_color.rgb, vec3(0.7, 0.8, 1.0) / exposure, clamp(screen_distance, 0.0, 1.0));
        }
    #else
        if(isEyeInWater == 3) {
            block_color.rgb =
                mix(block_color.rgb, vec3(0.85, 0.9, 0.6), clamp(screen_distance, 0.0, 1.0));
        }
    #endif

    #ifdef BLOOM
        // Bloom source
        float bloom_luma = smoothstep(0.85, 1.0, luma(block_color.rgb * exposure)) * 0.5;

        block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));     
        /* DRAWBUFFERS:146 */
        gl_FragData[0] = block_color;
        gl_FragData[1] = block_color * bloom_luma;
        gl_FragData[2] = vec4(exposure, 0.0, 0.0, 0.0);
    #else
        block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
        /* DRAWBUFFERS:16 */
        gl_FragData[0] = block_color;
        gl_FragData[1] = vec4(exposure, 0.0, 0.0, 0.0);
    #endif
}
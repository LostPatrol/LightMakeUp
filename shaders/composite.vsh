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

/* Color utils */

#include "/lib/color_utils.glsl"

/* Uniforms */

uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;


uniform int isEyeInWater;
uniform float light_mix;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform sampler2D colortex1;
uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTime;

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 direct_light_color;

varying vec3 vol_light_color;  // Flat
varying float exposure;  // Flat
varying vec2 lightpos;  // Flat
varying vec3 astro_pos;  // Flat
varying mat4 modeli_times_projectioni;


/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    direct_light_color = day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    direct_light_color = mix(direct_light_color, ZENITH_SKY_RAIN_COLOR * luma(direct_light_color), rainStrength);

    // Exposure
    float mipmap_level = log2(min(viewWidth, viewHeight)) - 1.0;

    vec3 exposure_col = texture2DLod(colortex1, vec2(0.5), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.25), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.75), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.25, 0.75), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.75, 0.25), mipmap_level).rgb;

    exposure = clamp(luma(exposure_col), 0.0005, 100.0);

    float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

    exposure = (exp(-exposure) * 3.03) + 0.6;
    exposure = mix(exposure, prev_exposure, exp(-frameTime * 1.25));

    float vol_attenuation;
    if(isEyeInWater == 0) {
        vol_attenuation = 1.0;
    } else {
        vol_attenuation = 0.1 + (eye_bright_smooth.y * 0.002);
    }

    vol_light_color = day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR) * 1.2 * vol_attenuation;

    astro_pos = sunPosition * step(0.5, light_mix) * 2.0 + moonPosition;
    vec4 tpos = vec4(astro_pos, 1.0) * gbufferProjection;
    tpos = vec4(tpos.xyz / tpos.w, 1.0);
    vec2 pos1 = tpos.xy / tpos.z;
    lightpos = pos1 * 0.5 + 0.5;

    modeli_times_projectioni = gbufferModelViewInverse * gbufferProjectionInverse;
}

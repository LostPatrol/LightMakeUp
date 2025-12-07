/* MakeUp - volumetric_lights.glsl
Volumetric light - MakeUp implementation
*/

float ss_godrays(float dither) {
    float light = 0.0;
    float comp = 1.0 - (near / (far * far));

    vec2 ray_step = vec2(lightpos - texcoord) * 0.2;
    vec2 dither2d = texcoord + (ray_step * dither);

    float depth;

    for (int i = 0; i < CHEAP_GODRAY_SAMPLES; i++) {
        depth = texture2D(depthtex1, dither2d).x;
        dither2d += ray_step;
        light += step(comp, depth);
    }

    return light / CHEAP_GODRAY_SAMPLES;
}

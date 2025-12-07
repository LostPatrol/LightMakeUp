// Fog intensity calculation
float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;

float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);

frog_adjust = pow(
    clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
    mix(fog_density_coeff, 1.0, rainStrength)
);

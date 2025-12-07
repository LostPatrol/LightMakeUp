/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.
*/

vec4 convex_hull(
    vec3 c, vec3 previous, vec3 up, vec3 down, vec3 left, vec3 right, 
    vec3 ul, vec3 ur, vec3 dl, vec3 dr) {

    // Variance calculation
    vec3 sum = c + up + down + left + right + ul + ur + dl + dr;
    vec3 sum_sq =
        c*c +
        up*up +
        down*down +
        left*left +
        right*right +
        ul*ul +
        ur*ur +
        dl*dl +
        dr*dr;

    vec3 mean = sum * 0.1111111111111111; // 1 / 9
    vec3 variance = abs(sum_sq * 0.1111111111111111 - mean * mean); // Variance = E[x^2] - E[x]^2

    // 2. Define the clamping range
    vec3 std_dev = sqrt(variance);
    vec3 min_valid = mean - std_dev;
    vec3 max_valid = mean + std_dev;

    // 3. Apply clamping
    return vec4(clamp(previous, min_valid, max_valid), distance(min_valid, max_valid));
}



vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Previous color
        vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;

        vec3 left = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0).rgb;
        vec3 right = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0).rgb;
        vec3 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0).rgb;
        vec3 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0).rgb;
        vec3 ul = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y), 0.0).rgb;
        vec3 ur = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y), 0.0).rgb;
        vec3 dl = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y), 0.0).rgb;
        vec3 dr = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y), 0.0).rgb;

        vec3 c_max = max(max(max(left, right), down),max(up, max(ul, max(ur, max(dl, max(dr, current_color))))));
	    vec3 c_min = min(min(min(left, right), down),min(up, min(ul, min(ur, min(dl, min(dr, current_color))))));

        // Clip 3
        vec4 previous_cliped = convex_hull(
            current_color,
            previous,
            up,
            down,
            left,
            right,
            ul,
            ur,
            dl,
            dr
        );

        float ponderation = clamp((distance(c_max, c_min) - previous_cliped.a) / previous_cliped.a, 0.0, 1.0);
        return mix(current_color, previous_cliped.rgb, 0.99 - (smoothstep(0.0, 1.0, ponderation) * 0.44));
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Muestra del pasado
        vec4 previous = texture2DLod(colortex3, texcoord_past, 0.0);

        vec4 left = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0);
        vec4 right = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0);
        vec4 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0);
        vec4 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0);
        vec4 ul = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y), 0.0);
        vec4 ur = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y), 0.0);
        vec4 dl = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y), 0.0);
        vec4 dr = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y), 0.0);

        vec3 c_max = max(max(max(left.rgb, right.rgb), down.rgb),max(up.rgb, max(ul.rgb, max(ur.rgb, max(dl.rgb, max(dr.rgb, current_color.rgb))))));
	    vec3 c_min = min(min(min(left.rgb, right.rgb), down.rgb),min(up.rgb, min(ul.rgb, min(ur.rgb, min(dl.rgb, min(dr.rgb, current_color.rgb))))));

        // Clip 3
        vec4 previous_cliped = convex_hull(
            current_color.rgb,
            previous.rgb,
            up.rgb,
            down.rgb,
            left.rgb,
            right.rgb,
            ul.rgb,
            ur.rgb,
            dl.rgb,
            dr.rgb
        );

        float ponderation = clamp((distance(c_max, c_min) - previous_cliped.a) / previous_cliped.a, 0.0, 1.0);
        return mix(current_color, vec4(previous_cliped.rgb, previous.a), 0.99 - (smoothstep(0.0, 1.0, ponderation) * 0.39));
    }
}

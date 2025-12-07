/* MakeUp - tone_maps.glsl
Tonemap functions.
*/

vec3 custom_sigmoid(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

    return pow(color, vec3(1.15));
}
/* MakeUp - depth_dh.glsl
Depth utilities.
*/

float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

shader_type canvas_item;

uniform float angle : hint_range(0.0, 6.283) = 0.0; // radianes

void fragment() {
    vec2 center = vec2(0.5);
    vec2 pos = UV - center;
    float r = length(pos);
    float a = atan(pos.y, pos.x);

    // Gira la coordenada
    a -= angle;

    // Solo muestra una parte del círculo
    if (a < -3.141592) a += 6.283184;
    float mask = step(0.0, a);

    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color * mask;
}

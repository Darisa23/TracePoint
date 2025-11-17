shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.05; // Intensidad del glitch (0.0 a 1.0)
uniform float glitch_speed : hint_range(0.0, 10.0) = 2.0;    // Velocidad de cambio del glitch
uniform float glitch_offset : hint_range(0.0, 0.1) = 0.005; // Desplazamiento de líneas (pixelizado)

void fragment() {
    vec2 uv = UV;
    vec4 color = texture(TEXTURE, uv);

    // Efecto de barrido horizontal aleatorio (shifting)
    float shift_x = sin(TIME * glitch_speed + uv.y * 10.0) * glitch_intensity * 0.1;
    uv.x += shift_x * (sin(TIME * 5.0) * 0.5 + 0.5); // Hace que el shift sea más dinámico

    // Efecto de fragmentación de líneas (scanline glitch)
    float y_noise = fract(sin(uv.y * 1234.5 + TIME * glitch_speed * 1.5) * 4567.8);
    y_noise = step(0.95, y_noise) * glitch_intensity * 2.0; // Solo afecta a algunas líneas

    // Desplazamiento vertical aleatorio en líneas específicas
    uv.x += sin(TIME * glitch_speed * 3.0 + uv.y * 50.0) * glitch_offset * y_noise;
    uv.y += cos(TIME * glitch_speed * 2.5 + uv.x * 30.0) * glitch_offset * y_noise;

    // Efecto de color desfasado (chromatic aberration)
    vec4 col_r = texture(TEXTURE, uv + vec2(glitch_offset * glitch_intensity * 0.5, 0.0));
    vec4 col_g = texture(TEXTURE, uv); // Verde se mantiene en el centro
    vec4 col_b = texture(TEXTURE, uv - vec2(glitch_offset * glitch_intensity * 0.5, 0.0));

    // Mezcla los canales con el glitch
    color.r = col_r.r;
    color.g = col_g.g;
    color.b = col_b.b;

    // Aplicar el color base y la transparencia
    COLOR = color * COLOR;
}
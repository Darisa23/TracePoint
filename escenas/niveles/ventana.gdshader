shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float scan_line_speed : hint_range(0.0, 10.0) = 2.0;
uniform vec3 glitch_color : source_color = vec3(0.0, 0.5, 1.0); // Azul cibernético
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.02;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.3;

// Función para generar ruido
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Función para bloques de glitch
float glitch_block(vec2 uv, float time) {
    float block = floor(uv.y * 10.0 + time * 5.0);
    return random(vec2(block, floor(time * 2.0)));
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;
    
    // Efecto de desplazamiento horizontal (glitch)
    float glitch = glitch_block(uv, time);
    if (glitch > 0.7 && glitch_intensity > 0.5) {
        uv.x += (random(vec2(time, uv.y)) - 0.5) * 0.1 * glitch_intensity;
    }
    
    // Aberración cromática (separación RGB)
    vec4 color_r = texture(TEXTURE, uv + vec2(chromatic_aberration * glitch_intensity, 0.0));
    vec4 color_g = texture(TEXTURE, uv);
    vec4 color_b = texture(TEXTURE, uv - vec2(chromatic_aberration * glitch_intensity, 0.0));
    
    vec4 final_color = vec4(color_r.r, color_g.g, color_b.b, color_g.a);
    
    // Líneas de escaneo
    float scan_line = sin(uv.y * 300.0 + time * scan_line_speed) * 0.05;
    final_color.rgb += scan_line;
    
    // Overlay de color azul glitch
    float blue_glitch = step(0.85, glitch) * glitch_intensity;
    final_color.rgb = mix(final_color.rgb, glitch_color, blue_glitch * 0.7);
    
    // Ruido digital
    float noise = random(uv + time) * noise_amount;
    final_color.rgb += (noise - 0.5) * glitch_intensity * 0.2;
    
    // Parpadeo de bloques
    float block_flicker = step(0.95, random(vec2(floor(uv.x * 5.0), floor(uv.y * 5.0) + floor(time * 3.0))));
    final_color.rgb += glitch_color * block_flicker * glitch_intensity * 0.5;
    
    // Distorsión vertical ocasional
    if (random(vec2(time * 0.5, 0.0)) > 0.95) {
        uv.y += sin(uv.x * 50.0 + time * 10.0) * 0.02 * glitch_intensity;
        final_color = texture(TEXTURE, uv);
    }
    
    COLOR = final_color;
}